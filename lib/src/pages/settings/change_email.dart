import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:neurossistant/src/db/auth/logout_api.dart';
import 'package:neurossistant/src/db/settings/change_email_api.dart';
import 'package:neurossistant/src/homepage.dart';
import 'package:neurossistant/src/localization/app_localizations.dart';
import 'package:neurossistant/src/pages/auth/login.dart';
import 'package:neurossistant/src/reusable_comp/language_changer.dart';
import 'package:neurossistant/src/reusable_comp/theme_changer.dart';
import 'package:neurossistant/src/reusable_func/form_validator.dart';
import 'package:neurossistant/src/reusable_func/localization_change.dart';
import 'package:neurossistant/src/reusable_func/theme_change.dart';
import 'package:neurossistant/src/theme/theme.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class ChangeEmailPage extends StatefulWidget {
  const ChangeEmailPage({super.key});

  @override
  ChangeEmailState createState() => ChangeEmailState();
}

class ChangeEmailState extends State<ChangeEmailPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isDarkMode = Get.isDarkMode;
  bool isProcessing = false;
  bool passwordVisible = false;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: isDarkMode
          ? ThemeClass.darkTheme.scaffoldBackgroundColor
          : ThemeClass().lightPrimaryColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: BackButton(
          color: Colors.white,
          onPressed: () => Get.back(),
        ),
        title: Text(
            AppLocalizations.of(context)!.translate('change_email_title1') ??
                'Change Email',
            style: const TextStyle(color: Colors.white)),
        actions: [
          Container(
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Colors.transparent
                  : Colors
                      .white, // Change this to your desired background color
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(25), // Adjust the radius as needed
              ),
            ),
            child: const LanguageSwitcher(onPressed: localizationChange),
          ),
          Container(
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Colors.transparent
                  : Colors
                      .white, // Change this to your desired background color
            ),
            child: ThemeSwitcher(
              color: isDarkMode
                  ? const Color.fromARGB(255, 211, 227, 253)
                  : Colors.black,
              onPressed: () {
                setState(
                  () {
                    themeChange();
                    isDarkMode = !isDarkMode;
                  },
                );
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned(
                  right: 0,
                  child: SvgPicture.asset(
                    isDarkMode
                        ? 'assets/images/changeemail1_dark.svg'
                        : 'assets/images/changeemail1_light.svg',
                    width: width,
                    fit: BoxFit.fill,
                  ),
                ),
                Positioned(
                  top: height * 0.35,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    decoration: ShapeDecoration(
                      color:
                          isDarkMode ? ThemeClass().darkRounded : Colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(50),
                            topLeft: Radius.circular(50)),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16.0, left: 16.0),
                      child: SingleChildScrollView(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              SizedBox(
                                height: height * 0.05,
                              ),
                              Text(
                                AppLocalizations.of(context)!
                                        .translate('change_email_desc1') ??
                                    'Please enter your new email below:',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode
                                      ? const Color.fromARGB(255, 211, 227, 253)
                                      : Colors.black,
                                ),
                              ),
                              TextFormField(
                                controller: emailController,
                                validator: FormValidator.validateEmail,
                                decoration: InputDecoration(
                                  labelStyle: TextStyle(
                                    color: isDarkMode
                                        ? const Color.fromARGB(
                                            255, 211, 227, 253)
                                        : Colors
                                            .black, // Change this to your desired color
                                  ),
                                  hintText: 'email@email.com',
                                  labelText: AppLocalizations.of(context)!
                                          .translate(
                                              'change_email_label_text1') ??
                                      'New Email',
                                  prefixIcon: Icon(
                                    Icons.email,
                                    color: isDarkMode
                                        ? const Color.fromARGB(
                                            255, 211, 227, 253)
                                        : Colors.black,
                                  ),
                                ),
                              ),
                              StatefulBuilder(
                                builder: (BuildContext context,
                                    StateSetter setState) {
                                  return TextFormField(
                                    controller: passwordController,
                                    validator: FormValidator.validatePassword,
                                    style: const TextStyle(color: Colors.black),
                                    decoration: InputDecoration(
                                      labelStyle: TextStyle(
                                        color: isDarkMode
                                            ? const Color.fromARGB(
                                                255, 211, 227, 253)
                                            : Colors.black,
                                      ),
                                      hintText: '********',
                                      labelText: AppLocalizations.of(context)!
                                              .translate(
                                                  'change_email_password_label_text1') ??
                                          'Your Password',
                                      prefixIcon: Icon(
                                        Icons.lock,
                                        color: isDarkMode
                                            ? const Color.fromARGB(
                                                255, 211, 227, 253)
                                            : Colors.black,
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          // Based on passwordVisible state choose the icon
                                          passwordVisible
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                          color: isDarkMode
                                              ? const Color.fromARGB(
                                                  255, 211, 227, 253)
                                              : Colors.black,
                                        ),
                                        onPressed: () {
                                          // Update the state i.e. toggle the state of passwordVisible variable
                                          setState(
                                            () {
                                              passwordVisible =
                                                  !passwordVisible;
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                    obscureText: !passwordVisible,
                                  );
                                },
                              ),
                              SizedBox(
                                height: height * 0.05,
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shadowColor: Colors.grey,
                                  elevation: 5,
                                ),
                                onPressed: isProcessing
                                    ? null
                                    : () async {
                                        if (_formKey.currentState!.validate()) {
                                          setState(() {
                                            isProcessing = true;
                                          });

                                          EasyLoading.show(
                                              status: AppLocalizations.of(
                                                          context)!
                                                      .translate(
                                                          'change_email_process1') ??
                                                  'Changing Email...');
                                          final result = await ChangeEmailAPI()
                                              .changeEmail(emailController.text,
                                                  passwordController.text);
                                          EasyLoading.dismiss();

                                          setState(() {
                                            isProcessing = false;
                                          });
                                          if (!context.mounted) return;
                                          if (result == 'SUCCESS_SIR') {
                                            AwesomeDialog(
                                              context: context,
                                              btnOkColor: ThemeClass()
                                                  .lightPrimaryColor,
                                              keyboardAware: true,
                                              dismissOnBackKeyPress: false,
                                              dialogType: DialogType.success,
                                              animType: AnimType.scale,
                                              transitionAnimationDuration:
                                                  const Duration(
                                                      milliseconds: 200),
                                              btnOkText: "Ok",
                                              title: AppLocalizations.of(
                                                          context)!
                                                      .translate(
                                                          'change_email_success_title1') ??
                                                  'Email Changed',
                                              desc: AppLocalizations.of(
                                                          context)!
                                                      .translate(
                                                          'change_email_success_desc1') ??
                                                  'We\'ve changed your email, please verify your new email and relogin.',
                                              btnOkOnPress: () async {
                                                await LogoutAPI().logout();
                                                Get.offAll(
                                                  () => const LoginPage(),
                                                );
                                              },
                                            ).show();
                                          } else if (result ==
                                              'WRONG_PASSWORD') {
                                            AwesomeDialog(
                                              context: context,
                                              btnOkColor: ThemeClass()
                                                  .lightPrimaryColor,
                                              keyboardAware: true,
                                              dismissOnBackKeyPress: false,
                                              dialogType: DialogType.error,
                                              animType: AnimType.scale,
                                              transitionAnimationDuration:
                                                  const Duration(
                                                      milliseconds: 200),
                                              btnOkText:
                                                  AppLocalizations.of(context)!
                                                          .translate('back') ??
                                                      "Back",
                                              title: 'Error',
                                              desc: AppLocalizations.of(
                                                          context)!
                                                      .translate(
                                                          'change_email_error_desc1') ??
                                                  'Wrong password, please try again.',
                                              btnOkOnPress: () {
                                                DismissType.btnOk;
                                              },
                                            ).show();
                                          } else if (result == 'ERROR') {
                                            AwesomeDialog(
                                              context: context,
                                              btnOkColor: ThemeClass()
                                                  .lightPrimaryColor,
                                              keyboardAware: true,
                                              dismissOnBackKeyPress: false,
                                              dialogType: DialogType.error,
                                              animType: AnimType.scale,
                                              transitionAnimationDuration:
                                                  const Duration(
                                                      milliseconds: 200),
                                              btnOkText:
                                                  AppLocalizations.of(context)!
                                                          .translate('back') ??
                                                      "Back",
                                              title: 'Error',
                                              desc: AppLocalizations.of(
                                                          context)!
                                                      .translate(
                                                          'change_email_error_desc2') ??
                                                  'There was an error changing your email, please try again.',
                                              btnOkOnPress: () {
                                                Get.offAll(
                                                  () => const HomePage(
                                                    indexFromPrevious: 2,
                                                  ),
                                                );
                                              },
                                            ).show();
                                          } else if (result == 'NO_USER') {
                                            AwesomeDialog(
                                              context: context,
                                              btnOkColor: ThemeClass()
                                                  .lightPrimaryColor,
                                              keyboardAware: true,
                                              dismissOnBackKeyPress: false,
                                              dialogType: DialogType.error,
                                              animType: AnimType.scale,
                                              transitionAnimationDuration:
                                                  const Duration(
                                                      milliseconds: 200),
                                              btnOkText:
                                                  AppLocalizations.of(context)!
                                                          .translate('back') ??
                                                      "Back",
                                              title: 'Error',
                                              desc: AppLocalizations.of(
                                                          context)!
                                                      .translate(
                                                          'change_email_error_desc3') ??
                                                  'You are not logged in, please relogin and try again.',
                                              btnOkOnPress: () {
                                                Get.offAll(
                                                  () => const HomePage(
                                                    indexFromPrevious: 2,
                                                  ),
                                                );
                                              },
                                            ).show();
                                          }
                                        }
                                      },
                                child: Text(
                                    '   ${AppLocalizations.of(context)!.translate('change') ?? 'Change'}   ',
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: isDarkMode
                                          ? const Color.fromARGB(
                                              255, 211, 227, 253)
                                          : Colors.white,
                                    )),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
