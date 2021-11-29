// import 'package:fugstudent/screens/StudentRegisterScreen.dart';
// import 'package:flutter/material.dart';
// import 'package:fugstudent/HandleNetworking.dart';
// import 'package:fugstudent/components/ReusableButton.dart';
// import 'package:fugstudent/services/facenet.service.dart';

// class AuthActionButton extends StatefulWidget {
//   AuthActionButton(this._initializeControllerFuture,
//       {Key key, @required this.onPressed, @required this.isLogin, this.reload});
//   final Future _initializeControllerFuture;
//   final Function onPressed;
//   final bool isLogin;
//   final Function reload;
//   @override
//   _AuthActionButtonState createState() => _AuthActionButtonState();
// }

// class _AuthActionButtonState extends State<AuthActionButton> {
//   /// service injection
//   final FaceNetService _faceNetService = FaceNetService();
//   final HandleNetworking handleNetworking = HandleNetworking();

//   Future _signUp(context) async {
//     /// gets predicted data from facenet service (user face detected)
//     List predictedData = _faceNetService.predictedData;

//     /// resets the face stored in the face net sevice
//     this._faceNetService.setPredictedData(null);
//     if (predictedData.length != 0) {
//       Navigator.push(
//           context,
//           MaterialPageRoute(
//               builder: (BuildContext context) =>
//                   StudentRegisterScreen(features: predictedData)));
//     } else {
//       Navigator.pushNamed(
//         context,
//         '/auth_home',
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: () async {
//         try {
//           // Ensure that the camera is initialized.
//           await widget._initializeControllerFuture;
//           // onShot event (takes the image and predict output)
//           bool faceDetected = await widget.onPressed();

//           if (faceDetected) {
//             PersistentBottomSheetController bottomSheetController =
//                 Scaffold.of(context)
//                     .showBottomSheet((context) => signSheet(context));
//             bottomSheetController.closed.whenComplete(() => widget.reload());
//           }
//         } catch (e) {
//           // If an error occurs, log the error to the console.
//           print(e);
//         }
//       },
//       child: ReusableButton("CAPTURE"),
//     );
//   }

//   signSheet(context) {
//     return Container(
//       padding: EdgeInsets.all(50),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Container(
//             child: Column(
//               children: [
//                 GestureDetector(
//                   child: ReusableButton('Continue'),
//                   onTap: () async {
//                     await _signUp(context);
//                   },
//                 ),
//                 SizedBox(
//                   height: 15.0,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     super.dispose();
//   }
// }
