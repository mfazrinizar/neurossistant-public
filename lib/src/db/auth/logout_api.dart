import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:neurossistant/src/db/push_notification/push_notification_api.dart';
import 'package:neurossistant/src/encrypted/secure_storage.dart';
import 'package:neurossistant/src/pages/auth/login.dart';

class LogoutAPI {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> logout(
      {bool? notGoToLoginPage, bool? isFromRegisterPage}) async {
    if (isFromRegisterPage == null) {
      final pushNotificationApi = PushNotificationAPI();
      await pushNotificationApi.deleteDeviceToken();
      await UserSecureStorage.clearAll();
    }

    await _auth.signOut();

    if (notGoToLoginPage != null) {
      if (notGoToLoginPage) {
        return;
      }
    }
    Get.offAll(() => const LoginPage());
  }
}
