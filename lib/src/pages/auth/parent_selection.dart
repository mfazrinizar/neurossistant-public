import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:neurossistant/src/db/auth/register_api.dart';
import 'package:neurossistant/src/localization/app_localizations.dart';
import 'package:neurossistant/src/pages/auth/login.dart';
import 'package:neurossistant/src/reusable_comp/language_changer.dart';
import 'package:neurossistant/src/reusable_comp/theme_changer.dart';
import 'package:neurossistant/src/reusable_func/localization_change.dart';
import 'package:neurossistant/src/reusable_func/theme_change.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:neurossistant/src/theme/theme.dart';

import 'register.dart';

class ParentSelectionPage extends StatefulWidget {
  final File profileImage;
  final String nameOfUser;
  final String userEmail;
  final String userPassword;

  const ParentSelectionPage(
      {super.key,
      required this.profileImage,
      required this.nameOfUser,
      required this.userEmail,
      required this.userPassword});

  @override
  ParentSelectionState createState() => ParentSelectionState();
}

class ParentSelectionState extends State<ParentSelectionPage> {
  bool isDarkMode = Get.isDarkMode,
      passwordVisible = false,
      rePasswordVisible = false,
      isProcessing = false;
  List<String> allTags = ['ADHD', 'ASD', 'DCD', 'Dyslexia', 'Others'];
  List<String> selectedTags = [];

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: [
          const LanguageSwitcher(onPressed: localizationChange),
          ThemeSwitcher(
              color: isDarkMode
                  ? const Color.fromARGB(255, 211, 227, 253)
                  : Colors.black,
              onPressed: () {
                setState(() {
                  themeChange();
                  isDarkMode = !isDarkMode;
                });
              }),
        ],
      ),
      body: SingleChildScrollView(
        child: SizedBox(
            height: height,
            child: Column(children: [
              SvgPicture.asset(
                isDarkMode
                    ? 'assets/images/parent1_dark.svg'
                    : 'assets/images/parent1_light.svg',
                width: width,
                fit: BoxFit.fill,
              ),
              SizedBox(height: height * 0.04),
              Text(
                AppLocalizations.of(context)!
                        .translate('parent_register_desc1') ??
                    'Please select your child\'s special need(s):',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: height * 0.02),
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.lightBlue, width: 3),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: selectedTags.isEmpty
                    ? Center(
                        child: Text(AppLocalizations.of(context)!
                                .translate('parent_register_desc2') ??
                            'Please select a need...'))
                    : Wrap(
                        spacing: 8.0, // gap between adjacent chips
                        runSpacing: 4.0, // gap between lines
                        children: selectedTags.map((tag) {
                          return Container(
                            padding: const EdgeInsets.all(8.0),
                            margin: const EdgeInsets.symmetric(horizontal: 4.0),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      allTags.add(tag);
                                      selectedTags.remove(tag);
                                    });
                                  },
                                  child: const Icon(Icons.close,
                                      size: 18, color: Colors.white),
                                ),
                                const SizedBox(width: 4.0),
                                Text(tag,
                                    style:
                                        const TextStyle(color: Colors.white)),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
              ),
              SizedBox(
                height: height * 0.02,
              ),
              Expanded(
                child: Container(
                  alignment: Alignment.topCenter,
                  color: Colors.transparent,
                  child: Wrap(
                    spacing: 8.0, // gap between adjacent chips
                    runSpacing: 4.0, // gap between lines
                    children: allTags.map((tag) {
                      return InkWell(
                        onTap: () {
                          setState(() {
                            selectedTags.add(tag);
                            allTags.remove(tag);
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          margin: const EdgeInsets.symmetric(horizontal: 4.0),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.add,
                                  size: 18, color: Colors.white),
                              const SizedBox(width: 4.0),
                              Text(tag,
                                  style: const TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Theme.of(context).brightness == Brightness.dark
                          ? ThemeClass().darkRounded
                          : ThemeClass().lightPrimaryColor,
                ),
                onPressed: isProcessing
                    ? null
                    : () async {
                        if (selectedTags.isNotEmpty) {
                          setState(() {
                            isProcessing = true;
                          });
                          EasyLoading.show(
                              status: AppLocalizations.of(context)!
                                      .translate('register_process1') ??
                                  'Registering...');
                          String userCode = await RegisterApi().registerUser(
                            profilePictureImage: widget.profileImage,
                            userType: 'Parent',
                            nameOfUser: widget.nameOfUser,
                            userEmail: widget.userEmail,
                            userPassword: widget.userPassword,
                            userTags: selectedTags,
                          );

                          EasyLoading.dismiss();
                          setState(() {
                            isProcessing = false;
                          });

                          if (!context.mounted) return;
                          if (userCode == 'SUCCESSFUL_SIR') {
                            _showVerificationDialog(context);
                          } else if (userCode == 'email-already-in-use') {
                            _showErrorDialog(
                                context,
                                AppLocalizations.of(context)!
                                        .translate('email_already_exists1') ??
                                    'The email address is already registered.',
                                true);
                          } else if (userCode == 'invalid-email') {
                            _showErrorDialog(
                                context,
                                AppLocalizations.of(context)!
                                        .translate('email_invalid1') ??
                                    'The email address is invalid. Kindly check again and retry.',
                                true);
                          } else if (userCode == 'operation-not-allowed') {
                            _showErrorDialog(
                                context,
                                AppLocalizations.of(context)!
                                        .translate('operation_not_allowed') ??
                                    'Something went wrong in server-side. Please contact developer.',
                                true);
                          } else if (userCode == 'weak-password') {
                            _showErrorDialog(
                                context,
                                AppLocalizations.of(context)!
                                        .translate('weak_password') ??
                                    'Your password is considered weak. Kindly check again and retry.',
                                true);
                          } else {
                            _showErrorDialog(
                                context,
                                AppLocalizations.of(context)!
                                        .translate('common_error') ??
                                    'Something went wrong, please check your internet or contact developer.',
                                true);
                          }

                          // Get.offAll(() => const LoginPage());
                        } else {
                          _showErrorDialog(
                              context,
                              AppLocalizations.of(context)!
                                      .translate('parent_register_error1') ??
                                  'Please select at least one of your child\'s need.',
                              false);
                        }
                      },
                child: Text(
                    '  ${AppLocalizations.of(context)!.translate('parent_register_button1') ?? 'Finish'}  ',
                    style: const TextStyle(fontSize: 20)),
              ),
              const Spacer(),
            ])),
      ),
    );
  }
}

void _showVerificationDialog(BuildContext context) {
  AwesomeDialog(
    dismissOnTouchOutside: false,
    context: context,
    keyboardAware: true,
    dismissOnBackKeyPress: false,
    dialogType: DialogType.info,
    animType: AnimType.scale,
    transitionAnimationDuration: const Duration(milliseconds: 200),
    btnOkText:
        AppLocalizations.of(context)!.translate('login_title1') ?? "Login",
    title: AppLocalizations.of(context)!.translate('verify_email_title') ??
        'Verify Your Email',
    desc: AppLocalizations.of(context)!.translate('verify_email_description') ??
        'Please check your email, then click the verification link to finish the registration process and be able to login your account.',
    btnOkOnPress: () {
      Get.offAll(() => const LoginPage());
    },
  ).show();
}

void _showErrorDialog(
    BuildContext context, String errorMessage, bool returnRegister) {
  AwesomeDialog(
    dismissOnTouchOutside: false,
    context: context,
    keyboardAware: true,
    dismissOnBackKeyPress: false,
    dialogType: DialogType.error,
    animType: AnimType.scale,
    transitionAnimationDuration: const Duration(milliseconds: 200),
    btnOkText: "Ok",
    title: AppLocalizations.of(context)!.translate('register_error1') ??
        'Error Occured',
    desc: errorMessage +
        (returnRegister
            ? AppLocalizations.of(context)!
                    .translate('parent_register_desc1') ??
                'Return to register page.'
            : ''),
    btnOkOnPress: () {
      returnRegister
          ? Get.offAll(() => const RegisterPage())
          : DismissType.btnOk;
    },
  ).show();
}
