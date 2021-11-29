import 'package:flutter/material.dart';
import 'package:fugusface/HandleNetworking.dart';
import 'package:fugusface/components/EnrolledStudentTile.dart';

class Page2 extends StatefulWidget {
  final String id;
  Page2(this.id);
  @override
  _Page2State createState() => _Page2State();
}

class _Page2State extends State<Page2> {
  @override
  void initState() {
    super.initState();
    fetchStudentList();
  }

  Future<List<EnrolledStudentTile>> studentList;
  Future<void> fetchStudentList() async {
    HandleNetworking handleNetworking = HandleNetworking();
    studentList = handleNetworking.getEnrolledStudents(widget.id);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<EnrolledStudentTile>>(
      future: studentList,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return RefreshIndicator(
            onRefresh: fetchStudentList,
            child: ListView(
              children: snapshot.data,
            ),
          );
        } else if (snapshot.hasError) {
          return Center(
                        child: Text(
                          "Connection failed!",
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w300, // light
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      );
        }

        return Center(child: CircularProgressIndicator());
      },
    );
  }
}
