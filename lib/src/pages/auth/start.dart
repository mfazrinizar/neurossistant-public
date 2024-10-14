import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_exit_app/flutter_exit_app.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:neurossistant/src/localization/app_localizations.dart';
import 'package:neurossistant/src/pages/onboarding/onboarding_screen.dart';
import 'package:neurossistant/src/reusable_comp/language_changer.dart';
import 'package:neurossistant/src/reusable_comp/theme_changer.dart';
import 'package:neurossistant/src/reusable_func/localization_change.dart';
import 'package:neurossistant/src/reusable_func/theme_change.dart';
import 'package:neurossistant/src/theme/theme.dart';
import 'login.dart';
import 'register.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  StartPageState createState() => StartPageState();
}

class StartPageState extends State<StartPage> {
  final isDarkMode = RxBool(Get.isDarkMode);
  @override
  void initState() {
    isDarkMode.value = Get.isDarkMode;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    isDarkMode.value = Theme.of(context).brightness == Brightness.dark;
    return Obx(
      () => PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (!didPop) {
            AwesomeDialog(
              dismissOnTouchOutside: true,
              context: context,
              keyboardAware: true,
              dismissOnBackKeyPress: false,
              dialogType: DialogType.question,
              animType: AnimType.scale,
              transitionAnimationDuration: const Duration(milliseconds: 200),
              title: AppLocalizations.of(context)!
                      .translate('settings_exit_app_title1') ??
                  'Exit App',
              desc: AppLocalizations.of(context)!
                      .translate('settings_exit_app_desc1') ??
                  'Are you sure you want to exit the app?',
              btnOkText:
                  AppLocalizations.of(context)!.translate('yes') ?? 'Yes',
              btnCancelText:
                  AppLocalizations.of(context)!.translate('cancel') ?? 'Cancel',
              btnOkOnPress: () async {
                await FlutterExitApp.exitApp();
              },
              btnCancelOnPress: () {
                DismissType.btnCancel;
              },
            ).show();
          }
        },
        child: Scaffold(
          // Replace with your primary color
          backgroundColor: isDarkMode.value
              ? ThemeClass.darkTheme.scaffoldBackgroundColor
              : ThemeClass().lightPrimaryColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text('Neurossistant',
                style: TextStyle(color: Colors.white)),
            leading: BackButton(
                color: Colors.white,
                onPressed: () => Get.offAll(() =>
                    const OnboardingScreen())), // Empty container to remove back button
            actions: [
              Container(
                decoration: BoxDecoration(
                  color: isDarkMode.value
                      ? Colors.transparent
                      : Colors
                          .white, // Change this to your desired background color
                  borderRadius: const BorderRadius.only(
                    bottomLeft:
                        Radius.circular(25), // Adjust the radius as needed
                  ),
                ),
                child: const LanguageSwitcher(onPressed: localizationChange),
              ),
              Container(
                decoration: BoxDecoration(
                  color: isDarkMode.value ? Colors.transparent : Colors.white,
                ),
                child: ThemeSwitcher(
                    color: isDarkMode.value
                        ? const Color.fromARGB(255, 211, 227, 253)
                        : Colors.black,
                    onPressed: () {
                      setState(() {
                        themeChange();
                        isDarkMode.value = !isDarkMode.value;
                      });
                    }),
              ),
            ],
          ),
          body: Stack(
            children: [
              Positioned(
                bottom: 0,
                child: Container(
                  width: MediaQuery.of(context)
                      .size
                      .width, // make it cover the full width
                  height: MediaQuery.of(context).size.height * 0.60,
                  decoration: ShapeDecoration(
                    color: isDarkMode.value
                        ? ThemeClass().darkRounded
                        : Colors.white,
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.only(topRight: Radius.circular(80)),
                    ),
                  ),
                ),
              ),
              Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height * 0.1,
                      ),
                      SvgPicture.asset(
                        isDarkMode.value
                            ? 'assets/images/start1_dark.svg'
                            : 'assets/images/start1_light.svg',
                        height: MediaQuery.of(context).size.height * 0.45,
                        fit: BoxFit.fill,
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.1,
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            shadowColor: Colors.grey, elevation: 5),
                        onPressed: () async => Get.to(() => const LoginPage()),
                        child: Text(
                            AppLocalizations.of(context)!
                                    .translate('start_button1') ??
                                '  Login  ',
                            style: const TextStyle(fontSize: 20)),
                      ),
                      const SizedBox(height: 5),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            shadowColor: Colors.grey,
                            elevation: 5,
                            backgroundColor:
                                isDarkMode.value ? Colors.grey : Colors.white),
                        onPressed: () async =>
                            Get.to(() => const RegisterPage()),
                        child: Text(
                            AppLocalizations.of(context)!
                                    .translate('start_button2') ??
                                'Register',
                            style: TextStyle(
                                fontSize: 20,
                                color: isDarkMode.value
                                    ? Colors.white
                                    : ThemeClass().lightPrimaryColor)),
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.05)
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
