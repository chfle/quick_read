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

  // Explicit initialization method
  Future<void> initialize() async {
    await database;
  }

  Future<Database> _initDB(String filePath) async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, filePath);
      print('Database path: $path');

      return await openDatabase(
        path,
        version: 1,
        onCreate: _createDB,
        onOpen: (db) {
          print('Database opened successfully');
        },
      );
    } catch (e) {
      print('Error initializing database: $e');
      rethrow;
    }
  }

  Future _createDB(Database db, int version) async {
    print('Creating database tables...');
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const textTypeNullable = 'TEXT';

    try {
      // Users table
      print('Creating users table...');
      await db.execute('''
        CREATE TABLE users (
          id $idType,
          username $textType UNIQUE,
          password $textType,
          favoriteCategories $textType,
          createdAt $textType
        )
      ''');
      print('Users table created successfully');
    } catch (e) {
      print('Error creating users table: $e');
      rethrow;
    }

    try {
      // Bookmarks table
      print('Creating bookmarks table...');
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
      print('Bookmarks table created successfully');
    } catch (e) {
      print('Error creating bookmarks table: $e');
      rethrow;
    }

    try {
      // Reading history table
      print('Creating reading_history table...');
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
      print('Reading history table created successfully');
    } catch (e) {
      print('Error creating reading_history table: $e');
      rethrow;
    }

    try {
      // Create indexes for better performance
      print('Creating indexes...');
      await db.execute('''
        CREATE INDEX idx_bookmarks_articleId ON bookmarks(articleId)
      ''');

      await db.execute('''
        CREATE INDEX idx_history_readAt ON reading_history(readAt DESC)
      ''');
      print('Indexes created successfully');
    } catch (e) {
      print('Error creating indexes: $e');
      rethrow;
    }
    
    print('Database setup completed successfully');
  }

  // User operations
  Future<int> createUser(Map<String, dynamic> user) async {
    try {
      final db = await database;
      print('Creating user with data: $user');
      final result = await db.insert('users', user);
      print('User created with ID: $result');
      return result;
    } catch (e) {
      print('Error creating user: $e');
      rethrow;
    }
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