import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _userId;
  String? _userName;

  bool get isAuthenticated => _isAuthenticated;
  String? get userId => _userId;
  String? get userName => _userName;

  void login(String userId, String userName) {
    _userId = userId;
    _userName = userName;
    _isAuthenticated = true;
    notifyListeners();
  }

  void logout() {
    _userId = null;
    _userName = null;
    _isAuthenticated = false;
    notifyListeners();
  }
}


