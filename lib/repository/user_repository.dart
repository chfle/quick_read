// repositories/user_repository.dart
import '../database/database_helper.dart';
import '../models/user_model.dart';

class UserRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Create new user (Register)
  Future<bool> registerUser({
    required String username,
    required String password,
    List<String> favoriteCategories = const [],
  }) async {
    try {
      // Check if user already exists
      final existingUser = await _dbHelper.getUser(username);
      if (existingUser != null) {
        throw Exception('Username already exists');
      }

      final user = UserModel(
        username: username,
        password: password,
        favoriteCategories: favoriteCategories.isEmpty
            ? ['general', 'technology']
            : favoriteCategories,
      );

      await _dbHelper.createUser(user.toMap());
      return true;
    } catch (e) {
      throw Exception('Failed to register user: $e');
    }
  }

  // Login user
  Future<UserModel?> loginUser({
    required String username,
    required String password,
  }) async {
    try {
      final userMap = await _dbHelper.getUser(username);

      if (userMap == null) {
        throw Exception('User not found');
      }

      final user = UserModel.fromMap(userMap);

      // Simple password check (in production, use proper hashing)
      if (user.password != password) {
        throw Exception('Invalid password');
      }

      return user;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  // Get user by username
  Future<UserModel?> getUser(String username) async {
    try {
      final userMap = await _dbHelper.getUser(username);
      if (userMap != null) {
        return UserModel.fromMap(userMap);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  // Update user's favorite categories
  Future<void> updateFavoriteCategories({
    required int userId,
    required List<String> categories,
  }) async {
    try {
      final updateData = {
        'favoriteCategories': categories.join(','),
      };
      await _dbHelper.updateUser(userId, updateData);
    } catch (e) {
      throw Exception('Failed to update categories: $e');
    }
  }

  // Get user by ID
  Future<UserModel?> getUserById(int id) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.query(
        'users',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (result.isNotEmpty) {
        return UserModel.fromMap(result.first);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user by ID: $e');
    }
  }

  // Update entire user
  Future<void> updateUser(UserModel user) async {
    try {
      if (user.id != null) {
        await _dbHelper.updateUser(user.id!, user.toMap());
      }
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  // Check if username exists
  Future<bool> usernameExists(String username) async {
    try {
      final userMap = await _dbHelper.getUser(username);
      return userMap != null;
    } catch (e) {
      return false;
    }
  }

  // Update username
  Future<void> updateUsername({
    required int userId,
    required String newUsername,
  }) async {
    try {
      // Check if new username is already taken by another user
      final existingUser = await _dbHelper.getUser(newUsername);
      if (existingUser != null && existingUser['id'] != userId) {
        throw Exception('Username already taken');
      }

      final updateData = {
        'username': newUsername,
      };
      await _dbHelper.updateUser(userId, updateData);
    } catch (e) {
      throw Exception('Failed to update username: $e');
    }
  }

  // Update password
  Future<void> updatePassword({
    required int userId,
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      // Verify current password first
      final user = await getUserById(userId);
      if (user == null) {
        throw Exception('User not found');
      }

      if (user.password != currentPassword) {
        throw Exception('Current password is incorrect');
      }

      final updateData = {
        'password': newPassword,
      };
      await _dbHelper.updateUser(userId, updateData);
    } catch (e) {
      throw Exception('Failed to update password: $e');
    }
  }
}