// main.dart

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:get/get.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:neurossistant/src/db/push_notification/push_notification_api.dart';
import 'package:neurossistant/src/encrypted/env.dart';
import 'package:neurossistant/src/homepage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'src/pages/onboarding/onboarding_screen.dart';
import 'src/localization/app_localizations_delegate.dart';
import 'package:neurossistant/src/theme/theme.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: await currentPlatform);
  final env = Env.create();
  await requestPermission();
  await loadFCM();
  await listenFCM();
  // final pushNotificationApi = PushNotificationAPI();
  // await pushNotificationApi.storeDeviceToken();

  Gemini.init(apiKey: env.geminiApiKey);
  runApp(const MyApp());
}

// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
//   if (kDebugMode) {
//     print("Handling a background message: ${message.messageId}");
//   }
// }

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  final pushNotificationApi = PushNotificationAPI();
  String _locale = 'en';
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();

    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    // print(Get.locale);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? localeString = prefs.getString('locale');
    bool isDarkMode = prefs.getBool('isDarkMode') ?? false;

    setState(() {
      _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
      _locale = localeString ?? 'en';
      Get.updateLocale(Locale(_locale, ''));
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Neurossistant',
      theme: ThemeClass.lightTheme,
      darkTheme: ThemeClass.darkTheme,
      themeMode: _themeMode,
      locale: Locale(_locale, ''),
      builder: EasyLoading.init(),
      home: FirebaseAuth.instance.currentUser != null
          ? const HomePage()
          : const OnboardingScreen(),
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // English
        Locale('id', ''), // Indonesian
      ],
    );
  }
}
