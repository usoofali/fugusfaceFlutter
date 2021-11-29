import 'package:flutter/material.dart';
import 'package:fugusface/HandleNetworking.dart';
import 'package:fugusface/components/ReusableButton.dart';
import 'package:fugusface/components/changePasswordScreen.dart';
import 'package:fugusface/lecturerViews/coursesList.dart';
import 'package:fugusface/studentViews/StudentHomePage.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';
  final String msg;
  LoginScreen({this.msg});
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final HandleNetworking handleNetworking = HandleNetworking();
  bool emailNotValid = false;
  bool passwordNotValid = false;
  String email;
  String password;
  bool isLoading = false;

  String get emailError {
    String pattern =
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
    RegExp regExp = new RegExp(pattern);
    if (email.isEmpty) {
      return 'Can\'t be empty';
    }
    if (!regExp.hasMatch(email)) {
      return 'Invalid email';
    }
    // return null if the text is valid
    return null;
  }

  String get passwordError {
    if (password.isEmpty) {
      return 'Can\'t be empty';
    }
    if (password.length < 8) {
      return 'Too short at least 8 characters';
    }
    // return null if the text is valid
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      child: Scaffold(
        body: Center(
          child: Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(36.0),
              child: ListView(
                // crossAxisAlignment: CrossAxisAlignment.center,
                // mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 100,
                  ),
                  SizedBox(
                    height: 155.0,
                    child: Image.asset(
                      "images/logo.png",
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(height: 45.0),
                  TextField(
                    onChanged: (String value) {
                      if (emailNotValid) {
                        setState(() {
                          emailNotValid = false;
                        });
                      }
                      email = value.trim();
                    },
                    obscureText: false,
                    decoration: InputDecoration(
                      contentPadding:
                          EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                      hintText: "Email",
                      errorText: emailNotValid ? emailError : null,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32.0)),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Colors.teal, width: 2.0),
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 25.0),
                  TextField(
                    onChanged: (String value) {
                      if (passwordNotValid) {
                        setState(() {
                          passwordNotValid = false;
                        });
                      }
                      password = value.trim();
                    },
                    obscureText: true,
                    decoration: InputDecoration(
                      contentPadding:
                          EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                      hintText: "Password",
                      errorText: passwordNotValid ? passwordError : null,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32.0)),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Colors.teal, width: 2.0),
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 35.0,
                  ),
                  Builder(builder: (BuildContext context) {
                    return GestureDetector(
                      child: ReusableButton('Login'),
                      onTap: () async {
                        if (emailError != null || passwordError != null) {
                          if (emailError != null) {
                            setState(() {
                              emailNotValid = true;
                            });
                          }
                          if (passwordError != null) {
                            setState(() {
                              passwordNotValid = true;
                            });
                          }
                          return;
                        }

                        setState(() {
                          isLoading = true;
                        });

                        Map<String, dynamic> result = await handleNetworking
                            .login(email, password)
                            .onError((error, stackTrace) async {
                          print(error);
                          return null;
                        });
                        final prefs = await SharedPreferences.getInstance();

                        setState(() {
                          isLoading = false;
                        });

                        if (result != null) {
                          if (result['err']) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(result['msg']),
                            ));
                          } else {
                            prefs.setString("id", result['msg']);
                            prefs.setInt("level", result['level']);
                            prefs.setBool("isUserLoggedIn", true);

                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text("Logged successfully."),
                            ));
                            if (result['level'] == 1) {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => CoursesList()),
                                (Route<dynamic> route) => false,
                              );
                            } else {
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                  StudentHomePage.routeName,
                                  (Route<dynamic> route) => false);
                            }
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                                "something went wrong please try again later"),
                          ));
                        }
                      },
                    );
                  }),
                  SizedBox(
                    height: 25.0,
                  ),
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ChangePasswordScreen()),
                        );
                      },
                      child: Text(
                        'Forget Password?',
                        style: TextStyle(
                          color: Colors.blueAccent,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30.0, vertical: 18.0),
                    child: Text(
                      widget.msg,
                      style: TextStyle(
                        color: Colors.green,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 15.0,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
