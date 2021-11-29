import 'package:flutter/material.dart';
import 'package:fugusface/components/LoginScreen.dart';
import 'package:fugusface/components/Registration.dart';
import 'package:fugusface/components/ReusableButton.dart';

class WelcomeScreen extends StatelessWidget {
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
                  "FUGUS FACE",
                  style: TextStyle(
                    fontSize: 30.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 35.0),
                GestureDetector(
                  child: ReusableButton('Register'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Registration()),
                    );
                  },
                ),
                SizedBox(height: 25.0),
                GestureDetector(
                  child: ReusableButton('Login'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => LoginScreen(msg: '')),
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
