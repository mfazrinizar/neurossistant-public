import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:neurossistant/src/db/campaign/campaign_api.dart';
import 'package:neurossistant/src/homepage.dart';
import 'package:neurossistant/src/localization/app_localizations.dart';
import 'package:neurossistant/src/reusable_comp/language_changer.dart';
import 'package:neurossistant/src/reusable_comp/theme_changer.dart';
import 'package:neurossistant/src/reusable_func/localization_change.dart';
import 'package:neurossistant/src/reusable_func/theme_change.dart';
import 'package:neurossistant/src/theme/theme.dart';
import 'package:url_launcher/url_launcher.dart';

class CampaignPage extends StatefulWidget {
  final List<Campaign> campaigns;

  const CampaignPage({Key? key, required this.campaigns}) : super(key: key);

  @override
  CampaignPageState createState() => CampaignPageState();
}

class CampaignPageState extends State<CampaignPage> {
  final themeClass = ThemeClass();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.translate('campaign_title1') ??
              'Campaign',
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () => Get.offAll(
            () => const HomePage(indexFromPrevious: 0),
          ),
        ),
        actions: [
          LanguageSwitcher(
            onPressed: localizationChange,
            textColor: Theme.of(context).brightness == Brightness.dark
                ? const Color.fromARGB(255, 211, 227, 253)
                : Colors.white,
          ),
          ThemeSwitcher(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color.fromARGB(255, 211, 227, 253)
                : Colors.white,
            onPressed: () {
              setState(
                () {
                  themeChange();
                },
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: widget.campaigns.length,
        itemBuilder: (context, index) {
          final campaign = widget.campaigns[index];
          return Card(
            color: Theme.of(context).brightness == Brightness.dark
                ? themeClass.darkRounded
                : const Color.fromARGB(255, 243, 243, 243),
            child: Column(
              children: [
                Image.network(campaign.campaignImage),
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Align(
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            campaign.campaignDescription,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        await launchUrl(Uri.parse(campaign.campaignUrl));
                      },
                      child: Text(AppLocalizations.of(context)!
                              .translate('campaign_more1') ??
                          'More'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
