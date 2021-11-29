import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:fugusface/components/ReusableButton.dart';
import 'package:fugusface/services/ml_kit_service.dart';
import 'package:fugusface/studentViews/auth/face_capture.dart';
import 'package:fugusface/studentViews/services/facenet.service.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class AuthHome extends StatefulWidget {
  static const routeName = '/auth_home';
  AuthHome({Key key}) : super(key: key);
  @override
  _AuthHomeState createState() => _AuthHomeState();
}

class _AuthHomeState extends State<AuthHome> {
  // Services injection
  FaceNetService _faceNetService = FaceNetService();
  MLKitService _mlKitService = MLKitService();
  // DataBaseService _dataBaseService = DataBaseService();

  CameraDescription cameraDescription;
  bool loading = false;

  /// 1 Obtain a list of the available cameras on the device.
  /// 2 loads the face net model
  _startUp() async {
    
    _setLoading(true);

    List<CameraDescription> cameras = await availableCameras();

    /// takes the front camera
    cameraDescription = cameras.firstWhere(
      (CameraDescription camera) =>
          camera.lensDirection == CameraLensDirection.front,
    );

    // start the services
    await _faceNetService.loadModel();
    _mlKitService.initialize();

    _setLoading(false);
  }

  // shows or hides the circular progress indicator
  _setLoading(bool value) {
    setState(() {
      loading = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: loading,
      child: Scaffold(
        // backgroundColor: Color(0XFFC7FFBE),
        appBar: AppBar(
          leading: Container(),
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Image(image: AssetImage('assets/logo.png')),
                Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Column(
                    children: [
                      Text(
                        "FACE BIOMETRIC CAPTURE",
                        style: TextStyle(
                            fontSize: 25, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        "To capture your face biometric, align your face in the GREEN box clearly then capture.",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    InkWell(
                      onTap: () {
                        _startUp();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) => FaceCapture(
                                cameraDescription: cameraDescription),
                          ),
                        );
                      },
                      child: ReusableButton("Proceed"),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
