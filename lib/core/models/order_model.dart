class OrderModel {
  final String id;
  final String orderCode; // Order code with # prefix (e.g., "#ABC123")
  final String userId;
  final String addressId;
  final String paymentMethod;
  final double subtotal;
  final double discount;
  final double deliveryFee;
  final double vat;
  final double total;
  final String status; // 'active', 'completed', 'cancelled'
  final DateTime orderDate;
  final DateTime? deliveryDate;
  final List<OrderItem> items;

  OrderModel({
    required this.id,
    required this.orderCode,
    required this.userId,
    required this.addressId,
    required this.paymentMethod,
    required this.subtotal,
    required this.discount,
    required this.deliveryFee,
    required this.vat,
    required this.total,
    required this.status,
    required this.orderDate,
    this.deliveryDate,
    required this.items,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order_code': orderCode,
      'user_id': userId,
      'address_id': addressId,
      'payment_method': paymentMethod,
      'subtotal': subtotal,
      'discount': discount,
      'delivery_fee': deliveryFee,
      'vat': vat,
      'total': total,
      'status': status,
      'order_date': orderDate.toIso8601String(),
      'delivery_date': deliveryDate?.toIso8601String(),
      'items': items.map((item) => item.toMap()).toList().toString(),
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id'] as String,
      orderCode: map['order_code'] as String? ?? '#${(map['id'] as String).substring((map['id'] as String).length - 6)}',
      userId: map['user_id'] as String,
      addressId: map['address_id'] as String,
      paymentMethod: map['payment_method'] as String,
      subtotal: (map['subtotal'] as num).toDouble(),
      discount: (map['discount'] as num).toDouble(),
      deliveryFee: (map['delivery_fee'] as num).toDouble(),
      vat: (map['vat'] as num).toDouble(),
      total: (map['total'] as num).toDouble(),
      status: map['status'] as String,
      orderDate: DateTime.parse(map['order_date'] as String),
      deliveryDate: map['delivery_date'] != null
          ? DateTime.parse(map['delivery_date'] as String)
          : null,
      items: [], // Will be loaded separately or from JSON
    );
  }
}

class OrderItem {
  final String foodId;
  final String foodName;
  final String foodImage;
  final double price;
  final int quantity;
  final String restaurantId;
  final String restaurantName;

  OrderItem({
    required this.foodId,
    required this.foodName,
    required this.foodImage,
    required this.price,
    required this.quantity,
    required this.restaurantId,
    required this.restaurantName,
  });

  Map<String, dynamic> toMap() {
    return {
      'food_id': foodId,
      'food_name': foodName,
      'food_image': foodImage,
      'price': price,
      'quantity': quantity,
      'restaurant_id': restaurantId,
      'restaurant_name': restaurantName,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      foodId: map['food_id'] as String,
      foodName: map['food_name'] as String,
      foodImage: map['food_image'] as String,
      price: (map['price'] as num).toDouble(),
      quantity: map['quantity'] as int,
      restaurantId: map['restaurant_id'] as String,
      restaurantName: map['restaurant_name'] as String,
    );
  }
}

