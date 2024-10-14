// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neurossistant/src/homepage.dart';
import 'package:neurossistant/src/localization/app_localizations.dart';
import 'package:neurossistant/src/pages/games/pages/game_page.dart';
import 'package:neurossistant/src/pages/games/theme_game.dart';
import 'package:neurossistant/src/reusable_comp/language_changer.dart';
import 'package:neurossistant/src/reusable_comp/theme_changer.dart';
import 'package:neurossistant/src/reusable_func/localization_change.dart';
import 'package:neurossistant/src/reusable_func/theme_change.dart';
import 'package:neurossistant/src/theme/theme.dart';
import 'package:quickalert/quickalert.dart';

class NST extends StatefulWidget {
  const NST({super.key});

  @override
  NSTState createState() => NSTState();
}

class NSTState extends State<NST> {
  List<List<int>> gridData = [];
  //TODO: buat agar pengambilan gambar lebih jelas pke map
  int answer = 1;
  int answerRight = 0;
  int answerWrong = 0;

  List<int> angkaList = List.generate(36, (index) => index + 1);
  int? angkaAcak;

  bool isDarkMode = Get.isDarkMode;

  void generateRandomNumber() {
    Random random = Random();
    int randomNumber = random.nextInt(angkaList.length);
    setState(() {
      angkaAcak = angkaList[randomNumber];
    });
  }

  final audioPlayer = AudioPlayer();
  @override
  void initState() {
    super.initState();
    generateGrid();
    angkaAcak = Random().nextInt(36) + 1;
    audioPlayer.play(AssetSource('backsound.mp3'));
    audioPlayer.setReleaseMode(ReleaseMode.loop);
    // audioPlayer.play('backsound.mp3', isLocal: true);
  }

  void generateGrid() {
    List<int> numbers = List.generate(36, (index) => index + 1);
    numbers.shuffle();

    gridData.clear();
    for (int i = 0; i < 6; i++) {
      gridData.add(numbers.sublist(i * 6, (i + 1) * 6));
    }
  }

  void randomizeGrid() {
    setState(() {
      generateGrid();
      angkaAcak = Random().nextInt(36) + 1;
    });
  }

  void showSnackBar() {
    QuickAlert.show(
      text: AppLocalizations.of(context)!
              .translate('games_matching_your_choice_correct') ??
          'Pilihan kamu benar',
      title: AppLocalizations.of(context)!
              .translate('games_matching_game_success') ??
          'Selamat!',
      context: context,
      type: QuickAlertType.custom,
      customAsset: 'assets/nst/correct.png',
      widget: const SizedBox(),
      confirmBtnColor: Colors.green,
      confirmBtnText: AppLocalizations.of(context)!
              .translate('games_matching_game_success_btn') ??
          'Lanjut',
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? const Color.fromARGB(255, 3, 21, 37)
          : Colors.white,
      textColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.white
          : Colors.black,
    );
  }

  void showSnackBarFailed() {
    QuickAlert.show(
      text: AppLocalizations.of(context)!
              .translate('games_matching_your_choice_incorrect') ??
          'Pilihan kamu salah',
      title: AppLocalizations.of(context)!
              .translate('games_matching_game_failed') ??
          'Gagal',
      context: context,
      type: QuickAlertType.custom,
      customAsset: 'assets/nst/wrong.png',
      widget: const SizedBox(),
      confirmBtnColor: Colors.red,
      confirmBtnText: AppLocalizations.of(context)!
              .translate('games_matching_game_failed_btn') ??
          'Coba lagi',
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? const Color.fromARGB(255, 3, 21, 37)
          : Colors.white,
      textColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.white
          : Colors.black,
    );
  }

  void showSnackBarResult() {
    QuickAlert.show(
      text:
          '$answerRight ${AppLocalizations.of(context)!.translate('games_matching_game_correct_count') ?? 'jawaban kamu benar'}',
      title: AppLocalizations.of(context)!
              .translate('games_matching_game_correct_count_title') ??
          'Berakhir',
      context: context,
      type: QuickAlertType.custom,
      customAsset: 'assets/nst/result.png',
      widget: const SizedBox(),
      confirmBtnColor: Colors.green,
      confirmBtnText:
          AppLocalizations.of(context)!.translate('done') ?? 'Selesai',
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? const Color.fromARGB(255, 3, 21, 37)
          : Colors.white,
      textColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.white
          : Colors.black,
      headerBackgroundColor: Theme.of(context).brightness == Brightness.dark
          ? const Color.fromARGB(255, 3, 21, 37)
          : Colors.white,
    );
  }

  void funHomeActive() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const HomePage(),
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
                  .translate('games_matching_game_title') ??
              "Matching Games",
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
              audioPlayer.stop();
              Get.offAll(() => const GamePage());
            }),
        actions: [
          LanguageSwitcher(
            onPressed: localizationChange,
            textColor: Theme.of(context).brightness == Brightness.dark
                ? const Color.fromARGB(255, 211, 227, 253)
                : Colors.white,
          ),
          ThemeSwitcher(
            onPressed: () async {
              themeChange();
              setState(
                () {
                  isDarkMode = !isDarkMode;
                },
              );
            },
          ),
        ],
      ),
      body: PopScope(
        canPop: true,
        onPopInvoked: (didPop) {
          // showExitPopup();
        },
        child: Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                Text(
                  AppLocalizations.of(context)!
                          .translate('games_matching_find') ??
                      'Find the Same Image',
                  // 'Temukan Gambar yang Sama',
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color.fromARGB(255, 211, 227, 253)
                        : Colors.black,
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(16),
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
                      child: Image.asset(
                        'assets/animal_list/$angkaAcak.png',
                        width: 100,
                        height: 100,
                      ),
                    ),
                  ),
                ),
                Text(
                  '$answer ',
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color.fromARGB(255, 211, 227, 253)
                        : Colors.black,
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 6,
                    ),
                    itemCount: gridData.length * 6,
                    itemBuilder: (context, index) {
                      int row = index ~/ 6;
                      int col = index % 6;
                      String imagePath =
                          'assets/animal_list/${gridData[row][col]}.png';
                      return GestureDetector(
                        onTap: () {
                          if (gridData[row][col] == angkaAcak && answer == 10) {
                            //selesai
                            answerRight++;
                            showSnackBarResult();
                            randomizeGrid();
                            answer = 1;
                            answerRight = 0;
                            answerWrong = 0;
                          } else if (answer == 10) {
                            // selesai
                            showSnackBarResult();
                            randomizeGrid();
                            answer = 1;
                            answerRight = 0;
                            answerWrong = 0;
                          } else if (gridData[row][col] == angkaAcak) {
                            // kalo bener
                            showSnackBar();
                            randomizeGrid();
                            answerRight++;
                            answer++;
                          } else {
                            //kalo salah
                            showSnackBarFailed();
                            randomizeGrid();
                            answerWrong++;
                            answer++;
                          }
                        },
                        child: GridTile(
                          child: Center(
                            child: ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                  //second xor to take the main image back in
                                  Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? const Color.fromARGB(255, 211, 227, 253)
                                      : Colors.black,
                                  BlendMode.xor),
                              child: ColorFiltered(
                                //fisrt xor to take out the main image
                                colorFilter: ColorFilter.mode(
                                    Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? const Color.fromARGB(
                                            255, 211, 227, 253)
                                        : Colors.black,
                                    BlendMode.xor),
                                child: Image.asset(
                                  imagePath,
                                  width: 60,
                                  height: 60,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // What the hell is this for, Fachry? Exiting from GamePage?
  Future<bool> showExitPopup() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Keluar Aplikasi'),
            content: const Text('Kamu ingin keluar aplikasi?'),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: greenColor,
                    textStyle: GoogleFonts.nunito(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Tidak'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                    backgroundColor: redColor,
                    textStyle: GoogleFonts.nunito(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                child: const Text('Ya'),
              ),
            ],
          ),
        ) ??
        false;
  }
}
