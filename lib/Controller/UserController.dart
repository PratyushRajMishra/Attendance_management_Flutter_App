import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:attendance_system/utils/UserModel.dart';

class UserController extends GetxController {
  final Rx<UserModel?> userModel = Rx<UserModel?>(null);
  final Rx<User?> firebaseUser = Rx<User?>(null);

  void setUser(UserModel user, User firebaseUser) {
    userModel.value = user;
    this.firebaseUser.value = firebaseUser;
  }
}
