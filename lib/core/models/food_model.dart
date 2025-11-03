class FoodModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String image;
  final String categoryId;
  final int rating;
  final bool isAvailable;
  final int? preparationTime;

  FoodModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    required this.categoryId,
    required this.rating,
    required this.isAvailable,
    this.preparationTime,
  });

  // Convert FoodModel to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'image': image,
      'categoryId': categoryId,
      'rating': rating,
      'isAvailable': isAvailable ? 1 : 0,
      'preparationTime': preparationTime,
    };
  }

  // Create FoodModel from Map
  factory FoodModel.fromMap(Map<String, dynamic> map) {
    return FoodModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      image: map['image'] ?? '',
      categoryId: map['categoryId'] ?? '',
      rating: (map['rating'] ?? 0).toInt(),
      isAvailable: (map['isAvailable'] ?? 0) == 1,
      preparationTime: map['preparationTime'],
    );
  }

  // Create FoodModel from JSON (for API)
  factory FoodModel.fromJson(Map<String, dynamic> json) {
    return FoodModel.fromMap(json);
  }

  // Copy with method for updating
  FoodModel copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? image,
    String? categoryId,
    int? rating,
    bool? isAvailable,
    int? preparationTime
  }) {
    return FoodModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      image: image ?? this.image,
      categoryId: categoryId ?? this.categoryId,
      rating: rating ?? this.rating,
      isAvailable: isAvailable ?? this.isAvailable,
      preparationTime: preparationTime ?? this.preparationTime,
    );
  }

  @override
  String toString() {
    return 'FoodModel(id: $id, name: $name, price: $price, categoryId: $categoryId)';
  }
}

