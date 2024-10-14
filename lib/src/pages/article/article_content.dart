// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neurossistant/src/localization/app_localizations.dart';
import 'package:neurossistant/src/pages/article/article_list.dart';
import 'package:neurossistant/src/pages/article/article_overview.dart';
import 'package:neurossistant/src/reusable_comp/language_changer.dart';
import 'package:neurossistant/src/reusable_comp/theme_changer.dart';
import 'package:neurossistant/src/reusable_func/localization_change.dart';
import 'package:neurossistant/src/reusable_func/theme_change.dart';
import 'package:neurossistant/src/theme/theme.dart';
// import 'package:photo_view/photo_view.dart';

class ArticleContent {
  final String body;

  ArticleContent({
    required this.body,
  });

  static Future<ArticleContent> getDataFromFirestore(String id) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('articles').doc(id).get();
      if (snapshot.exists) {
        final Map<String, dynamic> data = snapshot.data()!;
        final String body = data['body'] ?? '';
        return ArticleContent(body: body);
      } else {
        throw Exception('Document with ID $id does not exist');
      }
    } catch (e) {
      throw Exception('Failed to fetch data from Firestore: $e');
    }
  }
}

class ArticleContentPage extends StatefulWidget {
  final ArticleOverview articleOverview;

  const ArticleContentPage(
    this.articleOverview, {
    Key? key,
  }) : super(key: key);

  @override
  State<ArticleContentPage> createState() => _ArticleContentPageState();
}

class _ArticleContentPageState extends State<ArticleContentPage> {
  ArticleContent? articleContent;
  bool isDarkMode = Get.isDarkMode;

  @override
  void initState() {
    super.initState();
    isDarkMode = Get.isDarkMode;
    loadArticleContent();
  }

  void loadArticleContent() async {
    try {
      ArticleContent data =
          await ArticleContent.getDataFromFirestore(widget.articleOverview.id);
      setState(() {
        articleContent = data;
      });
    } catch (e) {
      // Handle error
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? ThemeClass().darkRounded
            : ThemeClass().lightPrimaryColor,
        title: Text(
          AppLocalizations.of(context)!.translate('article_content_title1') ??
              'Article Content',
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
            Get.offAll(() => const ArticleListPage());
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
      body: Column(
        children: [
          const SizedBox(
            height: 15,
          ),
          Image.network(
            widget.articleOverview.imageURL,
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),
          // PhotoView(
          //   imageProvider: NetworkImage(widget.articleOverview.imageURL),
          //   initialScale: PhotoViewComputedScale.contained,
          // ),
          // GestureDetector(
          //   //as always doesnt make the list show wherever i put this shi-
          //   //even if i were to make the parent before this child static
          //   onTap: () {
          //     showDialog(
          //       context: context,
          //       builder: (context) => Dialog(
          //         child: Stack(
          //           children: [
          //             PhotoView(
          //               imageProvider:
          //                   NetworkImage(widget.articleOverview.imageURL),
          //               initialScale: PhotoViewComputedScale.contained,
          //             ),
          //           ],
          //         ),
          //       ),
          //     );
          //   },
          // ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              widget.articleOverview.title,
              style: GoogleFonts.nunito(
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: articleContent == null
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : Text(
                    articleContent!.body,
                    style: const TextStyle(fontSize: 16),
                  ),
          ),
        ],
      ),
    );
  }
}
