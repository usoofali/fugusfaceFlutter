import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fugusface/lecturerViews/auth/face_verificate.dart';

import '../HandleNetworking.dart';

class Page1 extends StatefulWidget {
  final String id;
  Page1(this.id);

  @override
  _Page1State createState() => _Page1State();
}

class _Page1State extends State<Page1> {
  // bool isPortalActive = false;
  int sessioncode;
  bool loading = false;
  HandleNetworking handleNetworking = HandleNetworking();

  Map<String, List> studentList;

  @override
  Widget build(BuildContext context) {
    return !loading
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: double.infinity,
              ),
              GestureDetector(
                onTap: () async {
                  setState(() {
                    loading = true;
                  });
                  sessioncode = await handleNetworking
                      .openPortal(widget.id)
                      .onError((error, stackTrace) {
                    print(error);
                    return null;
                  });
                  if (sessioncode != null) {
                    studentList = await handleNetworking
                        .getEnrolledFeatures(widget.id)
                        .onError((error, stackTrace) => null);
                    if (studentList.length == 0 || studentList == null) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("No students records found."),
                      ));
                      setState(() {
                        loading = false;
                      });
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => FaceVerification(
                                  studentData: studentList,
                                  sessioncode: sessioncode.toString(),
                                  cid: widget.id,
                                )),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("Data downloaded."),
                      ));
                      setState(() {
                        loading = false;
                      });
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Some error occured."),
                    ));
                    setState(() {
                      loading = false;
                    });
                  }
                },
                child: Container(
                  width: 160.0,
                  height: 160.0,
                  decoration: BoxDecoration(
                    color: Colors.teal,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      'Take Attendance',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          )
        : Center(child: CircularProgressIndicator());
  }
}
