import 'package:flutter/material.dart';
import 'package:fugusface/components/ReusableButton.dart';
import 'package:fugusface/lecturerViews/LecturerRegisterScreen.dart';

class Registration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(36.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: 155.0,
                  child: Image.asset(
                    "images/logo.png",
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: 45.0),
                Text(
                  "Registration Portal",
                  style: TextStyle(
                    fontSize: 30.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 35.0),
                GestureDetector(
                  child: ReusableButton('Student'),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/auth_home',
                    );
                  },
                ),
                SizedBox(height: 25.0),
                GestureDetector(
                  child: ReusableButton('Lecturer'),
                  onTap: () {
                    
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => LecturerRegisterScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
