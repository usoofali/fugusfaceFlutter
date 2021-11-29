import 'package:flutter/material.dart';
import 'package:fugusface/components/LoginScreen.dart';
import 'package:fugusface/components/WelcomeScreen.dart';
import 'package:fugusface/lecturerViews/coursesList.dart';
import 'package:fugusface/studentViews/StudentHomePage.dart';
import 'package:fugusface/studentViews/auth/auth_home.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    checkUserSignedIn();
  }

  void checkUserSignedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isUserLoggedIn = prefs.getBool('isUserLoggedIn') ?? false;
      level = prefs.getInt('level') ?? null;
    });
  }

  bool isUserLoggedIn = false;
  int level;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'AMS FUGUS',
        debugShowCheckedModeBanner: false,
        home: isUserLoggedIn
            ? level == 1
                ? CoursesList()
                : StudentHomePage()
            : WelcomeScreen(),
        routes: {
          LoginScreen.routeName: (context) => LoginScreen(),
          StudentHomePage.routeName: (context) => StudentHomePage(),
          AuthHome.routeName: (context) => AuthHome(),
        });
  }
}
