import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:neurossistant/src/db/settings/change_password_api.dart';
import 'package:neurossistant/src/localization/app_localizations.dart';
import 'package:neurossistant/src/reusable_comp/language_changer.dart';
import 'package:neurossistant/src/reusable_comp/theme_changer.dart';
import 'package:neurossistant/src/reusable_func/form_validator.dart';
import 'package:neurossistant/src/reusable_func/localization_change.dart';
import 'package:neurossistant/src/reusable_func/theme_change.dart';
import 'package:neurossistant/src/theme/theme.dart';
import 'package:neurossistant/src/homepage.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  ChangePasswordState createState() => ChangePasswordState();
}

class ChangePasswordState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController newRePasswordController = TextEditingController();
  bool isDarkMode = Get.isDarkMode,
      oldPasswordVisible = false,
      newPasswordVisible = false,
      newRePasswordVisible = false;
  bool isProcessing = false;

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
          AppLocalizations.of(context)!.translate('change_password_title1') ??
              'Change Password',
          style: const TextStyle(color: Colors.white),
        ),
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
                        ? 'assets/images/changepw1_dark.svg'
                        : 'assets/images/changepw1_light.svg',
                    width: width * 0.75,
                    fit: BoxFit.fill,
                  ),
                ),
                Positioned(
                  top: height * 0.25,
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
                                          .translate('change_password_desc1') ??
                                      'Please Fill the Form',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode
                                        ? const Color.fromARGB(
                                            255, 211, 227, 253)
                                        : Colors.black,
                                  )),
                              StatefulBuilder(
                                builder: (BuildContext context,
                                    StateSetter setState) {
                                  return TextFormField(
                                    controller: oldPasswordController,
                                    validator: FormValidator.validatePassword,
                                    style: TextStyle(
                                      color: isDarkMode
                                          ? const Color.fromARGB(
                                              255, 211, 227, 253)
                                          : Colors.black,
                                    ),
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
                                                  'change_password_current_label1') ??
                                          'Current Password',
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
                                          oldPasswordVisible
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
                                              oldPasswordVisible =
                                                  !oldPasswordVisible;
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                    obscureText: !oldPasswordVisible,
                                  );
                                },
                              ),
                              StatefulBuilder(
                                builder: (BuildContext context,
                                    StateSetter setState) {
                                  return TextFormField(
                                    controller: newPasswordController,
                                    validator: FormValidator.validatePassword,
                                    style: TextStyle(
                                      color: isDarkMode
                                          ? const Color.fromARGB(
                                              255, 211, 227, 253)
                                          : Colors.black,
                                    ),
                                    decoration: InputDecoration(
                                      labelStyle: TextStyle(
                                        color: isDarkMode
                                            ? const Color.fromARGB(
                                                255, 211, 227, 253)
                                            : Colors
                                                .black, // Change this to your desired color
                                      ),
                                      hintText: '********',
                                      labelText: AppLocalizations.of(context)!
                                              .translate(
                                                  'change_password_new_label1') ??
                                          'New Password',
                                      prefixIcon: Icon(
                                        Icons.password,
                                        color: isDarkMode
                                            ? const Color.fromARGB(
                                                255, 211, 227, 253)
                                            : Colors.black,
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          // Based on passwordVisible state choose the icon
                                          newPasswordVisible
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
                                              newPasswordVisible =
                                                  !newPasswordVisible;
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                    obscureText: !newPasswordVisible,
                                  );
                                },
                              ),
                              StatefulBuilder(
                                builder: (BuildContext context,
                                    StateSetter setState) {
                                  return TextFormField(
                                    controller: newRePasswordController,
                                    validator: (value) =>
                                        FormValidator.validateRePassword(
                                            newPasswordController.text,
                                            newRePasswordController.text),
                                    style: TextStyle(
                                      color: isDarkMode
                                          ? const Color.fromARGB(
                                              255, 211, 227, 253)
                                          : Colors.black,
                                    ),
                                    decoration: InputDecoration(
                                      labelStyle: TextStyle(
                                        color: isDarkMode
                                            ? const Color.fromARGB(
                                                255, 211, 227, 253)
                                            : Colors
                                                .black, // Change this to your desired color
                                      ),
                                      hintText: '********',
                                      labelText: AppLocalizations.of(context)!
                                              .translate(
                                                  'change_password_reenter_label1') ??
                                          'Re-enter New Password',
                                      prefixIcon: Icon(
                                        Icons.restart_alt,
                                        color: isDarkMode
                                            ? const Color.fromARGB(
                                                255, 211, 227, 253)
                                            : Colors.black,
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          // Based on passwordVisible state choose the icon
                                          newRePasswordVisible
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
                                              newRePasswordVisible =
                                                  !newRePasswordVisible;
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                    obscureText: !newRePasswordVisible,
                                  );
                                },
                              ),
                              SizedBox(
                                height: height * 0.1,
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
                                                          'change_password_process1') ??
                                                  'Changing Password...');

                                          final result =
                                              await ChangePasswordApi()
                                                  .changePassword(
                                                      oldPasswordController
                                                          .text,
                                                      newPasswordController
                                                          .text);
                                          EasyLoading.dismiss();
                                          setState(() {
                                            isProcessing = false;
                                          });

                                          if (!context.mounted) return;
                                          if (result['status'] ==
                                              'SUCCESS_SIR') {
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
                                              btnOkText:
                                                  AppLocalizations.of(context)!
                                                          .translate('back') ??
                                                      "Back",
                                              title: AppLocalizations.of(
                                                          context)!
                                                      .translate(
                                                          'change_password_success_title1') ??
                                                  'Password Changed',
                                              desc: AppLocalizations.of(
                                                          context)!
                                                      .translate(
                                                          'change_password_success_desc1') ??
                                                  'We\'ve changed your password, please proceed.',
                                              btnOkOnPress: () {
                                                Get.offAll(() => const HomePage(
                                                      indexFromPrevious: 2,
                                                    ));
                                              },
                                            ).show();
                                          } else if (result['status'] ==
                                              'NO_USER') {
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
                                              title: AppLocalizations.of(
                                                          context)!
                                                      .translate(
                                                          'change_password_error_title1') ??
                                                  'Error Occured',
                                              desc: AppLocalizations.of(
                                                          context)!
                                                      .translate(
                                                          'change_password_error_desc1') ??
                                                  'There was an error changing your email, please relogin and try again.',
                                              btnOkOnPress: () {
                                                Get.offAll(() => const HomePage(
                                                      indexFromPrevious: 2,
                                                    ));
                                              },
                                            ).show();
                                          } else if (result['message'] ==
                                              'too-many-requests') {
                                            AwesomeDialog(
                                                context: context,
                                                btnOkColor: Colors.red,
                                                keyboardAware: true,
                                                dismissOnBackKeyPress: false,
                                                dialogType: DialogType.error,
                                                animType: AnimType.scale,
                                                transitionAnimationDuration:
                                                    const Duration(
                                                        milliseconds: 200),
                                                btnOkText: "Ok",
                                                title: AppLocalizations.of(
                                                            context)!
                                                        .translate(
                                                            'change_password_error_title1') ??
                                                    'Error Occured',
                                                desc: AppLocalizations.of(
                                                            context)!
                                                        .translate(
                                                            'change_password_error_desc2') ??
                                                    'Too many failed reset password requests, please try again later.',
                                                btnOkOnPress: () {
                                                  DismissType.btnOk;
                                                }).show();
                                          } else {
                                            AwesomeDialog(
                                                context: context,
                                                btnOkColor: Colors.red,
                                                keyboardAware: true,
                                                dismissOnBackKeyPress: false,
                                                dialogType: DialogType.error,
                                                animType: AnimType.scale,
                                                transitionAnimationDuration:
                                                    const Duration(
                                                        milliseconds: 200),
                                                btnOkText: "Ok",
                                                title: AppLocalizations.of(
                                                            context)!
                                                        .translate(
                                                            'change_password_error_title1') ??
                                                    'Error Occured',
                                                desc: AppLocalizations.of(
                                                            context)!
                                                        .translate(
                                                            'change_password_error_desc3') ??
                                                    'Please check your current password or internet connection and try again.',
                                                btnOkOnPress: () {
                                                  DismissType.btnOk;
                                                }).show();
                                          }
                                        }
                                      },
                                child: Text(
                                    '  ${AppLocalizations.of(context)!.translate('change_password_title1') ?? 'Change Password'}  ',
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
