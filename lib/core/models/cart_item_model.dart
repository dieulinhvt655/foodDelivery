class CartItemModel {
  final String id;
  final String foodId;
  final String foodName;
  final String foodImage;
  final double price;
  final int quantity;
  final String restaurantId;
  final String restaurantName;

  CartItemModel({
    required this.id,
    required this.foodId,
    required this.foodName,
    required this.foodImage,
    required this.price,
    required this.quantity,
    required this.restaurantId,
    required this.restaurantName,
  });

  double get totalPrice => price * quantity;

  CartItemModel copyWith({
    String? id,
    String? foodId,
    String? foodName,
    String? foodImage,
    double? price,
    int? quantity,
    String? restaurantId,
    String? restaurantName,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      foodId: foodId ?? this.foodId,
      foodName: foodName ?? this.foodName,
      foodImage: foodImage ?? this.foodImage,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      restaurantId: restaurantId ?? this.restaurantId,
      restaurantName: restaurantName ?? this.restaurantName,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'foodId': foodId,
      'foodName': foodName,
      'foodImage': foodImage,
      'price': price,
      'quantity': quantity,
      'restaurantId': restaurantId,
      'restaurantName': restaurantName,
    };
  }

  factory CartItemModel.fromMap(Map<String, dynamic> map) {
    return CartItemModel(
      id: map['id'] ?? '',
      foodId: map['foodId'] ?? '',
      foodName: map['foodName'] ?? '',
      foodImage: map['foodImage'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      quantity: map['quantity'] ?? 1,
      restaurantId: map['restaurantId'] ?? '',
      restaurantName: map['restaurantName'] ?? '',
    );
  }
}

