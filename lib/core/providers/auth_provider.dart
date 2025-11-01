import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _userId;
  String? _userName;

  bool get isAuthenticated => _isAuthenticated;
  String? get userId => _userId;
  String? get userName => _userName;

  Future<void> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (email.isNotEmpty && password.isNotEmpty) {
      _userId = email;
      _userName = email.split('@').first;
      _isAuthenticated = true;
      notifyListeners();
    } else {
      throw Exception('Invalid credentials');
    }
  }

  void logout() {
    _userId = null;
    _userName = null;
    _isAuthenticated = false;
    notifyListeners();
  }
}


