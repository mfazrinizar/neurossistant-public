class ArticleOverview {
  final String id;
  final String title;
  final String description;
  final String imageURL;

  ArticleOverview({
    required this.id,
    required this.title,
    required this.description,
    required this.imageURL,
  });

  static Future<List<ArticleOverview>> getAllFromFirestore() async {
    return List.generate(
      5,
      (index) => ArticleOverview(
        id: index.toString(),
        title: 'Article $index',
        description: 'Description of Article $index',
        imageURL:
            'https://www.mendelian.co/uploads/190813/autism-150-rare-diseases.jpg',
      ),
    );
  }
}
