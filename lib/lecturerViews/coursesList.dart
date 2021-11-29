import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fugusface/HandleNetworking.dart';
import 'package:fugusface/components/CourseTile.dart';
import 'package:fugusface/lecturerViews/AddCourses.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CoursesList extends StatefulWidget {
  @override
  _CoursesListState createState() => _CoursesListState();
}

class _CoursesListState extends State<CoursesList> {
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

  Future<List<CourseTile>> coursesList;
  Future<void> fetchCoursesList() async {
    HandleNetworking handleNetworking = HandleNetworking();
    coursesList =
        handleNetworking.getCourses().onError((error, stackTrace) => null);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    fetchCoursesList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Center(child: Text('Dashboard')),
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
      body: FutureBuilder<List<CourseTile>>(
        future: coursesList,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return RefreshIndicator(
              onRefresh: fetchCoursesList,
              child: ListView(
                children: snapshot.data,
              ),
            );
          } else if (snapshot.hasError) {
            return Text("Network connection error.");
          }

          return Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => AddCourses()));
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        backgroundColor: Colors.teal,
      ),
    );
  }
}
