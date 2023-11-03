import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentDataPage extends StatefulWidget {
  final String studentId;

  const StudentDataPage({Key? key, required this.studentId}) : super(key: key);

  @override
  State<StudentDataPage> createState() => _StudentDataPageState();
}

class _StudentDataPageState extends State<StudentDataPage> {
  String studentName = '';
  String className = '';
  String section = '';
  String rollNumber = '';

  @override
  void initState() {
    super.initState();
    // Fetch student data and attendance data from Firebase Firestore.
    fetchStudentData(widget.studentId);
  }

  List<Map<String, String>> attendanceData = [];
  int presentCount = 0;
  int absentCount = 0;
  int leaveCount = 0;

  void fetchStudentData(String studentId) {
    FirebaseFirestore.instance
        .collection('students_data')
        .doc(studentId)
        .get()
        .then((DocumentSnapshot studentSnapshot) {
      if (studentSnapshot.exists) {
        setState(() {
          studentName = studentSnapshot['name'];
          className = studentSnapshot['class'];
          rollNumber = studentSnapshot['rollNumber'];
          section = studentSnapshot['section'];
        });

        // Fetch attendance data for the current week (use the current week as the document ID).
        FirebaseFirestore.instance
            .collection('students_data')
            .doc(studentId)
            .collection('attendance')
            .get()
            .then((QuerySnapshot attendanceSnapshot) {
          if (attendanceSnapshot.docs.isNotEmpty) {
            // Handle attendance data, e.g., store it in a list of maps.
            attendanceData = attendanceSnapshot.docs
                .map((doc) => {
              'date': doc.id,
              'attendance': doc['attendanceState'].toString(),
            })
                .toList();

            // Count attendance states
            presentCount = attendanceData.where((entry) => entry['attendance'] == 'Present').length;
            absentCount = attendanceData.where((entry) => entry['attendance'] == 'Absent').length;
            leaveCount = attendanceData.where((entry) => entry['attendance'] == 'Leave').length;
          } else {
            print('Attendance data does not exist for this student.');
          }
          // Update the UI to reflect the fetched data.
          setState(() {});
        }).catchError((error) {
          print('Error fetching attendance data: $error');
        });
      } else {
        print('Student document does not exist on Firestore');
      }
    }).catchError((error) {
      print('Error fetching student data from Firestore: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.blue.shade50,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(200),
          child: Container(
            color: Colors.blue.shade600,
            padding: EdgeInsets.only(top: 24),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: Icon(Icons.arrow_back),
                    ),
                    SizedBox(width: 25),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          studentName,
                          style: TextStyle(
                            fontSize: 30,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Class- $className '$section",
                          style: TextStyle(
                            fontSize: 22,
                            color: Colors.white70,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Roll: $rollNumber",
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 22,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 30),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                  ),
                  height: 50,
                  width: double.infinity,
                  child: Center(
                    child: Text(
                      "Your attendance this week",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: Center(
          child: ListView.builder(
            itemCount: attendanceData.length >= 7 ? 8 : attendanceData.length + 1, // Update item count
            itemBuilder: (context, index) {
              if (index == 7) {
                return ListTile(
                  title: Text("Present: $presentCount, Absent: $absentCount, Leave: $leaveCount"),
                );
              } else if (index < attendanceData.length) {
                final date = attendanceData[index]['date'];
                final attendanceState = attendanceData[index]['attendance'];

                String displayText;
                Color textColor;

                if (attendanceState != null) {
                  if (attendanceState == 'Present') {
                    displayText = 'P';
                    textColor = Colors.green;
                  } else if (attendanceState == 'Absent') {
                    displayText = 'A';
                    textColor = Colors.red;
                  } else if (attendanceState == 'Leave') {
                    displayText = 'L';
                    textColor = Colors.black;
                  } else {
                    displayText = 'N/A';
                    textColor = Colors.black;
                  }
                } else {
                  displayText = 'N/A';
                  textColor = Colors.black;
                }

                return Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey,
                        width: 1.0,
                      ),
                    ),
                  ),
                  child: ListTile(
                    tileColor: Colors.white,
                    title: Text(
                      date != null ? date : 'N/A',
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    trailing: Text(
                      displayText,
                      style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontSize: 22),
                    ),
                  ),
                );
              }
            },
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.check, color: Colors.green),
              label: 'Present: $presentCount',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.close, color: Colors.red),
              label: 'Absent: $absentCount',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.file_copy, color: Colors.black),
              label: 'Leave: $leaveCount',
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: StudentDataPage(studentId: 'YOUR_STUDENT_ID'), // Replace with the actual student ID
  ));
}
