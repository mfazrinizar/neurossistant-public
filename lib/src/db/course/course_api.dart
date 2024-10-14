import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class CoursesData {
  final String courseId;
  final DateTime dateTime;
  final String titleEn;
  final String titleId;
  final String descriptionEn;
  final String descriptionId;
  final int popularity;
  final String psychologist;
  final String psychologistId;
  final int durations;
  final int sessions;
  final String tag;
  final String imageUrl;

  CoursesData({
    required this.courseId,
    required this.titleEn,
    required this.titleId,
    required this.descriptionEn,
    required this.descriptionId,
    required this.dateTime,
    required this.popularity,
    required this.psychologist,
    required this.psychologistId,
    required this.durations,
    required this.sessions,
    required this.tag,
    required this.imageUrl,
  });

  factory CoursesData.fromMap(Map<String, dynamic> data) {
    return CoursesData(
      courseId: data['courseId'],
      titleEn: data['title']['en'],
      titleId: data['title']['id'],
      descriptionEn: data['description']['en'],
      descriptionId: data['description']['id'],
      dateTime: (data['dateTime'] as Timestamp).toDate(),
      popularity: data['popularity'],
      psychologist: data['psychologist'],
      psychologistId: data['psychologistId'],
      durations: data['durations'],
      sessions: data['sessions'],
      tag: data['tag'],
      imageUrl: data['imageUrl'],
    );
  }
}

class CourseApi {
  static final _firestore = FirebaseFirestore.instance;

  // Fetch all courses
  static Future<List<CoursesData>> fetchCourses() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('courses').get();
      return snapshot.docs.map((doc) {
        // Creating a new map without subcollection references
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return CoursesData.fromMap(data);
      }).toList();
    } catch (e) {
      if (kDebugMode) debugPrint('Error fetching courses: $e');
      return [];
    }
  }

  static Future<String> fetchUserType() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return 'Parent';
    }

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    return doc.data()?['userType'] ?? 'Parent';
  }
}
