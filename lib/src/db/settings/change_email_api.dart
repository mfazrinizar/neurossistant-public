import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class ChangeEmailAPI {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> changeEmail(String newEmail, String password) async {
    User? user = _auth.currentUser;

    if (user != null && user.email != null) {
      try {
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!, // Assuming the user's current email is not null
          password: password,
        );

        // Reauthenticate user (updating email is a sensitive operation that requires reauthentication)
        await user.reauthenticateWithCredential(credential);

        // Proceed to update email after successful reauthentication
        await user.verifyBeforeUpdateEmail(newEmail);

        return 'SUCCESS_SIR'; // Return 'SUCCESS_SIR' if the email was updated successfully
      } on FirebaseAuthException catch (e) {
        if (kDebugMode) debugPrint(e.code + user.email!);
        if (e.code == 'invalid-credential') {
          return 'WRONG_PASSWORD'; // Return 'WRONG_PASSWORD' if the password is incorrect
        } else {
          return 'ERROR'; // Return 'ERROR' if there was an error updating the email
        }
      } catch (e) {
        if (kDebugMode) debugPrint(e.toString());
        return 'ERROR'; // Return 'ERROR' if there was an error updating the email
      }
    } else {
      return 'NO_USER'; // Return 'NO_USER' if no user is currently signed in
    }
  }
}
