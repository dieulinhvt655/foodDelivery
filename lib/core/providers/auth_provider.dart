import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import '../database/account_database_helper.dart';
import '../models/account_model.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider();

  final AccountDatabaseHelper _databaseHelper = AccountDatabaseHelper.instance;

  AccountModel? _currentAccount;
  UserModel? _currentUser;

  bool get isAuthenticated => _currentUser != null;
  String? get userId => _currentUser?.email;
  String? get userName => _currentUser?.name;
  UserModel? get currentUser => _currentUser;
  AccountModel? get currentAccount => _currentAccount;

  Future<void> login(String email, String password) async {
    final trimmedEmail = email.trim();
    final trimmedPassword = password.trim();

    if (trimmedEmail.isEmpty || trimmedPassword.isEmpty) {
      throw Exception('Please provide both email and password');
    }

    final account = await _databaseHelper.getAccountByEmail(trimmedEmail);
    if (account == null) {
      throw Exception('Account not found');
    }

    if (account.password != trimmedPassword) {
      throw Exception('Incorrect password');
    }

    _currentAccount = account;
    _currentUser = UserModel.fromAccount(account);
    notifyListeners();
  }

  Future<void> register(String name, String email, String password, {String? phone}) async {
    final trimmedName = name.trim();
    final trimmedEmail = email.trim();
    final trimmedPassword = password.trim();
    final trimmedPhone = phone?.trim();

    if (trimmedName.isEmpty || trimmedEmail.isEmpty || trimmedPassword.isEmpty) {
      throw Exception('Missing required fields');
    }

    final exists = await _databaseHelper.checkAccountExists(trimmedEmail);
    if (exists) {
      throw Exception('Email already registered');
    }

    final account = AccountModel(
      name: trimmedName,
      email: trimmedEmail,
      password: trimmedPassword,
      phone: trimmedPhone?.isEmpty ?? true ? null : trimmedPhone,
    );

    try {
      await _databaseHelper.insertAccount(account);
    } on DatabaseException catch (e) {
      if (e.isUniqueConstraintError()) {
        throw Exception('Email already registered');
      }
      throw Exception('Failed to create account');
    }
  }

  void logout() {
    _currentAccount = null;
    _currentUser = null;
    notifyListeners();
  }

  Future<void> updateProfile({
    required String name,
    required String email,
    String? phone,
  }) async {
    if (_currentAccount == null) {
      throw Exception('User not logged in');
    }

    final trimmedName = name.trim();
    final trimmedEmail = email.trim();
    final trimmedPhone = phone?.trim();

    if (trimmedName.isEmpty || trimmedEmail.isEmpty) {
      throw Exception('Name and email are required');
    }

    if (trimmedEmail != _currentAccount!.email) {
      final existing = await _databaseHelper.getAccountByEmail(trimmedEmail);
      if (existing != null && existing.id != _currentAccount!.id) {
        throw Exception('Email already registered');
      }
    }

    final updatedAccount = _currentAccount!.copyWith(
      name: trimmedName,
      email: trimmedEmail,
      phone: trimmedPhone?.isEmpty ?? true ? null : trimmedPhone,
    );

    await _databaseHelper.updateAccount(updatedAccount);

    _currentAccount = updatedAccount;
    _currentUser = UserModel.fromAccount(updatedAccount);
    notifyListeners();
  }
}


