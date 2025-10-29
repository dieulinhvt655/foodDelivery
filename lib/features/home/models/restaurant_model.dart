class RestaurantModel {
  final String id;
  final String name;
  final String image;
  final String cuisine;
  final double rating;
  final int deliveryTime;
  final String priceRange;

  RestaurantModel({
    required this.id,
    required this.name,
    required this.image,
    required this.cuisine,
    required this.rating,
    required this.deliveryTime,
    required this.priceRange,
  });

  factory RestaurantModel.fromJson(Map<String, dynamic> json) {
    return RestaurantModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      cuisine: json['cuisine'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      deliveryTime: json['deliveryTime'] ?? 0,
      priceRange: json['priceRange'] ?? '',
    );
  }
}


