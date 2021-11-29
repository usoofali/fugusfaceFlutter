import 'package:flutter/material.dart';
import 'package:fugusface/HandleNetworking.dart';
import 'package:fugusface/components/AvailableCourses.dart';

class Courses extends StatefulWidget {
  @override
  _CoursesState createState() => _CoursesState();
}

class _CoursesState extends State<Courses> {
  @override
  void initState() {
    super.initState();
    getCoursesList();
  }

  Future<List<AvailableCourses>> coursesList;
  Future<void> getCoursesList() async {
    HandleNetworking handleNetworking = HandleNetworking();
    coursesList = handleNetworking.getAvailableCourses();
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
              "Available Courses",
              style: TextStyle(fontSize: 25),
            ),
            toolbarHeight: 65,
          ),
          Container(
            height: MediaQuery.of(context).size.height * .8,
            width: MediaQuery.of(context).size.width,
            child: SafeArea(
                child: FutureBuilder<List<AvailableCourses>>(
              future: coursesList,
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
            )),
          ),
        ],
      ),
    );
  }
}
