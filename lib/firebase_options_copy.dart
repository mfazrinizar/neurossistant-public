// File generated by FlutterFire CLI and modified for Encryption & Decryption of Env.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:neurossistant/src/encrypted/env.dart';

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```

final env = Env.create();

Future<FirebaseOptions> get currentPlatform async {
  if (kIsWeb) {
    return web;
  }
  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      return android;
    case TargetPlatform.iOS:
      return ios;
    case TargetPlatform.macOS:
      return macos;
    case TargetPlatform.windows:
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for windows - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    case TargetPlatform.linux:
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for linux - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    default:
      throw UnsupportedError(
        'DefaultFirebaseOptions are not supported for this platform.',
      );
  }
}

FirebaseOptions web = FirebaseOptions(
  apiKey: env.firebaseWebApiKey,
  appId: env.firebaseWebAppId,
  messagingSenderId: env.firebaseWebMessagingSenderId,
  projectId: env.firebaseWebProjectId,
  authDomain: env.firebaseWebAuthDomain,
  databaseURL: env.firebaseWebDatabaseUrl,
  storageBucket: env.firebaseWebStorageBucket,
  measurementId: env.firebaseWebAppMeasurementId,
);

FirebaseOptions android = FirebaseOptions(
  apiKey: env.firebaseAndroidApiKey,
  appId: env.firebaseAndroidAppId,
  messagingSenderId: env.firebaseAndroidMessagingSenderId,
  projectId: env.firebaseAndroidProjectId,
  databaseURL: env.firebaseAndroidDatabaseUrl,
  storageBucket: env.firebaseAndroidStorageBucket,
);

FirebaseOptions ios = FirebaseOptions(
  apiKey: env.firebaseIosApiKey,
  appId: env.firebaseIosAppId,
  messagingSenderId: env.firebaseIosMessagingSenderId,
  projectId: env.firebaseIosProjectId,
  databaseURL: env.firebaseIosDatabaseUrl,
  storageBucket: env.firebaseIosStorageBucket,
  iosBundleId: env.firebaseIosBundleId,
);

FirebaseOptions macos = FirebaseOptions(
  apiKey: env.firebaseMacosApiKey,
  appId: env.firebaseMacosAppId,
  messagingSenderId: env.firebaseMacosMessagingSenderId,
  projectId: env.firebaseMacosProjectId,
  databaseURL: env.firebaseMacosDatabaseUrl,
  storageBucket: env.firebaseMacosStorageBucket,
  iosBundleId: env.firebaseMacosIosBundleId,
);
