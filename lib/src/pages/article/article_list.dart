import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:neurossistant/src/homepage.dart';
import 'package:neurossistant/src/localization/app_localizations.dart';
import 'package:neurossistant/src/pages/article/article_list_item.dart';
import 'package:neurossistant/src/pages/article/article_overview.dart';
import 'package:neurossistant/src/reusable_comp/language_changer.dart';
import 'package:neurossistant/src/reusable_comp/theme_changer.dart';
import 'package:neurossistant/src/reusable_func/localization_change.dart';
import 'package:neurossistant/src/reusable_func/theme_change.dart';
import 'package:neurossistant/src/theme/theme.dart';

class ArticleListPage extends StatefulWidget {
  const ArticleListPage({super.key});
  @override
  ArticleListPageState createState() => ArticleListPageState();
}

class ArticleListPageState extends State<ArticleListPage> {
  bool isDarkMode = Get.isDarkMode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? ThemeClass().darkRounded
            : ThemeClass().lightPrimaryColor,
        title: Text(
          AppLocalizations.of(context)!.translate('article_title1') ??
              'Articles',
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
            Get.offAll(
              () => const HomePage(
                indexFromPrevious: 0,
              ),
            );
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
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('articles').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return const Center(
              child: Text('Error fetching data'),
            );
          }
          final List<ArticleOverview> articleOverviews = snapshot.data!.docs
              .map((doc) => ArticleOverview(
                    id: doc.id,
                    title: doc['title'],
                    description: doc['body'],
                    imageURL: doc['imageUrl'],
                  ))
              .toList();
          return ListView.builder(
            itemCount: articleOverviews.length,
            itemBuilder: (context, index) {
              return ArticleListItem(articleOverviews[index]);
            },
          );
        },
      ),
    );
  }
}
