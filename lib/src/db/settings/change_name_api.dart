import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:neurossistant/src/encrypted/secure_storage.dart';

class ChangeNameApi {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> changeName(String newName) async {
    try {
      User? currentUser = _auth.currentUser;

      if (currentUser != null) {
        // Update the name in the user's Firebase Auth profile
        await currentUser.updateDisplayName(newName);

        // Update the name in Firestore Database
        await _firestore.collection('users').doc(currentUser.uid).update({
          'name': newName,
        });

        final discussions = await _firestore
            .collection('discussions')
            .where('discussionPostUserId', isEqualTo: currentUser.uid)
            .get();

        for (final doc in discussions.docs) {
          await doc.reference.update({
            'discussionUserName': newName,
          });
        }

        final comments = await _firestore.collection('discussions').get();

        for (final doc in comments.docs) {
          final commentsList =
              List<Map<String, dynamic>>.from(doc.data()['commentsList'] ?? []);

          // Update the avatarUrl for comments made by the current user
          for (final comment in commentsList) {
            if (comment['commenterId'] == currentUser.uid) {
              comment['commenterName'] = newName;
            }
          }

          // Update the commentsList field in the discussion document
          await doc.reference.update({
            'commentsList': commentsList,
          });
        }

        final coursesSnapshot = await _firestore.collection('courses').get();

        for (final courseDoc in coursesSnapshot.docs) {
          final contentDocRef = _firestore
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
                  updatedComment['commenterName'] = newName;
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

        await UserSecureStorage.setUserDisplayName(newName);

        return {'status': 'success', 'message': 'Name changed successfully.'};
      } else {
        return {
          'status': 'error',
          'message': 'No user is currently signed in.'
        };
      }
    } on FirebaseAuthException catch (e) {
      return {'status': 'error', 'message': e.code};
    } catch (e) {
      return {'status': 'error', 'message': 'An error occurred'};
    }
  }
}
