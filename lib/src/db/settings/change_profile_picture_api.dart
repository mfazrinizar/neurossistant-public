// change_profile_picture.dart

import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:neurossistant/src/encrypted/secure_storage.dart';
import 'package:path/path.dart' as path;

class ChangeProfilePictureApi {
  Future<bool> changeProfilePicture(File pickedImage) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      final firestore = FirebaseFirestore.instance;

      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_pictures')
          .child('${currentUser!.uid}${path.extension(pickedImage.path)}');

      await ref.putFile(pickedImage);

      final url = await ref.getDownloadURL();

      await currentUser.updatePhotoURL(url);

      final discussions = await firestore
          .collection('discussions')
          .where('discussionPostUserId', isEqualTo: currentUser.uid)
          .get();

      for (final doc in discussions.docs) {
        await doc.reference.update({
          'discussionUserPhotoProfileUrl': url,
        });
      }

      final comments = await firestore.collection('discussions').get();

      for (final doc in comments.docs) {
        final commentsList =
            List<Map<String, dynamic>>.from(doc.data()['commentsList'] ?? []);

        for (final comment in commentsList) {
          if (comment['commenterId'] == currentUser.uid) {
            comment['avatarUrl'] = url;
          }
        }

        await doc.reference.update({
          'commentsList': commentsList,
        });
      }

      final coursesSnapshot = await firestore.collection('courses').get();

      for (final courseDoc in coursesSnapshot.docs) {
        final contentDocRef = firestore
            .collection('courses')
            .doc(courseDoc.id)
            .collection('contents')
            .doc('sessions');
        final contentDocSnapshot = await contentDocRef.get();

        if (contentDocSnapshot.exists) {
          Map<String, dynamic> contentData = contentDocSnapshot.data()!;
          List<dynamic> sessions = contentData['sessions'] ?? [];
          bool shouldUpdate = false;

          List<Map<String, dynamic>> updatedSessions = [];

          for (var session in sessions) {
            List<dynamic> commentsList = session['commentsList'] ?? [];
            List<Map<String, dynamic>> updatedCommentsList = [];

            bool updatedComments = false;

            for (var comment in commentsList) {
              Map<String, dynamic> updatedComment =
                  Map<String, dynamic>.from(comment);
              if (updatedComment['commenterId'] == currentUser.uid) {
                if (kDebugMode) {
                  debugPrint(
                      "Updating comment for user: ${currentUser.uid}"); // Debugging statement
                }
                updatedComment['avatarUrl'] = url;
                updatedComments = true;
              }
              updatedCommentsList.add(updatedComment);
            }

            if (updatedComments) {
              Map<String, dynamic> updatedSession =
                  Map<String, dynamic>.from(session);
              updatedSession['commentsList'] = updatedCommentsList;
              updatedSessions.add(updatedSession);
              shouldUpdate = true;
            } else {
              updatedSessions.add(Map<String, dynamic>.from(session));
            }
          }

          if (shouldUpdate) {
            if (kDebugMode) {
              debugPrint(
                  "Updating sessions for document: ${courseDoc.id}"); // Debugging statement
            }
            await contentDocRef.update({'sessions': updatedSessions});
          }
        }
      }

      await UserSecureStorage.setUserPhotoUrl(url);

      return true;
    } catch (e) {
      return false;
    }
  }
}
