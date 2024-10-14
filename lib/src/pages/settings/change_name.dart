import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:neurossistant/src/db/settings/change_name_api.dart';
import 'package:neurossistant/src/homepage.dart';
import 'package:neurossistant/src/reusable_comp/language_changer.dart';
import 'package:neurossistant/src/reusable_comp/theme_changer.dart';
import 'package:neurossistant/src/reusable_func/localization_change.dart';
import 'package:neurossistant/src/reusable_func/theme_change.dart';
import 'package:neurossistant/src/theme/theme.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class ChangeNamePage extends StatefulWidget {
  const ChangeNamePage({super.key});

  @override
  ChangeNameState createState() => ChangeNameState();
}

class ChangeNameState extends State<ChangeNamePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  bool isDarkMode = Get.isDarkMode;
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
        title: const Text('Change Name', style: TextStyle(color: Colors.white)),
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
                  setState(() {
                    themeChange();
                    isDarkMode = !isDarkMode;
                  });
                }),
          ),
        ],
      ),
      body: Column(children: [
        Expanded(
          child: Stack(
            children: [
              Positioned(
                right: 0,
                child: SvgPicture.asset(
                  isDarkMode
                      ? 'assets/images/changename1_dark.svg'
                      : 'assets/images/changename1_light.svg',
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
                    color: isDarkMode ? ThemeClass().darkRounded : Colors.white,
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
                            Text('Please enter your new name below:',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode
                                      ? const Color.fromARGB(255, 211, 227, 253)
                                      : Colors.black,
                                )),
                            TextFormField(
                              controller: nameController,
                              decoration: InputDecoration(
                                labelStyle: TextStyle(
                                  color: isDarkMode
                                      ? const Color.fromARGB(255, 211, 227, 253)
                                      : Colors
                                          .black, // Change this to your desired color
                                ),
                                hintText: 'Sucipto Hiu',
                                labelText: 'New Name',
                                prefixIcon: Icon(
                                  Icons.email,
                                  color: isDarkMode
                                      ? const Color.fromARGB(255, 211, 227, 253)
                                      : Colors.black,
                                ),
                              ),
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
                                            status: 'Changing Name...');

                                        final result = await ChangeNameApi()
                                            .changeName(nameController.text);

                                        EasyLoading.dismiss();

                                        setState(() {
                                          isProcessing = false;
                                        });

                                        if (!context.mounted) return;
                                        if (result['status'] == 'success') {
                                          AwesomeDialog(
                                            context: context,
                                            btnOkColor:
                                                ThemeClass().lightPrimaryColor,
                                            keyboardAware: true,
                                            dismissOnBackKeyPress: false,
                                            dialogType: DialogType.info,
                                            animType: AnimType.scale,
                                            transitionAnimationDuration:
                                                const Duration(
                                                    milliseconds:
                                                        200), // Duration(milliseconds: 300),
                                            btnOkText: "Back",
                                            title: 'Name Changed',
                                            desc:
                                                'We\'ve changed your name, please proceed.',
                                            btnOkOnPress: () {
                                              Get.offAll(() => const HomePage(
                                                    indexFromPrevious: 2,
                                                  ));
                                            },
                                          ).show();
                                        } else {
                                          AwesomeDialog(
                                            context: context,
                                            btnOkColor:
                                                ThemeClass().lightPrimaryColor,
                                            keyboardAware: true,
                                            dismissOnBackKeyPress: false,
                                            dialogType: DialogType.error,
                                            animType: AnimType.scale,
                                            transitionAnimationDuration:
                                                const Duration(
                                                    milliseconds:
                                                        200), // Duration(milliseconds: 300),
                                            btnOkText: "Back",
                                            title: 'Error Occured',
                                            desc:
                                                'There was an error changing your name, please try again.',
                                            btnOkOnPress: () {
                                              Get.back();
                                            },
                                          ).show();
                                        }
                                      }
                                    },
                              child: Text(
                                '   Change   ',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: isDarkMode
                                      ? const Color.fromARGB(255, 211, 227, 253)
                                      : Colors.white,
                                ),
                              ),
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
      ]),
    );
  }
}
