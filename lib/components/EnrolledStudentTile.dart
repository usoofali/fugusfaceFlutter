import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

class EnrolledStudentTile extends StatelessWidget {
  final String enrolledStudentUsername;
  final String enrolledStudentRegno;
  final String enrolledStudentName;
  final double attendanceRatio;

  EnrolledStudentTile(this.enrolledStudentName, this.enrolledStudentRegno,
      this.enrolledStudentUsername, this.attendanceRatio);
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(Icons.account_circle_rounded),
        title: Text(enrolledStudentName),
        subtitle: Text(enrolledStudentRegno),
        trailing: CircularPercentIndicator(
          radius: 50.0,
          lineWidth: 6.0,
          animation: true,
          percent: attendanceRatio,
          center: Text(
            (attendanceRatio * 100).toStringAsPrecision(3) + "%",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10.0),
          ),
          circularStrokeCap: CircularStrokeCap.round,
          progressColor: Colors.teal,
        ),
      ),
    );
  }
}
