import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neurossistant/src/localization/app_localizations.dart';
import 'package:neurossistant/src/pages/games/pages/game_page.dart';
import 'package:neurossistant/src/reusable_comp/language_changer.dart';
import 'package:neurossistant/src/reusable_comp/theme_changer.dart';
import 'package:neurossistant/src/reusable_func/localization_change.dart';
import 'package:neurossistant/src/reusable_func/theme_change.dart';
import 'package:neurossistant/src/theme/theme.dart';

class PhonetikList extends StatefulWidget {
  const PhonetikList({super.key});

  @override
  PhonetikListState createState() => PhonetikListState();
}

class PhonetikListState extends State<PhonetikList> {
  final player = AudioPlayer();

  bool isDarkMode = Get.isDarkMode;

  // Function to generate a single card
  Widget generateCard(String letter) {
    return Expanded(
      child: GestureDetector(
          onTap: () async {
            player.play(AssetSource('sound/$letter.mp3'));
          },
          child: Container(
            padding: const EdgeInsets.all(2),
            child: Card(
              color: Theme.of(context).brightness == Brightness.dark
                  ? ThemeClass().darkRounded
                  : const Color.fromARGB(255, 240, 255, 255),
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(10),
                child: Text(
                  letter.toUpperCase(),
                  style: TextStyle(
                    fontSize: 115,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color.fromARGB(255, 211, 227, 253)
                        : Colors.blueAccent,
                  ),
                ),
              ),
            ),
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? ThemeClass().darkRounded
            : ThemeClass().lightPrimaryColor,
        title: Text(
          AppLocalizations.of(context)!.translate('games_phonetic_title1') ??
              'Phonetic',
          // 'Phonetic untuk Disleksia',
          style: GoogleFonts.nunito(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color.fromARGB(255, 211, 227, 253)
                : Colors.white,
          ),
        ),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color.fromARGB(255, 211, 227, 253)
                : Colors.white,
            onPressed: () {
              Get.offAll(() => const GamePage());
            }),
        actions: [
          LanguageSwitcher(
            onPressed: localizationChange,
            textColor: Theme.of(context).brightness == Brightness.dark
                ? const Color.fromARGB(255, 211, 227, 253)
                : Colors.white,
          ),
          ThemeSwitcher(onPressed: () async {
            themeChange();
            setState(() {
              isDarkMode = !isDarkMode;
            });
          }),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(3),
        child: Column(
          children: List.generate(
            13, // Number of rows (from 'a' to 'z' is 26 letters, 2 letters per row)
            (index) => Row(
              children: [
                generateCard(
                    String.fromCharCode(97 + index * 2)), // ASCII of 'a' is 97
                generateCard(
                    String.fromCharCode(98 + index * 2)), // ASCII of 'b' is 98
              ],
            ),
          ),
        ),
      ),
    );
  }
}
