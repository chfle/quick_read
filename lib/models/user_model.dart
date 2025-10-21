class UserModel {
  final int? id;
  final String username;
  final String password;
  final List<String> favoriteCategories;
  final DateTime createdAt;

  UserModel({
    this.id,
    required this.username,
    required this.password,
    required this.favoriteCategories,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'favoriteCategories': favoriteCategories.join(','),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      username: map['username'],
      password: map['password'],
      favoriteCategories: (map['favoriteCategories'] as String).split(','),
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  UserModel copyWith({
    int? id,
    String? username,
    String? password,
    List<String>? favoriteCategories,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      password: password ?? this.password,
      favoriteCategories: favoriteCategories ?? this.favoriteCategories,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}