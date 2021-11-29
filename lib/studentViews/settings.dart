import 'package:flutter/material.dart';
import 'package:fugusface/components/changePasswordScreen.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            AppBar(
              automaticallyImplyLeading: false,
              elevation: 10,
              backgroundColor: Colors.teal,
              title: Text(
                "Settings",
                style: TextStyle(fontSize: 25),
              ),
              toolbarHeight: 65,
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.03,
            ),
            SettingsSection(
              title: 'Account',
              titleTextStyle: TextStyle(fontSize: 18),
              tiles: [
                // SettingsTile(
                //   title: 'Email',
                //   leading: Icon(Icons.language),
                //   onPressed: (BuildContext context) {},
                // ),
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
                                      Text('Are you sure you want to logout?'),
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
        ));
  }
}

saveValue(String key, bool value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  print("set $key as $value");
  prefs.setBool(key, value);
}
