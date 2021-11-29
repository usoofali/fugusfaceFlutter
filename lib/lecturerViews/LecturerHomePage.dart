import 'package:flutter/material.dart';
import 'package:fugusface/lecturerViews/Page1.dart';
import 'package:fugusface/lecturerViews/Page2.dart';
import 'package:fugusface/lecturerViews/settings.dart';

class LecturerHomePage extends StatefulWidget {
  final Map course;
  LecturerHomePage(this.course);
  @override
  _LecturerHomePageState createState() => _LecturerHomePageState();
}

class _LecturerHomePageState extends State<LecturerHomePage> {
  //
  // String courseId;
  int _currentIndex = 0;
  List<Widget> widgetOptions = [];

  Widget build(BuildContext context) {
    widgetOptions = [
      Page1(widget.course['_id']),
      Page2(widget.course['_id']),
    ];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Center(child: Text(widget.course['course_code'])),
        actions: [
          IconButton(
              icon: Icon(
                Icons.settings,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Settings(widget.course)),
                );
              })
        ],
      ),
      body: widgetOptions.elementAt(_currentIndex),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        backgroundColor: Colors.teal,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white.withOpacity(.6),
        selectedFontSize: 14,
        unselectedFontSize: 14,
        onTap: (value) {
          // Respond to item press.
          setState(() => _currentIndex = value);
        },
        items: [
          BottomNavigationBarItem(
            label: 'Home',
            icon: Icon(Icons.home),
          ),
          BottomNavigationBarItem(
            label: 'Enrolled Students',
            icon: Icon(Icons.format_list_bulleted),
          ),

          // BottomNavigationBarItem(
          //   label: 'Settings',
          //   icon: Icon(Icons.account_circle_outlined),
          // ),
        ],
      ),
    );
  }
}
