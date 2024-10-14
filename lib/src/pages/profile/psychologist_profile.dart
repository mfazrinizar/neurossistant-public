import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:neurossistant/src/localization/app_localizations.dart';
import 'package:neurossistant/src/pages/consult/consult.dart';

import '../../db/consult/inbox_api.dart';
import '../../theme/theme.dart';
import '../consult/chat.dart';

class PsychologistProfile extends StatefulWidget {
  final Pengguna pengguna;
  const PsychologistProfile({super.key, required this.pengguna});

  @override
  State<PsychologistProfile> createState() => _PsychologistProfileState();
}

class _PsychologistProfileState extends State<PsychologistProfile> {
  bool isDarkMode = Get.isDarkMode;
  final locale = Get.locale?.toLanguageTag() ?? 'en';

  void _datePick(BuildContext context) {
    showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2045),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: ThemeData(
              colorScheme: ColorScheme.light(
                surface: isDarkMode ? Colors.grey[900]! : Colors.grey[200]!,
                primary: isDarkMode
                    ? ThemeClass().lightPrimaryColor
                    : Colors.blue, // Header background color
                onPrimary: isDarkMode
                    ? Colors.white
                    : Colors.black, // Header text color
                onSurface:
                    isDarkMode ? Colors.white : Colors.black, // Body text color
              ),
              dialogBackgroundColor: isDarkMode
                  ? Colors.grey[900]
                  : Colors.white, // Background color
            ),
            child: child!,
          );
        }).then((value) {
      if (value != null) {
        _timePick(context, value);
      }
    });
  }

  void _timePick(BuildContext context, DateTime date) {
    TimeOfDay now = TimeOfDay.now();
    DateTime currentTime = DateTime(DateTime.now().year, DateTime.now().month,
        DateTime.now().day, now.hour, now.minute);

    showTimePicker(
        context: context,
        initialTime: now,
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: ThemeData(
              colorScheme: ColorScheme.light(
                surface: isDarkMode ? Colors.grey[900]! : Colors.grey[200]!,
                primary: isDarkMode
                    ? ThemeClass().lightPrimaryColor
                    : Colors.blue, // Header background color
                onPrimary: isDarkMode
                    ? Colors.white
                    : Colors.black, // Header text color
                onSurface:
                    isDarkMode ? Colors.white : Colors.black, // Body text color
              ),
              dialogBackgroundColor: isDarkMode
                  ? Colors.grey[900]
                  : Colors.white, // Background color
            ),
            child: child!,
          );
        }).then((selectedTime) {
      if (selectedTime != null) {
        DateTime selectedDateTime = DateTime(date.year, date.month, date.day,
            selectedTime.hour, selectedTime.minute);
        DateTime oneHourLater = currentTime.add(const Duration(hours: 1));

        if (selectedDateTime.isBefore(oneHourLater)) {
          // Show a message to the user and reopen the time picker
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(locale == 'en'
                    ? 'Please select a time at least 1 hour from now.'
                    : 'Mohon pilih waktu setidaknya 1 jam dari sekarang.')),
          );
          _timePick(context, date);
        } else {
          String formattedDateTimeForBody =
              DateFormat('dd/MM/yy hh:mm a').format(selectedDateTime);
          _sendConsultRequest(formattedDateTimeForBody, selectedDateTime);
        }
      }
    });
  }

  Future<void> _sendConsultRequest(String time, DateTime date) async {
    final inboxBody = {'id': time, 'en': time};
    final postInbox = await InboxAPI.postInbox(
        inboxBody: inboxBody,
        inboxDateTime: DateTime.now(),
        inboxSenderPhotoUrl: FirebaseAuth.instance.currentUser!.photoURL!,
        inboxType: "request",
        inboxSender: FirebaseAuth.instance.currentUser!.displayName!,
        inboxSenderId: FirebaseAuth.instance.currentUser!.uid,
        userIdTo: widget.pengguna.uid,
        consultDate: date);

    if (postInbox == 'SUCCESS') {
      Get.snackbar(
          'Success',
          locale == 'en'
              ? 'Consult requested successfully.'
              : 'Konsultasi berhasil diminta');
    } else {
      Get.snackbar(
          'Error',
          locale == 'en'
              ? 'Something went wrong, try again.'
              : 'Terjadi kesalahan, coba lagi');
    }
  }

  @override
  Widget build(BuildContext context) {
    const reviewTemp = 0;
    const experienceTemp = 4;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Builder(
            builder: (BuildContext context) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(0, 30, 0, 25),
                child: Center(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(80),
                    onTap: () {
                      // ke profil pengguna yang ditekan
                    },
                    child: Ink(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: NetworkImage(widget.pengguna.profilPicture),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: const SizedBox(
                        width: 150,
                        height: 150,
                      ),
                    ),
                  ),
                ),
              ); // display the user's profile picture
            },
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Text(
              widget.pengguna.name,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                  onPressed: () {
                    Get.to(() => ChatScreen(
                          pengguna: widget.pengguna,
                        ));
                  },
                  style: ButtonStyle(
                      foregroundColor: WidgetStateProperty.all<Color>(
                          ThemeClass().lightPrimaryColor),
                      backgroundColor: WidgetStateProperty.all<Color>(isDarkMode
                          ? ThemeClass().darkPrimaryColor
                          : Colors.white),
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                              side: BorderSide(
                                  color: ThemeClass().lightPrimaryColor,
                                  width: 2))),
                      minimumSize: WidgetStateProperty.all<Size>(
                          Size(MediaQuery.of(context).size.width / 2.6, 60))),
                  child: Text(
                    AppLocalizations.of(context)!
                            .translate('psychologist_profile_consult_chat1') ??
                        "Chat",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  )),
              const SizedBox(
                width: 12,
              ),
              ElevatedButton(
                  onPressed: () => _datePick(context),
                  style: ButtonStyle(
                      foregroundColor:
                          WidgetStateProperty.all<Color>(Colors.white),
                      backgroundColor: WidgetStateProperty.all<Color>(
                          ThemeClass().lightPrimaryColor),
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                              side: BorderSide(
                                  color: ThemeClass().lightPrimaryColor))),
                      minimumSize: WidgetStateProperty.all<Size>(
                          Size(MediaQuery.of(context).size.width / 2.6, 60)),
                      maximumSize: WidgetStateProperty.all<Size>(
                          Size(MediaQuery.of(context).size.width / 2, 60))),
                  child: Text(
                    AppLocalizations.of(context)!.translate(
                            'psychologist_profile_consult_appointment') ??
                        "Make Appointment",
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  )),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Divider(
              color: isDarkMode
                  ? Colors.white
                  : const Color.fromARGB(255, 75, 74, 74),
              thickness: 0.7,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 10, 30, 40),
            child: Container(
              // constraints: BoxConstraints(minHeight: 400),
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: isDarkMode
                    ? const Color.fromARGB(255, 41, 41, 41)
                    : const Color.fromARGB(255, 230, 230, 230),
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: isDarkMode
                        ? Colors.transparent
                        : const Color.fromARGB(255, 74, 74, 74),
                    blurRadius: 6,
                    spreadRadius: 0,
                    offset: const Offset(0, 2), // Shadow position
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Flexible(
                          child: Text(
                            AppLocalizations.of(context)!.translate(
                                    'psychologist_profile_consult_experience') ??
                                "Experience",
                            style: TextStyle(
                                fontSize: 16,
                                color: isDarkMode
                                    ? Colors.grey[300]
                                    : Colors.grey[900]),
                          ),
                        ),
                        Flexible(
                          child: Text(
                            "4 ${(AppLocalizations.of(context)!.translate('year') ?? 'Year') + (locale == 'en' && experienceTemp > 1 ? 's' : '')}",
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                            textAlign: TextAlign.right,
                            // overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Flexible(
                          child: Text(
                            AppLocalizations.of(context)!.translate(
                                    'psychologist_profile_consult_education') ??
                                "Educational Background",
                            style: TextStyle(
                                fontSize: 16,
                                color: isDarkMode
                                    ? Colors.grey[300]
                                    : Colors.grey[900]),
                          ),
                        ),
                        const Flexible(
                          child: Text(
                            "S2 Psikologi Universitas Sriwijaya",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Flexible(
                          child: Text(
                            AppLocalizations.of(context)!.translate(
                                    'psychologist_profile_consult_practice') ??
                                "Practice Place",
                            style: TextStyle(
                                fontSize: 16,
                                color: isDarkMode
                                    ? Colors.grey[300]
                                    : Colors.grey[900]),
                          ),
                        ),
                        const Flexible(
                          child: Text(
                            "Rumah Sakit Umum Palembang",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Flexible(
                          child: Text(
                            AppLocalizations.of(context)!.translate(
                                    'psychologist_profile_consult_domicile') ??
                                "Domicile",
                            style: TextStyle(
                                fontSize: 16,
                                color: isDarkMode
                                    ? Colors.grey[300]
                                    : Colors.grey[900]),
                          ),
                        ),
                        const Flexible(
                          child: Text(
                            "Palembang",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Flexible(
                          child: Text(
                            AppLocalizations.of(context)!.translate(
                                    'psychologist_profile_consult_fee') ??
                                "Consultation Fee",
                            style: TextStyle(
                                fontSize: 16,
                                color: isDarkMode
                                    ? Colors.grey[300]
                                    : Colors.grey[900]),
                          ),
                        ),
                        const Flexible(
                          child: Text(
                            "Rp.0—Rp.1.000.000",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Flexible(
                          child: Text(
                            AppLocalizations.of(context)!.translate(
                                    'psychologist_profile_consult_rating') ??
                                "Rating",
                            style: TextStyle(
                                fontSize: 16,
                                color: isDarkMode
                                    ? Colors.grey[300]
                                    : Colors.grey[900]),
                          ),
                        ),
                        Flexible(
                          child: Text(
                            "⭐${widget.pengguna.rating} | 0 ${(AppLocalizations.of(context)!.translate('review') ?? 'Review') + (locale == 'en' && reviewTemp > 1 ? 's' : '')}",
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
