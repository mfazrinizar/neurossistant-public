// homebody.dart

import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:neurossistant/src/db/campaign/campaign_api.dart';
import 'package:neurossistant/src/localization/app_localizations.dart';
import 'package:neurossistant/src/pages/article/article_list.dart';
import 'package:neurossistant/src/pages/campaign/campaign.dart';
import 'package:neurossistant/src/pages/chatbot/chatbot.dart';
import 'package:neurossistant/src/pages/consult/consult.dart';
import 'package:neurossistant/src/pages/course/course.dart';
import 'package:neurossistant/src/pages/donate/donate.dart';
import 'package:neurossistant/src/pages/games/pages/game_page.dart';
import 'package:neurossistant/src/pages/under_construction/under_construction.dart';
import 'package:neurossistant/src/theme/theme.dart';

class HomePageBody extends StatefulWidget {
  final double height;
  final double width;
  final bool isDarkMode;
  final List<String> buttonTitlesEn;
  final List<String> buttonTitlesId;
  final List<IconData> buttonIcons;
  final List<Campaign> campaigns;
  final CarouselController controller;
  final Function launchUrl;
  final int current;

  const HomePageBody({
    super.key,
    required this.height,
    required this.width,
    required this.isDarkMode,
    required this.buttonTitlesEn,
    required this.buttonTitlesId,
    required this.buttonIcons,
    required this.campaigns,
    required this.controller,
    required this.launchUrl,
    required this.current,
  });

  @override
  HomePageBodyState createState() => HomePageBodyState();
}

class HomePageBodyState extends State<HomePageBody> {
  int current = 0;
  bool isDarkMode = Get.isDarkMode;
  String displayName = FirebaseAuth.instance.currentUser?.displayName ?? 'User';
  List<Campaign> campaignsToShow = [];

  @override
  void initState() {
    super.initState();
    current = widget.current;
    EasyLoading.dismiss();
  }

  @override
  Widget build(context) {
    isDarkMode = Get.isDarkMode;
    widget.campaigns.sort((a, b) => b.campaignDate.compareTo(a.campaignDate));
    // if (widget.campaigns.length > 5)
    campaignsToShow = widget.campaigns.take(5).toList();
    final locale = Get.locale?.toLanguageTag() ?? 'en';

    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.topCenter,
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: DefaultTextStyle.of(context).style,
                  children: <TextSpan>[
                    TextSpan(
                      text:
                          '${AppLocalizations.of(context)!.translate('hello') ?? 'Hello'} ',
                      style: TextStyle(
                        fontSize: widget.width * 0.05,
                      ),
                    ),
                    TextSpan(
                      text: displayName,
                      style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? const Color.fromARGB(255, 211, 227, 253)
                              : ThemeClass().lightPrimaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: widget.width * 0.05),
                    ),
                    TextSpan(
                      text:
                          '!\n${AppLocalizations.of(context)!.translate('home_welcome1') ?? 'How could I be of assistance?'}',
                      style: TextStyle(fontSize: widget.width * 0.05),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: SizedBox(
              width: widget.width,
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 10, // Add some space horizontally
                mainAxisSpacing: 10,
                crossAxisCount: 4,
                children: List.generate(widget.buttonTitlesEn.length, (index) {
                  return _buildFeatureButton(
                      widget.buttonIcons[index],
                      (locale == 'en'
                          ? widget.buttonTitlesEn[index]
                          : widget.buttonTitlesId[index]),
                      context,
                      widget.campaigns);
                }),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '   ${AppLocalizations.of(context)!.translate('home_campaign1') ?? 'Campaign'}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Column(
            children: [
              CarouselSlider.builder(
                itemCount: campaignsToShow.length,
                carouselController: widget.controller,
                itemBuilder:
                    (BuildContext context, int itemIndex, int pageViewIndex) {
                  if (campaignsToShow.isNotEmpty) {
                    return GestureDetector(
                      onTap: () async => await widget.launchUrl(
                          Uri.parse(campaignsToShow[itemIndex].campaignUrl)),
                      child: FadeInImage.assetNetwork(
                        image: campaignsToShow[itemIndex].campaignImage,
                        fit: BoxFit.cover,
                        placeholder: 'assets/images/placeholder_loading.gif',
                      ),
                    );
                  } else {
                    return Container();
                  }
                },
                options: CarouselOptions(
                  autoPlay: true,
                  enlargeCenterPage: true,
                  aspectRatio: 2.0,
                  onPageChanged: (index, reason) {
                    setState(
                      () {
                        current = index;
                      },
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: campaignsToShow.asMap().entries.map((entry) {
                  return GestureDetector(
                    onTap: () => widget.controller.animateToPage(entry.key),
                    child: Container(
                      width: 12.0,
                      height: 12.0,
                      margin: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 4.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: (Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black)
                            .withOpacity(current == entry.key ? 0.9 : 0.4),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          SizedBox(height: widget.height * 0.05)
        ],
      ),
    );
  }
}

Widget _buildFeatureButton(IconData icon, String title, BuildContext context,
    List<Campaign> campaigns) {
  bool isDarkMode = HomePageBodyState().isDarkMode;
  double deviceWidth = MediaQuery.of(context).size.width;
  double deviceHeight = MediaQuery.of(context).size.height;
  double iconSize = deviceHeight * 0.1;
  double maxIconHeight = deviceHeight * 0.1;
  double maxIconWidth = deviceWidth * 0.1;

  while (iconSize > maxIconHeight || iconSize > maxIconWidth) {
    iconSize -= deviceHeight * 0.01;
  }
  return SingleChildScrollView(
    child: Column(
      children: [
        Card(
          color: isDarkMode
              ? ThemeClass().darkRounded
              : ThemeClass().lightPrimaryColor,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(16), // This makes the card rounded
          ),
          child: InkWell(
            onTap: () {
              if (title == 'Articles' || title == 'Artikel') {
                // Create a dummy ArticleOverview instance
                // Navigate to ArticleContentPage with the dummy ArticleOverview instance
                Get.to(() => const ArticleListPage());
              } else if (title == 'ChatBot') {
                Get.to(() => const ChatBotPage());
              } else if (title == 'Consult' || title == 'Konsultasi') {
                // Get.to(() => const PsychologistListScreen()); <- errors occured, uncomment if it's been fixed.
                Get.to(() => const ConsultHome());
              } else if (title == 'Donate' || title == 'Donasi') {
                Get.to(() => const DonatePage());
              } else if (title == 'Games' || title == 'Permainan') {
                Get.to(() => const GamePage());
              } else if (title == 'Campaign' || title == 'Kampanye') {
                Get.to(
                  () => CampaignPage(
                    campaigns: campaigns,
                  ),
                );
              } else if (title == 'Course' || title == 'Kursus') {
                Get.to(() => const CoursePage());
              } else {
                Get.to(() => const UnderConstructionPage());
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                icon,
                size: iconSize,
                color: isDarkMode
                    ? const Color.fromARGB(255, 211, 227, 253)
                    : Colors.white,
              ), // Adjust the size as needed
            ),
          ),
        ),
        Text(title),
      ],
    ),
  );
}
