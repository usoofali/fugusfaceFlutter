import 'package:flutter/material.dart';
import 'package:fugusface/HandleNetworking.dart';
import 'package:fugusface/components/ReusableButton.dart';
import 'package:fugusface/lecturerViews/coursesList.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class AddCourses extends StatefulWidget {
  @override
  _AddCoursesState createState() => _AddCoursesState();
}

class _AddCoursesState extends State<AddCourses> {
  final HandleNetworking handleNetworking = HandleNetworking();
  bool idNotValid = false;
  bool nameNotValid = false;
  String courseId;
  String courseName;
  bool isLoading = false;

  String get idError {
    String pattern = r"^[A-Z]{3}[0-9]{3}";
    RegExp regExp = new RegExp(pattern);
    if (courseId.isEmpty) {
      return 'Can\'t be empty';
    }
    if (!regExp.hasMatch(courseId)) {
      return 'Course Code not valid';
    }
    // return null if the text is valid
    return null;
  }

  String get nameError {
    String pattern = r"(([a-zA-Z',]{1,})\s)?";
    RegExp regExp = new RegExp(pattern);
    if (courseName.isEmpty) {
      return 'Can\'t be empty';
    }
    if (!regExp.hasMatch(courseName)) {
      return 'Invalid course title';
    }
    // return null if the text is valid
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      child: Scaffold(
        body: Center(
          child: Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(36.0),
              child: ListView(
                // crossAxisAlignment: CrossAxisAlignment.center,
                // mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 155.0,
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 30.0),
                      child: Text(
                        'Add New Course',
                        style: TextStyle(
                          color: Colors.teal,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  TextField(
                    onChanged: (String value) {
                      if (idNotValid) {
                        setState(() {
                          idNotValid = false;
                        });
                      }
                      courseId = value;
                    },
                    obscureText: false,
                    decoration: InputDecoration(
                      contentPadding:
                          EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                      hintText: "Course Code",
                      errorText: idNotValid ? idError : null,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32.0)),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Colors.teal, width: 2.0),
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 0.0, vertical: 30.0),
                    child: TextField(
                      onChanged: (String value) {
                        if (nameNotValid) {
                          setState(() {
                            nameNotValid = false;
                          });
                        }
                        courseName = value;
                      },
                      obscureText: false,
                      decoration: InputDecoration(
                        contentPadding:
                            EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                        hintText: "Course Title",
                        errorText: nameNotValid ? nameError : null,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(32.0)),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.teal, width: 2.0),
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                      ),
                    ),
                  ),
                  Builder(builder: (BuildContext context) {
                    return GestureDetector(
                      child: ReusableButton('Add course'),
                      onTap: () async {
                        if (idError != null || nameError != null) {
                          if (idError != null) {
                            setState(() {
                              idNotValid = true;
                            });
                          }
                          if (nameError != null) {
                            setState(() {
                              nameNotValid = true;
                            });
                          }
                          return;
                        }

                        setState(() {
                          isLoading = true;
                        });

                        String isAdded = await handleNetworking
                            .addCourse(courseName, courseId)
                            .onError((error, stackTrace) => null);

                        setState(() {
                          isLoading = false;
                        });

                        if (isAdded != null) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("Course is added"),
                          ));
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CoursesList()),
                            (Route<dynamic> route) => false,
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                                "OOPS! Some error occur. Please try again later"),
                          ));
                        }
                      },
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
