import 'package:fugusface/Models/FutureResponse.dart';
import 'package:fugusface/components/AvailableCourses.dart';
import 'package:fugusface/components/CourseTile.dart';
import 'package:fugusface/components/EnrolledList.dart';
import 'package:fugusface/components/EnrolledStudentTile.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class HandleNetworking {
  final String ipAddress = "http://34.65.90.41:3000";
  Future<FutureResponse> registerLecturer(String lecturerEmail,
      String lecturerName, String lecturerPassword) async {
    final http.Response response =
        await http.post(ipAddress + "/lecturer/register",
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, dynamic>{
              'email': lecturerEmail,
              'password': lecturerPassword,
              'name': lecturerName,
              'ip': ipAddress,
            }));
    if (response.statusCode == 200 ||
        response.statusCode == 400 ||
        response.statusCode == 500)
      return FutureResponse.fromJson(jsonDecode(response.body));
    else
      return null;
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final http.Response response =
        await http.post(ipAddress + "/lecturer/login",
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, dynamic>{
              'email': email,
              'password': password,
            }));
    if (response.statusCode == 200 ||
        response.statusCode == 400 ||
        response.statusCode == 500)
      return jsonDecode(response.body);
    else
      return null;
  }

  Future<String> attend(String cid, String code, Set scanned) async {
    List<String> sids = [];
    scanned.forEach((element) {
      sids.add(element.split(":")[0]);
    });
    final http.Response response =
        await http.post(ipAddress + "/api/student/attend",
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, dynamic>{
              'sessioncode': code,
              'cid': cid,
              'sids': sids,
            }));

    if (response.statusCode == 200) {
      var jsonRes = jsonDecode(response.body);
      //print(jsonRes);

      if (jsonRes['success'] == true) {
        return "Records submitted successfully.";
      } else {
        return jsonRes['message'];
      }
    } else {
      return 'Failed to connect.';
    }
  }

  Future<FutureResponse> resetPassword(
      String lecturerEmail, String newPassword) async {
    final http.Response response =
        await http.post(ipAddress + "/lecturer/resetPassword",
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, dynamic>{
              'email': lecturerEmail,
              'password': newPassword,
              'ip': ipAddress,
            }));

    if (response.statusCode == 200 ||
        response.statusCode == 400 ||
        response.statusCode == 500)
      return FutureResponse.fromJson(jsonDecode(response.body));
    else
      return null;
  }

  Future<List<CourseTile>> getCourses() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String profId = prefs.getString('id');
    final http.Response response =
        await http.get(ipAddress + "/api/course/getcourses/" + profId);

    if (response.statusCode == 200) {
      var jsonRes = jsonDecode(response.body);
      List courses = jsonRes['result'];
      List<CourseTile> coursesTileList = [];

      for (int i = 0; i < courses.length; i++) {
        // print(courses[i]);
        coursesTileList.add(CourseTile(courses[i]));
      }

      return coursesTileList;
    } else {
      throw Exception('Failed to load album');
    }
  }

  Future<String> addCourse(String courseName, String courseId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String profId = prefs.getString('id');

    final http.Response response =
        await http.post(ipAddress + "/api/course/create",
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, dynamic>{
              'name': courseName,
              'admin_id': profId,
              'course_id': courseId,
            }));

    if (response.statusCode == 200 ||
        response.statusCode == 500 ||
        response.statusCode == 501) {
      var jsonRes = jsonDecode(response.body);
      return jsonRes['msg'];
    } else {
      return null;
    }
  }

  Future<int> openPortal(String id) async {
    final http.Response response =
        await http.get(ipAddress + "/api/course/start/" + id);
    if (response.statusCode == 200) {
      var decodedRes = jsonDecode(response.body);
      return decodedRes['result'];
    } else {
      print(jsonDecode(response.body));
      return null;
    }
  }

  Future<bool> closePortal(String id) async {
    final http.Response response =
        await http.get(ipAddress + "/api/course/stop/" + id);

    if (response.statusCode == 200)
      return true;
    else
      return false;
  }

  Future<bool> deleteCourse(String id) async {
    final http.Response response = await http.delete(
      ipAddress + '/api/course/delete/$id',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200)
      return true;
    else
      return false;
  }

  Future<List<EnrolledStudentTile>> getEnrolledStudents(String id) async {
    final http.Response response =
        await http.get(ipAddress + "/api/course/home/" + id);

    if (response.statusCode == 200) {
      var jsonRes = jsonDecode(response.body);
      var students = jsonRes['name'];
      List<EnrolledStudentTile> studentTileList = [];

      for (int i = 0; i < students.length; i++) {
        studentTileList.add(EnrolledStudentTile(
            jsonRes['name'][i],
            jsonRes['regno'][i],
            jsonRes['username'][i],
            jsonRes['attendance'][i].toDouble()));
      }

      return studentTileList;
    } else {
      throw Exception('Failed to load album');
    }
  }

  Future<String> exportEnrolledStudents(String id) async {
    final http.Response response =
        await http.get(ipAddress + "/api/course/export/" + id);

    if (response.statusCode == 200) {
      var jsonRes = jsonDecode(response.body);
      return jsonRes['result'];
    } else {
      return null;
    }
  }

  Future<Map<String, List>> getEnrolledFeatures(String id) async {
    final http.Response response =
        await http.get(ipAddress + "/api/course/verification/" + id);

    if (response.statusCode == 200) {
      var jsonRes = jsonDecode(response.body);
      var ids = jsonRes['id'];
      Map<String, List> finalResult = {};
      if (ids != null) {
        for (int i = 0; i < ids.length; i++) {
          finalResult[jsonRes['id'][i] + ":" + jsonRes['regno'][i]] =
              jsonRes['features'][i];
        }
        return finalResult;
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  Future<bool> enrollHandler(String id, bool allow) async {
    final http.Response response =
        await http.post(ipAddress + "/api/course/enrollhandler/$id/$allow");
    if (response.statusCode == 200) {
      var jsonRes = jsonDecode(response.body);
      return jsonRes['success'];
    } else {
      return null;
    }
  }

  /////////  Beging of Student APIs ///////////////////////////////////////////////////////

  Future<FutureResponse> registerStudent(
      String studentEmail,
      String studentName,
      String studentPassword,
      String regno,
      List features) async {
    print(features);
    final http.Response response =
        await http.post(ipAddress + "/student/register",
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, dynamic>{
              'email': studentEmail,
              'regno': regno,
              'password': studentPassword,
              'name': studentName,
              'ip': ipAddress,
              'features': features,
            }));
    if (response.statusCode == 200 ||
        response.statusCode == 400 ||
        response.statusCode == 500)
      return FutureResponse.fromJson(jsonDecode(response.body));
    else
      return null;
  }

  Future<List<AvailableCourses>> getAvailableCourses() async {
    final http.Response response =
        await http.get(ipAddress + "/api/student/all");

    if (response.statusCode == 200) {
      var jsonRes = jsonDecode(response.body);
      int length = jsonRes.length;
      //print(length);

      List<AvailableCourses> availableCoursesList = [];
      int i = 0;
      while (i < length) {
        var courses = jsonRes[i];
        availableCoursesList.add(AvailableCourses(
            courses['_id'],
            courses['course_code'],
            courses['name'],
            courses['admin_id'],
            courses['sessioncount'],
            courses['session'],
            courses['allowEnroll'],
            courses['course_id']));

        //print(availableCoursesList[i].courseName);
        i++;
      }
      print(availableCoursesList[0].courseId);
      return availableCoursesList;
    } else {
      throw Exception('Failed to get available courses');
    }
  }

  Future<List<EnrolledList>> getEnrolledCourses(String id) async {
    final http.Response response =
        await http.get(ipAddress + "/api/student/home/" + id);

    if (response.statusCode == 200) {
      var jsonRes = jsonDecode(response.body);
      int length = jsonRes['Id'].length;

      List<EnrolledList> enrolled = [];
      int i = 0;

      while (i < length) {
        var attendance = jsonRes['attendance'][i];
        if (attendance == null) {
          attendance = 0;
        }
        enrolled.add(EnrolledList(
            jsonRes['Id'][i], jsonRes['names'][i], attendance.toDouble()));
        i++;
      }
      return enrolled;
    } else {
      throw Exception('Failed to get available courses');
    }
  }

  Future<String> enroll(String cid, String code) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String sid = prefs.getString("id");
    final http.Response response =
        await http.post(ipAddress + "/api/student/enroll/$sid/$cid/$code");

    if (response.statusCode == 200) {
      var jsonRes = jsonDecode(response.body);

      if (jsonRes['success'] == true) {
        return "true";
      } else {
        return jsonRes['message'];
      }
    } else {
      throw Exception('Failed to get available courses');
    }
  }
}

saveValue(String key, String idValue) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString(key, idValue);
}
