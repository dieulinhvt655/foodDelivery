import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:path/path.dart';
import '../models/food_model.dart';
import '../models/category_model.dart';

class FoodDatabaseHelper {
  static final FoodDatabaseHelper instance = FoodDatabaseHelper._init();
  static Database? _database;

  FoodDatabaseHelper._init();

  // Get database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('food_delivery.db');
    return _database!;
  }

  // Initialize database
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  // Create database tables
  Future<void> _createDB(Database db, int version) async {
    // Create Categories table
    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        icon TEXT NOT NULL,
        displayName TEXT NOT NULL
      )
    ''');

    // Create Foods table
    await db.execute('''
      CREATE TABLE foods (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        price REAL NOT NULL,
        image TEXT NOT NULL,
        categoryId TEXT NOT NULL,
        rating INTEGER NOT NULL,
        isAvailable INTEGER NOT NULL DEFAULT 1,
        preparationTime INTEGER,
        restaurantId TEXT,
        FOREIGN KEY (categoryId) REFERENCES categories (id)
      )
    ''');

    // Create indexes for better performance
    await db.execute('CREATE INDEX idx_foods_categoryId ON foods(categoryId)');
    await db.execute('CREATE INDEX idx_foods_restaurantId ON foods(restaurantId)');
  }

  // ==================== Category Operations ====================

  // Insert a category
  Future<String> insertCategory(CategoryModel category) async {
    final db = await database;
    await db.insert(
      'categories',
      category.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return category.id;
  }

  // Get all categories
  Future<List<CategoryModel>> getAllCategories() async {
    final db = await database;
    final result = await db.query('categories', orderBy: 'name ASC');
    return result.map((map) => CategoryModel.fromMap(map)).toList();
  }

  // Get category by ID
  Future<CategoryModel?> getCategoryById(String id) async {
    final db = await database;
    final maps = await db.query(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return CategoryModel.fromMap(maps.first);
    }
    return null;
  }

  // Get category by name
  Future<CategoryModel?> getCategoryByName(String name) async {
    final db = await database;
    final maps = await db.query(
      'categories',
      where: 'name = ?',
      whereArgs: [name],
    );

    if (maps.isNotEmpty) {
      return CategoryModel.fromMap(maps.first);
    }
    return null;
  }

  // Update category
  Future<int> updateCategory(CategoryModel category) async {
    final db = await database;
    return await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  // Delete category
  Future<int> deleteCategory(String id) async {
    final db = await database;
    return await db.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== Food Operations ====================

  // Insert a food
  Future<String> insertFood(FoodModel food) async {
    final db = await database;
    await db.insert(
      'foods',
      food.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return food.id;
  }

  // Insert multiple foods
  Future<void> insertFoods(List<FoodModel> foods) async {
    final db = await database;
    final batch = db.batch();

    for (var food in foods) {
      batch.insert(
        'foods',
        food.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  // Get all foods
  Future<List<FoodModel>> getAllFoods() async {
    final db = await database;
    final result = await db.query('foods', orderBy: 'name ASC');
    return result.map((map) => FoodModel.fromMap(map)).toList();
  }

  // Get food by ID
  Future<FoodModel?> getFoodById(String id) async {
    final db = await database;
    final maps = await db.query(
      'foods',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return FoodModel.fromMap(maps.first);
    }
    return null;
  }

  // Get foods by category ID
  Future<List<FoodModel>> getFoodsByCategoryId(String categoryId) async {
    final db = await database;
    final result = await db.query(
      'foods',
      where: 'categoryId = ?',
      whereArgs: [categoryId],
      orderBy: 'name ASC',
    );
    return result.map((map) => FoodModel.fromMap(map)).toList();
  }

  // Get available foods only
  Future<List<FoodModel>> getAvailableFoods() async {
    final db = await database;
    final result = await db.query(
      'foods',
      where: 'isAvailable = ?',
      whereArgs: [1],
      orderBy: 'name ASC',
    );
    return result.map((map) => FoodModel.fromMap(map)).toList();
  }

  // Get foods by restaurant ID
  Future<List<FoodModel>> getFoodsByRestaurantId(String restaurantId) async {
    final db = await database;
    final result = await db.query(
      'foods',
      where: 'restaurantId = ?',
      whereArgs: [restaurantId],
      orderBy: 'name ASC',
    );
    return result.map((map) => FoodModel.fromMap(map)).toList();
  }

  // Search foods by name
  Future<List<FoodModel>> searchFoods(String query) async {
    final db = await database;
    final result = await db.query(
      'foods',
      where: 'name LIKE ? OR description LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'name ASC',
    );
    return result.map((map) => FoodModel.fromMap(map)).toList();
  }

  // Update food
  Future<int> updateFood(FoodModel food) async {
    final db = await database;
    return await db.update(
      'foods',
      food.toMap(),
      where: 'id = ?',
      whereArgs: [food.id],
    );
  }

  // Delete food
  Future<int> deleteFood(String id) async {
    final db = await database;
    return await db.delete(
      'foods',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete all foods
  Future<int> deleteAllFoods() async {
    final db = await database;
    return await db.delete('foods');
  }

  // ==================== Utility Methods ====================

  // Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }

  // Delete database (for testing/reset)
  Future<void> deleteDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'food_delivery.db');
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }
}

