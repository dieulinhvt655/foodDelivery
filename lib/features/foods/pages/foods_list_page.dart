import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/database/food_database_helper.dart';
import '../../../core/models/food_model.dart';
import '../../../core/models/restaurants_model.dart';

class FoodsListPage extends StatefulWidget {
  const FoodsListPage({super.key});

  @override
  State<FoodsListPage> createState() => _FoodsListPageState();
}

class _FoodsListPageState extends State<FoodsListPage> {
  final FoodDatabaseHelper _dbHelper = FoodDatabaseHelper.instance;
  bool _isLoading = true;
  List<FoodModel> _foods = [];
  Map<String, List<RestaurantModel>> _restaurantsByFood = {};
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFoods();
  }

  Future<void> _loadFoods() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final foods = await _dbHelper.getAllFoods();
      
      // Load all restaurants grouped by food (more efficient)
      final restaurantsByFood = await _dbHelper.getAllRestaurantsByFoods();
      
      if (!mounted) return;
      setState(() {
        _foods = foods;
        _restaurantsByFood = restaurantsByFood;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header with decoration
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFFFFB800),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        'All Foods',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48), // Balance the back button
                  ],
                ),
              ),
            ),
            Expanded(
              child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        'Error: $_error',
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadFoods,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _foods.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.restaurant_menu, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No foods available',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadFoods,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _foods.length,
                        itemBuilder: (context, index) {
                          final food = _foods[index];
                          return _buildFoodCard(food);
                        },
                      ),
                    ),
            )],
        ),
      ),
    );
  }

  Widget _buildFoodCard(FoodModel food) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          final rid = _restaurantsByFood[food.id]?.isNotEmpty == true
              ? _restaurantsByFood[food.id]!.first.id
              : null;
          final q = rid != null ? '?rid=' + rid : '';
          context.push('/food/' + food.id + q);
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Food Image
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              color: Colors.grey[200],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: food.image.startsWith('http')
                  ? Image.network(food.image, fit: BoxFit.cover)
                  : Image.asset(
                      food.image,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.restaurant, size: 50, color: Colors.grey);
                      },
                    ),
            ),
          ),
          // Food Info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          food.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D2D2D),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!food.isAvailable)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Unavailable',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    food.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // Rating
                      Row(
                        children: [
                          const Icon(Icons.star, size: 16, color: Color(0xFFFFB800)),
                          const SizedBox(width: 4),
                          Text(
                            food.rating.toString(),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF2D2D2D),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      // Price
                      Text(
                        '\$${food.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF6B35),
                        ),
                      ),
                    ],
                  ),
                  // Restaurants that sell this food
                  if (_restaurantsByFood[food.id] != null && 
                      _restaurantsByFood[food.id]!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.restaurant, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _restaurantsByFood[food.id]!.length == 1
                                ? 'Available at: ${_restaurantsByFood[food.id]!.first.name}'
                                : 'Available at ${_restaurantsByFood[food.id]!.length} restaurants',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  ),
);
  }
}

