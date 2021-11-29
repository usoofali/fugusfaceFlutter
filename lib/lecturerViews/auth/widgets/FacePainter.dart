import 'dart:ui';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class FacePainter extends CustomPainter {
  FacePainter({
    @required this.imageSize,
    @required this.results,
    @required this.scanned,
  });
  final Size imageSize;
  Set<String> scanned;
  double scaleX, scaleY;
  Map<String, Face> results;
  @override
  void paint(Canvas canvas, Size size) {
    if (results == null) return;
    Paint paint;

    for (String label in results.keys) {
      Face face = results[label];
      if (face.headEulerAngleY > 10 || face.headEulerAngleY < -10) {
        paint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0
          ..color = Colors.red;
      } else {
        paint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0
          ..color = Colors.green;
      }
      // face = results[label];
      scaleX = size.width / imageSize.width;
      scaleY = size.height / imageSize.height;
      canvas.drawRRect(
          _scaleRect(
              rect: face.boundingBox,
              imageSize: imageSize,
              widgetSize: size,
              scaleX: scaleX,
              scaleY: scaleY),
          paint);

      TextSpan span = new TextSpan(
          style: new TextStyle(color: Colors.orange[300], fontSize: 20),
          text: label == "NOT RECOGNIZED"
              ? label
              : scanned.contains(label)
                  ? label.split(":")[1] + "->Scanned"
                  : label.split(":")[1]);
      TextPainter textPainter = new TextPainter(
          text: span,
          textAlign: TextAlign.left,
          textDirection: TextDirection.ltr);
      textPainter.layout();
      textPainter.paint(
          canvas,
          new Offset(
              size.width - (320 + face.boundingBox.left.toDouble()) * scaleX,
              (face.boundingBox.top.toDouble() - 45) * scaleY));

      TextSpan span1 = new TextSpan(
          style: new TextStyle(color: Colors.green, fontSize: 20),
          text: "[ Total Captured: " + scanned.length.toString() + " ]");
      TextPainter textPainter1 = new TextPainter(
          text: span1,
          textAlign: TextAlign.left,
          textDirection: TextDirection.ltr);
      textPainter1.layout();
      textPainter1.paint(canvas, new Offset(size.width / 4, size.height / 12));
    }
  }

  @override
  bool shouldRepaint(FacePainter oldDelegate) {
    return oldDelegate.imageSize != imageSize || oldDelegate.results != results;
  }
}

RRect _scaleRect(
    {@required Rect rect,
    @required Size imageSize,
    @required Size widgetSize,
    double scaleX,
    double scaleY}) {
  return RRect.fromLTRBR(
      (widgetSize.width - rect.left.toDouble() * scaleX),
      rect.top.toDouble() * scaleY,
      widgetSize.width - rect.right.toDouble() * scaleX,
      rect.bottom.toDouble() * scaleY,
      Radius.circular(10));
}
