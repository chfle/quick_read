import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('news_aggregator.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const textTypeNullable = 'TEXT';

    // Users table
    await db.execute('''
      CREATE TABLE users (
        id $idType,
        username $textType UNIQUE,
        password $textType,
        favoriteCategories $textType,
        createdAt $textType
      )
    ''');

    // Bookmarks table
    await db.execute('''
      CREATE TABLE bookmarks (
        id $idType,
        articleId $textType UNIQUE,
        title $textType,
        description $textTypeNullable,
        imageUrl $textTypeNullable,
        source $textType,
        publishedAt $textType,
        url $textType,
        bookmarkedAt $textType
      )
    ''');

    // Reading history table
    await db.execute('''
      CREATE TABLE reading_history (
        id $idType,
        articleId $textType,
        title $textType,
        imageUrl $textTypeNullable,
        source $textType,
        url $textType,
        readAt $textType
      )
    ''');

    // Create indexes for better performance
    await db.execute('''
      CREATE INDEX idx_bookmarks_articleId ON bookmarks(articleId)
    ''');

    await db.execute('''
      CREATE INDEX idx_history_readAt ON reading_history(readAt DESC)
    ''');
  }

  // User operations
  Future<int> createUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.insert('users', user);
  }

  Future<Map<String, dynamic>?> getUser(String username) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> updateUser(int id, Map<String, dynamic> user) async {
    final db = await database;
    return await db.update(
      'users',
      user,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Bookmark operations
  Future<int> addBookmark(Map<String, dynamic> bookmark) async {
    final db = await database;
    return await db.insert(
      'bookmarks',
      bookmark,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getBookmarks() async {
    final db = await database;
    return await db.query(
      'bookmarks',
      orderBy: 'bookmarkedAt DESC',
    );
  }

  Future<bool> isBookmarked(String articleId) async {
    final db = await database;
    final result = await db.query(
      'bookmarks',
      where: 'articleId = ?',
      whereArgs: [articleId],
    );
    return result.isNotEmpty;
  }

  Future<int> removeBookmark(String articleId) async {
    final db = await database;
    return await db.delete(
      'bookmarks',
      where: 'articleId = ?',
      whereArgs: [articleId],
    );
  }

  // Reading history operations
  Future<int> addToHistory(Map<String, dynamic> history) async {
    final db = await database;
    return await db.insert('reading_history', history);
  }

  Future<List<Map<String, dynamic>>> getReadingHistory({int? limit}) async {
    final db = await database;
    return await db.query(
      'reading_history',
      orderBy: 'readAt DESC',
      limit: limit,
    );
  }

  Future<int> clearHistory() async {
    final db = await database;
    return await db.delete('reading_history');
  }

  Future<int> deleteHistoryItem(int id) async {
    final db = await database;
    return await db.delete(
      'reading_history',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Close database
  Future close() async {
    final db = await database;
    db.close();
  }
}