import 'package:flutter/material.dart';
import 'package:fugusface/HandleNetworking.dart';
import 'package:fugusface/Models/FutureResponse.dart';
import 'package:fugusface/components/LoginScreen.dart';
import 'package:fugusface/components/ReusableButton.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class LecturerRegisterScreen extends StatefulWidget {
  @override
  _LecturerRegisterScreenState createState() => _LecturerRegisterScreenState();
}

class _LecturerRegisterScreenState extends State<LecturerRegisterScreen> {
  final HandleNetworking handleNetworking = HandleNetworking();
  bool emailNotValid = false;
  bool passwordNotValid = false;
  bool nameNotValid = false;
  String email;
  String password;
  String name;
  bool isLoading = false;

  String get nameError {
    String pattern = r"^[a-zA-Z]+(([',. -][a-zA-Z ])?[a-zA-Z]*)*$";
    RegExp regExp = new RegExp(pattern);
    if (name.isEmpty) {
      return 'Can\'t be empty';
    }
    if (!regExp.hasMatch(name)) {
      return 'Invalid name';
    }
    // return null if the text is valid
    return null;
  }

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
                      if (nameNotValid) {
                        setState(() {
                          nameNotValid = false;
                        });
                      }
                      name = value.trim();
                    },
                    obscureText: false,
                    decoration: InputDecoration(
                      contentPadding:
                          EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                      hintText: "Name",
                      errorText: nameNotValid ? nameError : null,
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
                      child: ReusableButton('Register'),
                      onTap: () async {
                        if (emailError != null ||
                            passwordError != null ||
                            nameError != null) {
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
                          if (nameError != null) {
                            setState(() {
                              nameNotValid = true;
                            });
                          }
                          return;
                        }

                        setState(() {
                          isLoading = true;
                        });

                        FutureResponse result = await handleNetworking
                            .registerLecturer(email, name, password);
                        setState(() {
                          isLoading = false;
                        });
                        if (result != null) {
                          if (result.err) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(result.msg),
                            ));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(result.msg),
                            ));
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginScreen(
                                      msg:
                                          "Confirmation email sent. First verify your email then login to AMS")),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                                "Something went wrong please try again later"),
                          ));
                        }
                      },
                    );
                  }),
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
