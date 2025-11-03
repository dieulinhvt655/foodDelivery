class RestaurantModel {
  final String id;
  final String name;
  final String? address;
  final String? phone;
  final String image;
  final double rating;
  final bool isOpen;

  RestaurantModel({
    required this.id,
    required this.name,
    this.address,
    this.phone,
    required this.image,
    required this.rating,
    this.isOpen = true,
  });

  // Convert RestaurantModel to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'image': image,
      'rating': rating,
      'is_open': isOpen ? 1 : 0,
    };
  }

  // Create RestaurantModel from Map
  factory RestaurantModel.fromMap(Map<String, dynamic> map) {
    return RestaurantModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      address: map['address'],
      phone: map['phone'],
      image: map['image'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      isOpen: (map['is_open'] ?? 1) == 1,
    );
  }

  // Create RestaurantModel from JSON (for API)
  factory RestaurantModel.fromJson(Map<String, dynamic> json) {
    return RestaurantModel.fromMap(json);
  }

  // Copy with method for updating
  RestaurantModel copyWith({
    String? id,
    String? name,
    String? address,
    String? phone,
    String? image,
    double? rating,
    bool? isOpen,
  }) {
    return RestaurantModel(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      image: image ?? this.image,
      rating: rating ?? this.rating,
      isOpen: isOpen ?? this.isOpen,
    );
  }

  @override
  String toString() {
    return 'RestaurantModel(id: $id, name: $name, address: $address, phone: $phone, rating: $rating, isOpen: $isOpen)';
  }
}

