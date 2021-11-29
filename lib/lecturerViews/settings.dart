import 'package:flutter/material.dart';
import 'package:fugusface/HandleNetworking.dart';
import 'package:fugusface/components/changePasswordScreen.dart';
import 'package:fugusface/lecturerViews/coursesList.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatefulWidget {
  final Map course;
  Settings(this.course);
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final HandleNetworking handleNetworking = HandleNetworking();
  bool isSwitched = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 10,
        backgroundColor: Colors.teal,
        title: Center(
          child: Text(
            "Settings",
            style: TextStyle(fontSize: 24),
          ),
        ),
        toolbarHeight: 65,
      ),
      body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.03,
              ),
              SettingsSection(
                title: widget.course['course_code'],
                subtitle:
                    Center(child: Text(widget.course['enrollCode'].toString())),
                titleTextStyle: TextStyle(fontSize: 22),
                tiles: [
                  SettingsTile.switchTile(
                    title: 'Enrollement open',
                    leading: Icon(Icons.phone_android),
                    switchValue: widget.course['allowEnroll'] != null
                        ? widget.course['allowEnroll']
                        : false,
                    onToggle: (value) async {
                      bool attended = await handleNetworking
                          .enrollHandler(widget.course['_id'], value)
                          .onError((error, stackTrace) => null);

                      if (attended != null) {
                        if (attended == true) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content:
                                Text("Enrollment status changed successfully."),
                          ));
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CoursesList(),
                              ),
                              (route) => false);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("Status change failed."),
                          ));
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("Connection failed."),
                        ));
                      }
                      setState(() {
                        isSwitched = value;
                      });
                    },
                  ),
                  SettingsTile(
                    title: 'Reset Password',
                    leading: Icon(Icons.fingerprint),
                    onPressed: (BuildContext context) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ChangePasswordScreen()),
                      );
                    },
                  ),
                  SettingsTile(
                    title: 'Export Report to Email',
                    leading: Icon(Icons.attach_email),
                    onPressed: (BuildContext context) {
                      showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                                  title: Text('Attendance Report'),
                                  content: SingleChildScrollView(
                                    child: ListBody(
                                      children: <Widget>[
                                        Text(
                                            'Are you sure you want to receive attendance report?'),
                                      ],
                                    ),
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                        child: Text('Yes'),
                                        onPressed: () async {
                                          String attended =
                                              await handleNetworking
                                                  .exportEnrolledStudents(
                                                      widget.course['_id'])
                                                  .onError(
                                                      (error, stackTrace) =>
                                                          null);

                                          if (attended != null) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                              content: Text(attended),
                                            ));
                                            Navigator.of(context).pop(false);
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                              content:
                                                  Text("Connection failed."),
                                            ));
                                            Navigator.of(context).pop(false);
                                          }
                                        }),
                                    TextButton(
                                        child: Text('No'),
                                        onPressed: () =>
                                            Navigator.of(context).pop(false)),
                                  ]));
                    },
                  ),
                  SettingsTile(
                    title: 'Logout',
                    leading: Icon(Icons.logout),
                    onPressed: (BuildContext context) {
                      showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                                  title: Text('Logout'),
                                  content: SingleChildScrollView(
                                    child: ListBody(
                                      children: <Widget>[
                                        Text(
                                            'Are you sure you want to logout?'),
                                      ],
                                    ),
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                        child: Text('Logout'),
                                        onPressed: () {
                                          saveValue("status", false);
                                          Navigator.of(context)
                                              .pushNamedAndRemoveUntil(
                                                  '/',
                                                  (Route<dynamic> route) =>
                                                      false);
                                        }),
                                    TextButton(
                                        child: Text('Cancel'),
                                        onPressed: () =>
                                            Navigator.of(context).pop(false)),
                                  ]));
                    },
                  )
                ],
              ),
            ],
          )),
    );
  }
}

saveValue(String key, bool value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  print("set $key as $value");
  prefs.setBool(key, value);
}
