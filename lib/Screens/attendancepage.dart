import 'package:attendance_system/Screens/student_data.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AttendanceController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Rx<Stream<QuerySnapshot>> studentDataStream = Rx(Stream.empty());
  final RxMap<String, String> studentAttendanceState = RxMap();
  final List<Map<String, String>> pendingAttendanceUpdates = [];
  DateTime selectedDate = DateTime.now();

  void loadStudentDataStream(String userId) {
    studentDataStream.value = _firestore
        .collection('students_data')
        .where('userId', isEqualTo: userId)
        .snapshots();
  }

  void markAttendance(
      String studentId, String attendanceState, DateTime selectedDate) {
    DocumentReference studentAttendanceRef = _firestore
        .collection('students_data')
        .doc(studentId)
        .collection('attendance')
        .doc(formatDate(selectedDate));

    studentAttendanceRef.set({'attendanceState': attendanceState}).then((_) {
      studentAttendanceState[studentId] = attendanceState;
    }).catchError((error) {
      print("Error updating attendance data: $error");
    });

    pendingAttendanceUpdates.add({
      'studentId': studentId,
      'attendanceState': attendanceState,
    });
  }

  void submitAttendance() {
    for (final update in pendingAttendanceUpdates) {
      final studentId = update['studentId'];
      final attendanceState = update['attendanceState'];

      DocumentReference studentAttendanceRef = _firestore
          .collection('students_data')
          .doc(studentId)
          .collection('attendance')
          .doc(formatDate(selectedDate));

      studentAttendanceRef.set({'attendanceState': attendanceState}).then((_) {
        studentAttendanceState[studentId.toString()] = attendanceState!;
      }).catchError((error) {
        print("Error updating attendance data: $error");
      });
    }

    pendingAttendanceUpdates.clear();
  }

  String formatDate(DateTime date) {
    return date.toLocal().toString().split(' ')[0];
  }

  @override
  void onInit() {
    super.onInit();
  }
}

class AttendancePage extends StatefulWidget {
  @override
  _AttendancePageState createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  final AttendanceController controller = Get.put(AttendanceController());

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: controller.selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != controller.selectedDate) {
      // Clear the pending attendance updates and studentAttendanceState
      controller.pendingAttendanceUpdates.clear();
      controller.studentAttendanceState.clear();

      setState(() {
        // Update the selected date if a date is picked
        controller.selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid;

    if (userId != null) {
      controller.loadStudentDataStream(userId);
    }

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.blue.shade50,
        appBar: AppBar(
          title: Text(
            "Attendance",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
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
        floatingActionButton: Align(
          alignment: Alignment.bottomCenter,
          child: FloatingActionButton.extended(
            backgroundColor: Colors.blue,
            onPressed: () {
              controller.submitAttendance();
            },
            label: Text(
              "   Submit   ",
              style: TextStyle(fontSize: 18),
            ),
          ),
        ),
        body: Obx(() {
          final studentDataStream = controller.studentDataStream.value;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GestureDetector(
                      onTap: () {
                        _selectDate(context);
                      },
                      child: Container(
                        height: 40,
                        width: 150,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue),
                          color: Colors.white,
                        ),
                        child: Center(
                          child: Text(
                            controller.formatDate(controller.selectedDate),
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: 40,
                      width: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue),
                        color: Colors.white,
                      ),
                      child: Center(
                        child: Text(
                          "Select Class",
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: studentDataStream,
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      final students = snapshot.data!.docs;
                      if (students.isEmpty) {
                        return Center(child: Text('No students found.'));
                      }

                      return ListView.builder(
                        itemCount: students.length,
                        itemBuilder: (context, index) {
                          var student = students[index];
                          String studentId = student.id;
                          String studentName = student['name'] ?? 'N/A';
                          String avatarText =
                              studentName.isNotEmpty ? studentName[0] : 'N';

                          return Obx(() {
                            String attendanceState =
                                controller.studentAttendanceState[studentId] ??
                                    '';

                            Color presentButtonColor =
                                attendanceState == 'Present'
                                    ? Colors.green
                                    : Colors.white;
                            Color absentButtonColor =
                                attendanceState == 'Absent'
                                    ? Colors.red
                                    : Colors.white;
                            Color leaveButtonColor = attendanceState == 'Leave'
                                ? Colors.black
                                : Colors.white;

                            return GestureDetector(
                              onTap: () {
                                Get.to(
                                  StudentDataPage(
                                      studentId:
                                          studentId), // Pass the studentId
                                );
                              },
                              child: Container(
                                margin: EdgeInsets.fromLTRB(10, 15, 10, 0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  border: Border.all(color: Colors.blue),
                                ),
                                child: ListTile(
                                  tileColor: Colors.white,
                                  title: Row(
                                    children: [
                                      CircleAvatar(
                                        child: Text(avatarText,
                                            style:
                                                TextStyle(color: Colors.white)),
                                        backgroundColor: Colors.blueAccent,
                                      ),
                                      SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            studentName,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              letterSpacing: 1.0,
                                            ),
                                          ),
                                          Text(
                                            'Roll Number: ${student['rollNumber'] ?? 'N/A'}',
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  subtitle: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(5, 8, 5, 6),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () {
                                            controller.markAttendance(
                                                studentId,
                                                'Present',
                                                controller.selectedDate);
                                          },
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all<
                                                    Color>(presentButtonColor),
                                            shape: MaterialStateProperty.all<
                                                RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                side: BorderSide(
                                                    color: Colors.blue),
                                              ),
                                            ),
                                          ),
                                          child: Text("Present",
                                              style: TextStyle(
                                                color:
                                                    attendanceState == 'Present'
                                                        ? Colors.white
                                                        : Colors.grey,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                              )),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            controller.markAttendance(
                                                studentId,
                                                'Absent',
                                                controller.selectedDate);
                                          },
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all<
                                                    Color>(absentButtonColor),
                                            shape: MaterialStateProperty.all<
                                                RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                side: BorderSide(
                                                    color: Colors.blue),
                                              ),
                                            ),
                                          ),
                                          child: Text("Absent",
                                              style: TextStyle(
                                                color:
                                                    attendanceState == 'Absent'
                                                        ? Colors.white
                                                        : Colors.grey,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                              )),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            controller.markAttendance(
                                                studentId,
                                                'Leave',
                                                controller.selectedDate);
                                          },
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all<
                                                    Color>(leaveButtonColor),
                                            shape: MaterialStateProperty.all<
                                                RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                side: BorderSide(
                                                    color: Colors.blue),
                                              ),
                                            ),
                                          ),
                                          child: Text("Leave",
                                              style: TextStyle(
                                                color:
                                                    attendanceState == 'Leave'
                                                        ? Colors.white
                                                        : Colors.grey,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                              )),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          });
                        },
                      );
                    }
                  },
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

void main() {
  runApp(GetMaterialApp(
    debugShowCheckedModeBanner: false,
    home: AttendancePage(),
  ));
}
