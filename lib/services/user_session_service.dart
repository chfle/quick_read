import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../repository/user_repository.dart';

class UserSessionService {
  static final UserSessionService _instance = UserSessionService._internal();
  factory UserSessionService() => _instance;
  UserSessionService._internal();

  final UserRepository _userRepository = UserRepository();
  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  static const String _userIdKey = 'current_user_id';
  static const String _usernameKey = 'current_username';

  Future<void> login(UserModel user) async {
    _currentUser = user;
    await _saveSession(user);
  }

  Future<void> logout() async {
    _currentUser = null;
    await _clearSession();
  }

  Future<void> _saveSession(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_userIdKey, user.id ?? 0);
    await prefs.setString(_usernameKey, user.username);
  }

  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
    await prefs.remove(_usernameKey);
  }

  Future<bool> restoreSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt(_userIdKey);
      final username = prefs.getString(_usernameKey);

      if (userId != null && username != null) {
        // Try to get user from database
        final user = await _userRepository.getUserById(userId);
        if (user != null) {
          _currentUser = user;
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Error restoring session: $e');
      return false;
    }
  }

  Future<void> updateCurrentUser(UserModel user) async {
    _currentUser = user;
    await _saveSession(user);
  }

  Future<void> refreshCurrentUser() async {
    if (_currentUser?.id != null) {
      final user = await _userRepository.getUserById(_currentUser!.id!);
      if (user != null) {
        _currentUser = user;
      }
    }
  }
}