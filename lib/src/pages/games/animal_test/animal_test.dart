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

class AnimalTest extends StatefulWidget {
  const AnimalTest({super.key});

  @override
  AnimalTestState createState() => AnimalTestState();
}

class AnimalTestState extends State<AnimalTest> {
  final player = AudioPlayer();

  bool isDarkMode = Get.isDarkMode;

  // Function to generate a single card
  Widget generateCard(String letter) {
    return Expanded(
      child: GestureDetector(
        onTap: () async {
          player.play(AssetSource('sound/animal-$letter.mp3'));
        },
        child: Container(
          padding: const EdgeInsets.all(2),
          child: Card(
            child: Container(
              constraints: const BoxConstraints(
                  minWidth: 100, maxWidth: 100, minHeight: 180, maxHeight: 180),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(
                  Radius.circular(15),
                ),
                color: Theme.of(context).brightness == Brightness.dark
                    ? ThemeClass()
                        .darkRounded //this now became useless as to invert function takes whole container?
                    : const Color.fromARGB(255, 240, 255, 255),
              ),
              padding: const EdgeInsets.all(10),
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(
                    //second xor to take the main image back in
                    Theme.of(context).brightness == Brightness.dark
                        ? const Color.fromARGB(255, 211, 227, 253)
                        : Colors.black,
                    BlendMode.xor),
                child: ColorFiltered(
                  //fisrt xor to take out the main image
                  colorFilter: ColorFilter.mode(
                      Theme.of(context).brightness == Brightness.dark
                          ? const Color.fromARGB(255, 211, 227, 253)
                          : Colors.black,
                      BlendMode.xor),
                  child: Image.asset('assets/animal/$letter.png'),
                ),
              ),
            ),
          ),
        ),
      ),
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
          AppLocalizations.of(context)!
                  .translate('games_guess_animal_title1') ??
              'Guess the Animal',
          // 'Tebak hewan untuk Autisme',
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
        padding: const EdgeInsets.all(2),
        child: Column(
          children: List.generate(
            5, // Number of rows (from 'a' to 'z' is 26 letters, 2 letters per row)
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
