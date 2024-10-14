import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:neurossistant/src/db/auth/logout_api.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as path;

import 'dart:io';

class RegisterApi {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> registerUser({
    required File profilePictureImage,
    required String userType,
    required String nameOfUser,
    required String userEmail,
    required String userPassword,
    List<String>? userTags,
  }) async {
    try {
      // Register the user
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: userEmail,
        password: userPassword,
      );

      // Send verification email
      await userCredential.user!.sendEmailVerification();

      // Get file extension of the profilePictureImage
      String fileExtension = path.extension(profilePictureImage.path);

      // Upload the profile picture to Firebase Storage
      UploadTask uploadTask = _storage
          .ref('profile_pictures/${userCredential.user!.uid}$fileExtension')
          .putFile(profilePictureImage);

      // Get the download URL of the profile picture
      final TaskSnapshot downloadUrl = (await uploadTask);
      final String url = (await downloadUrl.ref.getDownloadURL());

      // Update the user's profile with the name and profile picture URL
      await userCredential.user!.updateDisplayName(nameOfUser);
      await userCredential.user!.updatePhotoURL(url);

      // Create a document in Firestore with the user's ID
      Map<String, dynamic> userData = {
        'name': nameOfUser,
        'userType': userType,
        'uid': userCredential.user!.uid,
        'profilePicture': url,
      };

      if (userType == 'Parent' && userTags != null) {
        userData['userTags'] = userTags;
      }

      if (userType == 'Psychologist') {
        userData['isActiveInConsult'] = false;
        userData['rating'] = '0.0';
      }

      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(userData);

      // Make sure it's not logged in before verifying email
      await LogoutAPI()
          .logout(notGoToLoginPage: true, isFromRegisterPage: true);

      // Return a success message
      return 'SUCCESSFUL_SIR';
    } on FirebaseAuthException catch (e) {
      // Return the error code
      return e.code;
    } catch (e) {
      // Return a generic error message
      return 'An error occurred';
    }
  }
}
