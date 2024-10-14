import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neurossistant/src/pages/article/article_content.dart';
import 'package:neurossistant/src/pages/article/article_overview.dart';
import 'package:neurossistant/src/theme/theme.dart';

class ArticleListItem extends StatelessWidget {
  final ArticleOverview articleOverview;
  final themeClass = ThemeClass();

  ArticleListItem(
    this.articleOverview, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArticleContentPage(articleOverview),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(4.69),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            color: Theme.of(context).brightness == Brightness.dark
                ? themeClass.darkRounded
                : themeClass.lightDiscussion,
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).brightness == Brightness.dark
                    ? themeClass.darkRounded
                    : Colors.grey.withOpacity(0.5),
                spreadRadius: 1,
                blurRadius: 2,
                offset: const Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Image.network(
                articleOverview.imageURL,
                fit: BoxFit.cover,
                height: 100,
                width: 80,
                alignment: Alignment.topCenter,
              ),
            ),
            title: Text(
              articleOverview.title,
              style: GoogleFonts.nunito(
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            // subtitle: Text( //dont need any sub for list
            //   articleOverview.description,
            //   style: GoogleFonts.nunito(fontSize: 15),
            //   overflow: TextOverflow.ellipsis,
            //   maxLines: 2,
            // ),
          ),
        ),
      ),
    );
  }
}
