import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/cart_item_model.dart';

class CartDatabaseHelper {
  CartDatabaseHelper._();

  static final CartDatabaseHelper instance = CartDatabaseHelper._();
  static const _dbName = 'yummy.db';
  static const _dbVersion = 4;
  static const _cartTable = 'cart_items';

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
        await _createCartTable(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 4) {
          await _createCartTable(db);
        }
      },
    );
  }

  Future<void> _createCartTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_cartTable (
        id TEXT PRIMARY KEY,
        user_email TEXT NOT NULL,
        food_id TEXT NOT NULL,
        food_name TEXT NOT NULL,
        food_image TEXT NOT NULL,
        price REAL NOT NULL,
        quantity INTEGER NOT NULL,
        restaurant_id TEXT NOT NULL,
        restaurant_name TEXT NOT NULL
      )
    ''');
  }

  // Save cart items for a user
  Future<void> saveCart(String userEmail, List<CartItemModel> items) async {
    final db = await database;
    
    // Delete old cart items for this user
    await db.delete(
      _cartTable,
      where: 'user_email = ?',
      whereArgs: [userEmail],
    );

    // Insert new cart items
    for (var item in items) {
      await db.insert(
        _cartTable,
        {
          'id': item.id,
          'user_email': userEmail,
          'food_id': item.foodId,
          'food_name': item.foodName,
          'food_image': item.foodImage,
          'price': item.price,
          'quantity': item.quantity,
          'restaurant_id': item.restaurantId,
          'restaurant_name': item.restaurantName,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  // Load cart items for a user
  Future<List<CartItemModel>> loadCart(String userEmail) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _cartTable,
      where: 'user_email = ?',
      whereArgs: [userEmail],
    );

    return List.generate(maps.length, (i) {
      return CartItemModel.fromMap(maps[i]);
    });
  }

  // Clear cart for a user
  Future<void> clearCart(String userEmail) async {
    final db = await database;
    await db.delete(
      _cartTable,
      where: 'user_email = ?',
      whereArgs: [userEmail],
    );
  }
}

