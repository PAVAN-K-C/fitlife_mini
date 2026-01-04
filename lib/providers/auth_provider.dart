import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/database_service.dart';

class AuthProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  User? _currentUser;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;
  bool get isGuest => _currentUser?.isGuest ?? false;

  AuthProvider() {
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('currentUserId');

    if (userId != null) {
      _currentUser = await _databaseService.getUser(userId);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await _databaseService.getUserByEmail(email);

      if (user != null && user.password == password) {
        _currentUser = user;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('currentUserId', user.id);
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signup(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final existingUser = await _databaseService.getUserByEmail(email);

      if (existingUser != null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final newUser = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email,
        password: password,
        isGuest: false,
        createdAt: DateTime.now(),
      );

      await _databaseService.saveUser(newUser);
      _currentUser = newUser;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('currentUserId', newUser.id);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> loginAsGuest() async {
    _isLoading = true;
    notifyListeners();

    try {
      final guestUser = User(
        id: 'guest_${DateTime.now().millisecondsSinceEpoch}',
        email: 'guest@fitlifemini.local',
        isGuest: true,
        createdAt: DateTime.now(),
      );

      await _databaseService.saveUser(guestUser);
      _currentUser = guestUser;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('currentUserId', guestUser.id);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('currentUserId');
    notifyListeners();
  }
}
