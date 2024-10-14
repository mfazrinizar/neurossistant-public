import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_exit_app/flutter_exit_app.dart';
import 'package:get/get.dart';
import 'package:neurossistant/src/localization/app_localizations.dart';
import 'package:neurossistant/src/theme/theme.dart';
import 'onboarding_base.dart';
import 'package:neurossistant/src/reusable_func/localization_change.dart';
import 'package:neurossistant/src/reusable_func/theme_change.dart';
import 'package:neurossistant/src/pages/auth/start.dart';
import 'package:neurossistant/src/reusable_comp/language_changer.dart';
import 'package:neurossistant/src/reusable_comp/theme_changer.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  OnboardingScreenState createState() => OnboardingScreenState();
}

class OnboardingScreenState extends State<OnboardingScreen> {
  int currentPage = 0;
  final PageController controller = PageController();

  // String? translate(BuildContext context, String key) {
  //   final localizations = AppLocalizations.of(context);
  //   if (localizations == null) {
  //     return null;
  //   }
  //   return localizations.translate(key);
  // }

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> onboardingData = [
      {
        "title": AppLocalizations.of(context)!.translate('onboarding_title1') ??
            'problem',
        "description": AppLocalizations.of(context)!
                .translate('onboarding_description1') ??
            'problem',
        "imageLight": "assets/images/onboarding1_light.svg",
        "imageDark": "assets/images/onboarding1_dark.svg",
        "isSvg": "true",
      },
      {
        "title": AppLocalizations.of(context)!.translate('onboarding_title2') ??
            'problem',
        "description": AppLocalizations.of(context)!
                .translate('onboarding_description2') ??
            'problem',
        "imageLight": "assets/images/onboarding2_light.svg",
        "imageDark": "assets/images/onboarding2_dark.svg",
        "isSvg": "true",
      },
    ];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Neurossistant'),
        actions: <Widget>[
          const LanguageSwitcher(onPressed: localizationChange),
          ThemeSwitcher(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color.fromARGB(255, 211, 227, 253)
                  : Colors.black,
              onPressed: themeChange),
        ],
      ),
      body: PopScope(
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
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.75,
                child: PageView.builder(
                  controller: controller,
                  onPageChanged: (value) {
                    setState(
                      () {
                        currentPage = value;
                      },
                    );
                  },
                  itemCount: onboardingData.length,
                  itemBuilder: (context, index) => OnboardingContent(
                    title: onboardingData[index]["title"]!,
                    description: onboardingData[index]["description"]!,
                    imageLight: onboardingData[index]["imageLight"]!,
                    imageDark: onboardingData[index]["imageDark"]!,
                    isSvg:
                        onboardingData[index]["isSvg"] == "true" ? true : false,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(
                    width: 20,
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).brightness == Brightness.dark
                              ? ThemeClass().darkRounded
                              : ThemeClass().lightPrimaryColor,
                    ),
                    child: Text(
                      AppLocalizations.of(context)!
                              .translate('onboarding_button1') ??
                          'Skip',
                    ),
                    onPressed: () {
                      Get.to(() => const StartPage());
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List<Widget>.generate(
                      onboardingData.length,
                      (int index) {
                        return GestureDetector(
                          onTap: () {
                            controller.animateToPage(
                              index,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeIn,
                            );
                          },
                          child: Container(
                            width: 15.0,
                            height: 15.0,
                            margin: const EdgeInsets.symmetric(horizontal: 8.0),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: currentPage == index
                                  ? (Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? const Color.fromARGB(255, 211, 227, 253)
                                      : Theme.of(context).colorScheme.primary)
                                  : (Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? ThemeClass().darkRounded
                                      : Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withOpacity(0.5)),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).brightness == Brightness.dark
                              ? ThemeClass().darkRounded
                              : ThemeClass().lightPrimaryColor,
                    ),
                    child: Text(AppLocalizations.of(context)!
                            .translate('onboarding_button2') ??
                        'Next'),
                    onPressed: () {
                      if (currentPage == onboardingData.length - 1) {
                        Get.offAll(() => const StartPage());
                      }
                      controller.nextPage(
                        // Index of the second page
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeIn,
                      );
                    },
                  ),
                  const SizedBox(
                    width: 20,
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
