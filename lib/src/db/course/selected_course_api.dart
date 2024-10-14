import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class SelectedCourseApi {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _user = FirebaseAuth.instance.currentUser;

  // Upload a new course
  Future<void> uploadCourse(Map<String, dynamic> courseData) async {
    try {
      await _firestore.collection('courses').add(courseData);
      if (kDebugMode) debugPrint('Course uploaded successfully');
    } catch (e) {
      if (kDebugMode) debugPrint('Error uploading course: $e');
    }
  }

  // Fetch a specific course by ID
  Future<Map<String, dynamic>?> fetchCourseById(String courseId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('courses').doc(courseId).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      } else {
        if (kDebugMode) debugPrint('Course not found');
        return null;
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error fetching course: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> fetchCourseByPsychologistId(
      String psychologistId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('courses')
          .where('psychologistId', isEqualTo: psychologistId)
          .get();
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first.data() as Map<String, dynamic>;
      } else {
        if (kDebugMode) debugPrint('Course not found');
        return null;
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error fetching course: $e');
      return null;
    }
  }

  Future<bool?> isUserRegistered(String courseId, String userId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('courses')
          .doc(courseId)
          .collection('users')
          .doc(userId)
          .get();
      return doc.exists;
    } catch (e) {
      if (kDebugMode) debugPrint('Error checking user registration: $e');
      return null;
    }
  }

  Future<bool?> registerUser(String courseId, String userId) async {
    try {
      await _firestore
          .collection('courses')
          .doc(courseId)
          .collection('users')
          .doc(userId)
          .set({
        'registeredAt': DateTime.now(),
        'userName': _user != null ? _user.displayName : 'Unknown'
      });

      await _firestore.collection('courses').doc(courseId).update({
        'popularity': FieldValue.increment(1),
      });
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('Error registering user: $e');
      return null;
    }
  }

  Future<UserProgress?> fetchUserProgress(
      String courseId, String userId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('courses')
          .doc(courseId)
          .collection('users')
          .doc(userId)
          .get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        Map<String, dynamic> progressData =
            data['progress'] as Map<String, dynamic>;
        return UserProgress.fromMap(progressData);
      } else {
        if (kDebugMode) debugPrint('User progress not found');
        return null;
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error fetching user progress: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> fetchUserTestAndTaskResults(
      String courseId) async {
    try {
      QuerySnapshot userDocsSnapshot = await _firestore
          .collection('courses')
          .doc(courseId)
          .collection('users')
          .get();

      List<Map<String, dynamic>> userResults = [];

      for (var userDoc in userDocsSnapshot.docs) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

        Map<String, dynamic> userResult = {
          'userId': userDoc.id,
          'preTestResult': userData['preTestResult'],
          'postTestResult': userData['postTestResult'],
          'progress': userData['progress'],
          'sessionsCompletion': userData['sessionsCompletion'],
          'taskSubmissions': userData['taskSubmissions'],
          'registeredAt': userData['registeredAt'],
          'evaluations': userData['evaluations'],
          'lastEvaluatedAt': userData['lastEvaluatedAt'],
          'userName': userData['userName'],
        };

        userResults.add(userResult);
      }

      if (kDebugMode) debugPrint(userResults.toString());

      return userResults;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error fetching user test and task results: $e');
      }
      return [];
    }
  }
}

class UserProgress {
  final bool isPreTestDone;
  final bool isSessionsDone;
  final bool isPostTestDone;
  final bool isEvaluated;

  UserProgress({
    required this.isPreTestDone,
    required this.isSessionsDone,
    required this.isPostTestDone,
    required this.isEvaluated,
  });

  factory UserProgress.fromMap(Map<String, dynamic> map) {
    return UserProgress(
      isPreTestDone: map['isPreTestDone'] ?? false,
      isSessionsDone: map['isSessionsDone'] ?? false,
      isPostTestDone: map['isPostTestDone'] ?? false,
      isEvaluated: map['isEvaluated'] ?? false,
    );
  }
}
