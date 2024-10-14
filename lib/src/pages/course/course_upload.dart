import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:neurossistant/src/db/course/course_upload_api.dart';
import 'package:neurossistant/src/homepage.dart';
import 'package:neurossistant/src/pages/course/add_post_test_question.dart';
import 'package:neurossistant/src/pages/course/add_pre_test_question.dart';
import 'package:neurossistant/src/pages/course/add_session.dart';

class UploadCoursePage extends StatefulWidget {
  const UploadCoursePage({Key? key}) : super(key: key);

  @override
  State<UploadCoursePage> createState() => _UploadCoursePageState();
}

class _UploadCoursePageState extends State<UploadCoursePage> {
  final TextEditingController nameEnController = TextEditingController();
  final TextEditingController nameIdController = TextEditingController();
  final TextEditingController descriptionEnController = TextEditingController();
  final TextEditingController descriptionIdController = TextEditingController();
  final TextEditingController tagController = TextEditingController();
  final List<Map<String, dynamic>> preTestQuestions = [];
  final List<Map<String, dynamic>> postTestQuestions = [];
  final List<Map<String, dynamic>> sessions = [];

  void _addPreTestQuestion(Map<String, dynamic> question) {
    setState(() {
      preTestQuestions.add(question);
    });
  }

  void _addPostTestQuestion(Map<String, dynamic> question) {
    setState(() {
      postTestQuestions.add(question);
    });
  }

  void _addSession(Map<String, dynamic> session) {
    setState(() {
      sessions.add(session);
    });
  }

  Future<void> uploadCourse() async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      CollectionReference courses =
          FirebaseFirestore.instance.collection('courses');

      await courses.add({
        'name': {
          'en': nameEnController.text,
          'id': nameIdController.text,
        },
        'description': {
          'en': descriptionEnController.text,
          'id': descriptionIdController.text,
        },
        'pretest': preTestQuestions,
        'posttest': postTestQuestions,
        'sessions': sessions,
        'tag': tagController.text,
        'authorId': uid,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      Get.snackbar('Success', 'Course uploaded successfully!');
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (kDebugMode) debugPrint(e.toString());
      Get.snackbar('Success', 'Course uploaded successfully!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            Get.offAll(() => const HomePage(
                  indexFromPrevious: 2,
                ));
          },
        ),
        title: const Text('Upload Course'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextFormField(
                controller: nameEnController,
                decoration:
                    const InputDecoration(labelText: 'Course Name (EN)'),
              ),
              TextFormField(
                controller: nameIdController,
                decoration:
                    const InputDecoration(labelText: 'Course Name (ID)'),
              ),
              TextFormField(
                controller: descriptionEnController,
                decoration:
                    const InputDecoration(labelText: 'Description (EN)'),
              ),
              TextFormField(
                controller: descriptionIdController,
                decoration:
                    const InputDecoration(labelText: 'Description (ID)'),
              ),
              TextFormField(
                controller: tagController,
                decoration: const InputDecoration(labelText: 'Tag'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddPreTestQuestionPage(
                          onAddQuestion: _addPreTestQuestion),
                    ),
                  );
                },
                child: const Text('Add Pre-Test Question'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddPostTestQuestionPage(
                          onAddQuestion: _addPostTestQuestion),
                    ),
                  );
                },
                child: const Text('Add Post-Test Question'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AddSessionPage(onAddSession: _addSession),
                    ),
                  );
                },
                child: const Text('Add Session'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  CourseUploadApi.uploadCourseData();
                },
                child: const Text('Upload Course'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
