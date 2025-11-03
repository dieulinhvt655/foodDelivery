import 'package:sqflite/sqflite.dart';
import '../models/order_model.dart';
import '../models/address_model.dart';
import 'account_database_helper.dart';
import 'address_database_helper.dart';

class OrderDatabaseHelper {
  OrderDatabaseHelper._();

  static final OrderDatabaseHelper instance = OrderDatabaseHelper._();
  static const _ordersTable = 'orders';
  static const _orderItemsTable = 'order_items';

  Future<Database> get _db async => AccountDatabaseHelper.instance.database;

  Future<void> _createOrdersTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_ordersTable (
        id TEXT PRIMARY KEY,
        order_code TEXT NOT NULL UNIQUE,
        user_id TEXT NOT NULL,
        address_id TEXT NOT NULL,
        payment_method TEXT NOT NULL,
        subtotal REAL NOT NULL,
        discount REAL NOT NULL,
        delivery_fee REAL NOT NULL,
        vat REAL NOT NULL,
        total REAL NOT NULL,
        status TEXT NOT NULL,
        order_date TEXT NOT NULL,
        delivery_date TEXT,
        FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_orderItemsTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id TEXT NOT NULL,
        food_id TEXT NOT NULL,
        food_name TEXT NOT NULL,
        food_image TEXT NOT NULL,
        price REAL NOT NULL,
        quantity INTEGER NOT NULL,
        restaurant_id TEXT NOT NULL,
        restaurant_name TEXT NOT NULL,
        FOREIGN KEY(order_id) REFERENCES $_ordersTable(id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> saveOrder(OrderModel order) async {
    final db = await _db;
    await db.transaction((txn) async {
      // Save order
      await txn.insert(
        _ordersTable,
        {
          'id': order.id,
          'order_code': order.orderCode,
          'user_id': order.userId,
          'address_id': order.addressId,
          'payment_method': order.paymentMethod,
          'subtotal': order.subtotal,
          'discount': order.discount,
          'delivery_fee': order.deliveryFee,
          'vat': order.vat,
          'total': order.total,
          'status': order.status,
          'order_date': order.orderDate.toIso8601String(),
          'delivery_date': order.deliveryDate?.toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Save order items
      for (var item in order.items) {
        await txn.insert(
          _orderItemsTable,
          {
            'order_id': order.id,
            'food_id': item.foodId,
            'food_name': item.foodName,
            'food_image': item.foodImage,
            'price': item.price,
            'quantity': item.quantity,
            'restaurant_id': item.restaurantId,
            'restaurant_name': item.restaurantName,
          },
        );
      }
    });
  }

  Future<bool> orderCodeExists(String orderCode) async {
    final db = await _db;
    final result = await db.query(
      _ordersTable,
      where: 'order_code = ?',
      whereArgs: [orderCode],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  Future<List<OrderModel>> getOrdersByUserId(String userId, {String? status}) async {
    final db = await _db;
    
    String query = '''
      SELECT * FROM $_ordersTable 
      WHERE user_id = ?
    ''';
    
    List<dynamic> whereArgs = [userId];
    
    if (status != null) {
      query += ' AND status = ?';
      whereArgs.add(status);
    }
    
    query += ' ORDER BY order_date DESC';
    
    final ordersResult = await db.rawQuery(query, whereArgs);
    
    final List<OrderModel> orders = [];
    for (var orderMap in ordersResult) {
      // Get order items
      final itemsResult = await db.query(
        _orderItemsTable,
        where: 'order_id = ?',
        whereArgs: [orderMap['id'] as String],
      );
      
      final items = itemsResult.map((item) => OrderItem.fromMap(item)).toList();
      
      final order = OrderModel.fromMap(orderMap);
      orders.add(OrderModel(
        id: order.id,
        orderCode: order.orderCode,
        userId: order.userId,
        addressId: order.addressId,
        paymentMethod: order.paymentMethod,
        subtotal: order.subtotal,
        discount: order.discount,
        deliveryFee: order.deliveryFee,
        vat: order.vat,
        total: order.total,
        status: order.status,
        orderDate: order.orderDate,
        deliveryDate: order.deliveryDate,
        items: items,
      ));
    }
    
    return orders;
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    final db = await _db;
    await db.update(
      _ordersTable,
      {'status': status},
      where: 'id = ?',
      whereArgs: [orderId],
    );
  }

  Future<void> initTables() async {
    final db = await _db;
    await _createOrdersTable(db);
  }

  // Public method for creating tables (used by AccountDatabaseHelper)
  Future<void> createTablesOnInit(Database db) async {
    await _createOrdersTable(db);
  }

  // Seed sample completed orders for testing
  Future<void> seedSampleCompletedOrders(String userId) async {
    // Check if user already has completed orders
    final existingOrders = await getOrdersByUserId(userId, status: 'completed');
    if (existingOrders.isNotEmpty) {
      return; // Already has completed orders, don't seed
    }

    // Get or create a default address for the user
    final userIdInt = int.tryParse(userId);
    if (userIdInt == null) return;

    final addressHelper = AddressDatabaseHelper.instance;
    final addresses = await addressHelper.fetchAddresses(userIdInt);
    
    int? addressId;
    if (addresses.isNotEmpty) {
      // Use the default address or first address
      final defaultAddress = addresses.firstWhere(
        (a) => a.isDefault,
        orElse: () => addresses.first,
      );
      addressId = defaultAddress.id;
    } else {
      // Create a sample address if none exists
      final sampleAddress = AddressModel(
        userId: userIdInt,
        label: 'Home',
        address: '123 Main Street, District 1, Ho Chi Minh City',
        note: null,
        isDefault: true,
        createdAt: DateTime.now(),
      );
      addressId = await addressHelper.insertAddress(sampleAddress, setAsDefault: true);
    }

    if (addressId == null) return;

    final now = DateTime.now();
    final sampleFoods = [
      {'name': 'Grilled Salmon Fillet', 'price': 28.0, 'image': 'assets/images/dishes-square/grilled_salmon.jpg', 'restaurant': 'KFC Vietnam'},
      {'name': 'Pizza Margherita', 'price': 18.5, 'image': 'assets/images/dishes-square/pizza_margherita.jpg', 'restaurant': 'Pizza Hut'},
      {'name': 'Sushi Platter', 'price': 32.0, 'image': 'assets/images/dishes-square/sushi_platter.jpg', 'restaurant': 'Sushi Express'},
      {'name': 'Burger Combo', 'price': 15.0, 'image': 'assets/images/dishes-square/burger_combo.jpg', 'restaurant': 'Burger King'},
      {'name': 'Caesar Salad', 'price': 12.5, 'image': 'assets/images/dishes-square/caesar_salad.jpg', 'restaurant': 'THE VEG - Organic vego & tea'},
    ];

    for (int i = 0; i < 5; i++) {
      final orderDate = now.subtract(Duration(days: 5 - i, hours: 2 - i));
      final deliveryDate = orderDate.add(Duration(days: 2, hours: 4));
      
      // Generate unique order code
      String orderCode;
      bool exists;
      int attempts = 0;
      do {
        final chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
        final code = List.generate(6, (_) => chars[(DateTime.now().millisecondsSinceEpoch + attempts) % chars.length]).join();
        orderCode = '#$code';
        exists = await orderCodeExists(orderCode);
        attempts++;
      } while (exists && attempts < 100);

      final food = sampleFoods[i];
      final subtotal = food['price'] as double;
      final discount = subtotal * 0.1; // 10% discount
      final deliveryFee = 4.50;
      final vat = subtotal * 0.10;
      final total = subtotal - discount + deliveryFee + vat;

      final order = OrderModel(
        id: 'sample_completed_${userId}_$i',
        orderCode: orderCode,
        userId: userId,
        addressId: addressId.toString(),
        paymentMethod: 'cod',
        subtotal: subtotal,
        discount: discount,
        deliveryFee: deliveryFee,
        vat: vat,
        total: total,
        status: 'completed',
        orderDate: orderDate,
        deliveryDate: deliveryDate,
        items: [
          OrderItem(
            foodId: 'food_sample_$i',
            foodName: food['name'] as String,
            foodImage: food['image'] as String,
            price: food['price'] as double,
            quantity: 1 + i % 3, // Varying quantities
            restaurantId: 'rest_sample_$i',
            restaurantName: food['restaurant'] as String,
          ),
        ],
      );

      await saveOrder(order);
    }
  }
}

