import 'package:flutter/material.dart';
import 'package:fugusface/HandleNetworking.dart';
import 'package:fugusface/lecturerViews/LecturerHomePage.dart';
import 'package:fugusface/lecturerViews/coursesList.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:toast/toast.dart';

class CourseTile extends StatelessWidget {
  final Map course;
  CourseTile(this.course);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () async {
        _showMyDialog(context);
      },
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LecturerHomePage(course)),
        );
      },
      child: Card(
        child: ListTile(
          leading: Icon(Icons.library_books),
          title: Text(course['name']),
          subtitle: Text(course['course_code']),
          trailing: CircularPercentIndicator(
            radius: 50.0,
            lineWidth: 6.0,
            animation: true,
            percent: 0.0,
            center: Text(
              course['sessioncount'].toString(),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0),
            ),
            circularStrokeCap: CircularStrokeCap.round,
            progressColor: Colors.teal,
          ),
        ),
      ),
    );
  }

  Future<void> _showMyDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Course'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete this course?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Yes"),
              onPressed: () async {
                HandleNetworking handleNetworking = HandleNetworking();
                bool res = await handleNetworking.deleteCourse(course['_id']);
                if (res) {
                  Toast.show("Successfully deleted course", context,
                      duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => CoursesList()),
                    (Route<dynamic> route) => false,
                  );
                } else {
                  Toast.show("Some error occured occur while deleting a course",
                      context,
                      duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
                  Navigator.pop(context);
                }
              },
            ),
            TextButton(
              child: Text("No"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
