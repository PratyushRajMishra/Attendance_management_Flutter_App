import 'package:attendance_system/Screens/attendancepage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import '../utils/UserModel.dart';
import 'addStudent.dart';
import 'login.dart';

class HomePage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;// Pass UserModel as a parameter
  const HomePage({Key? key, required this.userModel, required this.firebaseUser}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  UserModel? _userModel;

  @override
  void initState() {
    super.initState();
    _userModel = widget.userModel; // Use the provided UserModel
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Attendance Management',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22, letterSpacing: 1.0)),
          centerTitle: true,
          backgroundColor: Colors.blue,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(

              children: [
                if (_userModel != null)
                  Column(
                    children: [
                      SizedBox(height: 80,),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(100.0),
                        child: CachedNetworkImage(
                          imageUrl: widget.userModel.profilepic.toString(),
                          width: 150,
                          height: 150,
                          fit: BoxFit.fill,
                          errorWidget: (context, url, error) {
                            // Handle errors here, for example, display a default image or show an error message.
                            return CircleAvatar(
                              child: Icon(CupertinoIcons.person, color: Colors.white),
                            );
                          },
                          placeholder: (context, url) {
                            // You can also add a placeholder image while the image is loading.
                            return CircularProgressIndicator(color: Colors.white54,); // or any other loading indicator.
                          },
                        ),
                      ),
                      SizedBox(height: 10,),
                      Text('Welcome, ${_userModel!.fullname}', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      SizedBox(height: 5,),
                      Text('Email: ${_userModel!.email}', style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                      SizedBox(height: 5,),
                      Text('Mobile: ${_userModel!.mobile}', style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ],
                  ),
                SizedBox(height: 50,),
                Container(
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.blue), // Change the color here
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return AddStudentPage(); // Replace 'AddStudentPage()' with the actual widget of your "AddStudentPage"
                          },
                        ),
                      );

                    },
                    child: Text(
                      "Add Student",
                      style: TextStyle(color: Colors.white), // Change the text color
                    ),
                  ),
                ),

                SizedBox(height: 20,),
                Container(
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.green), // Change the color here
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return AttendancePage(); // Replace 'AddStudentPage()' with the actual widget of your "AddStudentPage"
                          },
                        ),
                      );
                    },
                    child: Text("Take Attendance", style: TextStyle(color: Colors.white),),
                  ),
                ),
                SizedBox(height: 20,),
                Container(
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.red.shade100),
                    ),
                    onPressed: () async {
                      try {
                        await FirebaseAuth.instance.signOut();
                        // After signing out, you can navigate to a login page or any other desired page.
                        // For example, navigate to the login page:
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()), // Replace with your login page widget
                        );
                      } catch (e) {
                        print("Error signing out: $e");
                        // Handle sign-out error, if any.
                      }
                    },
                    child: Text(
                      "Logout",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
