// settings.dart

import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_exit_app/flutter_exit_app.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:neurossistant/src/db/auth/logout_api.dart';
import 'package:neurossistant/src/db/push_notification/push_notification_api.dart';

import 'package:neurossistant/src/db/settings/change_profile_picture_api.dart';
import 'package:neurossistant/src/localization/app_localizations.dart';
import 'package:neurossistant/src/pages/article/article_upload.dart';
import 'package:neurossistant/src/pages/campaign/campaign_upload.dart';
import 'package:neurossistant/src/pages/course/course_upload.dart';
// import 'package:neurossistant/src/pages/settings/change_name.dart';
import 'package:neurossistant/src/pages/settings/payment_history.dart';
import 'package:neurossistant/src/reusable_func/file_picking.dart';
import 'package:neurossistant/src/theme/theme.dart';

import 'change_email.dart';
import 'change_password.dart';

class SettingsPage extends StatefulWidget {
  final double height;
  final double width;
  final bool isDarkMode;
  final List<String> buttonTitlesEn;
  final List<String> buttonTitlesId;
  final List<IconData> buttonIcons;
  final List<String> imgList;
  final List<String> urlList;
  final CarouselController controller;
  final Function launchUrl;
  final int current;

  const SettingsPage({
    super.key,
    required this.height,
    required this.width,
    required this.isDarkMode,
    required this.buttonTitlesEn,
    required this.buttonTitlesId,
    required this.buttonIcons,
    required this.imgList,
    required this.urlList,
    required this.controller,
    required this.launchUrl,
    required this.current,
  });

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  final user = FirebaseAuth.instance.currentUser;
  final pushNotificationApi = PushNotificationAPI();
  bool isProcessing = false;

  Future<DocumentSnapshot> getUserData() async {
    try {
      pushNotificationApi.storeDeviceToken();
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();
      return userDoc;
    } catch (e) {
      Get.snackbar('Error', e.toString());
      rethrow;
    }
  }

  File? newProfileImage;
  final filePicking = FilePicking();
  int current = 0;
  bool isDarkMode = Get.isDarkMode;
  String userType = 'Parent'; // Psychologist

  @override
  void initState() {
    super.initState();
    current = widget.current;
    isDarkMode = Get.isDarkMode;
  }

  @override
  Widget build(context) {
    final locale = Get.locale?.toLanguageTag() ?? 'en';
    List<Map<String, Object>> tilesData = [
      // {
      //   'icon': Icons.upload,
      //   'titleEn': 'Upload Article',
      //   'titleId': 'Unggah Artikel',
      //   'onTap': () {
      //     Get.to(() => const UploadArticlePage());
      //   }
      // },
      {
        'icon': Icons.payment,
        'titleEn': 'Payment History',
        'titleId': 'Riwayat Pembayaran',
        'onTap': () {
          Get.to(() => const PaymentHistoryPage());
        }
      },
      // {
      //   'icon': Icons.person,
      //   'titleEn': 'Change Name',
      //   'titleId': 'Ubah Nama',
      //   'onTap': () {
      //     Get.to(() => const ChangeNamePage());
      //   }
      // },
      {
        'icon': Icons.email,
        'titleEn': 'Change Email',
        'titleId': 'Ubah Email',
        'onTap': () {
          Get.to(() => const ChangeEmailPage());
        }
      },
      {
        'icon': Icons.lock,
        'titleEn': 'Change Password',
        'titleId': 'Ubah Kata Sandi',
        'onTap': () {
          Get.to(() => const ChangePasswordPage());
        }
      },
      {
        'icon': Icons.exit_to_app,
        'titleEn': 'Exit App',
        'titleId': 'Keluar Aplikasi',
        'onTap': () {
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
            btnOkText: AppLocalizations.of(context)!.translate('yes') ?? 'Yes',
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
      {
        'icon': Icons.logout,
        'titleEn': 'Logout',
        'titleId': 'Keluar Akun',
        'onTap': () async {
          AwesomeDialog(
            context: context,
            dialogType: DialogType.question,
            headerAnimationLoop: false,
            animType: AnimType.bottomSlide,
            title:
                AppLocalizations.of(context)!.translate('settings_logout1') ??
                    'Logout',
            desc: AppLocalizations.of(context)!
                    .translate('settings_logout_desc1') ??
                'Are you sure you want to logout?',
            btnOkText: AppLocalizations.of(context)!.translate('yes') ?? 'Yes',
            btnCancelText:
                AppLocalizations.of(context)!.translate('cancel') ?? 'Cancel',
            btnCancelOnPress: () {},
            btnOkOnPress: () async {
              await LogoutAPI().logout();
              // Get.to(() => const OnboardingScreen());
            },
          ).show();
        }
      },
      // {
      //   'icon': Icons.notifications,
      //   'title': 'Push Notification',
      //   'onTap': () async {
      //     final pushNotificationApi = PushNotificationAPI();

      //     final fetchedToken =
      //         await pushNotificationApi.fetchDeviceToken(user?.uid ?? "");

      //     Map<String, dynamic> data = {
      //       'poster': {
      //         'tokens': fetchedToken ?? [],
      //         'title': 'title of the post owner',
      //         'body': 'body post',
      //         'imageUrl': 'nothing',
      //         'screen': 'screen',
      //         'dataId': 'id',
      //       },
      //       'commenter': {
      //         'tokens': fetchedToken ?? [],
      //         'title': 'title of the post commenter',
      //         'body': 'body comment',
      //         'imageUrl': 'nothing',
      //         'screen': 'screen',
      //         'dataId': 'id',
      //       },
      //     };

      //     await pushNotificationApi.multiUserTypeSendNotification(data: data);
      //     // await pushNotificationApi.sendNotification([
      //     //   "fniV8JHCSWC8UPIc3QDP2n:APA91bHoc3sF8flF6_SsA8IBfBzuMPqhoTu7mprsbXe_UldPr0lHmjUIFCmT-4MdtU3HMH3k1tlHJFzUor1L1yFP17wwkVlxcxHAf7XbH-zQINEpiJRkdqAS758glvfZYkuAEQ239OxZ"
      //     // ], "title", "body", "nothing");
      //   },
      // }
    ];
    return FutureBuilder<DocumentSnapshot>(
      future: getUserData(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const CircularProgressIndicator(
                  color: Colors.blueAccent,
                ),
                const SizedBox(height: 20),
                Text(AppLocalizations.of(context)!
                        .translate('settings_loading1') ??
                    'Loading Settings...'),
              ],
            ),
          );
        } else {
          final userDoc = snapshot.data;

          if (userDoc == null || !userDoc.exists) {
            return Container();
          }
          final userType = userDoc['userType'];
          List<String>? userTags;
          if (userType == 'Parent' && userDoc['userTags'] is List) {
            userTags = (userDoc['userTags'] as List)
                .map((item) => item.toString())
                .toList();
          }
          final userData = userDoc.data() as Map<String, dynamic>?;
          if (userData != null &&
              userData.containsKey('adminAccess') &&
              userData['adminAccess'] == true &&
              tilesData.length < 7) {
            // tilesData.length < 8 if with Change Name
            tilesData.add(
              {
                'icon': Icons.article,
                'titleEn': 'Upload Article',
                'titleId': 'Unggah Artikel',
                'onTap': () {
                  Get.to(() => const ArticleUploadPage());
                }
              },
            );

            tilesData.add(
              {
                'icon': Icons.campaign,
                'titleEn': 'Upload Campaign',
                'titleId': 'Unggah Kampanye',
                'onTap': () {
                  Get.to(() => const CampaignUploadPage());
                }
              },
            );

            tilesData.add(
              {
                'icon': Icons.document_scanner,
                'titleEn': 'Upload Course',
                'titleId': 'Unggah Kursus',
                'onTap': () {
                  Get.to(() => const UploadCoursePage());
                }
              },
            );
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                    height: widget.height * 0.01, width: widget.width * 0.01),
                // 1. User avatar
                CircleAvatar(
                  backgroundColor: Colors.transparent,
                  radius: widget.height * 0.125,
                  backgroundImage: newProfileImage != null
                      ? FileImage(newProfileImage!)
                      : user != null && user!.photoURL != null
                          ? NetworkImage(user!.photoURL!)
                          : const AssetImage('assets/icons/logo.png')
                              as ImageProvider<Object>?,
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      width: widget.height * 0.1,
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? ThemeClass().darkRounded
                            : ThemeClass().lightPrimaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: isProcessing
                            ? null
                            : () async {
                                final action = await showDialog<String>(
                                  context: context,
                                  builder: (BuildContext context) =>
                                      AlertDialog(
                                    title: Text(AppLocalizations.of(context)!
                                            .translate(
                                                'image_dialog_choose_an_action1') ??
                                        'Choose an action'),
                                    content: Text(AppLocalizations.of(context)!
                                            .translate(
                                                'image_dialog_take_a_photo_source1') ??
                                        'Pick an image from the gallery or take a new photo?'),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, 'Gallery'),
                                        child: Text(
                                          AppLocalizations.of(context)!
                                                  .translate(
                                                      'image_dialog_gallery1') ??
                                              'Gallery',
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                          .brightness ==
                                                      Brightness.dark
                                                  ? Colors.white
                                                  : Colors.black),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, 'Camera'),
                                        child: Text(
                                          AppLocalizations.of(context)!
                                                  .translate(
                                                      'image_dialog_camera1') ??
                                              'Camera',
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                          .brightness ==
                                                      Brightness.dark
                                                  ? Colors.white
                                                  : Colors.black),
                                        ),
                                      ),
                                    ],
                                  ),
                                );

                                ImageSource source;
                                if (action == 'Gallery') {
                                  source = ImageSource.gallery;
                                } else if (action == 'Camera') {
                                  source = ImageSource.camera;
                                } else {
                                  // The user cancelled the dialog
                                  return;
                                }

                                final pickedImage =
                                    await filePicking.pickImage(source);
                                final changeProfilePictureApi =
                                    ChangeProfilePictureApi();
                                if (user != null && pickedImage != null) {
                                  if (context.mounted) {
                                    EasyLoading.show(
                                        status: AppLocalizations.of(context)!
                                                .translate(
                                                    'settings_uploading1') ??
                                            'Uploading...');
                                  }
                                  setState(() {
                                    isProcessing = true;
                                  });

                                  final status = await changeProfilePictureApi
                                      .changeProfilePicture(pickedImage);
                                  if (status) {
                                    setState(() {
                                      newProfileImage = pickedImage;
                                      isProcessing = false;
                                    });

                                    if (context.mounted) {
                                      Get.snackbar(
                                          AppLocalizations.of(context)!
                                                  .translate('success') ??
                                              'Success',
                                          AppLocalizations.of(context)!.translate(
                                                  'settings_uploading_success') ??
                                              'Image uploaded successfully.');
                                    }
                                  } else {
                                    setState(() {
                                      isProcessing = false;
                                    });
                                    if (context.mounted) {
                                      Get.snackbar(
                                          'Error',
                                          AppLocalizations.of(context)!.translate(
                                                  'settings_uploading_error1') ??
                                              'Failed to upload image.');
                                    }
                                  }
                                  EasyLoading.dismiss();
                                }
                              },
                        icon: Icon(
                          Icons.camera_alt,
                          color: isProcessing
                              ? Colors.grey
                              : Theme.of(context).brightness == Brightness.dark
                                  ? const Color.fromARGB(255, 211, 227, 253)
                                  : Colors.white,
                          size: widget.height * 0.05,
                        ),
                      ),
                    ),
                  ), // Replace with your image path
                ),
                // 2. Neurodivergent tags
                Text(
                  user != null && user!.displayName != null
                      ? user!.displayName!
                      : AppLocalizations.of(context)!.translate('guest') ??
                          'Guest',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                (userType != null && userType == 'Parent')
                    ? Wrap(
                        spacing: 8.0, // gap between adjacent chips
                        runSpacing: 4.0, // gap between lines
                        children: (userTags ?? [])
                            .map((String tag) => Chip(label: Text(tag)))
                            .toList(),
                      )
                    : Wrap(
                        spacing: 8.0, // gap between adjacent chips
                        runSpacing: 4.0, // gap between lines
                        children: [
                          Chip(
                            label: Text(AppLocalizations.of(context)!
                                    .translate('psychologist') ??
                                'Psychologist'),
                          )
                        ],
                      ),
                if (userType == 'Parent')
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton.icon(
                        onPressed: () async {
                          // List<String>? initialTagsTemp = userTags;
                          final result = await showDialog<List<String>>(
                            context: context,
                            builder: (context) => TagSelectionDialog(
                              initialTags: userTags!,
                              availableTags: const [
                                'ADHD',
                                'DCD',
                                'Dyslexia',
                                'Others'
                              ],
                            ),
                          );

                          if (result != null) {
                            setState(
                              () {
                                userTags = result;
                              },
                            );

                            // Update the userTags field in Firestore
                            final user = FirebaseAuth.instance.currentUser;
                            if (user != null) {
                              FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(user.uid)
                                  .update({'userTags': userTags});
                            }
                          }
                          // else {
                          //   setState(
                          //     () {
                          //       userTags = initialTagsTemp;
                          //     },
                          //   );
                          // }
                        },
                        icon: Icon(
                          Icons.edit,
                          size: 24,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? const Color.fromARGB(255, 211, 227, 253)
                              : Colors.black,
                        ),
                        label: Text(
                          AppLocalizations.of(context)!
                                  .translate('settings_select_needs1') ??
                              'Edit Needs',
                          style: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? const Color.fromARGB(255, 211, 227, 253)
                                    : Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),

                // 3. List tile button
                Column(
                  children: tilesData.map(
                    (tile) {
                      return _buildListTile(
                          tile['icon'] as IconData,
                          (locale == 'en' ? tile['titleEn'] : tile['titleId'])
                              as String,
                          tile['onTap'] as void Function(),
                          context);
                    },
                  ).toList(),
                )
              ],
            ),
          );
        }
      },
    );
  }
}

Widget _buildListTile(
    IconData icon, String title, VoidCallback onTap, BuildContext context) {
  bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
  return Padding(
    padding: const EdgeInsets.only(left: 16.0, right: 16.0),
    child: Card(
      color: isDarkMode
          ? ThemeClass().darkRounded
          : ThemeClass().lightPrimaryColor,
      elevation: 5.0, // Adjust as needed
      shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(16)), // Adjust color and width as needed
      child: ListTile(
        leading: Icon(icon,
            color: isDarkMode
                ? const Color.fromARGB(255, 211, 227, 253)
                : Colors.white),
        title: Text(title,
            style: TextStyle(
                color: isDarkMode
                    ? const Color.fromARGB(255, 211, 227, 253)
                    : Colors.white)),
        onTap: onTap,
      ),
    ),
  );
}

class TagSelectionDialog extends StatefulWidget {
  final List<String> initialTags;
  final List<String> availableTags;

  const TagSelectionDialog({
    super.key,
    required this.initialTags,
    required this.availableTags,
  });

  @override
  TagSelectionDialogState createState() => TagSelectionDialogState();
}

class TagSelectionDialogState extends State<TagSelectionDialog> {
  late List<String> selectedTags;

  @override
  void initState() {
    super.initState();
    selectedTags = widget.initialTags;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
          AppLocalizations.of(context)!.translate('settings_select_needs1') ??
              'Select Need(s)'),
      content: Wrap(
        spacing: 8.0,
        runSpacing: 4.0,
        children: widget.availableTags.map(
          (tag) {
            return FilterChip(
              label: Text(
                tag,
                style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color.fromARGB(255, 211, 227, 253)
                        : Theme.of(context).primaryColorLight),
              ),
              selected: selectedTags.contains(tag),
              onSelected: (isSelected) {
                setState(
                  () {
                    if (isSelected) {
                      selectedTags.add(tag);
                    } else {
                      selectedTags.remove(tag);
                    }
                  },
                );
              },
            );
          },
        ).toList(),
      ),
      actions: [
        TextButton(
          child: Text(
            AppLocalizations.of(context)!.translate('cancel') ?? 'Cancel',
            style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color.fromARGB(255, 211, 227, 253)
                    : Theme.of(context).primaryColorLight),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text(
            'OK',
            style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color.fromARGB(255, 211, 227, 253)
                    : Theme.of(context).primaryColorLight),
          ),
          onPressed: () {
            Navigator.of(context).pop(selectedTags);
          },
        ),
      ],
    );
  }
}
