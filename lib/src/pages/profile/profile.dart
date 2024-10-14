import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:neurossistant/src/localization/app_localizations.dart';
import 'package:neurossistant/src/pages/consult/consult.dart';
import 'package:neurossistant/src/pages/profile/parent_profile.dart';
import 'package:neurossistant/src/pages/profile/psychologist_profile.dart';

class ProfilePage extends StatefulWidget {
  final Pengguna pengguna;

  const ProfilePage({super.key, required this.pengguna});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isDarkMode = Get.isDarkMode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
              widget.pengguna.userType == "Parent"
                  ? AppLocalizations.of(context)!.translate('parent_profile') ??
                      "Parent Profile"
                  : widget.pengguna.userType == "Psychologist"
                      ? AppLocalizations.of(context)!
                              .translate('psychologist_profile') ??
                          "Psychologist Profile"
                      : AppLocalizations.of(context)!.translate('profile') ??
                          "Profile",
              style: const TextStyle(
                  fontFamily: "Poppins",
                  color: Colors.white,
                  fontWeight: FontWeight.w400)),
          centerTitle: true,
          leading: BackButton(
            color: isDarkMode
                ? const Color.fromARGB(255, 211, 227, 253)
                : Colors.white,
          ),
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.black,
          elevation: 7,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                icon: Icon(Icons.more_vert_rounded,
                    color: isDarkMode
                        ? const Color.fromARGB(255, 211, 227, 253)
                        : Colors.white),
                tooltip: 'Other',
                onPressed: () {
                  // handle the press
                },
              ),
            ),
          ],
        ),
        body: widget.pengguna.userType == 'Psychologist'
            ? PsychologistProfile(pengguna: widget.pengguna)
            : ParentProfile(pengguna: widget.pengguna));
  }
}
