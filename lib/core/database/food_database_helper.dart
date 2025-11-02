import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:path/path.dart';
import '../models/food_model.dart';
import '../models/category_model.dart';
import '../models/restaurants_model.dart';

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
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  // Create database tables
  Future<void> _createDB(Database db, int version) async {
    // Create Categories table
    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL
      )
    ''');

    // Create Restaurants table
    await db.execute('''
      CREATE TABLE restaurants (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        address TEXT,
        phone TEXT,
        image TEXT NOT NULL,
        rating INTEGER NOT NULL,
        is_open INTEGER NOT NULL DEFAULT 1
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
        FOREIGN KEY (categoryId) REFERENCES categories (id),
        FOREIGN KEY (restaurantId) REFERENCES restaurants (id)
      )
    ''');

    // Create indexes for better performance
    await db.execute('CREATE INDEX idx_foods_categoryId ON foods(categoryId)');
    await db.execute('CREATE INDEX idx_foods_restaurantId ON foods(restaurantId)');
    await db.execute('CREATE INDEX idx_restaurants_rating ON restaurants(rating)');

    // Insert sample data
    await _insertSampleData(db);
  }

  // Insert sample data
  Future<void> _insertSampleData(Database db) async {
    // Insert 5 categories: snacks, meal, vegan, dessert, drink
    await db.insert('categories', {'id': 'cat_1', 'name': 'snacks'});
    await db.insert('categories', {'id': 'cat_2', 'name': 'meal'});
    await db.insert('categories', {'id': 'cat_3', 'name': 'vegan'});
    await db.insert('categories', {'id': 'cat_4', 'name': 'dessert'});
    await db.insert('categories', {'id': 'cat_5', 'name': 'drink'});

    // Insert 10 restaurants
    await db.insert('restaurants', {
      'id': 'rest_1',
      'name': 'Burger King',
      'address': '123 Main Street, District 1, Ho Chi Minh City',
      'phone': '+84 28 1234 5678',
      'image': 'assets/images/restaurants/burger_king.jpg',
      'rating': 4,
      'is_open': 1,
    });
    await db.insert('restaurants', {
      'id': 'rest_2',
      'name': 'Pizza Hut',
      'address': '456 Nguyen Hue Boulevard, District 1, Ho Chi Minh City',
      'phone': '+84 28 2345 6789',
      'image': 'assets/images/restaurants/pizza_hut.jpg',
      'rating': 5,
      'is_open': 1,
    });
    await db.insert('restaurants', {
      'id': 'rest_3',
      'name': 'Sushi Express',
      'address': '789 Le Loi Street, District 1, Ho Chi Minh City',
      'phone': '+84 28 3456 7890',
      'image': 'assets/images/restaurants/sushi_express.jpg',
      'rating': 4,
      'is_open': 1,
    });
    await db.insert('restaurants', {
      'id': 'rest_4',
      'name': 'KFC Vietnam',
      'address': '555 Bui Vien Street, District 1, Ho Chi Minh City',
      'phone': '+84 28 5678 9012',
      'image': 'assets/images/restaurants/kfc.jpg',
      'rating': 4,
      'is_open': 1,
    });
    await db.insert('restaurants', {
      'id': 'rest_5',
      'name': 'McDonald\'s',
      'address': '888 Le Thanh Ton Street, District 1, Ho Chi Minh City',
      'phone': '+84 28 6789 0123',
      'image': 'assets/images/restaurants/mcdonalds.jpg',
      'rating': 4,
      'is_open': 1,
    });
      await db.insert('restaurants', {
        'id': 'rest_6',
        'name': 'Anân Saigon',
        'address': '89 Ho Tung Mau, District 1, Ho Chi Minh City',
        'phone': '+84 28 3914 8888',
        'image': 'assets/images/restaurants/anan_saigon.jpg',
        'rating': 5,
        'is_open': 1,
      });
    await db.insert('restaurants', {
      'id': 'rest_7',
      'name': 'Cục Gạch Quán',
      'address': '10 Dang Tat, District 1, Ho Chi Minh City',
      'phone': '+84 28 3925 3399',
      'image': 'assets/images/restaurants/cuc_gach_quan.jpg',
      'rating': 4,
      'is_open': 1,
    });
    await db.insert('restaurants', {
      'id': 'rest_8',
      'name': 'Pizza 4P’s – Le Thanh Ton',
      'address': '8/15 Le Thanh Ton, District 1, Ho Chi Minh City',
      'phone': '+84 28 3925 0570',
      'image': 'assets/images/restaurants/pizza_4ps.jpg',
      'rating': 5,
      'is_open': 1,
    });
    await db.insert('restaurants', {
      'id': 'rest_9',
      'name': 'Hum Vegetarian, Cafe & Restaurant',
      'address': '32 Vo Van Tan, District 3, Ho Chi Minh City',
      'phone': '+84 28 3823 1083',
      'image': 'assets/images/restaurants/hum_vegetarian.jpg',
      'rating': 5,
      'is_open': 1,
    });
    await db.insert('restaurants', {
      'id': 'rest_10',
      'name': 'La Villa French Restaurant',
      'address': '14 Ngo Quang Huy, Thao Dien, District 2, Ho Chi Minh City',
      'phone': '+84 28 3744 9191',
      'image': 'assets/images/restaurants/la_villa.jpg',
      'rating': 5,
      'is_open': 1,
    });
    await db.insert('restaurants', {
      'id': 'rest_6',
      'name': 'Anân Saigon',
      'address': '89 Ho Tung Mau, District 1, Ho Chi Minh City',
      'phone': '+84 28 3914 8888',
      'image': 'assets/images/restaurants/anan_saigon.jpg',
      'rating': 5,
      'is_open': 1,
    });
    await db.insert('restaurants', {
      'id': 'rest_7',
      'name': 'Cục Gạch Quán',
      'address': '10 Dang Tat, District 1, Ho Chi Minh City',
      'phone': '+84 28 3925 3399',
      'image': 'assets/images/restaurants/cuc_gach_quan.jpg',
      'rating': 4,
      'is_open': 1,
    });
    await db.insert('restaurants', {
      'id': 'rest_8',
      'name': 'Pizza 4P’s – Le Thanh Ton',
      'address': '8/15 Le Thanh Ton, District 1, Ho Chi Minh City',
      'phone': '+84 28 3925 0570',
      'image': 'assets/images/restaurants/pizza_4ps.jpg',
      'rating': 5,
      'is_open': 1,
    });
    await db.insert('restaurants', {
      'id': 'rest_9',
      'name': 'Hum Vegetarian, Cafe & Restaurant',
      'address': '32 Vo Van Tan, District 3, Ho Chi Minh City',
      'phone': '+84 28 3823 1083',
      'image': 'assets/images/restaurants/hum_vegetarian.jpg',
      'rating': 5,
      'is_open': 1,
    });
    await db.insert('restaurants', {
      'id': 'rest_10',
      'name': 'La Villa French Restaurant',
      'address': '14 Ngo Quang Huy, Thao Dien, District 2, Ho Chi Minh City',
      'phone': '+84 28 3744 9191',
      'image': 'assets/images/restaurants/la_villa.jpg',
      'rating': 5,
      'is_open': 1,
    });

    // Insert 25 foods - five for each category

    // Category: snacks (cat_1)
    await db.insert('foods', {
      'id': 'food_1',
      'name': 'Onion Rings',
      'description': 'Crispy onion rings served with BBQ sauce',
      'price': 9.0,
      'image': 'assets/images/dishes-square/onion_rings.jpg',
      'categoryId': 'cat_1',
      'rating': 4,
      'isAvailable': 1,
      'preparationTime': 6,
      'restaurantId': 'rest_8',
    });
    await db.insert('foods', {
      'id': 'food_2',
      'name': 'Sweet Potato Fries',
      'description': 'Baked sweet potato fries with sea salt',
      'price': 8.5,
      'image': 'assets/images/dishes-square/sweet_potato_fries.jpg',
      'categoryId': 'cat_1',
      'rating': 4,
      'isAvailable': 1,
      'preparationTime': 7,
      'restaurantId': 'rest_4',
    });
    await db.insert('foods', {
      'id': 'food_3',
      'name': 'Nachos with Cheese',
      'description': 'Corn tortilla chips topped with melted cheese and jalapenos',
      'price': 11.0,
      'image': 'assets/images/dishes-square/nachos_cheese.jpg',
      'categoryId': 'cat_1',
      'rating': 5,
      'isAvailable': 1,
      'preparationTime': 8,
      'restaurantId': 'rest_2',
    });
    await db.insert('foods', {
      'id': 'food_4',
      'name': 'Garlic Bread Sticks',
      'description': 'Warm garlic bread sticks served with marinara sauce',
      'price': 7.5,
      'image': 'assets/images/dishes-square/garlic_bread_sticks.jpg',
      'categoryId': 'cat_1',
      'rating': 4,
      'isAvailable': 1,
      'preparationTime': 5,
      'restaurantId': 'rest_5',
    });
    await db.insert('foods', {
      'id': 'food_5',
      'name': 'Potato Chips',
      'description': 'Crispy golden potato chips seasoned with salt',
      'price': 8.50,
      'image': 'assets/images/dishes-square/Rectangle 128.svg',
      'categoryId': 'cat_1', // snacks
      'rating': 4,
      'isAvailable': 1,
      'preparationTime': 5,
      'restaurantId': 'rest_4', // KFC
    });

    // Category: meal (cat_2)
    await db.insert('foods', {
      'id': 'food_6',
      'name': 'Grilled Salmon Fillet',
      'description': 'Grilled salmon served with lemon butter sauce and veggies',
      'price': 28.0,
      'image': 'assets/images/dishes-square/grilled_salmon.jpg',
      'categoryId': 'cat_2',
      'rating': 5,
      'isAvailable': 1,
      'preparationTime': 14,
      'restaurantId': 'rest_6',
    });
    await db.insert('foods', {
      'id': 'food_7',
      'name': 'Chicken Alfredo Pasta',
      'description': 'Fettuccine with creamy Alfredo sauce and grilled chicken',
      'price': 22.0,
      'image': 'assets/images/dishes-square/chicken_alfredo.jpg',
      'categoryId': 'cat_2',
      'rating': 4,
      'isAvailable': 1,
      'preparationTime': 12,
      'restaurantId': 'rest_7',
    });
    await db.insert('foods', {
      'id': 'food_8',
      'name': 'Beef Steak Medium',
      'description': '10oz beef steak cooked medium, served with mashed potato',
      'price': 30.0,
      'image': 'assets/images/dishes-square/beef_steak.jpg',
      'categoryId': 'cat_2',
      'rating': 5,
      'isAvailable': 1,
      'preparationTime': 15,
      'restaurantId': 'rest_10',
    });
    await db.insert('foods', {
      'id': 'food_9',
      'name': 'Shrimp Scampi',
      'description': 'Garlic butter shrimp served with pasta and greens',
      'price': 24.0,
      'image': 'assets/images/dishes-square/shrimp_scampi.jpg',
      'categoryId': 'cat_2',
      'rating': 4,
      'isAvailable': 1,
      'preparationTime': 13,
      'restaurantId': 'rest_3',
    });
    await db.insert('foods', {
      'id': 'food_10',
      'name': 'Sushi Roll',
      'description': 'Fresh sushi roll with salmon and avocado',
      'price': 103.0,
      'image': 'assets/images/dishes-square/Rectangle 128-1.svg',
      'categoryId': 'cat_2', // meal
      'rating': 5,
      'isAvailable': 1,
      'preparationTime': 15,
      'restaurantId': 'rest_3', // Sushi Express
    });

// Category: vegan (cat_3)
    await db.insert('foods', {
      'id': 'food_11',
      'name': 'Vegan Burger',
      'description': 'Plant-based burger with fresh vegetables and vegan sauce',
      'price': 25.0,
      'image': 'assets/images/dishes-square/Rectangle 128-2.svg',
      'categoryId': 'cat_3', // vegan
      'rating': 5,
      'isAvailable': 1,
      'preparationTime': 10,
      'restaurantId': 'rest_1', // Burger King
    });
    await db.insert('foods', {
      'id': 'food_12',
      'name': 'Vegan Falafel Wrap',
      'description': 'Falafel wrap with hummus, lettuce and vegan mayo',
      'price': 14.0,
      'image': 'assets/images/dishes-square/vegan_falafel_wrap.jpg',
      'categoryId': 'cat_3',
      'rating': 4,
      'isAvailable': 1,
      'preparationTime': 8,
      'restaurantId': 'rest_9',
    });
    await db.insert('foods', {
      'id': 'food_13',
      'name': 'Quinoa & Kale Bowl',
      'description': 'Quinoa and kale salad bowl with avocado and seeds',
      'price': 16.0,
      'image': 'assets/images/dishes-square/quinoa_kale_bowl.jpg',
      'categoryId': 'cat_3',
      'rating': 5,
      'isAvailable': 1,
      'preparationTime': 9,
      'restaurantId': 'rest_9',
    });
    await db.insert('foods', {
      'id': 'food_14',
      'name': 'Stuffed Bell Peppers',
      'description': 'Bell peppers stuffed with rice, beans and vegan cheese',
      'price': 18.0,
      'image': 'assets/images/dishes-square/stuffed_bell_peppers.jpg',
      'categoryId': 'cat_3',
      'rating': 4,
      'isAvailable': 1,
      'preparationTime': 12,
      'restaurantId': 'rest_9',
    });
    await db.insert('foods', {
      'id': 'food_15',
      'name': 'Vegan Pad Thai',
      'description': 'Rice noodles stir-fried with tofu, peanuts and tamarind sauce',
      'price': 17.0,
      'image': 'assets/images/dishes-square/vegan_pad_thai.jpg',
      'categoryId': 'cat_3',
      'rating': 5,
      'isAvailable': 1,
      'preparationTime': 11,
      'restaurantId': 'rest_9',
    });
    // Category: dessert (cat_4)
    await db.insert('foods', {
      'id': 'food_16',
      'name': 'Berry Cheesecake',
      'description': 'New York style cheesecake topped with fresh mixed berries',
      'price': 15.0,
      'image': 'assets/images/dishes-square/berry_cheesecake.jpg',
      'categoryId': 'cat_4',
      'rating': 5,
      'isAvailable': 1,
      'preparationTime': 0,
      'restaurantId': 'rest_6',
    });
    await db.insert('foods', {
      'id': 'food_17',
      'name': 'Tiramisu Classic',
      'description': 'Italian tiramisu with mascarpone and espresso soaked ladyfingers',
      'price': 14.0,
      'image': 'assets/images/dishes-square/tiramisu_classic.jpg',
      'categoryId': 'cat_4',
      'rating': 5,
      'isAvailable': 1,
      'preparationTime': 0,
      'restaurantId': 'rest_10',
    });
    await db.insert('foods', {
      'id': 'food_18',
      'name': 'Lemon Tart',
      'description': 'Tangy lemon tart with buttery crust and whipped cream',
      'price': 12.0,
      'image': 'assets/images/dishes-square/lemon_tart.jpg',
      'categoryId': 'cat_4',
      'rating': 4,
      'isAvailable': 1,
      'preparationTime': 0,
      'restaurantId': 'rest_7',
    });
    await db.insert('foods', {
      'id': 'food_19',
      'name': 'Matcha Ice Cream Bowl',
      'description': 'Japanese matcha ice cream served with red beans and mochi',
      'price': 13.0,
      'image': 'assets/images/dishes-square/matcha_ice_cream.jpg',
      'categoryId': 'cat_4',
      'rating': 5,
      'isAvailable': 1,
      'preparationTime': 0,
      'restaurantId': 'rest_8',
    });
    await db.insert('foods', {
      'id': 'food_20',
      'name': 'Chocolate Cake',
      'description': 'Rich chocolate cake with cream frosting',
      'price': 15.0,
      'image': 'assets/images/dishes-square/Rectangle 133.svg',
      'categoryId': 'cat_4', // dessert
      'rating': 5,
      'isAvailable': 1,
      'preparationTime': 0,
      'restaurantId': 'rest_5', // McDonald's
    });

// Category: drink (cat_5)
    await db.insert('foods', {
      'id': 'food_21',
      'name': 'Mango Smoothie',
      'description': 'Fresh mango blended with yogurt and honey',
      'price': 6.0,
      'image': 'assets/images/dishes-square/mango_smoothie.jpg',
      'categoryId': 'cat_5',
      'rating': 4,
      'isAvailable': 1,
      'preparationTime': 3,
      'restaurantId': 'rest_2',
    });
    await db.insert('foods', {
      'id': 'food_22',
      'name': 'Strawberry Milkshake',
      'description': 'Creamy strawberry milkshake topped with whipped cream',
      'price': 5.5,
      'image': 'assets/images/dishes-square/strawberry_milkshake.jpg',
      'categoryId': 'cat_5',
      'rating': 4,
      'isAvailable': 1,
      'preparationTime': 2,
      'restaurantId': 'rest_5',
    });
    await db.insert('foods', {
      'id': 'food_23',
      'name': 'Iced Matcha Latte',
      'description': 'Iced matcha latte with almond milk and honey',
      'price': 5.0,
      'image': 'assets/images/dishes-square/iced_matcha_latte.jpg',
      'categoryId': 'cat_5',
      'rating': 5,
      'isAvailable': 1,
      'preparationTime': 2,
      'restaurantId': 'rest_9',
    });
    await db.insert('foods', {
      'id': 'food_24',
      'name': 'Sparkling Lemonade',
      'description': 'Fresh lemonade with sparkling water and mint leaves',
      'price': 4.0,
      'image': 'assets/images/dishes-square/sparkling_lemonade.jpg',
      'categoryId': 'cat_5',
      'rating': 4,
      'isAvailable': 1,
      'preparationTime': 1,
      'restaurantId': 'rest_3',
    });
    await db.insert('foods', {
      'id': 'food_25',
      'name': 'Fresh Orange Juice',
      'description': 'Freshly squeezed orange juice, no added sugar',
      'price': 5.0,
      'image': 'assets/images/dishes-square/orange_juice.jpg',
      'categoryId': 'cat_5', // drink
      'rating': 4,
      'isAvailable': 1,
      'preparationTime': 3,
      'restaurantId': 'rest_2', // Pizza Hut
    });
  }

  // Upgrade database schema
  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add restaurants table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS restaurants (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          address TEXT,
          phone TEXT,
          image TEXT NOT NULL,
          rating INTEGER NOT NULL,
          is_open INTEGER NOT NULL DEFAULT 1
        )
      ''');

      // Add foreign key constraint to foods table (if not exists)
      // Note: SQLite doesn't support adding foreign key constraints to existing tables
      // So we'll just add the index
      await db.execute('CREATE INDEX IF NOT EXISTS idx_restaurants_rating ON restaurants(rating)');
    }
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

  // ==================== Restaurant Operations ====================

  // Insert a restaurant
  Future<String> insertRestaurant(RestaurantModel restaurant) async {
    final db = await database;
    await db.insert(
      'restaurants',
      restaurant.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return restaurant.id;
  }

  // Insert multiple restaurants
  Future<void> insertRestaurants(List<RestaurantModel> restaurants) async {
    final db = await database;
    final batch = db.batch();

    for (var restaurant in restaurants) {
      batch.insert(
        'restaurants',
        restaurant.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  // Get all restaurants
  Future<List<RestaurantModel>> getAllRestaurants() async {
    final db = await database;
    final result = await db.query('restaurants', orderBy: 'name ASC');
    return result.map((map) => RestaurantModel.fromMap(map)).toList();
  }

  // Get restaurant by ID
  Future<RestaurantModel?> getRestaurantById(String id) async {
    final db = await database;
    final maps = await db.query(
      'restaurants',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return RestaurantModel.fromMap(maps.first);
    }
    return null;
  }

  // Get open restaurants only
  Future<List<RestaurantModel>> getOpenRestaurants() async {
    final db = await database;
    final result = await db.query(
      'restaurants',
      where: 'is_open = ?',
      whereArgs: [1],
      orderBy: 'name ASC',
    );
    return result.map((map) => RestaurantModel.fromMap(map)).toList();
  }

  // Get restaurants by rating (filter by minimum rating)
  Future<List<RestaurantModel>> getRestaurantsByRating(int minRating) async {
    final db = await database;
    final result = await db.query(
      'restaurants',
      where: 'rating >= ?',
      whereArgs: [minRating],
      orderBy: 'rating DESC, name ASC',
    );
    return result.map((map) => RestaurantModel.fromMap(map)).toList();
  }

  // Search restaurants by name
  Future<List<RestaurantModel>> searchRestaurants(String query) async {
    final db = await database;
    final result = await db.query(
      'restaurants',
      where: 'name LIKE ? OR address LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'name ASC',
    );
    return result.map((map) => RestaurantModel.fromMap(map)).toList();
  }

  // Update restaurant
  Future<int> updateRestaurant(RestaurantModel restaurant) async {
    final db = await database;
    return await db.update(
      'restaurants',
      restaurant.toMap(),
      where: 'id = ?',
      whereArgs: [restaurant.id],
    );
  }

  // Delete restaurant
  Future<int> deleteRestaurant(String id) async {
    final db = await database;
    return await db.delete(
      'restaurants',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete all restaurants
  Future<int> deleteAllRestaurants() async {
    final db = await database;
    return await db.delete('restaurants');
  }

  // Get restaurants with their foods count
  Future<List<Map<String, dynamic>>> getRestaurantsWithFoodCount() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT 
        r.*,
        COUNT(f.id) as foodCount
      FROM restaurants r
      LEFT JOIN foods f ON r.id = f.restaurantId
      GROUP BY r.id
      ORDER BY r.name ASC
    ''');
    return result;
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

