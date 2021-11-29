import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fugusface/HandleNetworking.dart';
import 'package:fugusface/components/EnrolledList.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EnrolledCourses extends StatefulWidget {
  @override
  _EnrolledCoursesState createState() => _EnrolledCoursesState();
}

class _EnrolledCoursesState extends State<EnrolledCourses> {
  @override
  void initState() {
    super.initState();

    getId();
    getId().then((id) => {studentId = id, getCoursesList()});
    //getCoursesList();
  }

  getId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String id = prefs.getString("id") ?? null;
    return id;
  }

  var studentId;

  Future<List<EnrolledList>> enrolledList;
  Future<void> getCoursesList() async {
    HandleNetworking handleNetworking = HandleNetworking();
    enrolledList = handleNetworking.getEnrolledCourses(studentId);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: ListView(
          children: [
            AppBar(
              automaticallyImplyLeading: false,
              elevation: 10,
              backgroundColor: Colors.teal,
              title: Text(
                "Enrolled Courses",
                style: TextStyle(fontSize: 25),
              ),
              toolbarHeight: 65,
              actions: [
                IconButton(
                    icon: Icon(
                      Icons.power_settings_new,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      _showMyDialog(context);
                    })
              ],
            ),
            Container(
              height: MediaQuery.of(context).size.height * .8,
              width: MediaQuery.of(context).size.width,
              child: SafeArea(
                child: FutureBuilder<List<EnrolledList>>(
                  future: enrolledList,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return RefreshIndicator(
                        child: ListView(
                          children: snapshot.data,
                        ),
                        onRefresh: getCoursesList,
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          "No Enrolled Courses!",
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
                ),
              ),
            ),
          ],
        ));
  }
  Future<void> _showMyDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to log out?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Yes"),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();

                prefs.remove('isUserLoggedIn');
                prefs.remove('id');
                SystemNavigator.pop();
                //Navigator.pop(context);
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
