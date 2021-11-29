import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:fugusface/studentViews/Courses.dart';
import 'package:fugusface/studentViews/EnrolledCourses.dart';
import 'package:fugusface/studentViews/settings.dart';

class StudentHomePage extends StatefulWidget {
  static const routeName = '/home';

  @override
  _StudentHomePageState createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  final _pageController = PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar: AppBar(
        //   backgroundColor: Colors.teal,
        //   automaticallyImplyLeading: false,
        //   title: Text('AMS'),
        // ),
        body: PageView(
            controller: _pageController,
            physics: new NeverScrollableScrollPhysics(),
            children: <Widget>[EnrolledCourses(), Courses(), Settings()],
            onPageChanged: (int index) {
              setState(() {
                //_pageController.jumpToPage(index);
              });
            }),
        bottomNavigationBar: CurvedNavigationBar(
          height: 55.0,
          color: Colors.teal,
          backgroundColor: Colors.transparent,
          animationDuration: Duration(
            milliseconds: 150,
          ),

          //animationCurve: Curves.bounceInOut,
          items: <Widget>[
            Icon(Icons.home, size: 35),
            Icon(Icons.format_list_bulleted, size: 35),
            Icon(Icons.account_circle_outlined, size: 35),
          ],
          onTap: (index) {
            //Handle button tap
            setState(() {
              _pageController.jumpToPage(index);
            });
          },
        ));
  }
}
