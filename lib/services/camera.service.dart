import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class CameraService {
  // singleton boilerplate
  static final CameraService _cameraServiceService = CameraService._internal();

  factory CameraService() {
    return _cameraServiceService;
  }
  // singleton boilerplate
  CameraService._internal();

  CameraController _cameraController;
  CameraController get cameraController => this._cameraController;

  CameraDescription _cameraDescription;

  InputImageRotation _cameraRotation;
  InputImageRotation get cameraRotation => this._cameraRotation;

  String _imagePath;
  String get imagePath => this._imagePath;

  Future startService(CameraDescription cameraDescription) async {
    this._cameraDescription = cameraDescription;
    this._cameraController = CameraController(
      this._cameraDescription,
      ResolutionPreset.high,
      enableAudio: false,
    );

    // sets the rotation of the image
    this._cameraRotation = rotationIntToImageRotation(
      this._cameraDescription.sensorOrientation,
    );

    // Next, initialize the controller. This returns a Future.
    return this._cameraController.initialize();
  }

  stopService() {
    this._cameraDescription = null;
    this._cameraController = null;
  }

  InputImageRotation rotationIntToImageRotation(int rotation) {
    switch (rotation) {
      case 90:
        return InputImageRotation.Rotation_90deg;
      case 180:
        return InputImageRotation.Rotation_180deg;
      case 270:
        return InputImageRotation.Rotation_270deg;
      default:
        return InputImageRotation.Rotation_0deg;
    }
  }

  /// returns the image size 📏
  Size getImageSize() {
    return Size(
      _cameraController.value.previewSize.height,
      _cameraController.value.previewSize.width,
    );
  }

  dispose() {
    this._cameraController.dispose();
  }
}
