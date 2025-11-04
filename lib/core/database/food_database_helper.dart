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
      version: 3,
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
        rating REAL NOT NULL,
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
        rating REAL NOT NULL,
        isAvailable INTEGER NOT NULL DEFAULT 1,
        preparationTime INTEGER,
        FOREIGN KEY (categoryId) REFERENCES categories (id)
      )
    ''');

    // Create RestaurantFoods table (many-to-many relationship)
    await db.execute('''
      CREATE TABLE restaurant_foods (
        id TEXT PRIMARY KEY,
        restaurantId TEXT NOT NULL,
        foodId TEXT NOT NULL,
        price REAL,
        isAvailable INTEGER,
        preparationTime INTEGER,
        FOREIGN KEY (restaurantId) REFERENCES restaurants(id),
        FOREIGN KEY (foodId) REFERENCES foods(id)
      )
    ''');

    // Create indexes for better performance
    await db.execute('CREATE INDEX idx_foods_categoryId ON foods(categoryId)');
    await db.execute('CREATE INDEX idx_restaurant_foods_restaurantId ON restaurant_foods(restaurantId)');
    await db.execute('CREATE INDEX idx_restaurant_foods_foodId ON restaurant_foods(foodId)');
    await db.execute('CREATE INDEX idx_restaurants_rating ON restaurants(rating)');

    // Insert sample data
    await _insertSampleData(db);
  }

  /// Insert sample data
  Future<void> _insertSampleData(Database db) async {
    // Insert 5 categories: snacks, meal, vegan, dessert, drink
    await db.insert('categories', {'id': 'cat_1', 'name': 'snacks'});
    await db.insert('categories', {'id': 'cat_2', 'name': 'meal'});
    await db.insert('categories', {'id': 'cat_3', 'name': 'vegan'});
    await db.insert('categories', {'id': 'cat_4', 'name': 'dessert'});
    await db.insert('categories', {'id': 'cat_5', 'name': 'drink'});

    /// Insert 10 restaurants
    await db.insert('restaurants', {
      'id': 'rest_1',
      'name': 'Burger King',
      'address': 'C4 Giang Vo, Ba Dinh District, Hanoi',
      'phone': '+84 28 1234 5678',
      'image': 'assets/images/restaurants/burger_king.jpg',
      'rating': 4,
      'is_open': 1,
    });
    await db.insert('restaurants', {
      'id': 'rest_2',
      'name': 'Pizza Hut',
      'address': 'Ho Guom Plaza, 110 Tran Phu Street, Ha Dong District, Ha Noi',
      'phone': '+84 28 2345 6789',
      'image': 'assets/images/restaurants/pizza_hut.jpg',
      'rating': 5,
      'is_open': 1,
    });
    await db.insert('restaurants', {
      'id': 'rest_3',
      'name': 'Sushi Express',
      'address': 'JW Hotel, Me Tri, South Tu Liem District, Hanoi',
      'phone': '+84 28 3456 7890',
      'image': 'assets/images/restaurants/sushi_express.jpg',
      'rating': 4,
      'is_open': 1,
    });
    await db.insert('restaurants', {
      'id': 'rest_4',
      'name': 'KFC Vietnam',
      'address': '34 Hang Bun, Ba Dinh Dist. Hanoi',
      'phone': '+84 28 5678 9012',
      'image': 'assets/images/restaurants/kfc.jpg',
      'rating': 4,
      'is_open': 1,
    });
    await db.insert('restaurants', {
      'id': 'rest_5',
      'name': 'McDonalds',
      'address': '34 Hang Bai, Hoan Kiem Dist. Hanoi',
      'phone': '+84 28 6789 0123',
      'image': 'assets/images/restaurants/mcdonalds.jpg',
      'rating': 4,
      'is_open': 1,
    });
    await db.insert('restaurants', {
      'id': 'rest_6',
      'name': 'Pizza 4P’s',
      'address': '05 Phan Ke Binh, Ba Dinh Hanoi',
      'phone': '+84 28 3925 0570',
      'image': 'assets/images/restaurants/pizza_4ps.jpg',
      'rating': 5,
      'is_open': 1,
    });
    await db.insert('restaurants', {
      'id': 'rest_7',
      'name': 'THE VEG - Organic vego & tea',
      'address': '2nd Floor, 48 Trang Tien Street Hoan Kiem Hanoi',
      'phone': '+84 28 3823 1083',
      'image': 'assets/images/restaurants/theveg.jpg',
      'rating': 5,
      'is_open': 1,
    });
    await db.insert('restaurants', {
      'id': 'rest_8',
      'name': 'French Grill',
      'address': 'No. 8, Do Duc Duc Road, Me Tri, South Tu Liem District, Hanoi',
      'phone': '+84 28 3744 9191',
      'image': 'assets/images/restaurants/french_grill.jpg',
      'rating': 5,
      'is_open': 1,
    });
    await db.insert('restaurants', {
      'id': 'rest_9',
      'name': 'Jollibee',
      'address': '2 Pham Ngoc Thach, Trung Tự Ward, Dong Da Distric, Ha Noi City',
      'phone': '+84 24 2346 6333',
      'image': 'assets/images/restaurants/jollibee.jpg',
      'rating': 4.8,
      'is_open': 1,
    });
    await db.insert('restaurants', {
      'id': 'rest_10',
      'name': 'Fresh Garden',
      'address': 'Nguy Nhu Kon Tum Street, Thanh Xuan District, Hanoi',
      'phone': '+84 24 3856 3856',
      'image': 'assets/images/restaurants/fresh_garden.jpg',
      'rating': 4.2,
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
    });
    await db.insert('foods', {
      'id': 'food_26',
      'name': 'Chickenjoy Solo',
      'description': '1-piece crispy fried chicken served with Jollibee gravy.',
      'price': 6.5,
      'image': 'assets/images/dishes-square/chickenjoy_solo.jpg',
      'categoryId': 'cat_2',
      'rating': 5,
      'isAvailable': 1,
      'preparationTime': 10,
    });
    await db.insert('foods', {
      'id': 'food_27',
      'name': 'Chickenjoy Spaghetti Combo',
      'description': '1-piece Chickenjoy with Jolly Spaghetti and a drink.',
      'price': 9.5,
      'image': 'assets/images/dishes-square/chickenjoy_spaghetti.jpg',
      'categoryId': 'cat_2',
      'rating': 4.7,
      'isAvailable': 1,
      'preparationTime': 14,
    });
    await db.insert('foods', {
      'id': 'food_28',
      'name': 'Chicken Burger Steak',
      'description': 'Tender chicken patty with savory mushroom gravy, served with rice.',
      'price': 7.0,
      'image': 'assets/images/dishes-square/chicken_burger_steak.jpg',
      'categoryId': 'cat_2',
      'rating': 4.6,
      'isAvailable': 1,
      'preparationTime': 9,
    });
    await db.insert('foods', {
      'id': 'food_29',
      'name': 'Salmon Nigiri',
      'description': 'Fresh salmon slice over seasoned sushi rice, served with wasabi and soy sauce.',
      'price': 4.5,
      'image': 'assets/images/dishes-square/salmon_nigiri.jpg',
      'categoryId': 'cat_2',
      'rating': 4.8,
      'isAvailable': 1,
      'preparationTime': 25,
    });
    await db.insert('foods', {
      'id': 'food_30',
      'name': 'Tuna Sashimi',
      'description': 'Thinly sliced fresh tuna served raw with soy sauce and wasabi.',
      'price': 6.0,
      'image': 'assets/images/dishes-square/tuna_sashimi.jpg',
      'categoryId': 'cat_2',
      'rating': 4.7,
      'isAvailable': 1,
      'preparationTime': 25,
    });
    await db.insert('foods', {
      'id': 'food_31',
      'name': 'Ebi Tempura',
      'description': 'Crispy fried shrimp tempura served with dipping sauce.',
      'price': 6.5,
      'image': 'assets/images/dishes-square/ebi_tempura.jpg',
      'categoryId': 'cat_2',
      'rating': 4.8,
      'isAvailable': 1,
      'preparationTime': 30,
    });
    await db.insert('foods', {
      'id': 'food_32',
      'name': 'Sushi Bento Box',
      'description': 'Assorted sushi rolls, sashimi, and tempura served with miso soup and salad.',
      'price': 15.0,
      'image': 'assets/images/dishes-square/sushi_bento_box.jpg',
      'categoryId': 'cat_2',
      'rating': 5,
      'isAvailable': 1,
      'preparationTime': 30,
    });
    await db.insert('foods', {
      'id': 'food_33',
      'name': 'Miso Soup',
      'description': 'Traditional Japanese miso soup with tofu, seaweed, and scallions.',
      'price': 3.0,
      'image': 'assets/images/dishes-square/miso_soup.jpg',
      'categoryId': 'cat_2',
      'rating': 4.4,
      'isAvailable': 1,
      'preparationTime': 3,
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
    });
    await db.insert('foods', {
      'id': 'food_34',
      'name': 'Cappuccino',
      'description': 'Rich espresso topped with steamed milk and foam.',
      'price': 4.0,
      'image': 'assets/images/dishes-square/cappuccino.jpg',
      'categoryId': 'cat_5',
      'rating': 4.8,
      'isAvailable': 1,
      'preparationTime': 5,
    });
    await db.insert('foods', {
      'id': 'food_35',
      'name': 'Iced Americano',
      'description': 'Strong espresso shot poured over ice water.',
      'price': 3.8,
      'image': 'assets/images/dishes-square/iced_americano.jpg',
      'categoryId': 'cat_5',
      'rating': 4.6,
      'isAvailable': 1,
      'preparationTime': 10,
    });
    await db.insert('foods', {
      'id': 'food_36',
      'name': 'Coconut Water',
      'description': 'Natural coconut water served chilled for instant refreshment.',
      'price': 3.0,
      'image': 'assets/images/dishes-square/coconut_water.jpg',
      'categoryId': 'cat_5',
      'rating': 4.3,
      'isAvailable': 1,
      'preparationTime': 1,
    });

 //Insert Restaurant_Foods data
 //F1
    await db.insert('restaurant_foods', {
      'id': 'rf_1',
      'restaurantId': 'rest_1',
      'foodId': 'food_1',
      'price': 9.0,
      'isAvailable': 1,
      'preparationTime': 6,
    });
    await db.insert('restaurant_foods', {
      'id': 'rf_2',
      'restaurantId': 'rest_2',
      'foodId': 'food_1',
      'price': 9.0,
      'isAvailable': 1,
      'preparationTime': 10,
    });
    await db.insert('restaurant_foods', {
      'id': 'rf_3',
      'restaurantId': 'rest_5',
      'foodId': 'food_1',
      'price': 11.0,
      'isAvailable': 1,
      'preparationTime': 8,
    });
    await db.insert('restaurant_foods', {
      'id': 'rf_4',
      'restaurantId': 'rest_6',
      'foodId': 'food_1',
      'price': 11.0,
      'isAvailable': 1,
      'preparationTime': 8,
    });
//F2
  await db.insert('restaurant_foods', {
    'id': 'rf_5',
    'restaurantId': 'rest_1',
    'foodId': 'food_2',
    'price': 8.5,
    'isAvailable': 1,
    'preparationTime': 8,
  });
  await db.insert('restaurant_foods', {
    'id': 'rf_6',
    'restaurantId': 'rest_2',
    'foodId': 'food_2',
    'price': 8.5,
    'isAvailable': 1,
    'preparationTime': 8,
  });
  await db.insert('restaurant_foods', {
    'id': 'rf_7',
    'restaurantId': 'rest_7',
    'foodId': 'food_2',
    'price': 8.5,
    'isAvailable': 1,
    'preparationTime': 8,
  });
  await db.insert('restaurant_foods', {
    'id': 'rf_8',
    'restaurantId': 'rest_8',
    'foodId': 'food_2',
    'price': 8.5,
    'isAvailable': 1,
    'preparationTime': 8,
  });
//F3
    await db.insert('restaurant_foods', {
    'id': 'rf_9',
    'restaurantId': 'rest_1',
    'foodId': 'food_3',
    'price': 11.0,
    'isAvailable': 1,
    'preparationTime': 8,
    });
    await db.insert('restaurant_foods', {
    'id': 'rf_10',
    'restaurantId': 'rest_4',
    'foodId': 'food_3',
    'price': 11.0,
    'isAvailable': 1,
    'preparationTime': 8,
    });
    await db.insert('restaurant_foods', {
    'id': 'rf_11',
    'restaurantId': 'rest_8',
    'foodId': 'food_3',
    'price': 11.0,
    'isAvailable': 1,
    'preparationTime': 8,
    });
//F4
    await db.insert('restaurant_foods', {
    'id': 'rf_12',
    'restaurantId': 'rest_1',
    'foodId': 'food_4',
    'price': 7.5,
    'isAvailable': 1,
    'preparationTime': 5,
    });
    await db.insert('restaurant_foods', {
    'id': 'rf_13',
    'restaurantId': 'rest_3',
    'foodId': 'food_4',
    'price': 7.5,
    'isAvailable': 1,
    'preparationTime': 5,
    });
    await db.insert('restaurant_foods', {
    'id': 'rf_14',
    'restaurantId': 'rest_7',
    'foodId': 'food_4',
    'price': 7.5,
    'isAvailable': 1,
    'preparationTime': 5,
    });
    await db.insert('restaurant_foods', {
    'id': 'rf_15',
    'restaurantId': 'rest_8',
    'foodId': 'food_4',
    'price': 7.5,
    'isAvailable': 1,
    'preparationTime': 5,
    });
//F5
    await db.insert('restaurant_foods', {
    'id': 'rf_16',
    'restaurantId': 'rest_4',
    'foodId': 'food_5',
    'price': 8.5,
    'isAvailable': 1,
    'preparationTime': 8,
    });
    await db.insert('restaurant_foods', {
    'id': 'rf_17',
    'restaurantId': 'rest_5',
    'foodId': 'food_5',
    'price': 8.5,
    'isAvailable': 1,
    'preparationTime': 8,
    });
    await db.insert('restaurant_foods', {
    'id': 'rf_18',
    'restaurantId': 'rest_6',
    'foodId': 'food_5',
    'price': 8.5,
    'isAvailable': 1,
    'preparationTime': 8,
    });
    await db.insert('restaurant_foods', {
    'id': 'rf_19',
    'restaurantId': 'rest_9',
    'foodId': 'food_5',
    'price': 8.5,
    'isAvailable': 1,
    'preparationTime': 8,
    }); 
    await db.insert('restaurant_foods', {
    'id': 'rf_20',
    'restaurantId': 'rest_7',
    'foodId': 'food_5',
    'price': 8.5,
    'isAvailable': 1,
    'preparationTime': 8,
    });         
    await db.insert('restaurant_foods', {
    'id': 'rf_21',
    'restaurantId': 'rest_2',
    'foodId': 'food_5',
    'price': 8.5,
    'isAvailable': 1,
    'preparationTime': 8,
    });    
    await db.insert('restaurant_foods', {
    'id': 'rf_22',
    'restaurantId': 'rest_1',
    'foodId': 'food_5',
    'price': 8.5,
    'isAvailable': 1,
    'preparationTime': 8,
    });   
 //F6 - Grilled Salmon (for rest_3 - Sushi Express)
 await db.insert('restaurant_foods', {
    'id': 'rf_23',
    'restaurantId': 'rest_3',
    'foodId': 'food_6',
    'price': 28.0,
    'isAvailable': 1,
    'preparationTime': 14,
    });
    //F7 - Chicken Alfredo Pasta
    await db.insert('restaurant_foods', {
    'id': 'rf_24',
    'restaurantId': 'rest_4',
    'foodId': 'food_7',
    'price': 22.0,
    'isAvailable': 1,
    'preparationTime': 12,
    });
    await db.insert('restaurant_foods', {
    'id': 'rf_25',
    'restaurantId': 'rest_5',
    'foodId': 'food_7',
    'price': 22.0,
    'isAvailable': 1,
    'preparationTime': 12,
    });
    await db.insert('restaurant_foods', {
    'id': 'rf_26',
    'restaurantId': 'rest_9',
    'foodId': 'food_7',
    'price': 22.0,
    'isAvailable': 1,
    'preparationTime': 12,
    });
//F8 - Beef Steak Medium
    await db.insert('restaurant_foods', {
        'id': 'rf_27',
        'restaurantId': 'rest_1',
        'foodId': 'food_8',
        'price': 30.0,
        'isAvailable': 1,
        'preparationTime': 15,
    });
    await db.insert('restaurant_foods', {
        'id': 'rf_28',
        'restaurantId': 'rest_8',
        'foodId': 'food_8',
        'price': 30.0,
        'isAvailable': 1,
        'preparationTime': 15,
    });
    await db.insert('restaurant_foods', {
        'id': 'rf_29',
        'restaurantId': 'rest_2',
        'foodId': 'food_8',
        'price': 30.0,
        'isAvailable': 1,
        'preparationTime': 15,
    });
    await db.insert('restaurant_foods', {           
        'id': 'rf_30',
        'restaurantId': 'rest_6',
        'foodId': 'food_8',
        'price': 30.0,
        'isAvailable': 1,
        'preparationTime': 15,
    });
//F9 - Shrimp Scampi
    await db.insert('restaurant_foods', {
        'id': 'rf_31',
        'restaurantId': 'rest_3',
        'foodId': 'food_9',
        'price': 24.0,
        'isAvailable': 1,
        'preparationTime': 13,
    });
//F10 - Sushi Roll (for rest_3 - Sushi Express)
    await db.insert('restaurant_foods', {
        'id': 'rf_33',
        'restaurantId': 'rest_3',
        'foodId': 'food_10',
        'price': 103.0,
        'isAvailable': 1,
        'preparationTime': 15,
        });
//F11 - Vegan Burger (for rest_7 - THE VEG)
    await db.insert('restaurant_foods', {
        'id': 'rf_34',
        'restaurantId': 'rest_7',
        'foodId': 'food_11',
        'price': 25.0,
        'isAvailable': 1,
        'preparationTime': 10,
        });
//F12 - Vegan Falafel Wrap (for rest_7 - THE VEG)
    await db.insert('restaurant_foods', {
        'id': 'rf_35',
        'restaurantId': 'rest_7',
        'foodId': 'food_12',
        'price': 14.0,
        'isAvailable': 1,
        'preparationTime': 8,
        });
//F13 - Quinoa & Kale Bowl (for rest_7 - THE VEG)
    await db.insert('restaurant_foods', {
        'id': 'rf_36',
        'restaurantId': 'rest_7',
        'foodId': 'food_13',
        'price': 16.0,
        'isAvailable': 1,
        'preparationTime': 9,
        });
    await db.insert('restaurant_foods', {
        'id': 'rf_37',
        'restaurantId': 'rest_1',
        'foodId': 'food_13',
        'price': 16.0,
        'isAvailable': 1,
        'preparationTime': 9,
        });
    await db.insert('restaurant_foods', {
        'id': 'rf_38',
        'restaurantId': 'rest_8',
        'foodId': 'food_13',
        'price': 16.0,
        'isAvailable': 1,
        'preparationTime': 9,
        });
    await db.insert('restaurant_foods', {
        'id': 'rf_39',
        'restaurantId': 'rest_2',
        'foodId': 'food_13',
        'price': 16.0,
        'isAvailable': 1,
        'preparationTime': 9,
        });
//F14 - Stuffed Bell Peppers (for rest_7 - THE VEG)
    await db.insert('restaurant_foods', {
        'id': 'rf_40',
        'restaurantId': 'rest_7',
        'foodId': 'food_14',
        'price': 18.0,
        'isAvailable': 1,
        'preparationTime': 12,
    });
//F15 - Vegan Pad Thai (for rest_7 - THE VEG)
    await db.insert('restaurant_foods', {
        'id': 'rf_41',
        'restaurantId': 'rest_7',
        'foodId': 'food_15',
        'price': 17.0,
        'isAvailable': 1,
        'preparationTime': 11,
    });
//F16
    await db.insert('restaurant_foods', {
        'id': 'rf_42',
        'restaurantId': 'rest_10',
        'foodId': 'food_16',
        'price': 8.5,
        'isAvailable': 1,
        'preparationTime': 8,
    });
    //F17
    await db.insert('restaurant_foods', {
        'id': 'rf_43',
        'restaurantId': 'rest_10',
        'foodId': 'food_17',
        'price': 8.5,
        'isAvailable': 1,
        'preparationTime': 8,
    });
//F18
    await db.insert('restaurant_foods', {
        'id': 'rf_44',
        'restaurantId': 'rest_10',
        'foodId': 'food_18',
        'price': 8.5,
        'isAvailable': 1,
        'preparationTime': 8,
    });
    //F19
    await db.insert('restaurant_foods', {
        'id': 'rf_45',
        'restaurantId': 'rest_10',
        'foodId': 'food_19',
        'price': 8.5,
        'isAvailable': 1,
        'preparationTime': 8,
    });
    //F20
    await db.insert('restaurant_foods', {
        'id': 'rf_46',
        'restaurantId': 'rest_10',
        'foodId': 'food_20',
        'price': 8.5,
        'isAvailable': 1,
        'preparationTime': 8,
    });
    //F21
    await db.insert('restaurant_foods', {
        'id': 'rf_47',
        'restaurantId': 'rest_10',
        'foodId': 'food_21',
        'price': 8.5,
        'isAvailable': 1,
        'preparationTime': 8,
    });
    //F22
    await db.insert('restaurant_foods', {
        'id': 'rf_48',
        'restaurantId': 'rest_10',
        'foodId': 'food_22',
        'price': 8.5,
        'isAvailable': 1,
        'preparationTime': 8,
    });
    //F23
    await db.insert('restaurant_foods', {
        'id': 'rf_49',
        'restaurantId': 'rest_10',
        'foodId': 'food_23',
        'price': 8.5,
        'isAvailable': 1,
        'preparationTime': 8,
    });
    //F24   
    await db.insert('restaurant_foods', {
        'id': 'rf_50',
        'restaurantId': 'rest_10',
        'foodId': 'food_24',
        'price': 8.5,
        'isAvailable': 1,
        'preparationTime': 8,
    });
    await db.insert('restaurant_foods', {
        'id': 'rf_51',
        'restaurantId': 'rest_1',
        'foodId': 'food_24',
        'price': 8.5,
        'isAvailable': 1,
        'preparationTime': 8,
    });
        await db.insert('restaurant_foods', {
        'id': 'rf_52',
        'restaurantId': 'rest_8',
        'foodId': 'food_24',
        'price': 4.0,
        'isAvailable': 1,
        'preparationTime': 1,
    });
        await db.insert('restaurant_foods', {
        'id': 'rf_54',
        'restaurantId': 'rest_3',
        'foodId': 'food_24',
        'price': 8.5,
        'isAvailable': 1,
        'preparationTime': 8,
    });
//F25
    await db.insert('restaurant_foods', {
        'id': 'rf_55',
        'restaurantId': 'rest_10',
        'foodId': 'food_25',
        'price': 8.5,
        'isAvailable': 1,
        'preparationTime': 8,
    });
    await db.insert('restaurant_foods', {
        'id': 'rf_56',
        'restaurantId': 'rest_1',
        'foodId': 'food_25',
        'price': 5.0,
        'isAvailable': 1,
        'preparationTime': 3,
    });
    await db.insert('restaurant_foods', {
        'id': 'rf_57',
        'restaurantId': 'rest_7',
        'foodId': 'food_25',
        'price': 5.0,
        'isAvailable': 1,
        'preparationTime': 3,
    });
    await db.insert('restaurant_foods', {
        'id': 'rf_59',
        'restaurantId': 'rest_8',
        'foodId': 'food_25',
        'price': 8.5,
        'isAvailable': 1,
        'preparationTime': 8,
    });
    //F26
    await db.insert('restaurant_foods', {
        'id': 'rf_60',
        'restaurantId': 'rest_9',
        'foodId': 'food_26',
        'price': 8.5,
        'isAvailable': 1,
        'preparationTime': 8,
    });
    //F27
    await db.insert('restaurant_foods', {
        'id': 'rf_61',
        'restaurantId': 'rest_9',
        'foodId': 'food_27',
        'price': 8.5,
        'isAvailable': 1,
        'preparationTime': 8,
    });
    //F28
    await db.insert('restaurant_foods', {
        'id': 'rf_62',
        'restaurantId': 'rest_9',
        'foodId': 'food_28',
        'price': 8.5,
        'isAvailable': 1,
        'preparationTime': 8,
    });
    //F29 - Salmon Nigiri (for rest_3 - Sushi Express)
    await db.insert('restaurant_foods', {
        'id': 'rf_63',
        'restaurantId': 'rest_3',
        'foodId': 'food_29',
        'price': 4.5,
        'isAvailable': 1,
        'preparationTime': 25,
    });
    //F30 - Tuna Sashimi (for rest_3 - Sushi Express)
    await db.insert('restaurant_foods', {
        'id': 'rf_64',
        'restaurantId': 'rest_3',
        'foodId': 'food_30',
        'price': 6.0,
        'isAvailable': 1,
        'preparationTime': 25,
    });
    //F31 - Ebi Tempura (for rest_3 - Sushi Express)
    await db.insert('restaurant_foods', {
        'id': 'rf_65',
        'restaurantId': 'rest_3',
        'foodId': 'food_31',
        'price': 6.5,
        'isAvailable': 1,
        'preparationTime': 30,
    });
    //F32 - Sushi Bento Box (for rest_3 - Sushi Express)
    await db.insert('restaurant_foods', {
        'id': 'rf_66',
        'restaurantId': 'rest_3',
        'foodId': 'food_32',
        'price': 15.0,
        'isAvailable': 1,
        'preparationTime': 30,
    });
    //F33 - Miso Soup (for rest_3 - Sushi Express)
    await db.insert('restaurant_foods', {
        'id': 'rf_67',
        'restaurantId': 'rest_3',
        'foodId': 'food_33',
        'price': 3.0,
        'isAvailable': 1,
        'preparationTime': 3,
    });
    //F34
    await db.insert('restaurant_foods', {
        'id': 'rf_68',
        'restaurantId': 'rest_10',
        'foodId': 'food_34',
        'price': 8.5,
        'isAvailable': 1,
        'preparationTime': 8,
    });
    //F35
    await db.insert('restaurant_foods', {
        'id': 'rf_69',
        'restaurantId': 'rest_10',
        'foodId': 'food_35',
        'price': 8.5,
        'isAvailable': 1,
        'preparationTime': 8,
    });
    //F36
    await db.insert('restaurant_foods', {
        'id': 'rf_70',
        'restaurantId': 'rest_7',
        'foodId': 'food_36',
        'price': 8.5,
        'isAvailable': 1,
        'preparationTime': 8,
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
          rating REAL NOT NULL,
          is_open INTEGER NOT NULL DEFAULT 1
        )
      ''');

      // Add restaurant_foods table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS restaurant_foods (
          id TEXT PRIMARY KEY,
          restaurantId TEXT NOT NULL,
          foodId TEXT NOT NULL,
          price REAL,
          isAvailable INTEGER,
          preparationTime INTEGER,
          FOREIGN KEY (restaurantId) REFERENCES restaurants(id),
          FOREIGN KEY (foodId) REFERENCES foods(id)
        )
      ''');

      await db.execute('CREATE INDEX IF NOT EXISTS idx_restaurants_rating ON restaurants(rating)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_restaurant_foods_restaurantId ON restaurant_foods(restaurantId)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_restaurant_foods_foodId ON restaurant_foods(foodId)');
    }
    
    if (oldVersion < 3) {
      // Change restaurants.rating from INTEGER to REAL
      // SQLite doesn't support ALTER COLUMN, so we need to recreate the table
      await db.execute('ALTER TABLE restaurants RENAME TO restaurants_old');
      await db.execute('''
        CREATE TABLE restaurants (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          address TEXT,
          phone TEXT,
          image TEXT NOT NULL,
          rating REAL NOT NULL,
          is_open INTEGER NOT NULL DEFAULT 1
        )
      ''');
      await db.execute('''
        INSERT INTO restaurants (id, name, address, phone, image, rating, is_open)
        SELECT id, name, address, phone, image, CAST(rating AS REAL), is_open
        FROM restaurants_old
      ''');
      await db.execute('DROP TABLE restaurants_old');
      
      // Change foods.rating from INTEGER to REAL
      await db.execute('ALTER TABLE foods RENAME TO foods_old');
      await db.execute('''
        CREATE TABLE foods (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          description TEXT NOT NULL,
          price REAL NOT NULL,
          image TEXT NOT NULL,
          categoryId TEXT NOT NULL,
          rating REAL NOT NULL,
          isAvailable INTEGER NOT NULL DEFAULT 1,
          preparationTime INTEGER,
          FOREIGN KEY (categoryId) REFERENCES categories (id)
        )
      ''');
      await db.execute('''
        INSERT INTO foods (id, name, description, price, image, categoryId, rating, isAvailable, preparationTime)
        SELECT id, name, description, price, image, categoryId, CAST(rating AS REAL), isAvailable, preparationTime
        FROM foods_old
      ''');
      await db.execute('DROP TABLE foods_old');
      
      // Recreate indexes
      await db.execute('CREATE INDEX IF NOT EXISTS idx_foods_categoryId ON foods(categoryId)');
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

  // Get foods by restaurant ID (using JOIN with restaurant_foods table)
  Future<List<FoodModel>> getFoodsByRestaurantId(String restaurantId) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT f.*, rf.restaurantId, rf.price as restaurantPrice, rf.isAvailable as restaurantAvailable, rf.preparationTime as restaurantPreparationTime
      FROM foods f
      INNER JOIN restaurant_foods rf ON f.id = rf.foodId
      WHERE rf.restaurantId = ?
      ORDER BY f.name ASC
    ''', [restaurantId]);
    
    return result.map((map) {
      // Use restaurant-specific price if available, otherwise use food price
      final price = map['restaurantPrice'] != null 
          ? (map['restaurantPrice'] as num).toDouble()
          : (map['price'] as num).toDouble();
      
      // Use restaurant-specific availability if available
      final isAvailable = map['restaurantAvailable'] != null
          ? (map['restaurantAvailable'] as num).toInt() == 1
          : (map['isAvailable'] as num).toInt() == 1;
      
      // Use restaurant-specific preparation time if available
      final preparationTime = map['restaurantPreparationTime'] ?? map['preparationTime'];

      return FoodModel(
        id: (map['id'] as String?) ?? '',
        name: (map['name'] as String?) ?? '',
        description: (map['description'] as String?) ?? '',
        price: price,
        image: (map['image'] as String?) ?? '',
        categoryId: (map['categoryId'] as String?) ?? '',
        rating: ((map['rating'] as num?) ?? 0).toInt(),
        isAvailable: isAvailable,
        preparationTime: preparationTime != null ? (preparationTime as num).toInt() : null,
      );
    }).toList();
  }

  // Search foods by name/description (case-insensitive)
  Future<List<FoodModel>> searchFoods(String query) async {
    final db = await database;
    final q = query.trim();
    if (q.isEmpty) return [];
    final like = '%${q.replaceAll('%', '\\%').replaceAll('_', '\\_')}%';
    final result = await db.query(
      'foods',
      where: 'LOWER(name) LIKE LOWER(?) OR LOWER(description) LIKE LOWER(?)',
      whereArgs: [like, like],
      orderBy: 'name ASC',
    );
    return result.map((map) => FoodModel.fromMap(map)).toList();
  }

  /// Filter foods by multiple criteria with AND logic across groups
  /// - categoryName: one of snacks, meal, vegan, dessert, drink (case-insensitive)
  /// - nameOptions: set of keywords like Bruschetta, Spring Rolls, ... (OR within the set)
  /// - minRating: minimum integer rating
  /// - priceMin/priceMax: inclusive price range
  Future<List<FoodModel>> filterFoods({
    String? categoryName,
    Set<String>? nameOptions,
    int? minRating,
    double? priceMin,
    double? priceMax,
  }) async {
    final db = await database;

    final whereClauses = <String>[];
    final whereArgs = <Object?>[];

    // Join with categories when needed to match by human-readable category
    final joinCategory = categoryName != null && categoryName.trim().isNotEmpty;

    if (joinCategory) {
      whereClauses.add('LOWER(c.name) = LOWER(?)');
      whereArgs.add(categoryName!.trim());
    }

    if (minRating != null && minRating > 0) {
      whereClauses.add('f.rating >= ?');
      whereArgs.add(minRating);
    }

    if (priceMin != null && priceMax != null) {
      whereClauses.add('f.price BETWEEN ? AND ?');
      whereArgs.add(priceMin);
      whereArgs.add(priceMax);
    } else if (priceMin != null) {
      whereClauses.add('f.price >= ?');
      whereArgs.add(priceMin);
    } else if (priceMax != null) {
      whereClauses.add('f.price <= ?');
      whereArgs.add(priceMax);
    }

    // Only list available foods
    whereClauses.add('f.isAvailable = 1');

    // Name options (OR inside the group)
    final options = nameOptions?.where((e) => e.trim().isNotEmpty).toList() ?? [];
    if (options.isNotEmpty) {
      final likeParts = <String>[];
      for (final opt in options) {
        likeParts.add('LOWER(f.name) LIKE LOWER(?)');
        whereArgs.add('%${opt.replaceAll('%', '\\%').replaceAll('_', '\\_').trim()}%');
      }
      whereClauses.add('(' + likeParts.join(' OR ') + ')');
    }

    final whereSql = whereClauses.isEmpty ? '' : 'WHERE ' + whereClauses.join(' AND ');

    final sql = StringBuffer()
      ..writeln('SELECT f.* FROM foods f')
      ..writeln(joinCategory ? 'INNER JOIN categories c ON c.id = f.categoryId' : '')
      ..writeln(whereSql)
      ..writeln('ORDER BY f.name ASC');

    final rows = await db.rawQuery(sql.toString(), whereArgs);
    return rows.map((map) => FoodModel.fromMap(map as Map<String, dynamic>)).toList();
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
        COUNT(rf.foodId) as foodCount
      FROM restaurants r
      LEFT JOIN restaurant_foods rf ON r.id = rf.restaurantId
      GROUP BY r.id
      ORDER BY r.name ASC
    ''');
    return result;
  }

  // Get restaurants that sell a specific food
  Future<List<RestaurantModel>> getRestaurantsByFoodId(String foodId) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT DISTINCT r.*
      FROM restaurants r
      INNER JOIN restaurant_foods rf ON r.id = rf.restaurantId
      WHERE rf.foodId = ?
      ORDER BY r.name ASC
    ''', [foodId]);
    
    return result.map((map) => RestaurantModel.fromMap(map)).toList();
  }

  // Get all restaurants grouped by food (more efficient for bulk loading)
  Future<Map<String, List<RestaurantModel>>> getAllRestaurantsByFoods() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT DISTINCT rf.foodId, r.*
      FROM restaurants r
      INNER JOIN restaurant_foods rf ON r.id = rf.restaurantId
      ORDER BY rf.foodId, r.name ASC
    ''');
    
    final Map<String, List<RestaurantModel>> restaurantsByFood = {};
    for (var row in result) {
      final foodId = row['foodId'] as String;
      final restaurant = RestaurantModel.fromMap(row);
      
      if (!restaurantsByFood.containsKey(foodId)) {
        restaurantsByFood[foodId] = [];
      }
      restaurantsByFood[foodId]!.add(restaurant);
    }
    
    return restaurantsByFood;
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

  // Reset database - delete and recreate with fresh data
  Future<void> resetDatabase() async {
    await deleteDatabase();
    // Next call to database getter will recreate the database
    await database;
  }
}