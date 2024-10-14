import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class Test {
  final String id;
  final String title;
  final List<TestQuestion> questions;
  final bool isPreTest;

  Test({
    required this.id,
    required this.title,
    required this.questions,
    required this.isPreTest,
  });

  // Adjusted factory constructor to include isPreTest as a parameter
  static Test fromMap(Map<String, dynamic> map, bool isPreTest) {
    return Test(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      isPreTest: isPreTest,
      questions: (map[isPreTest ? 'preTest' : 'postTest']['questions'] as List?)
              ?.map((question) =>
                  TestQuestion.fromMap(question as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class TestQuestion {
  final Map<String, String> questionText;
  final List<Map<String, String>> options;
  final String correctAnswer;
  int userAnswerIndex;

  TestQuestion(
      {required this.questionText,
      required this.options,
      required this.correctAnswer,
      this.userAnswerIndex = -1});

  factory TestQuestion.fromMap(Map<String, dynamic> map) {
    return TestQuestion(
      questionText: {
        'en': (map['question'] as Map<String, dynamic>)['en'] as String? ?? '',
        'id': (map['question'] as Map<String, dynamic>)['id'] as String? ?? '',
      },
      options: (map['options'] as Map<String, dynamic>)
          .entries
          .map((entry) => {
                'key': entry.key,
                'en': (entry.value as Map<String, dynamic>)['en'] as String? ??
                    '',
                'id': (entry.value as Map<String, dynamic>)['id'] as String? ??
                    '',
              })
          .toList(),
      correctAnswer: map['correctAnswer'] as String? ?? '',
    );
  }

  int get correctAnswerIndex {
    return options.indexWhere((option) => option['key'] == correctAnswer);
  }

  String get questionEn {
    return questionText['en'] ?? '';
  }

  String get questionId {
    return questionText['id'] ?? '';
  }

  List<String> get choicesEn {
    return options.map((option) => option['en'] ?? '').toList();
  }

  List<String> get choicesId {
    return options.map((option) => option['id'] ?? '').toList();
  }
}

class SelectedCourseTestApi {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Test?> fetchPreTest(String courseId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('courses')
          .doc(courseId)
          .collection('contents')
          .doc('preTest')
          .get();
      debugPrint(doc.data().toString());
      if (doc.exists) {
        if (kDebugMode) {
          debugPrint(Test.fromMap(doc.data() as Map<String, dynamic>, true)
              .toString());
        }
        return Test.fromMap(doc.data() as Map<String, dynamic>, true);
      } else {
        if (kDebugMode) debugPrint('Pre-test not found');
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error fetching pre-test: $e');
      }
      return null;
    }
  }

  Future<Test?> fetchPostTest(String courseId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('courses')
          .doc(courseId)
          .collection('contents')
          .doc('postTest')
          .get();
      debugPrint(doc.data().toString());
      if (doc.exists) {
        if (kDebugMode) {
          debugPrint(Test.fromMap(doc.data() as Map<String, dynamic>, false)
              .toString());
        }
        return Test.fromMap(doc.data() as Map<String, dynamic>, false);
      } else {
        if (kDebugMode) debugPrint('Pre-test not found');
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error fetching pre-test: $e');
      }
      return null;
    }
  }
}
