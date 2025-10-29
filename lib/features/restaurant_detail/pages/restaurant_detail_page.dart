import 'package:flutter/material.dart';
import '../../home/models/restaurant_model.dart';
import '../../home/services/restaurant_service.dart';

class RestaurantDetailPage extends StatelessWidget {
  final String restaurantId;
  
  const RestaurantDetailPage({super.key, required this.restaurantId});

  @override
  Widget build(BuildContext context) {
    final service = RestaurantService();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurant Detail'),
      ),
      body: FutureBuilder<RestaurantModel?>(
        future: service.getRestaurantById(restaurantId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('Restaurant not found'));
          }

          final restaurant = snapshot.data!;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Restaurant Header
                Container(
                  height: 200,
                  width: double.infinity,
                  color: Colors.orange.shade100,
                  child: Center(
                    child: Text(
                      restaurant.image,
                      style: const TextStyle(fontSize: 100),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        restaurant.name,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        restaurant.cuisine,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber),
                              const SizedBox(width: 4),
                              Text(
                                restaurant.rating.toString(),
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                          const SizedBox(width: 24),
                          Row(
                            children: [
                              Icon(Icons.access_time, size: 20, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text(
                                '${restaurant.deliveryTime} min',
                                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          const SizedBox(width: 24),
                          Text(
                            restaurant.priceRange,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'Menu Items',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildMenuItem('Burger Combo', '🍔', 12.99),
                      _buildMenuItem('Pizza Margherita', '🍕', 15.99),
                      _buildMenuItem('Caesar Salad', '🥗', 8.99),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {},
                          child: const Text('Add to Cart'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMenuItem(String name, String emoji, double price) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Text(emoji, style: const TextStyle(fontSize: 40)),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: Text(
          '\$$price',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFFFE6B35),
          ),
        ),
      ),
    );
  }
}


