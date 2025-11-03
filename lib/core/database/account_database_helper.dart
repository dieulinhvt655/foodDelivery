import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/account_model.dart';
import 'order_database_helper.dart';
import 'notification_database_helper.dart';

class AccountDatabaseHelper {
  AccountDatabaseHelper._();

  static final AccountDatabaseHelper instance = AccountDatabaseHelper._();
  static const _dbName = 'yummy.db';
  static const _dbVersion = 6;
  static const _usersTable = 'users';
  static const _addressesTable = 'addresses';

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
        await _createUsersTable(db);
        await _createAddressesTable(db);
        // Initialize orders and notifications tables
        await OrderDatabaseHelper.instance.createTablesOnInit(db);
        await NotificationDatabaseHelper.instance.createTablesOnInit(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE $_usersTable ADD COLUMN phone TEXT');
        }
        if (oldVersion < 3) {
          await _createAddressesTable(db);
        }
        if (oldVersion < 4 || oldVersion < 5) {
          // Initialize orders and notifications tables
          await OrderDatabaseHelper.instance.createTablesOnInit(db);
          await NotificationDatabaseHelper.instance.createTablesOnInit(db);
        }
        if (oldVersion < 6) {
          // Add order_code column to orders table if it doesn't exist
          try {
            await db.execute('ALTER TABLE orders ADD COLUMN order_code TEXT');
          } catch (e) {
            // Column might already exist, ignore error
          }
        }
      },
    );
  }

  Future<void> _createUsersTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_usersTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        phone TEXT
      )
    ''');
  }

  Future<void> _createAddressesTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_addressesTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        label TEXT NOT NULL,
        address TEXT NOT NULL,
        phone TEXT,
        note TEXT,
        is_default INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        FOREIGN KEY(user_id) REFERENCES $_usersTable(id) ON DELETE CASCADE
      )
    ''');
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
    final data = account.toMap();
    data.remove('id');
    return db.update(
      _usersTable,
      data,
      where: 'id = ?',
      whereArgs: [account.id],
    );
  }
}

