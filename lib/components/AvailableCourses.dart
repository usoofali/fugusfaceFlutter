import 'dart:core';
import 'package:flutter/material.dart';
import 'package:fugusface/HandleNetworking.dart';

class AvailableCourses extends StatelessWidget {
  final String courseId;
  final String courseCode;
  final String courseIdName;
  final String courseName;
  final String adminId;
  final int session;
  final int sessionCount;
  final bool enroll;

  AvailableCourses(
      this.courseId,
      this.courseCode,
      this.courseName,
      this.adminId,
      this.session,
      this.sessionCount,
      this.enroll,
      this.courseIdName);

  Future<String> createAlertDialogue(BuildContext context) {
    TextEditingController customController = TextEditingController();

    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Enter enrol code for $courseCode:"),
            content: TextField(
              controller: customController,
            ),
            actions: [
              MaterialButton(
                elevation: 5.0,
                child: Text("Submit"),
                onPressed: () {
                  Navigator.of(context).pop(customController.text.toString());
                },
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(Icons.library_books),
        title: Text(courseCode),
        subtitle: Text(courseName),
        onTap: () {
          createAlertDialogue(context).then((value) async {
            String enrollStatus =
                await HandleNetworking().enroll(courseId, value);
            if (enrollStatus.toString() == "true") {
              SnackBar newSnackbar = SnackBar(
                content: Text("You Successfully got enrolled in $courseName"),
                padding: EdgeInsets.only(bottom: 7.0, top: 7.0),
              );
              ScaffoldMessenger.of(context).showSnackBar(newSnackbar);
            } else if (value != null) {
              SnackBar newSnackbar = SnackBar(
                content: Text("Error: " + enrollStatus.toString()),
                padding: EdgeInsets.only(bottom: 7.0, top: 7.0),
              );
              ScaffoldMessenger.of(context).showSnackBar(newSnackbar);
            }
          });
        },
      ),
    );
  }
}
