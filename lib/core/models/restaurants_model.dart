class RestaurantModel {
  final String id;
  final String name;
  final String? description;
  final String? address;
  final String? phone;
  final String image;
  final double rating;
  final bool isOpen;

  RestaurantModel({
    required this.id,
    required this.name,
    this.description,
    this.address,
    this.phone,
    required this.image,
    this.rating = 4.5,
    this.isOpen = true,
  });

  // Convert RestaurantModel to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
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
      description: map['description'],
      address: map['address'],
      phone: map['phone'],
      image: map['image'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      isOpen: (map['is_open'] ?? 1) == 1,
    );
  }

  // Create RestaurantModel from JSON (for API)
  factory RestaurantModel.fromJson(Map<String, dynamic> json) {
    final status = (json['status'] as String?) ?? 'OPEN';

    return RestaurantModel(
      id: (json['id'] ?? '').toString(),
      name: json['name'] ?? '',
      description: json['description'],
      address: json['address'],
      phone: json['phone'],
      image: (json['imageUrl'] ?? json['image_url'] ?? json['image'] ?? '') as String,
      // Backend hiện chưa có rating -> gán default, sau này có thể lấy từ service khác
      rating: (json['rating'] ?? 4.5).toDouble(),
      isOpen: status == 'OPEN',
    );
  }

  // Copy with method for updating
  RestaurantModel copyWith({
    String? id,
    String? description,
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
      description: description ?? this.description,
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
