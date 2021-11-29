import 'package:flutter/material.dart';
import 'package:fugusface/HandleNetworking.dart';
import 'package:fugusface/Models/FutureResponse.dart';
import 'package:fugusface/components/ReusableButton.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class ChangePasswordScreen extends StatefulWidget {
  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final HandleNetworking handleNetworking = HandleNetworking();
  bool emailNotValid = false;
  bool passwordNotValid = false;
  bool confirmPasswordNotValid = false;
  String email;
  String password;
  String confirmPassword;
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

  String get confirmPasswordError {
    if (confirmPassword.isEmpty) {
      return 'Can\'t be empty';
    }
    if (password != confirmPassword) {
      return 'Passwords mismatched';
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
                  SizedBox(height: 60.0),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 30.0),
                      child: Text(
                        'Change Password',
                        style: TextStyle(
                          color: Colors.teal,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
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
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 0.0, vertical: 30.0),
                    child: TextField(
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
                        hintText: "New Password",
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
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 30.0),
                    child: TextField(
                      onChanged: (String value) {
                        if (confirmPasswordNotValid) {
                          setState(() {
                            confirmPasswordNotValid = false;
                          });
                        }
                        confirmPassword = value.trim();
                      },
                      obscureText: true,
                      decoration: InputDecoration(
                        contentPadding:
                            EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                        hintText: "Re-Enter New Password",
                        errorText: confirmPasswordNotValid
                            ? confirmPasswordError
                            : null,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(32.0)),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.teal, width: 2.0),
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 25.0),
                  Builder(builder: (BuildContext context) {
                    return GestureDetector(
                      child: ReusableButton('Change Password'),
                      onTap: () async {
                        if (emailError != null ||
                            passwordError != null ||
                            confirmPasswordError != null) {
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
                          if (confirmPasswordError != null) {
                            setState(() {
                              confirmPasswordNotValid = true;
                            });
                          }
                          return;
                        }

                        setState(() {
                          isLoading = true;
                        });

                        FutureResponse result = await handleNetworking
                            .resetPassword(email, confirmPassword);

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

                            Future.delayed(Duration(seconds: 2), () {
                              Navigator.pop(context);
                            });
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                                "OOPS! Some error occur. Please try again later"),
                          ));
                        }
                      },
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
