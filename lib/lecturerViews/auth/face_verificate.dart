// A screen that allows users to take a picture using a given camera.
import 'dart:async';
import 'package:camera/camera.dart';
import 'package:fugusface/HandleNetworking.dart';
import 'package:fugusface/lecturerViews/auth/widgets/FacePainter.dart';
import 'package:fugusface/lecturerViews/coursesList.dart';
import 'package:fugusface/lecturerViews/services/facenet.service.dart';
import 'package:fugusface/services/camera.service.dart';
import 'package:fugusface/services/ml_kit_service.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:flutter/material.dart';

class FaceVerification extends StatefulWidget {
  final Map<String, List> studentData;
  final String sessioncode;
  final String cid;

  const FaceVerification(
      {Key key,
      @required this.studentData,
      this.sessioncode,
      @required this.cid})
      : super(key: key);

  @override
  FaceVerificationState createState() => FaceVerificationState();
}

class FaceVerificationState extends State<FaceVerification> {
  CameraDescription cameraDescription;
  CameraService _cameraService = CameraService();
  MLKitService _mlKitService = MLKitService();
  FaceNetService _faceNetService = FaceNetService();
  CameraLensDirection _direction = CameraLensDirection.front;
  final HandleNetworking handleNetworking = HandleNetworking();

  Future _initializeControllerFuture;
  bool cameraInitializated = false;
  bool _detectingFaces = false;
  bool loading = true;

  String imagePath;
  Size imageSize;
  Map<String, Face> facesDetected;

  @override
  void initState() {
    super.initState();
    _faceNetService.studentData = widget.studentData;
    // initialize sevices, starts the camera & start framing faces
    WidgetsBinding.instance.addPostFrameCallback((_)=> _start());
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _cameraService.dispose();
    super.dispose();
  }

  Future<CameraDescription> getCamera(CameraLensDirection dir) async {
    return await availableCameras().then(
      (List<CameraDescription> cameras) => cameras.firstWhere(
        (CameraDescription camera) => camera.lensDirection == dir,
      ),
    );
  }

  void _toggleCameraDirection() async {
    setState(() {
      loading = true;
    });
    if (_direction == CameraLensDirection.back) {
      _direction = CameraLensDirection.front;
    } else {
      _direction = CameraLensDirection.back;
    }

    // await Future.delayed(Duration(milliseconds: 500));
    await _cameraService.cameraController.stopImageStream();
    await _cameraService.cameraController.dispose();
    // await Future.delayed(Duration(milliseconds: 300));
    setState(() {
      _initializeControllerFuture = null;
    });
    await _start();
  }

  /// starts the camera & start framing faces
  _start() async {
    cameraDescription = await getCamera(_direction);
    // start the services
    await _faceNetService.loadModel();
    _mlKitService.initialize();

    _initializeControllerFuture =
        _cameraService.startService(cameraDescription);
    await Future.delayed(Duration(milliseconds: 300));
    await _initializeControllerFuture;
    _frameFaces();
    setState(() {
      cameraInitializated = true;
      loading = false;
    });
  }

  /// draws rectangles when detects faces
  _frameFaces() {
    imageSize = _cameraService.getImageSize();

    _cameraService.cameraController.startImageStream((image) async {
      if (_cameraService.cameraController != null) {
        // if its currently busy, avoids overprocessing

        if (_detectingFaces) return;
        _detectingFaces = true;
        try {
          List<Face> faces = await _mlKitService.getFacesFromImage(image);

          if (faces.length > 0) {
            _faceNetService.setCurrentPrediction(image, faces);
            if (_faceNetService.predictedData != null)
              facesDetected = _faceNetService.predictedData;
            setState(() {});
          } else {
            setState(() {
              facesDetected = null;
            });
          }

          _detectingFaces = false;
        } catch (e) {
          _detectingFaces = false;
        }
      }
    });
  }

  /// handles the button pressed event
  Future<void> _submit() async {
    if (_faceNetService.scanned == null ||
        _faceNetService.scanned.length <= 0) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text('No face detected!'),
          );
        },
      );
      _start();
      Navigator.pop(context);
    } else {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Submit Attendance'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('Are you sure you want to submit?'),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text("Yes"),
                onPressed: () async {
                  String attended = await handleNetworking
                      .attend(widget.cid, widget.sessioncode,
                          _faceNetService.scanned)
                      .onError((error, stackTrace) => null);
                  if (attended != null) {
                    if (attended == "Records submitted successfully.") {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(attended),
                      ));
                      await Future.delayed(Duration(milliseconds: 100));
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CoursesList(),
                          ),
                          (route) => false);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(attended),
                      ));
                      Navigator.pop(context);
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Connection failed."),
                    ));
                    Navigator.pop(context);
                  }
                },
              ),
              TextButton(
                child: Text("No"),
                onPressed: () {
                  // _start();
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () async {
        await Future.delayed(Duration(milliseconds: 500));
        // });
        return showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Warning!'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('Are you sure you want to exit?'),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text("Yes"),
                onPressed: () async {
                  _faceNetService.scanner();
                  Navigator.of(context).pop(true);
                  // dispose();
                },
              ),
              TextButton(
                child: Text("No"),
                onPressed: () {
                  // _start();
                  Navigator.of(context).pop(false);
                },
              )
            ],
          ),
        );
      },
      child: Scaffold(
        body: Stack(
          children: [
            FutureBuilder<void>(
                future: _initializeControllerFuture != null
                    ? _initializeControllerFuture
                    : null,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return Transform.scale(
                      scale: 1.0,
                      child: AspectRatio(
                        aspectRatio: MediaQuery.of(context).size.aspectRatio,
                        child: OverflowBox(
                          alignment: Alignment.center,
                          child: FittedBox(
                            fit: BoxFit.fitHeight,
                            child: Container(
                              width: width,
                              height: width *
                                  _cameraService
                                      .cameraController.value.aspectRatio,
                              child: Stack(
                                fit: StackFit.expand,
                                children: <Widget>[
                                  CameraPreview(
                                      _cameraService.cameraController),
                                  CustomPaint(
                                    painter: FacePainter(
                                        imageSize: imageSize,
                                        results: facesDetected,
                                        scanned: _faceNetService.scanned),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  } else {
                    return Center(
                        child: CircularProgressIndicator(color: Colors.teal));
                  }
                }),
          ],
        ),
        floatingActionButton:
            Column(mainAxisAlignment: MainAxisAlignment.end, children: [
          FloatingActionButton(
            backgroundColor: Colors.teal,
            child: Icon(
              Icons.send_outlined,
            ),
            onPressed: () {
              _submit();
            },
            heroTag: null,
          ),
          SizedBox(
            height: 10,
          ),
          FloatingActionButton(
            backgroundColor: Colors.teal,
            onPressed: _toggleCameraDirection,
            heroTag: null,
            child: _direction == CameraLensDirection.back
                ? const Icon(Icons.camera_front)
                : const Icon(Icons.camera_rear),
          ),
        ]),
      ),
    );
  }
}
