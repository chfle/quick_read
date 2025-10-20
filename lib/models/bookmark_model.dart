import 'package:quick_read/models/article_model.dart';

class BookmarkModel {
  final int? id;
  final String articleId;
  final String title;
  final String? description;
  final String? imageUrl;
  final String source;
  final String publishedAt;
  final String url;
  final DateTime bookmarkedAt;

  BookmarkModel({
    this.id,
    required this.articleId,
    required this.title,
    this.description,
    this.imageUrl,
    required this.source,
    required this.publishedAt,
    required this.url,
    DateTime? bookmarkedAt,
  }) : bookmarkedAt = bookmarkedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'articleId': articleId,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'source': source,
      'publishedAt': publishedAt,
      'url': url,
      'bookmarkedAt': bookmarkedAt.toIso8601String(),
    };
  }

  factory BookmarkModel.fromMap(Map<String, dynamic> map) {
    return BookmarkModel(
      id: map['id'],
      articleId: map['articleId'],
      title: map['title'],
      description: map['description'],
      imageUrl: map['imageUrl'],
      source: map['source'],
      publishedAt: map['publishedAt'],
      url: map['url'],
      bookmarkedAt: DateTime.parse(map['bookmarkedAt']),
    );
  }

  factory BookmarkModel.fromArticle(ArticleModel article) {
    return BookmarkModel(
      articleId: article.id ?? article.url.hashCode.toString(),
      title: article.title,
      description: article.description,
      imageUrl: article.imageUrl,
      source: article.source,
      publishedAt: article.publishedAt,
      url: article.url,
    );
  }
}
