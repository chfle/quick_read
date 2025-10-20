import 'package:quick_read/models/article_model.dart';

class ReadingHistoryModel {
  final int? id;
  final String articleId;
  final String title;
  final String? imageUrl;
  final String source;
  final String url;
  final DateTime readAt;

  ReadingHistoryModel({
    this.id,
    required this.articleId,
    required this.title,
    this.imageUrl,
    required this.source,
    required this.url,
    DateTime? readAt,
  }) : readAt = readAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'articleId': articleId,
      'title': title,
      'imageUrl': imageUrl,
      'source': source,
      'url': url,
      'readAt': readAt.toIso8601String(),
    };
  }

  factory ReadingHistoryModel.fromMap(Map<String, dynamic> map) {
    return ReadingHistoryModel(
      id: map['id'],
      articleId: map['articleId'],
      title: map['title'],
      imageUrl: map['imageUrl'],
      source: map['source'],
      url: map['url'],
      readAt: DateTime.parse(map['readAt']),
    );
  }

  factory ReadingHistoryModel.fromArticle(ArticleModel article) {
    return ReadingHistoryModel(
      articleId: article.id ?? article.url.hashCode.toString(),
      title: article.title,
      imageUrl: article.imageUrl,
      source: article.source,
      url: article.url,
    );
  }
}
