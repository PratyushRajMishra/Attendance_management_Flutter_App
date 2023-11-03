import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class AddStudentController extends GetxController {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController rollNumberController = TextEditingController();
  final TextEditingController classController = TextEditingController();
  final TextEditingController sectionController = TextEditingController();

  void addStudentToFirestore() {
    final String studentName = nameController.text;
    final String rollNumber = rollNumberController.text;
    final String studentClass = classController.text;
    final String section = sectionController.text;

    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid;

    // Add student data to Firestore
    FirebaseFirestore.instance.collection('students_data').add({
      'userId': userId,
      'name': studentName,
      'rollNumber': rollNumber,
      'class': studentClass,
      'section': section,
    }).then((value) {
      print('Student data added to Firestore with ID: ${value.id}');

      // Clear the text fields after successful addition
      nameController.clear();
      rollNumberController.clear();
      classController.clear();
      sectionController.clear();

      Get.back(); // Close the bottom sheet

    }).catchError((error) {
      print('Error adding student data to Firestore: $error');
    });
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    rollNumberController.dispose();
    classController.dispose();
    sectionController.dispose();
  }
}

class AddStudentPage extends StatelessWidget {


  Stream<QuerySnapshot>? getTasksStream() {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid;

    if (userId != null) {
      return FirebaseFirestore.instance
          .collection('students_data')
          .where('userId', isEqualTo: userId)
          .snapshots();
    }

    return null;
  }

  final AddStudentController controller = Get.put(AddStudentController());

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Add Student",
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Colors.deepPurple,
          leading: BackButton(
            color: Colors.white,
            onPressed: () {
              Get.back();
            },
          ),
        ),
        body:Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: getTasksStream(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    final students = snapshot.data!.docs;
                    if (students.isEmpty) {
                      return Center(child: Text(textAlign: TextAlign.center,'No students found. \n Click on + button to add Students'));
                    }

                    return ListView.builder(
                      itemCount: students.length,
                      itemBuilder: (context, index) {
                        var student = students[index];
                        String studentName = student['name'] ?? 'N/A';
                        String avatarText = studentName.isNotEmpty ? studentName[0] : 'N'; // Get the first letter or use 'N' as default


                        return Container(
                          margin: EdgeInsets.fromLTRB(10, 15, 10, 0),
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.blue)
                          ),
                          child: ListTile(
                            tileColor: Colors.white,
                            title: Row(
                              children: [
                                CircleAvatar(
                                  child: Text(avatarText, style: TextStyle(color: Colors.white)),
                                  backgroundColor: Colors.blueAccent,
                                ),
                                SizedBox(width: 10), // Adjust the spacing between CircleAvatar and title
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(studentName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1.0),),
                                    Text('Roll Number: ${student['rollNumber'] ?? 'N/A'}', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 14),),
                                  ],
                                ),
                              ],
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Class ${student['class'] ?? 'N/A'}', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),),
                                Text('Section ${student['section'] ?? 'N/A'}', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),),
                              ],
                            ),
                          ),

                        );
                      },
                    );

                  }
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Get.bottomSheet(
              SingleChildScrollView(
                child: Container(
                  decoration: BoxDecoration(color: Colors.white),
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("Add Student"),
                      TextField(
                        controller: controller.nameController,
                        decoration: InputDecoration(labelText: "Student Name"),
                      ),
                      TextField(
                        controller: controller.rollNumberController,
                        decoration: InputDecoration(labelText: "Roll Number"),
                      ),
                      TextField(
                        controller: controller.classController,
                        decoration: InputDecoration(labelText: "Class"),
                      ),
                      TextField(
                        controller: controller.sectionController,
                        decoration: InputDecoration(labelText: "Section"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          controller.addStudentToFirestore();
                        },
                        child: Text("Add"),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          backgroundColor: Colors.blueAccent,
          label: Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}
