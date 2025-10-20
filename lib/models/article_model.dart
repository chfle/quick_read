class ArticleModel {
  final String? id;
  final String title;
  final String? description;
  final String? content;
  final String? imageUrl;
  final String source;
  final String publishedAt;
  final String url;

  ArticleModel({
    this.id,
    required this.title,
    this.description,
    this.content,
    this.imageUrl,
    required this.source,
    required this.publishedAt,
    required this.url,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id ?? url.hashCode.toString(),
      'title': title,
      'description': description,
      'content': content,
      'imageUrl': imageUrl,
      'source': source,
      'publishedAt': publishedAt,
      'url': url,
    };
  }

  factory ArticleModel.fromMap(Map<String, dynamic> map) {
    return ArticleModel(
      id: map['id'],
      title: map['title'] ?? '',
      description: map['description'],
      content: map['content'],
      imageUrl: map['imageUrl'],
      source: map['source'] ?? '',
      publishedAt: map['publishedAt'] ?? '',
      url: map['url'] ?? '',
    );
  }

  // Factory for NewsAPI response
  factory ArticleModel.fromNewsApi(Map<String, dynamic> json) {
    return ArticleModel(
      title: json['title'] ?? '',
      description: json['description'],
      content: json['content'],
      imageUrl: json['urlToImage'],
      source: json['source']['name'] ?? '',
      publishedAt: json['publishedAt'] ?? '',
      url: json['url'] ?? '',
    );
  }
}
