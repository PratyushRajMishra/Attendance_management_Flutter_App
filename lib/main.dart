import 'package:attendance_system/utils/FirebaseHelper.dart';
import 'package:attendance_system/utils/UserModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import 'Controller/UserController.dart';
import 'Screens/home.dart';
import 'Screens/login.dart';
import 'firebase_options.dart';

var uuid = Uuid();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final userController = UserController(); // Create UserController

  User? currentUser = FirebaseAuth.instance.currentUser;

  if (currentUser != null) {
    // User is logged in
    UserModel? thisUserModel = await FirebaseHelper.getUserModelById(currentUser.uid);

    if (thisUserModel != null) {
      userController.setUser(thisUserModel, currentUser);
    }
  }

  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: Obx(() {
        if (userController.userModel.value != null) {
          return HomePage(
            userModel: userController.userModel.value!,
            firebaseUser: userController.firebaseUser.value!,
          );
        } else {
          return LoginPage();
        }
      }),
    ),
  );
}
