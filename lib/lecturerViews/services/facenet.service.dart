import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter_beep/flutter_beep.dart';
import 'package:fugusface/services/image_converter.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as imglib;

class FaceNetService {
  // singleton boilerplate
  static final FaceNetService _faceNetService = FaceNetService._internal();
  factory FaceNetService() {
    return _faceNetService;
  }
  // singleton boilerplate
  FaceNetService._internal() {
    _scanned = {};
    counter = {};
  }

  Interpreter _interpreter;

  double threshold = 1.0;

  Set<String> _scanned;

  Set<String> get scanned => this._scanned;

  Map<String, int> counter;

  Map<String, Face> _predictedData;
  Map<String, Face> get predictedData => this._predictedData;

  //  saved users data
  Map<String, List> studentData;

  Future loadModel() async {
    Delegate delegate;
    try {
      if (Platform.isAndroid) {
        delegate = GpuDelegateV2(
            options: GpuDelegateOptionsV2(
          false,
          TfLiteGpuInferenceUsage.fastSingleAnswer,
          TfLiteGpuInferencePriority.minLatency,
          TfLiteGpuInferencePriority.auto,
          TfLiteGpuInferencePriority.auto,
        ));
      } else if (Platform.isIOS) {
        delegate = GpuDelegate(
          options: GpuDelegateOptions(true, TFLGpuDelegateWaitType.active),
        );
      }
      var interpreterOptions = InterpreterOptions()..addDelegate(delegate);

      this._interpreter = await Interpreter.fromAsset('mobilefacenet.tflite',
          options: interpreterOptions);
    } catch (e) {
      print(e);
    }
  }

  setCurrentPrediction(CameraImage cameraImage, List<Face> result) {
    /// crops the ace from the image and transforms it to an array of data
    Face face;
    Map<String, Face> finalResult = {};
    for (face in result) {
      List input = _preProcess(cameraImage, face);

      /// then reshapes input and ouput to model format 🧑‍🔧
      input = input.reshape([1, 112, 112, 3]);
      List output = List.generate(1, (index) => List.filled(192, 0));

      /// runs and transforms the data 🤖
      this._interpreter.run(input, output);
      output = output.reshape([192]);
      String predres = _searchResult(output);
      finalResult[predres] = face;
    }

    _predictedData = finalResult;
  }

  String _searchResult(List predictedData) {
    /// if no faces saved
    if (studentData?.length == 0) return "No student record found.";
    double minDist = 999;
    double currDist = 0.0;
    String predRes = "NOT RECOGNIZED";

    /// search the closest result 👓
    for (String label in studentData.keys) {
      currDist = _euclideanDistance(studentData[label], predictedData);
      if (currDist <= threshold && currDist < minDist) {
        minDist = currDist;
        predRes = label;
      }
    }
    //checks
    if (_scanned == null) _scanned = {};
    if (counter == null) counter = {};
    if (predRes != "NOT RECOGNIZED" && !_scanned.contains(predRes)) {
      if (counter.containsKey(predRes)) {
        if (counter[predRes] == 2) {
          _scanned.add(predRes);
          FlutterBeep.beep();
        } else {
          counter[predRes] += 1;
        }
      } else {
        counter[predRes] = 1;
      }
    }
    return predRes;
  }

  /// Adds the power of the difference between each point
  /// then computes the sqrt of the result 📐
  double _euclideanDistance(List e1, List e2) {
    if (e1 == null || e2 == null) throw Exception("Null argument");

    double sum = 0.0;
    for (int i = 0; i < e1.length; i++) {
      sum += pow((e1[i] - e2[i]), 2);
    }
    return sqrt(sum);
  }

  /// _preProess: crops the image to be more easy
  /// to detect and transforms it to model input.
  /// [cameraImage]: current image
  /// [face]: face detected
  List _preProcess(CameraImage image, Face faceDetected) {
    // crops the face 💇
    imglib.Image croppedImage = _cropFace(image, faceDetected);
    imglib.Image img = imglib.copyResizeCropSquare(croppedImage, 112);

    // transforms the cropped face to array data
    Float32List imageAsList = imageToByteListFloat32(img);
    return imageAsList;
  }

  /// crops the face from the image 💇
  /// [cameraImage]: current image
  /// [face]: face detected
  imglib.Image _cropFace(CameraImage image, Face faceDetected) {
    imglib.Image convertedImage = _convertCameraImage(image);
    double x = faceDetected.boundingBox.left - 10.0;
    double y = faceDetected.boundingBox.top - 10.0;
    double w = faceDetected.boundingBox.width + 10.0;
    double h = faceDetected.boundingBox.height + 10.0;
    return imglib.copyCrop(
        convertedImage, x.round(), y.round(), w.round(), h.round());
  }

  /// converts ___CameraImage___ type to ___Image___ type
  /// [image]: image to be converted
  imglib.Image _convertCameraImage(CameraImage image) {
    var img = convertToImage(image);
    var img1 = imglib.copyRotate(img, -90);
    return img1;
  }

  Float32List imageToByteListFloat32(imglib.Image image) {
    /// input size = 112
    var convertedBytes = Float32List(1 * 112 * 112 * 3);
    var buffer = Float32List.view(convertedBytes.buffer);
    int pixelIndex = 0;

    for (var i = 0; i < 112; i++) {
      for (var j = 0; j < 112; j++) {
        var pixel = image.getPixel(j, i);

        /// mean: 128, std: 128
        buffer[pixelIndex++] = (imglib.getRed(pixel) - 128) / 128;
        buffer[pixelIndex++] = (imglib.getGreen(pixel) - 128) / 128;
        buffer[pixelIndex++] = (imglib.getBlue(pixel) - 128) / 128;
      }
    }
    return convertedBytes.buffer.asFloat32List();
  }

  void scanner() {
    _scanned = {};
  }

  /// searchs the result in the DDBB (this function should be performed by Backend)
  /// [predictedData]: Array that represents the face by the MobileFaceNet model

}
