import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neurossistant/src/homepage.dart';
import 'package:neurossistant/src/localization/app_localizations.dart';
import 'package:neurossistant/src/pages/games/animal_test/animal_test.dart';
import 'package:neurossistant/src/pages/games/auth.dart';
import 'package:neurossistant/src/pages/games/pages/nst.dart';
import 'package:neurossistant/src/pages/games/phonetic%20list/phonetic_list.dart';
import 'package:neurossistant/src/pages/games/size_config.dart';
import 'package:neurossistant/src/reusable_comp/language_changer.dart';
import 'package:neurossistant/src/reusable_comp/theme_changer.dart';
import 'package:neurossistant/src/reusable_func/localization_change.dart';
import 'package:neurossistant/src/reusable_func/theme_change.dart';
import 'package:neurossistant/src/theme/theme.dart';

// testing init

class GamePage extends StatefulWidget {
  const GamePage({super.key});
  @override
  GamePageState createState() => GamePageState();
}

final User? user = Auth().currentUser;

class GamePageState extends State<GamePage> {
  bool isDarkMode = Get.isDarkMode;
  String _selectedTag = "";
  bool isClicked = false;
  final searchController = TextEditingController();

  List<Map<String, dynamic>> gamePages = [
    {
      "name": "games_matching_game_title",
      "tag": "ASD",
      "image": 'assets/images/matching_games2.png',
      "page": const NST(),
      "bgColor": const Color.fromARGB(255, 254, 239, 220),
      "textColor": const Color.fromARGB(255, 251, 177, 90),
    },
    {
      "name": "games_phonetic_game_title1",
      "tag": "Dyslexia",
      "image": 'assets/images/ABC_NEW.png',
      "page": const PhonetikList(),
      "bgColor": const Color.fromARGB(255, 206, 236, 254),
      "textColor": const Color.fromARGB(255, 61, 92, 255),
    },
    {
      "name": "games_audio_and_visual_therapy1",
      "tag": "Dyslexia",
      "image": 'assets/images/animal_new.png',
      "page": const AnimalTest(),
      "bgColor": const Color.fromARGB(255, 206, 236, 254),
      "textColor": const Color.fromARGB(255, 61, 92, 255),
    },
    // {
    //   "name": "Matching Games2",
    //   "tag": "DCD",
    //   "image": 'assets/images/autism1.png',
    //   "page": const NST(),
    //   "bgColor": const Color.fromARGB(255, 254, 239, 220),
    //   "textColor": const Color.fromARGB(255, 251, 177, 90),
    // },
    // {
    //   "name": "Phonetic Games2",
    //   "tag": "Autism",
    //   "image": 'assets/images/dyslexia1.png',
    //   "page": const PhonetikList(),
    //   "bgColor": const Color.fromARGB(255, 218, 238, 231),
    //   "textColor": const Color.fromARGB(255, 95, 228, 180),
    // },
    // {
    //   "name": "Audio and Visual Therapy2",
    //   "tag": "ADHD",
    //   "image": 'assets/images/animal_test.png',
    //   "page": const AnimalTest(),
    //   "bgColor": const Color.fromARGB(255, 255, 228, 241),
    //   "textColor": const Color.fromARGB(255, 255, 128, 189),
    // },
    // {
    //   "name": "Matching Games3",
    //   "tag": "ASD",
    //   "image": 'assets/images/autism1.png',
    //   "page": const NST(),
    //   "bgColor": const Color.fromARGB(255, 239, 224, 255),
    //   "textColor": const Color.fromARGB(255, 144, 101, 190),
    // },
    // {
    //   "name": "Phonetic Games3",
    //   "tag": "ASD",
    //   "image": 'assets/images/dyslexia1.png',
    //   "page": const PhonetikList(),
    //   "bgColor": const Color.fromARGB(255, 239, 224, 255),
    //   "textColor": const Color.fromARGB(255, 144, 101, 190),
    // },
    // {
    //   "name": "Audio and Visual Therapy3",
    //   "tag": "ADHD",
    //   "image": 'assets/images/animal_test.png',
    //   "page": const AnimalTest(),
    //   "bgColor": const Color.fromARGB(255, 255, 228, 241),
    //   "textColor": const Color.fromARGB(255, 255, 128, 189),
    // },
  ];

  final List<Map<String, dynamic>> tagFilters = [
    {
      "tag": "Dyslexia   ",
      "bgColor": const Color.fromARGB(255, 206, 236, 254),
      "bgText": const Color.fromARGB(255, 241, 249, 253),
      "textColor": const Color.fromARGB(255, 61, 92, 255),
      "image": 'assets/images/dyslexiaTagBlue.svg',
    },
    {
      "tag": "DCD   ",
      "bgColor": const Color.fromARGB(255, 239, 224, 255),
      "bgText": const Color.fromARGB(255, 255, 243, 255),
      "textColor": const Color.fromARGB(255, 144, 101, 190),
      "image": 'assets/images/dcdTagPurple.svg',
    },
    {
      "tag": "ASD   ",
      "bgColor": const Color.fromARGB(255, 254, 239, 220),
      "bgText": const Color.fromARGB(255, 255, 255, 236),
      "textColor": const Color.fromARGB(255, 251, 177, 90),
      "image": 'assets/images/asdTagOrange.svg',
    },
    {
      "tag": "ADHD   ",
      "bgColor": const Color.fromARGB(255, 255, 228, 241),
      "bgText": const Color.fromARGB(255, 254, 242, 255),
      "textColor": const Color.fromARGB(255, 255, 128, 189),
      "image": 'assets/images/adhdTagPink.svg',
    },
    // {
    //   "tag": "Autism   ",
    //   "bgColor": const Color.fromARGB(255, 218, 238, 231),
    //   "bgText": const Color.fromARGB(255, 240, 255, 253),
    //   "textColor": const Color.fromARGB(255, 37, 223, 155),
    //   "image": 'assets/images/autismTagGreen.svg',
    // },
  ];

  List<Map<String, dynamic>> foundGames = [];

  @override
  void initState() {
    foundGames = gamePages;
    super.initState();
  }

  void filterGame(String input) {
    List<Map<String, dynamic>> resultGames = [];
    if (input.contains("   ")) {
      //u said u already fix this bruh
      isClicked = true;
    } else {
      isClicked = false;
    }

    if (input.isNotEmpty) {
      resultGames = gamePages
          .where((game) =>
              (AppLocalizations.of(context)!.translate(game["name"]) ??
                      game["name"])
                  .toString()
                  .toLowerCase()
                  .contains(input.toLowerCase().trim()) ||
              game["tag"]
                  .toString()
                  .toLowerCase()
                  .contains(input.toLowerCase().trim()))
          .toList();
    } else {
      resultGames = gamePages;
    }

    setState(() {
      foundGames = resultGames;
    });
  }

  void filterGamesByTag() {
    List<Map<String, dynamic>> resultGames = [];
    if (_selectedTag.isNotEmpty) {
      resultGames = gamePages
          .where((game) => game["tag"]
              .toString()
              .toLowerCase()
              .contains(_selectedTag.toLowerCase().trim()))
          .toList();
    } else {
      resultGames = gamePages;
    }

    setState(() {
      foundGames = resultGames;
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? ThemeClass().darkRounded
            : ThemeClass().lightPrimaryColor,
        title: Text(
          AppLocalizations.of(context)!.translate('games_title1') ?? 'Games',
          style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color.fromARGB(255, 211, 227, 253)
                  : Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color.fromARGB(255, 211, 227, 253)
              : Colors.white,
          onPressed: () {
            if (Navigator.canPop(context)) {
              Get.back();
            } else {
              Get.offAll(() => const HomePage(indexFromPrevious: 0));
            }
          },
        ),
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
          PopupMenuButton<String>(
            icon: Icon(
              Icons.notifications,
              color: isDarkMode
                  ? const Color.fromARGB(255, 211, 227, 253)
                  : Colors.white,
            ),
            onSelected: (String result) {
              // Handle the selection
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'Notification 1',
                child: Text('No notifications'),
              ),
              // Add more PopupMenuItems for more notifications
            ],
          ),
          Builder(
            builder: (BuildContext context) {
              final user = FirebaseAuth.instance.currentUser;
              if (user != null && user.photoURL != null) {
                return ClipOval(
                  child: FadeInImage.assetNetwork(
                    image: user.photoURL!,
                    placeholder: 'assets/images/placeholder_loading.gif',
                    fit: BoxFit.cover,
                    width: 45,
                    height: 45,
                  ),
                ); // display the user's profile picture
              } else {
                return Icon(
                  Icons.account_circle,
                  color: isDarkMode
                      ? const Color.fromARGB(255, 211, 227, 253)
                      : Colors.white,
                ); // show a default icon if the user is not logged in or doesn't have a profile picture
              }
            },
          ),
        ],
      ),
      body: PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (!didPop) {
            if (Navigator.canPop(context)) {
              Get.back();
            } else {
              Get.offAll(() => const HomePage(indexFromPrevious: 0));
            }
          }
        },
        child: Column(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16.0),
                    bottomRight: Radius.circular(16.0),
                  ),
                  color: Theme.of(context).brightness == Brightness.dark
                      ? ThemeClass().darkRounded
                      : ThemeClass().lightPrimaryColor),
              child: Stack(
                children: <Widget>[
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          style: TextStyle(
                            color: isDarkMode
                                ? const Color.fromARGB(255, 211, 227, 253)
                                : Colors.black,
                          ),
                          controller: searchController,
                          onChanged: (value) => filterGame(value),
                          keyboardType: TextInputType.visiblePassword,
                          scrollPadding: const EdgeInsets.all(100),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor:
                                Theme.of(context).brightness == Brightness.dark
                                    ? const Color.fromARGB(255, 3, 21, 37)
                                    : const Color.fromARGB(255, 240, 240, 245),
                            prefixIcon: Icon(
                              Icons.search,
                              color: isDarkMode
                                  ? const Color.fromARGB(255, 211, 227, 253)
                                  : Colors.black,
                            ),
                            hintText: AppLocalizations.of(context)!
                                    .translate('games_search1') ??
                                'Search for Games...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(
                                color: isDarkMode
                                    ? const Color.fromARGB(255, 211, 227, 253)
                                    : Colors.white,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                  color: isDarkMode
                                      ? const Color.fromARGB(255, 211, 227, 253)
                                      : Colors.blueAccent,
                                  width: 2),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            SingleChildScrollView(
              scrollDirection: axisDirectionToAxis(AxisDirection.right),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(1),
                    height: 100,
                    width: MediaQuery.of(context).size.width,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const AlwaysScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: tagFilters.length,
                      itemBuilder: (context, index) {
                        return Row(
                          children: [
                            if (index == 0) const SizedBox(width: 10),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (_selectedTag ==
                                      tagFilters[index]['tag']) {
                                    _selectedTag = "";
                                  } else {
                                    _selectedTag = tagFilters[index]['tag'];
                                  }
                                  filterGamesByTag();
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 500),
                                // alignment: Alignment.bottomRight,
                                constraints: const BoxConstraints(
                                    minWidth: 180,
                                    maxWidth: 180,
                                    minHeight: 100,
                                    maxHeight: 100),
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(15),
                                  ),
                                  color: tagFilters[index]["bgColor"],
                                  boxShadow:
                                      _selectedTag == tagFilters[index]['tag']
                                          ? [
                                              const BoxShadow(
                                                  color: Colors.lightBlue,
                                                  blurRadius: 3,
                                                  spreadRadius: 2.5)
                                            ]
                                          : [],
                                ),
                                child: Column(
                                  children: [
                                    const SizedBox(
                                      // height: 25,
                                      width: 25,
                                    ),
                                    Row(
                                      children: [
                                        Stack(
                                          children: [
                                            SizedBox(
                                              height: 90,
                                              width: 90,
                                              child: SvgPicture.asset(
                                                  tagFilters[index]["image"]),
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const SizedBox(
                                                  width: 95,
                                                ),
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    const SizedBox(
                                                      height: 60,
                                                    ),
                                                    Container(
                                                      alignment: Alignment
                                                          .center, // Center the text inside the container
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            const BorderRadius
                                                                .all(
                                                          Radius.circular(20),
                                                        ),
                                                        color: tagFilters[index]
                                                            ["bgText"],
                                                      ),
                                                      padding:
                                                          const EdgeInsets.all(
                                                              5),
                                                      child: Text(
                                                        tagFilters[index]
                                                            ["tag"],
                                                        style: TextStyle(
                                                          color:
                                                              tagFilters[index]
                                                                  ["textColor"],
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                        ),
                                                        textAlign: TextAlign
                                                            .center, // Center the text
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                // scrollDirection: Axis.vertical,
                physics: const AlwaysScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: foundGames.length,
                // itemCount: 5,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          // builder: (context) =>const NST()));
                          builder: (context) => foundGames[index]["page"]));
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          margin: const EdgeInsets.all(7),
                          width: getRelativeWidth(0.90),
                          height: getRelativeHeight(0.20),
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: !isDarkMode
                                    ? Colors.grey.withOpacity(0.3)
                                    : Colors.blueGrey.withOpacity(0.15),
                                spreadRadius: 1.5,
                                blurRadius: 4,
                                offset: Offset.fromDirection(
                                    1, 5), // changes position of shadow
                              ),
                            ],
                            borderRadius: BorderRadius.circular(15),
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? ThemeClass().darkRounded
                                    : const Color.fromARGB(255, 240, 240, 245),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: getRelativeWidth(0.03)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        AppLocalizations.of(context)!.translate(
                                                foundGames[index]["name"]) ??
                                            foundGames[index]["name"],
                                        // "Matching Games",
                                        style: GoogleFonts.nunito(
                                          color: isDarkMode
                                              ? const Color.fromARGB(
                                                  255, 211, 227, 253)
                                              : const Color.fromARGB(
                                                  255, 124, 124, 124),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                      SizedBox(height: getRelativeHeight(0.02)),
                                    ],
                                  ),
                                ),
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(5),
                                      child: Column(
                                        children: [
                                          Align(
                                            alignment: Alignment.topRight,
                                            child: Chip(
                                              backgroundColor: foundGames[index]
                                                  ["bgColor"],
                                              label: Text(
                                                foundGames[index]["tag"],
                                                // "Dyslexia",
                                                style: GoogleFonts.nunito(
                                                  color: foundGames[index]
                                                      ["textColor"],
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13,
                                                ),
                                              ),
                                              side: BorderSide(
                                                  color: foundGames[index]
                                                      ["bgColor"]),
                                            ),
                                          ),
                                          Flexible(
                                            child: Image.asset(
                                              foundGames[index]["image"],
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
