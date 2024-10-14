import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:neurossistant/src/encrypted/secure_storage.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

class LoginApi {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> loginUser({
    required String userEmail,
    required String userPassword,
  }) async {
    try {
      // Sign in the user
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: userEmail,
        password: userPassword,
      );

      // Check if the user has verified their email address
      if (!userCredential.user!.emailVerified) {
        return {
          'status': 'error',
          'message': 'Please verify your email address.'
        };
      }

      // Get the user type from Firestore
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();
      String? userType = userDoc.get('userType');

      // Store the user sessions in secure storage
      if (userCredential.user != null) {
        await UserSecureStorage.setUserId(userCredential.user!.uid);
      }

      if (userType != null) {
        await UserSecureStorage.setUserType(userType);
      }

      if (userCredential.user!.displayName != null) {
        await UserSecureStorage.setUserDisplayName(
            _auth.currentUser!.displayName!);
      }

      if (userCredential.user!.photoURL != null) {
        await UserSecureStorage.setUserPhotoUrl(_auth.currentUser!.photoURL!);
      }

      if (userType == 'Parent') {
        List<String> userTags = List<String>.from(userDoc.get('userTags'));
        await UserSecureStorage.setUserTags(userTags);
      }

      // Return a success message and the user type
      return {
        'status': 'success',
        'message': 'SUCCESSFUL_SIR',
      };
    } on FirebaseAuthException catch (e) {
      // Return the error code
      if (e.code == 'wrong-password' ||
          e.code == 'invalid-email' ||
          e.code == 'user-not-found' ||
          e.code == 'invalid-credential') {
        return {'status': 'error', 'message': 'Wrong email or password.'};
      } else if (e.code == 'user-disabled') {
        return {
          'status': 'error',
          'message': 'Your account is disabled, please contact developer.'
        };
      }
      return {'status': 'error', 'message': e.code};
    } catch (e) {
      if (kDebugMode) debugPrint(e.toString());
      // Return a generic error message
      return {
        'status': 'error',
        'message': 'Check internet connection or contact developer.'
      };
    }
  }
}
