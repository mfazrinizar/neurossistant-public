import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:neurossistant/src/localization/app_localizations.dart';
import 'package:neurossistant/src/pages/consult/consult.dart';
import 'package:neurossistant/src/pages/profile/profile.dart';
import 'package:neurossistant/src/theme/theme.dart';
// import 'package:rxdart/rxdart.dart';

class PsychologistUserData {
  final List<DocumentSnapshot> docs;

  PsychologistUserData(this.docs);
}

class ListPsychologist extends StatefulWidget {
  const ListPsychologist({super.key});

  @override
  State<ListPsychologist> createState() => _ListPsychologistState();
}

class _ListPsychologistState extends State<ListPsychologist> {
  bool isDarkMode = Get.isDarkMode;

  String getTodayDate() {
    final now = DateTime.now();
    final day = now.day.toString().padLeft(2, '0');
    final month = now.month.toString().padLeft(2, '0');
    final year = now.year.toString().substring(2);

    return '$day/$month/$year';
  }

  Future<PsychologistUserData> getPsychologistUsers() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    // Fetch users excluding the current user
    QuerySnapshot snapshot1 = await FirebaseFirestore.instance
        .collection('users')
        .where('uid', isNotEqualTo: uid)
        .get();

    // Fetch users with userType 'Psychologist'
    QuerySnapshot snapshot2 = await FirebaseFirestore.instance
        .collection('users')
        .where('userType', isEqualTo: 'Psychologist')
        .get();

    // Create sets for intersection
    Set<String> set1 = snapshot1.docs.map((doc) => doc.id).toSet();
    Set<String> set2 = snapshot2.docs.map((doc) => doc.id).toSet();

    // Find the intersection
    Set<String> intersection = set1.intersection(set2);

    // Filter documents based on the intersection
    List<DocumentSnapshot> intersectedDocs =
        snapshot1.docs.where((doc) => intersection.contains(doc.id)).toList();

    return PsychologistUserData(intersectedDocs);
  }

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
                AppLocalizations.of(context)!
                        .translate('consult_psychologist_title1') ??
                    'List of Psychologists',
                style: const TextStyle(
                    fontFamily: "Poppins",
                    color: Colors.white,
                    fontWeight: FontWeight.w500)),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
            ),
            shadowColor: Colors.black,
            elevation: 7,
            actions: [
              IconButton(
                icon: Icon(Icons.search,
                    color: isDarkMode
                        ? const Color.fromARGB(255, 211, 227, 253)
                        : Colors.white),
                tooltip: AppLocalizations.of(context)!
                        .translate('consult_psychologist_search1') ??
                    'Search for Psychologist',
                onPressed: () {
                  // handle the press
                },
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: IconButton(
                  icon: Icon(Icons.more_vert_rounded,
                      color: isDarkMode
                          ? const Color.fromARGB(255, 211, 227, 253)
                          : Colors.white),
                  tooltip: AppLocalizations.of(context)!
                          .translate('consult_psychologist_other_tooltip1') ??
                      'Other',
                  onPressed: () {
                    // handle the press
                  },
                ),
              ),
            ],
          ),
        ),
        body: FutureBuilder<PsychologistUserData>(
          future: getPsychologistUsers(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.hasError) {
              return const Center(
                child: Text('Error fetching psychologists'),
              );
            }
            final List<Pengguna> psychologists = snapshot.data!.docs
                .map((doc) => Pengguna.fromFirestore(doc))
                .toList();
            return ListView.builder(
              itemCount: psychologists.length,
              itemBuilder: (context, index) {
                final psychologist = psychologists[index];
                return ListTile(
                  minVerticalPadding: 22,
                  title: Text(psychologist.name),
                  subtitle: Text(AppLocalizations.of(context)!
                          .translate('consult_psychologist_specializing1') ??
                      "Spesialis di bidang..."),
                  leading: CircleAvatar(
                    radius: 28,
                    backgroundImage: NetworkImage(psychologist.profilPicture),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.star,
                        size: 15,
                        color: Colors.amber,
                      ),
                      Text("${psychologist.rating}/5"),
                    ],
                  ),
                  onTap: () {
                    Get.to(() => ProfilePage(
                          pengguna: psychologist,
                        ));
                  },
                );
              },
            );
          },
        ));
  }
}

class PsychologistChatList extends StatelessWidget {
  const PsychologistChatList({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('userType', isEqualTo: 'Psychologist')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return const Center(
            child: Text('Error fetching psychologists'),
          );
        }
        final List<Pengguna> psychologists = snapshot.data!.docs
            .map((doc) => Pengguna.fromFirestore(doc))
            .toList();
        return ListView.builder(
          itemCount: psychologists.length,
          itemBuilder: (context, index) {
            return PsychologistChatListItem(psychologists[index]);
          },
        );
      },
    );
  }
}

class PsychologistChatListItem extends StatelessWidget {
  final Pengguna psychologist;

  const PsychologistChatListItem(this.psychologist, {super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(psychologist.name),
      subtitle: Text(
          '${AppLocalizations.of(context)!.translate('consult_parent_nd_tags1') ?? 'Neurodivergent tags:'} ${psychologist.userTags.join(', ')}'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PsychologistChatScreen(psychologist),
          ),
        );
      },
    );
  }
}

class PsychologistChatScreen extends StatelessWidget {
  final Pengguna psychologist;

  const PsychologistChatScreen(this.psychologist, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with ${psychologist.name}'),
      ),
      body: const Center(
        child: Text('Chat UI goes here'),
      ),
    );
  }
}
