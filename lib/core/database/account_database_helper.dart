import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/account_model.dart';

class AccountDatabaseHelper {
  AccountDatabaseHelper._();

  static final AccountDatabaseHelper instance = AccountDatabaseHelper._();
  static const _dbName = 'yummy.db';
  static const _dbVersion = 2;
  static const _usersTable = 'users';

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_usersTable (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            email TEXT NOT NULL UNIQUE,
            password TEXT NOT NULL,
            phone TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE $_usersTable ADD COLUMN phone TEXT');
        }
      },
    );
  }

  Future<int> insertAccount(AccountModel account) async {
    final db = await database;
    return db.insert(
      _usersTable,
      account.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<AccountModel?> getAccountByEmail(String email) async {
    final db = await database;
    final result = await db.query(
      _usersTable,
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return AccountModel.fromMap(result.first);
  }

  Future<AccountModel?> getAccountById(int id) async {
    final db = await database;
    final result = await db.query(
      _usersTable,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return AccountModel.fromMap(result.first);
  }

  Future<bool> checkAccountExists(String email) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT 1 FROM $_usersTable WHERE email = ? LIMIT 1',
      [email],
    );
    return result.isNotEmpty;
  }

  Future<int> updateAccount(AccountModel account) async {
    if (account.id == null) {
      throw ArgumentError('Account id is required for update');
    }
    final db = await database;
    return db.update(
      _usersTable,
      account.toMap()..remove('id'),
      where: 'id = ?',
      whereArgs: [account.id],
    );
  }
}

