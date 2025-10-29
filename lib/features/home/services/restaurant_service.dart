import '../models/restaurant_model.dart';

class RestaurantService {
  // Mock data for now
  Future<List<RestaurantModel>> getRestaurants() async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate API call
    
    return [
      RestaurantModel(
        id: '1',
        name: 'Burger King',
        image: '🍔',
        cuisine: 'Fast Food',
        rating: 4.5,
        deliveryTime: 25,
        priceRange: '\$',
      ),
      RestaurantModel(
        id: '2',
        name: 'Pizza Hut',
        image: '🍕',
        cuisine: 'Italian',
        rating: 4.8,
        deliveryTime: 30,
        priceRange: '\$\$',
      ),
      RestaurantModel(
        id: '3',
        name: 'Sushi Express',
        image: '🍣',
        cuisine: 'Japanese',
        rating: 4.7,
        deliveryTime: 35,
        priceRange: '\$\$\$',
      ),
      RestaurantModel(
        id: '4',
        name: 'Taco Bell',
        image: '🌮',
        cuisine: 'Mexican',
        rating: 4.3,
        deliveryTime: 20,
        priceRange: '\$',
      ),
    ];
  }

  Future<RestaurantModel?> getRestaurantById(String id) async {
    final restaurants = await getRestaurants();
    try {
      return restaurants.firstWhere((r) => r.id == id);
    } catch (e) {
      return null;
    }
  }
}


