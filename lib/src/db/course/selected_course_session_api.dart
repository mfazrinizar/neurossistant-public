import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;

class SelectedCoursesData {
  final List<Session> sessions;

  SelectedCoursesData({required this.sessions});

  factory SelectedCoursesData.fromMap(Map<String, dynamic> map) {
    var sessionList = map['sessions'];
    return SelectedCoursesData(
      sessions: sessionList != null
          ? (sessionList as List)
              .map(
                  (session) => Session.fromMap(session as Map<String, dynamic>))
              .toList()
          : [],
    );
  }
}

class Session {
  final int sessionNumber;
  final Map<String, String> sessionTitle;
  final int duration;
  final List<Material> materials;
  final Task task;
  final List<Comment> commentsList;

  Session({
    required this.sessionNumber,
    required this.sessionTitle,
    required this.duration,
    required this.materials,
    required this.task,
    required this.commentsList,
  });

  factory Session.fromMap(Map<String, dynamic> map) {
    var materialsList = map['materials'];
    var commentsList = map['commentsList'];
    return Session(
      sessionNumber: map['sessionNumber'],
      sessionTitle: Map<String, String>.from(map['sessionTitle']),
      duration: map['duration'],
      materials: materialsList != null
          ? (materialsList as List)
              .map((material) =>
                  Material.fromMap(material as Map<String, dynamic>))
              .toList()
          : [],
      task: Task.fromMap(map['task'] as Map<String, dynamic>),
      commentsList: commentsList != null
          ? (commentsList as List)
              .map(
                  (comment) => Comment.fromMap(comment as Map<String, dynamic>))
              .toList()
          : [],
    );
  }
}

class Material {
  final String type;
  final Map<String, dynamic> content;

  Material({required this.type, required this.content});

  factory Material.fromMap(Map<String, dynamic> map) {
    return Material(
      type: map['type'],
      content: map['content'],
    );
  }
}

class Task {
  final Map<String, dynamic> description;
  final List<String> acceptedFileTypes;

  Task({required this.description, required this.acceptedFileTypes});

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      description: map['description'],
      acceptedFileTypes: List<String>.from(map['acceptedFileTypes']),
    );
  }
}

class Comment {
  final String avatarUrl;
  final DateTime commentDate;
  final String commentId;
  final String commenterId;
  final String commenterName;
  final String text;

  Comment(
      {required this.avatarUrl,
      required this.commentDate,
      required this.commentId,
      required this.commenterId,
      required this.commenterName,
      required this.text});

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      avatarUrl: map['avatarUrl'],
      commentDate: (map['commentDate'] as Timestamp).toDate(),
      commentId: map['commentId'],
      commenterId: map['commenterId'],
      commenterName: map['commenterName'],
      text: map['text'],
    );
  }
}

class SelectedCourseSessionApi {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<SelectedCoursesData?> fetchSessions(String courseId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('courses')
          .doc(courseId)
          .collection('contents')
          .doc('sessions')
          .get();
      if (doc.exists) {
        return SelectedCoursesData.fromMap(doc.data() as Map<String, dynamic>);
      } else {
        if (kDebugMode) debugPrint('Sessions not found');
        return null;
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error fetching sessions: $e');
      return null;
    }
  }

  Future<bool> addComment(
      String courseId, int sessionNumber, Comment comment) async {
    try {
      Map<String, dynamic> commentMap = {
        'avatarUrl': comment.avatarUrl,
        'commentDate':
            comment.commentDate, // Ensure DateTime is properly serialized
        'commentId': comment.commentId,
        'commenterId': comment.commenterId,
        'commenterName': comment.commenterName,
        'text': comment.text,
      };

      DocumentReference sessionsDoc = _firestore
          .collection('courses')
          .doc(courseId)
          .collection('contents')
          .doc('sessions');

      DocumentSnapshot snapshot = await sessionsDoc.get();
      if (!snapshot.exists) {
        // Initialize the document if it doesn't exist
        await sessionsDoc.set({'sessions': []});
        snapshot = await sessionsDoc
            .get(); // Re-fetch the snapshot after initialization
      }

      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      List<dynamic> sessions = data['sessions'] ?? [];
      // Find the session by sessionNumber instead of relying on the index
      var sessionIndex =
          sessions.indexWhere((s) => s['sessionNumber'] == sessionNumber);
      if (sessionIndex != -1) {
        List<dynamic> commentsList =
            sessions[sessionIndex]['commentsList'] ?? [];
        commentsList.add(commentMap);
        sessions[sessionIndex]['commentsList'] = commentsList;
        await sessionsDoc.update({'sessions': sessions});
        return true;
      } else {
        if (kDebugMode) debugPrint("Session number is out of range.");
        return false;
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error adding comment: $e');
      return false;
    }
  }

  Future<bool> deleteComment(
      String courseId, int sessionNumber, String commentId) async {
    try {
      DocumentReference sessionsDoc = _firestore
          .collection('courses')
          .doc(courseId)
          .collection('contents')
          .doc('sessions');

      DocumentSnapshot snapshot = await sessionsDoc.get();
      if (!snapshot.exists) {
        if (kDebugMode) debugPrint('Sessions document not found');
        return false;
      }

      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      List<dynamic> sessions = data['sessions'] ?? [];
      var sessionIndex =
          sessions.indexWhere((s) => s['sessionNumber'] == sessionNumber);
      if (sessionIndex != -1) {
        List<dynamic> commentsList =
            sessions[sessionIndex]['commentsList'] ?? [];
        var commentIndex = commentsList
            .indexWhere((comment) => comment['commentId'] == commentId);
        if (commentIndex != -1) {
          commentsList.removeAt(commentIndex);
          sessions[sessionIndex]['commentsList'] = commentsList;
          await sessionsDoc.update({'sessions': sessions});
          return true;
        } else {
          if (kDebugMode) debugPrint('Comment not found');
          return false;
        }
      } else {
        if (kDebugMode) debugPrint('Session number is out of range.');
        return false;
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error deleting comment: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> getUserSessionsProgress(
      String courseId, String userId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('courses')
          .doc(courseId)
          .collection('users')
          .doc(userId)
          .get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        if (kDebugMode) {
          debugPrint('User progress found: ${data['sessionsCompletion']}');
        }
        return data['sessionsCompletion'];
      } else {
        if (kDebugMode) debugPrint('User progress not found');
        return {};
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error fetching user progress: $e');
      return {};
    }
  }

  Future<bool> updateUserSessionsProgress(String courseId, String userId,
      int sessionNumber, bool isLastSession) async {
    try {
      Map<String, dynamic> updateData = {
        'sessionsCompletion.session$sessionNumber': true,
      };

      if (isLastSession) {
        updateData['sessionsCompletion.isAllCompleted'] = true;
        updateData['progress.isSessionsDone'] = true;
      }

      await _firestore
          .collection('courses')
          .doc(courseId)
          .collection('users')
          .doc(userId)
          .update(updateData);

      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('Error updating user progress: $e');
      return false;
    }
  }

  Future<bool> uploadSessionTaskSubmission(String courseId, String userId,
      int sessionNumber, String taskText, File? taskFile) async {
    final storage = FirebaseStorage.instance;
    String? downloadUrl;
    try {
      if (taskFile != null) {
        final String fileType = path.extension(taskFile.path);
        final String taskSubmissionId = const Uuid().v4();
        if (fileType != '.pdf' && fileType != '.txt') {
          if (kDebugMode) debugPrint('Invalid file type');
          return false;
        }
        final String storagePath =
            'courses/$courseId/submissions/$userId/session$sessionNumber/$taskSubmissionId$fileType';

        await storage.ref(storagePath).putFile(taskFile);

        downloadUrl = await storage.ref(storagePath).getDownloadURL();
      }

      await _firestore
          .collection('courses')
          .doc(courseId)
          .collection('users')
          .doc(userId)
          .update(
        {
          'taskSubmissions': FieldValue.arrayUnion(
            [
              {
                'sessionNumber': sessionNumber,
                'taskText': taskText,
                'taskFileUrl': downloadUrl ??
                    'https://firebasestorage.googleapis.com/v0/b/neurossistant.appspot.com/o/courses%2Fempty.txt?alt=media',
                'submittedAt': DateTime.now(),
              }
            ],
          ),
        },
      );

      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('Error uploading task submission: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> fetchCurrentUserTaskSubmissions(
      String courseId, String userId, int sessionNumber) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('courses')
          .doc(courseId)
          .collection('users')
          .doc(userId)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final taskSubmissions = data['taskSubmissions'] as List<dynamic>;
        final currentSessionSubmissions = taskSubmissions
            .where((submission) => submission['sessionNumber'] == sessionNumber)
            .toList();
        final Map<String, dynamic> dataFinal =
            currentSessionSubmissions[0] as Map<String, dynamic>;

        if (kDebugMode) {
          debugPrint('Task submissions found: $currentSessionSubmissions');
        }
        return dataFinal;
      } else {
        if (kDebugMode) debugPrint('Task submissions not found');
        return null;
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error fetching task submissions: $e');
      return null;
    }
  }
}
