import 'package:sqflite/sqflite.dart';
import 'account_database_helper.dart';

class FavoritesDatabaseHelper {
  FavoritesDatabaseHelper._();

  static final FavoritesDatabaseHelper instance = FavoritesDatabaseHelper._();
  static const String _table = 'favorites';

  Future<Database> get _db async => AccountDatabaseHelper.instance.database;

  Future<void> createTablesOnInit(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_table (
        food_id TEXT PRIMARY KEY
      );
    ''');
  }

  Future<List<String>> loadFavoriteFoodIds() async {
    final db = await _db;
    final rows = await db.query(_table, columns: ['food_id']);
    return rows.map((r) => r['food_id'] as String).toList();
  }

  Future<void> addFavorite(String foodId) async {
    final db = await _db;
    await db.insert(
      _table,
      {'food_id': foodId},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> removeFavorite(String foodId) async {
    final db = await _db;
    await db.delete(_table, where: 'food_id = ?', whereArgs: [foodId]);
  }
}


