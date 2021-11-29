import 'dart:async';
import 'package:camera/camera.dart';
import 'package:fugusface/components/ReusableButton.dart';
import 'package:fugusface/services/camera.service.dart';
import 'package:fugusface/services/ml_kit_service.dart';
import 'package:fugusface/studentViews/auth/widgets/FacePainter.dart';
import 'package:fugusface/studentViews/auth/widgets/camera_header.dart';
import 'package:fugusface/studentViews/services/facenet.service.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:flutter/material.dart';

import '../StudentRegisterScreen.dart';

class FaceCapture extends StatefulWidget {
  final CameraDescription cameraDescription;

  const FaceCapture({Key key, @required this.cameraDescription})
      : super(key: key);

  @override
  _FaceCaptureState createState() => _FaceCaptureState();
}

class _FaceCaptureState extends State<FaceCapture> {
  // String imagePath;
  Face faceDetected;
  Size imageSize;

  bool _detectingFaces = false;

  Future _initializeControllerFuture;
  bool cameraInitializated = false;

  // switchs when the user press the camera
  bool _saving = false;
  // bool _bottomSheetVisible = false;

  // service injection
  MLKitService _mlKitService = MLKitService();
  CameraService _cameraService = CameraService();
  FaceNetService _faceNetService = FaceNetService();

  @override
  void initState() {
    super.initState();

    /// starts the camera & start framing faces
    WidgetsBinding.instance.addPostFrameCallback((_)=> _start());
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _cameraService.dispose();
    super.dispose();
  }

  /// starts the camera & start framing faces
  _start() async {
    _initializeControllerFuture =
        _cameraService.startService(widget.cameraDescription);
    await _initializeControllerFuture;

    setState(() {
      cameraInitializated = true;
    });

    _frameFaces();
  }

  /// handles the button pressed event
  Future<void> onShot() async {
    if (faceDetected == null) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text('No face detected!'),
          );
        },
      );
    } else {
      _saving = true;
      await Future.delayed(Duration(milliseconds: 500));
      // await _cameraService.cameraController.stopImageStream();
      // await Future.delayed(Duration(milliseconds: 200));
      List predictedData = _faceNetService.predictedData;

      /// resets the face stored in the face net sevice
      this._faceNetService.setPredictedData(null);
      if (predictedData.length != 0) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) =>
                    StudentRegisterScreen(features: predictedData)));
      } else {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text('No face detected!'),
            );
          },
        );
      }
    }
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
            setState(() {
              faceDetected = faces[0];
            });

            if (_saving) {
              _faceNetService.setCurrentPrediction(image, faceDetected);
              setState(() {
                _saving = false;
              });
            }
          } else {
            setState(() {
              faceDetected = null;
            });
          }

          _detectingFaces = false;
        } catch (e) {
          print(e);
          _detectingFaces = false;
        }
      }
    });
  }

  _onBackPressed() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Stack(
        children: [
          FutureBuilder<void>(
            future: _initializeControllerFuture,
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
                              _cameraService.cameraController.value.aspectRatio,
                          child: Stack(
                            fit: StackFit.expand,
                            children: <Widget>[
                              CameraPreview(_cameraService.cameraController),
                              CustomPaint(
                                painter: FacePainter(
                                    face: faceDetected, imageSize: imageSize),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              } else {
                return Center(child: CircularProgressIndicator());
              }
            },
          ),
          CameraHeader(
            "",
            onBackPressed: _onBackPressed,
          )
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: InkWell(
        onTap: () async {
          onShot();
        },
        child: ReusableButton("CAPTURE"),
      ),
    );
  }
}
