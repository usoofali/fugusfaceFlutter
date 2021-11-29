import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class EnrolledList extends StatelessWidget {
  final String id;
  final String name;
  final double attendance;

  EnrolledList(this.id, this.name, this.attendance);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(Icons.library_books),
        title: Text(id),
        subtitle: Text(name),
        trailing: CircularPercentIndicator(
          radius: 50.0,
          lineWidth: 6.0,
          animation: true,
          percent: attendance,
          center: Text(
            (attendance * 100).toStringAsFixed(2) + "%",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10.0),
          ),
          circularStrokeCap: CircularStrokeCap.round,
          progressColor: Colors.teal,
        ),
        // onTap: () {
        //   createAlertDialogue(context).then((value) async {
        //     String enrollStatus = await HandleNetworking().attend(id, value);
        //     if (enrollStatus.toString() == "true") {
        //       SnackBar newSnackbar = SnackBar(
        //         content: Text("You Successfully marked Attendance for $name"),
        //         padding: EdgeInsets.only(bottom: 7.0, top: 7.0),
        //       );
        //       ScaffoldMessenger.of(context).showSnackBar(newSnackbar);
        //     } else if (value != null) {
        //       SnackBar newSnackbar = SnackBar(
        //         content: Text("Error: " + enrollStatus.toString()),
        //         padding: EdgeInsets.only(bottom: 7.0, top: 7.0),
        //       );
        //       ScaffoldMessenger.of(context).showSnackBar(newSnackbar);
        //     }
        //   });
        // },
      ),
    );
  }
}
