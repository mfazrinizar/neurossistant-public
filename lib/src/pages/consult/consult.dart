import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
// import 'package:neurossistant/src/db/consult/chat_api.dart';
import 'package:neurossistant/src/db/consult/inbox_api.dart';
import 'package:neurossistant/src/localization/app_localizations.dart';
import 'package:neurossistant/src/pages/consult/chat.dart';
import 'package:neurossistant/src/pages/consult/psychologist.dart';
// import 'package:neurossistant/src/pages/profile/profile.dart';
import 'package:neurossistant/src/theme/theme.dart';

class Pengguna {
  final String name;
  final List<String> userTags;
  final String userType;
  final String profilPicture;
  final String rating;
  final String uid;

  Pengguna({
    required this.name,
    required this.userTags,
    required this.userType,
    required this.profilPicture,
    required this.rating,
    required this.uid,
  });

  factory Pengguna.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Pengguna(
      name: data['name'] ?? 'null',
      userTags: data.containsKey('userTags')
          ? List<String>.from(data['userTags'])
          : ['null'],
      userType: data['userType'] ?? 'null',
      profilPicture: data['profilePicture'] ?? 'null',
      rating: data['rating'] ?? 'null',
      uid: data['uid'] ?? 'null',
    );
  }
}

class Consultation {
  final String senderId;
  final String receiverId;
  final String message;
  final DateTime timestamp;

  Consultation({
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'timestamp': timestamp,
    };
  }

  factory Consultation.fromFirestore(DocumentSnapshot doc) {
    return Consultation(
      senderId: doc['senderId'],
      receiverId: doc['receiverId'],
      message: doc['message'],
      timestamp: (doc['timestamp'] as Timestamp).toDate(),
    );
  }
}

class ConsultHome extends StatefulWidget {
  const ConsultHome({super.key});

  @override
  State<ConsultHome> createState() => _ConsultHomeState();
}

class _ConsultHomeState extends State<ConsultHome> {
  bool isDarkMode = Get.isDarkMode;
  final currentUser = FirebaseAuth.instance.currentUser;
  final CollectionReference chats =
      FirebaseFirestore.instance.collection('chats');
  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');

  bool _isMeLastSender(String id) {
    return currentUser?.uid == id;
  }

  // Future<bool> _isPsychologist() {
  //   final currentUser = FirebaseAuth.instance.currentUser;

  //   return users.doc(currentUser?.uid).get().then((userDoc) {
  //     if (userDoc.exists) {
  //       var userData = userDoc.data();
  //       if (userData is Map<String, dynamic>) {
  //         // Memastikan userData memiliki tipe yang sesuai
  //         var userType = userData['userType'];
  //         return userType == 'Psychologist';
  //       } else {
  //         // UserData tidak memiliki tipe yang sesuai
  //         return false;
  //       }
  //     } else {
  //       // Dokumen pengguna tidak ditemukan
  //       return false;
  //     }
  //   }).catchError((error) {
  //     // Tangani error jika terjadi kesalahan saat mengambil dokumen
  //     print('Error fetching user document: $error');
  //     return false;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
        future: users.doc(currentUser?.uid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
                child: Text("Error initializing chat: ${snapshot.error}"));
          }

          var userData = snapshot.data!;

          String userType = userData['userType'];

          return StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('consult')
                  .doc(currentUser?.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                      child:
                          Text("Error initializing chat: ${snapshot.error}"));
                }
                if (snapshot.data!.data() == null) {
                  FirebaseFirestore.instance
                      .collection('consult')
                      .doc(currentUser?.uid)
                      .set({'notSeenInbox': 0});
                }

                Map<String, dynamic> inboxData;
                int notSeenInbox;

                if (snapshot.data!.data() == null) {
                  notSeenInbox = 0;
                  FirebaseFirestore.instance
                      .collection('consult')
                      .doc(currentUser?.uid)
                      .set({'notSeenInbox': 0});
                } else {
                  inboxData = snapshot.data!.data() as Map<String, dynamic>;
                  notSeenInbox = inboxData['notSeenInbox'];
                }

                return Scaffold(
                  appBar: PreferredSize(
                    preferredSize: const Size.fromHeight(65),
                    child: AppBar(
                      surfaceTintColor: Colors.transparent,
                      leading: BackButton(
                        color: isDarkMode
                            ? const Color.fromARGB(255, 211, 227, 253)
                            : Colors.white,
                      ),
                      backgroundColor: isDarkMode
                          ? ThemeClass().darkRounded
                          : ThemeClass().lightPrimaryColor,
                      title: Text(
                          AppLocalizations.of(context)!
                                  .translate('consult_title1') ??
                              'Consultation',
                          style: const TextStyle(
                              fontFamily: "Poppins",
                              color: Colors.white,
                              fontWeight: FontWeight.w500)),
                      shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(bottom: Radius.circular(15)),
                      ),
                      shadowColor: Colors.black,
                      elevation: 7,
                      actions: [
                        Padding(
                          padding: const EdgeInsets.only(right: 10.0),
                          child: IconButton(
                            icon: (notSeenInbox > 0)
                                ? Icon(Icons.mark_email_unread_rounded,
                                    color: isDarkMode
                                        ? const Color.fromARGB(
                                            255, 211, 227, 253)
                                        : Colors.white)
                                : Icon(Icons.mail_rounded,
                                    color: isDarkMode
                                        ? const Color.fromARGB(
                                            255, 211, 227, 253)
                                        : Colors.white),
                            tooltip: AppLocalizations.of(context)!
                                    .translate('consult_mail_tooltip1') ??
                                'Open mail',
                            onPressed: () {
                              Get.to(() => const ConsultInbox());
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: Builder(
                            builder: (BuildContext context) {
                              final user = FirebaseAuth.instance.currentUser;
                              if (user != null && user.photoURL != null) {
                                return InkWell(
                                  borderRadius: BorderRadius.circular(23),
                                  onTap: () {
                                    // ke profil user
                                  },
                                  child: Ink(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                        image: NetworkImage(user.photoURL!),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    child: const SizedBox(
                                      width: 45,
                                      height: 45,
                                    ),
                                  ),
                                ); // display the user's profile picture
                              } else {
                                return Icon(Icons.account_circle,
                                    color: isDarkMode
                                        ? Colors.black
                                        : Colors
                                            .white); // show a default icon if the user is not logged in or doesn't have a profile picture
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  body: StreamBuilder<QuerySnapshot>(
                      stream: chats
                          // .orderBy('lastMessageDate', descending: true)
                          .where('users', arrayContains: currentUser?.uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(
                              child: Text(
                                  "Error fetching chat history: ${snapshot.error}"));
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Center(
                              child: Text(
                            AppLocalizations.of(context)!
                                    .translate('consult_no_message1') ??
                                "Belum ada pesan di sini. Klik tombol + di atas untuk mencari seorang psikolog.",
                            textAlign: TextAlign.center,
                          ));
                        }

                        var chats = snapshot.data!.docs
                            .where((chat) => chat['lastMessage'].isNotEmpty)
                            .toList();

                        chats.sort((a, b) => b['lastMessageDate']
                            .compareTo(a['lastMessageDate']));

                        if (chats.isEmpty) {
                          return Center(
                              child: Text(
                            AppLocalizations.of(context)!
                                    .translate('consult_no_message1') ??
                                "There are no messages here yet. Click the + button above to search for a psychologist",
                            textAlign: TextAlign.center,
                          ));
                        }

                        return ListView.builder(
                          itemCount: chats.length,
                          itemBuilder: (context, index) {
                            var chat = chats[index];
                            var otherUserId = chat['users'].firstWhere(
                                (userId) => userId != currentUser?.uid);
                            return FutureBuilder<DocumentSnapshot>(
                                future: users.doc(otherUserId).get(),
                                builder: (context, userSnapshot) {
                                  if (userSnapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  }
                                  if (userSnapshot.hasError) {
                                    return ListTile(
                                      title: Text(
                                          'Error loading user: ${userSnapshot.error}'),
                                    );
                                  }
                                  if (!userSnapshot.hasData ||
                                      !userSnapshot.data!.exists) {
                                    return const ListTile(
                                      title: Text('User not found'),
                                    );
                                  }

                                  var otherUser = userSnapshot.data!.data()
                                      as Map<String, dynamic>;

                                  var pengguna = Pengguna(
                                    name: otherUser['name'] ?? 'Unknown',
                                    userTags: otherUser['userTags'] != null
                                        ? List<String>.from(
                                            otherUser['userTags'])
                                        : [],
                                    userType:
                                        otherUser['userType'] ?? 'Unknown',
                                    profilPicture:
                                        otherUser['profilePicture'] ?? '',
                                    rating: otherUser['rating'] ?? '0.0',
                                    uid: otherUser['uid'] ?? '',
                                  );

                                  return ListTile(
                                    minVerticalPadding: 22,
                                    title: Text(otherUser['name']),
                                    subtitle: _isMeLastSender(
                                            chat['lasMessageSendById'])
                                        ? Text(
                                            "${AppLocalizations.of(context)!.translate('you') ?? 'You'}: ${chat['lastMessage']}")
                                        : Text(
                                            "${chat['lastMessageSendByName'].split(' ').first}: ${chat['lastMessage']}"),
                                    leading: InkWell(
                                      borderRadius: BorderRadius.circular(28),
                                      onTap: () {
                                        // ke profil pengguna yang ditekan
                                      },
                                      child: Ink(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                            image: NetworkImage(
                                                otherUser['profilePicture']),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        child: const SizedBox(
                                          width: 55,
                                          height: 55,
                                        ),
                                      ),
                                    ),
                                    trailing:
                                        (chat["${currentUser?.uid}-notSeenMessages"] ==
                                                0)
                                            ? null
                                            : Container(
                                                width: 20,
                                                height: 20,
                                                decoration: BoxDecoration(
                                                    color: Colors.red,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            13)),
                                                child: Center(
                                                    child: Text(
                                                  chat["${currentUser?.uid}-notSeenMessages"]
                                                      .toString(),
                                                  style: TextStyle(
                                                      color: isDarkMode
                                                          ? const Color
                                                              .fromARGB(255,
                                                              211, 227, 253)
                                                          : Colors.white),
                                                )),
                                              ),
                                    onTap: () {
                                      Get.to(
                                          () => ChatScreen(pengguna: pengguna));
                                    },
                                  );
                                });
                          },
                        );
                      }),
                  floatingActionButtonLocation: (userType == 'Psychologist')
                      ? null
                      : FloatingActionButtonLocation.centerTop,
                  floatingActionButton: (userType == 'Psychologist')
                      ? null
                      : Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                                color: isDarkMode
                                    ? const Color.fromARGB(255, 105, 105, 117)
                                    : const Color.fromARGB(255, 211, 227, 253),
                                borderRadius: BorderRadius.circular(25)),
                            child: Center(
                              child: IconButton(
                                icon: Icon(
                                  Icons.add_rounded,
                                  size: 35,
                                  color: isDarkMode
                                      ? ThemeClass().darkRounded
                                      : ThemeClass().lightPrimaryColor,
                                ),
                                tooltip: AppLocalizations.of(context)!
                                        .translate(
                                            'consult_plus_button_tooltip1') ??
                                    'Open Psychologist List',
                                onPressed: () {
                                  Get.to(() => const ListPsychologist());
                                },
                              ),
                            ),
                          ),
                        ),
                );
              });
        });
  }
}

class ConsultInbox extends StatefulWidget {
  const ConsultInbox({super.key});

  @override
  State<ConsultInbox> createState() => _ConsultInboxState();
}

class _ConsultInboxState extends State<ConsultInbox> {
  bool isDarkMode = Get.isDarkMode;

  final userId = FirebaseAuth.instance.currentUser!.uid;

  Stream<QuerySnapshot<Map<String, dynamic>>> getInboxData() {
    try {
      final userDoc = FirebaseFirestore.instance
          .collection('consult')
          .doc(userId)
          .collection('inbox')
          .orderBy('inboxDateTime', descending: true)
          .snapshots();
      return userDoc;
    } catch (e) {
      Get.snackbar('Error', e.toString());
      rethrow;
    }
  }

  Future<void> _updateSeenInbox() async {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final chatDocRef =
        FirebaseFirestore.instance.collection('consult').doc(currentUserId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.update(chatDocRef, {
        'notSeenInbox': 0,
      });
    });
  }

  Future<void> _acceptConsultation(Inbox inbox) async {
    final currentUser = FirebaseAuth.instance.currentUser!;
    final chatDocRef = FirebaseFirestore.instance
        .collection('consult')
        .doc(currentUser.uid)
        .collection('inbox')
        .doc(inbox.inboxId);

    if (inbox.consultDate == null) {
      Get.snackbar('Error', 'Consultation date is missing.');
      return;
    }

    String formattedDate =
        DateFormat('dd MMMM yyyy').format(inbox.consultDate!);
    String formattedTime = DateFormat('hh:mm a').format(inbox.consultDate!);

    final inboxBody = {
      'id':
          "${currentUser.displayName} telah menerima permintaan konsultasi Anda pada $formattedDate pukul $formattedTime.",
      'en':
          "${currentUser.displayName} has accepted your consultation request on $formattedDate at $formattedTime."
    };

    final postInbox = await InboxAPI.postInbox(
        inboxBody: inboxBody,
        inboxDateTime: DateTime.now(),
        inboxSenderPhotoUrl: currentUser.photoURL!,
        inboxType: "accept",
        inboxSender: currentUser.displayName!,
        userIdTo: inbox.inboxSenderId,
        inboxSenderId: currentUser.uid,
        consultDate: inbox.consultDate);

    if (mounted) {
      if (postInbox == 'SUCCESS') {
        Get.snackbar(
            AppLocalizations.of(context)!.translate('success') ?? 'Success',
            AppLocalizations.of(context)!
                    .translate('consult_accept_consult_success') ??
                'Successfully sent consultation approval.');
      } else {
        Get.snackbar(
            'Error',
            AppLocalizations.of(context)!
                    .translate('consult_accept_consult_error') ??
                'Something went wrong, check logs.');
      }
    }

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.update(chatDocRef, {
        'inboxType': 'accept',
        'inboxBody': {
          'id':
              'Anda telah menyetujui permintaan konsultasi dari ${inbox.inboxSender} pada $formattedDate pukul $formattedTime.',
          'en':
              'You have agreed to the consultation request from ${inbox.inboxSender} on $formattedDate at $formattedTime.'
        }
      });
    });
  }

  Future<void> _rejectConsultation(Inbox inbox) async {
    final currentUser = FirebaseAuth.instance.currentUser!;
    final chatDocRef = FirebaseFirestore.instance
        .collection('consult')
        .doc(currentUser.uid)
        .collection('inbox')
        .doc(inbox.inboxId);

    if (inbox.rescheduleCount! < 3) {
      DateTime? rescheduleTime = await _datePick();
      if (rescheduleTime != null) {
        String formattedDateTime =
            DateFormat('dd/MM/yy hh:mm a').format(rescheduleTime);
        String formattedDate =
            DateFormat('dd MMMM yyyy').format(rescheduleTime);
        String formattedTime = DateFormat('hh:mm a').format(rescheduleTime);

        final inboxBody = {
          'id': "Penjadwalan ulang pada $formattedDateTime",
          'en': "Reschedule at $formattedDateTime"
        };

        final postInbox = await InboxAPI.sendReschedule(
          inboxBody: inboxBody,
          inboxDateTime: DateTime.now(),
          inboxSenderPhotoUrl: currentUser.photoURL!,
          inboxType: "request",
          inboxSender: currentUser.displayName!,
          inboxSenderId: currentUser.uid,
          userIdTo: inbox.inboxSenderId,
          consultDate: rescheduleTime,
          rescheduleCount: inbox.rescheduleCount!,
        );

        if (mounted) {
          if (postInbox == 'SUCCESS') {
            Get.snackbar(
                AppLocalizations.of(context)!.translate('success') ?? 'Success',
                AppLocalizations.of(context)!
                        .translate('consult_reschedule_consult_success') ??
                    'The consultation has been rescheduled.');
          } else {
            Get.snackbar(
                'Error',
                AppLocalizations.of(context)!
                        .translate('consult_reschedule_consult_error') ??
                    'Something went wrong, check logs.');
          }
        }

        await FirebaseFirestore.instance.runTransaction((transaction) async {
          transaction.update(chatDocRef, {
            'inboxType': 'rescheduled',
            'inboxBody': {
              'id':
                  'Permintaan penjadwalan ulang telah dikirimkan kepada ${inbox.inboxSender} untuk $formattedDate pukul $formattedTime.',
              'en':
                  'Reschedule request to ${inbox.inboxSender} has been sent for $formattedDate at $formattedTime.'
            }
          });
        });
      }
    } else {
      final inboxBody = {
        'id':
            "Konsultasi dengan ${currentUser.displayName} telah dibatalkan karena batas penjadwalan ulang telah tercapai.",
        'en':
            "The consultation with ${currentUser.displayName} has been canceled because the reschedule limit has been reached."
      };

      final postInbox = await InboxAPI.postInbox(
        inboxBody: inboxBody,
        inboxDateTime: DateTime.now(),
        inboxSenderPhotoUrl: currentUser.photoURL!,
        inboxType: "canceled",
        inboxSender: currentUser.displayName!,
        inboxSenderId: currentUser.uid,
        userIdTo: inbox.inboxSenderId,
      );

      if (mounted) {
        if (postInbox == 'SUCCESS') {
          Get.snackbar(
              AppLocalizations.of(context)!.translate('success') ?? 'Success',
              AppLocalizations.of(context)!
                      .translate('consult_reject_consult_success') ??
                  'Consultation cancelled successfully.');
        } else {
          Get.snackbar(
              'Error',
              AppLocalizations.of(context)!
                      .translate('consult_reject_consult_error') ??
                  'Something went wrong, check logs.');
        }
      }

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.update(chatDocRef, {
          'inboxType': 'canceled',
          'inboxBody': {
            'id':
                'Konsultasi dengan ${inbox.inboxSender} telah dibatalkan karena batas penjadwalan ulang telah tercapai.',
            'en':
                'The consultation with ${inbox.inboxSender} has been canceled because the reschedule limit has been reached.'
          }
        });
      });
    }
  }

  Future<DateTime?> _datePick() async {
    DateTime? pickedDate = await showDatePicker(
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
        });

    if (pickedDate != null) {
      return await _timePick(pickedDate);
    }
    return null;
  }

  Future<DateTime?> _timePick(DateTime date) async {
    TimeOfDay now = TimeOfDay.now();
    DateTime currentTime = DateTime(DateTime.now().year, DateTime.now().month,
        DateTime.now().day, now.hour, now.minute);

    TimeOfDay? selectedTime = await showTimePicker(
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
        });

    if (selectedTime != null) {
      DateTime selectedDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        selectedTime.hour,
        selectedTime.minute,
      );
      DateTime oneHourLater = currentTime.add(const Duration(hours: 1));

      if (selectedDateTime.isBefore(oneHourLater)) {
        // ignore: use_build_context_synchronously
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!
                      .translate('consult_time_pick1') ??
                  'Please select a time at least 1 hour from now.'),
            ),
          );
        }
        return await _timePick(date);
      } else {
        return selectedDateTime;
      }
    }
    return null;
  }

  // @override
  // void dispose() {
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(65),
        child: AppBar(
          surfaceTintColor: Colors.transparent,
          leading: BackButton(
            color: isDarkMode
                ? const Color.fromARGB(255, 211, 227, 253)
                : Colors.white,
          ),
          backgroundColor: isDarkMode
              ? ThemeClass().darkRounded
              : ThemeClass().lightPrimaryColor,
          title: Text(
              AppLocalizations.of(context)!.translate('consult_inbox') ??
                  'Inbox',
              style: const TextStyle(
                  fontFamily: "Poppins",
                  color: Colors.white,
                  fontWeight: FontWeight.w500)),
          centerTitle: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
          ),
          shadowColor: Colors.black,
          elevation: 7,
        ),
      ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerTop,
      // floatingActionButton: Padding(
      //   padding: const EdgeInsets.only(top: 12.0),
      //   child: Container(
      //     height: 50,
      //     width: 50,
      //     decoration: BoxDecoration(
      //         color: isDarkMode
      //             ? const Color.fromARGB(255, 105, 105, 117)
      //             : const Color.fromARGB(255, 211, 227, 253),
      //         borderRadius: BorderRadius.circular(25)),
      //     child: Center(
      //       child: IconButton(
      //         icon: Icon(
      //           Icons.add_rounded,
      //           size: 35,
      //           color: isDarkMode
      //               ? ThemeClass().darkRounded
      //               : ThemeClass().lightPrimaryColor,
      //         ),
      //         tooltip: 'add inbox',
      //         onPressed: () async {
      // final postInbox = await InboxAPI.postInbox(
      //     inboxBody:
      //         "Psychologist 1 telah menerima permintaan konsultasi anda pada 05 Juni 2024 pada pukul 08:00 AM.",
      //     inboxDateTime: DateTime.now(),
      //     inboxSenderPhotoUrl:
      //         FirebaseAuth.instance.currentUser!.photoURL!,
      //     inboxType: "accept",
      //     inboxSender:
      //         FirebaseAuth.instance.currentUser!.displayName!,
      //     userIdTo: FirebaseAuth.instance.currentUser!.uid);

      // if (postInbox == 'SUCCESS') {
      //   Get.snackbar('Success', 'Inbox posted successfully.');
      // } else {
      //   Get.snackbar('Error', 'Something went wrong, check logs.');
      // }
      //         },
      //       ),
      //     ),
      //   ),
      // ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: getInboxData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return const Center(
                  child: Text('Error fetching inbox data'),
                );
              } else {
                final inboxList = snapshot.data?.docs.map((doc) {
                      final data = doc.data();
                      Map<String, String> inboxBody;
                      if (data['inboxBody'] is String) {
                        try {
                          inboxBody = Map<String, String>.from(
                              json.decode(data['inboxBody']));
                        } catch (e) {
                          inboxBody = {};

                          if (kDebugMode) {
                            debugPrint('Error decoding inboxBody: $e');
                          }
                        }
                      } else {
                        inboxBody = Map<String, String>.from(data['inboxBody']);
                      }
                      return Inbox(
                        inboxBody: inboxBody,
                        inboxDateTime:
                            (data['inboxDateTime'] as Timestamp).toDate(),
                        inboxSenderPhotoUrl: data['inboxSenderPhotoUrl'],
                        inboxSender: data['inboxSender'],
                        inboxSenderId: data['inboxSenderId'],
                        inboxType: data['inboxType'],
                        inboxId: data['inboxId'],
                        consultDate: data['consultDate'] != null
                            ? (data['consultDate'] as Timestamp).toDate()
                            : null,
                        rescheduleCount: data['rescheduleCount'] ?? 0,
                      );
                    }).toList() ??
                    [];

                _updateSeenInbox();

                final Map<String, List<Inbox>> categorizedInbox =
                    categorizeInbox(inboxList);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (categorizedInbox.containsKey('Today')) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
                        child: Text(
                          AppLocalizations.of(context)?.translate('today') ??
                              'Today',
                          style: const TextStyle(
                            fontFamily: "Poppins",
                            fontWeight: FontWeight.w500,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      ...categorizedInbox['Today']!
                          .map(buildInboxTile)
                          .toList(),
                    ],
                    if (categorizedInbox.containsKey('Yesterday')) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
                        child: Text(
                          AppLocalizations.of(context)
                                  ?.translate('yesterday') ??
                              'Yesterday',
                          style: const TextStyle(
                            fontFamily: "Poppins",
                            fontWeight: FontWeight.w500,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      ...categorizedInbox['Yesterday']!
                          .map(buildInboxTile)
                          .toList(),
                    ],
                    ...categorizedInbox.entries
                        .where((entry) =>
                            entry.key != 'Today' && entry.key != 'Yesterday')
                        .map((entry) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
                            child: Text(
                              entry.key,
                              style: const TextStyle(
                                fontFamily: "Poppins",
                                fontWeight: FontWeight.w500,
                                fontSize: 20,
                              ),
                            ),
                          ),
                          ...entry.value.map(buildInboxTile).toList(),
                        ],
                      );
                    }).toList(),
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Widget buildInboxTile(Inbox inbox) {
    final locale = Get.locale?.toLanguageTag() ?? 'en';
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Container(
        constraints: const BoxConstraints(
          minHeight: 80,
        ),
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: isDarkMode
              ? const Color.fromARGB(255, 105, 105, 117)
              : const Color.fromARGB(255, 211, 227, 253),
          borderRadius: BorderRadius.circular(16),
        ),
        child: inbox.inboxType == 'request'
            ? ListTile(
                title: Text(inbox.inboxSender),
                subtitle: Text(locale == 'en'
                    ? inbox.inboxBody['en'] ?? ''
                    : inbox.inboxBody['id'] ?? ''),
                leading: inbox.inboxSenderPhotoUrl.isNotEmpty
                    ? InkWell(
                        onTap: () {
                          //ke profil pengguna yang ditekan
                        },
                        child: ClipOval(
                          child: FadeInImage.assetNetwork(
                            image: inbox.inboxSenderPhotoUrl,
                            placeholder:
                                'assets/images/placeholder_loading.gif',
                            fit: BoxFit.cover,
                            width: 55,
                            height: 55,
                          ),
                        ),
                      )
                    : Icon(Icons.account_circle,
                        color: isDarkMode ? Colors.black : Colors.white),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                        onPressed: () {
                          _acceptConsultation(inbox);
                        },
                        icon: const Icon(Icons.check)),
                    IconButton(
                        onPressed: () {
                          _rejectConsultation(inbox);
                        },
                        icon: const Icon(Icons.close)),
                  ],
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    inbox.inboxSenderPhotoUrl.isNotEmpty
                        ? InkWell(
                            onTap: () {
                              // ke profil pengguna yang ditekan
                            },
                            child: ClipOval(
                              child: FadeInImage.assetNetwork(
                                image: inbox.inboxSenderPhotoUrl,
                                placeholder:
                                    'assets/images/placeholder_loading.gif',
                                fit: BoxFit.cover,
                                width: 55,
                                height: 55,
                              ),
                            ),
                          )
                        : Icon(
                            Icons.account_circle,
                            color: isDarkMode ? Colors.black : Colors.white,
                            size: 55,
                          ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        locale == 'en'
                            ? inbox.inboxBody['en']!
                            : inbox.inboxBody['id']!,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Map<String, List<Inbox>> categorizeInbox(List<Inbox> inboxList) {
    final Map<String, List<Inbox>> categorizedInbox = {};

    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    final dateFormat = DateFormat('d MMM');

    for (var inbox in inboxList) {
      final inboxDate = inbox.inboxDateTime;
      String category;

      if (inboxDate.year == today.year &&
          inboxDate.month == today.month &&
          inboxDate.day == today.day) {
        category = 'Today';
      } else if (inboxDate.year == yesterday.year &&
          inboxDate.month == yesterday.month &&
          inboxDate.day == yesterday.day) {
        category = 'Yesterday';
      } else {
        category = dateFormat.format(inboxDate);
      }

      if (!categorizedInbox.containsKey(category)) {
        categorizedInbox[category] = [];
      }

      categorizedInbox[category]!.add(inbox);
    }

    return categorizedInbox;
  }
}

// class PsychologistListScreen extends StatelessWidget {
//   const PsychologistListScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold();
//   }
// }

// class PsychologistListItem extends StatelessWidget {
//   final User psychologist;

//   const PsychologistListItem(this.psychologist, {super.key});

//   @override
//   Widget build(BuildContext context) {
//     return ListTile(
//       title: Text(psychologist.name),
//       subtitle:
//           Text('Neurodivergent tags: ${psychologist.userTags.join(', ')}'),
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => ChatScreen(psychologist),
//           ),
//         );
//       },
//     );
//   }
// }

// class ChatScreen extends StatelessWidget {
//   final User psychologist;

//   const ChatScreen(this.psychologist, {super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Chat with ${psychologist.name}'),
//       ),
//       body: const Center(
//         child: Text('Chat UI goes here'),
//       ),
//     );
//   }
// }

// void main() {
//   runApp(const MaterialApp(
//     home: PsychologistListScreen(),
//   ));
// }
