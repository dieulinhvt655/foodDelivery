import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/favorites_provider.dart';
import '../../restaurant_detail/widgets/food_detail_popup.dart';
import 'package:go_router/go_router.dart';
import '../../../core/database/food_database_helper.dart';
import '../../../core/models/food_model.dart';
import '../../../core/models/restaurants_model.dart';
import '../../common/widgets/custom_bottom_nav_bar.dart';

class FoodsListPage extends StatefulWidget {
  final bool showFavoritesOnly;
  final String? categoryId;
  const FoodsListPage({super.key, this.showFavoritesOnly = false, this.categoryId});

  @override
  State<FoodsListPage> createState() => _FoodsListPageState();
}

class _FoodsListPageState extends State<FoodsListPage> {
  final FoodDatabaseHelper _dbHelper = FoodDatabaseHelper.instance;
  bool _isLoading = true;
  List<FoodModel> _foods = [];
  Map<String, List<RestaurantModel>> _restaurantsByFood = {};
  String? _error;
  String _priceSort = 'none'; // none | asc | desc

  void _showAddToCartPopup(FoodModel food) {
    final restaurants = _restaurantsByFood[food.id] ?? [];
    if (restaurants.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This food is not available at any restaurant'),
          backgroundColor: Color(0xFFFF6B35),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final restaurant = restaurants.first;

    showDialog(
      context: context,
      builder: (ctx) => FoodDetailPopup(food: food, restaurant: restaurant),
    );
  }

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
      List<FoodModel> foods;
      Map<String, List<RestaurantModel>> restaurantsByFood = {};
      
      // Truy vấn theo categoryId nếu có
      if (widget.categoryId != null && widget.categoryId!.isNotEmpty) {
        foods = await _dbHelper.getFoodsByCategoryId(widget.categoryId!);
        // Không load restaurants khi lọc theo category
        restaurantsByFood = {};
      } else {
        foods = await _dbHelper.getAllFoods();
        // Load restaurants chỉ khi không lọc theo category
        restaurantsByFood = await _dbHelper.getAllRestaurantsByFoods();
      }

      // Lọc theo favorites nếu cần
      if (widget.showFavoritesOnly) {
        final favs = context.read<FavoritesProvider>();
        await favs.loadFavorites();
        final favIds = favs.favoriteFoodIds;
        foods = foods.where((f) => favIds.contains(f.id)).toList();
        // Không load restaurants khi hiển thị favorites
        restaurantsByFood = {};
      }

      if (!mounted) return;
      setState(() {
        _foods = foods;
        _restaurantsByFood = restaurantsByFood;
      });
      _applySort();
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

  void _applySort() {
    if (_foods.isEmpty) return;
    setState(() {
      if (_priceSort == 'asc') {
        _foods.sort((a, b) {
          final c = a.price.compareTo(b.price);
          return c; // nếu bằng nhau giữ nguyên thứ tự hiện tại
        });
      } else if (_priceSort == 'desc') {
        _foods.sort((a, b) {
          final c = b.price.compareTo(a.price);
          return c;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadFoods,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Container(
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
                        GestureDetector(
                          onTap: () => context.go('/home'),
                          child: Container(
                            width: 44,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.arrow_back_ios_new, color: Color(0xFFFF6B35), size: 20),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            widget.showFavoritesOnly
                                ? 'Favorites'
                                : (widget.categoryId != null
                                    ? (widget.categoryId == 'cat_1'
                                        ? 'Snacks'
                                        : widget.categoryId == 'cat_2'
                                            ? 'Meal'
                                            : widget.categoryId == 'cat_3'
                                                ? 'Vegan'
                                                : widget.categoryId == 'cat_4'
                                                    ? 'Dessert'
                                                    : widget.categoryId == 'cat_5'
                                                        ? 'Drinks'
                                                        : 'Category')
                                    : 'All Foods'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),
                ),
              ),
              // Price sort control (back below header)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 16, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text('Sort by price:', style: TextStyle(fontSize: 13, color: Color(0xFFFF6B35))),
                      const SizedBox(width: 8),
                      DropdownButton<String>(
                        value: _priceSort,
                        items: const [
                          DropdownMenuItem(value: 'none', child: Text('Default',style: TextStyle(fontSize: 15))),
                          DropdownMenuItem(value: 'asc', child: Text('Low → High',style: TextStyle(fontSize: 15))),
                          DropdownMenuItem(value: 'desc', child: Text('High → Low',style: TextStyle(fontSize: 15))),
                        ],
                        onChanged: (val) {
                          if (val == null) return;
                          setState(() => _priceSort = val);
                          _applySort();
                        },
                      ),
                    ],
                  ),
                ),
              ),
              if (_isLoading)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_error != null)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Error: $_error', style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton(onPressed: _loadFoods, child: const Text('Retry')),
                      ],
                    ),
                  ),
                )
              else if (_foods.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.restaurant_menu, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No foods available', style: TextStyle(color: Colors.grey, fontSize: 16)),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final food = _foods[index];
                        return _buildFoodCard(food);
                      },
                      childCount: _foods.length,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: widget.showFavoritesOnly ? 2 : 3,
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
        border: Border.all(color: Color(0xFFFFB800).withValues(alpha: 0.35), width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
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
                      const SizedBox(width: 14),
                      // Price
                      Text(
                        '\$${food.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF6B35),
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: food.isAvailable ? () => _showAddToCartPopup(food) : null,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          child: const Icon(Icons.add_shopping_cart, color: Color(0xFFFF6B35), size: 20),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Consumer<FavoritesProvider>(
                        builder: (context, favs, _) {
                          final isFav = favs.isFavorite(food.id);
                          return GestureDetector(
                            onTap: () => favs.toggleFavorite(food.id),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              child: Icon(
                                isFav ? Icons.favorite : Icons.favorite_border,
                                color: isFav ? const Color(0xFFFF6B35) : Colors.grey[500],
                                size: 20,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  // Restaurants that sell this food
                  if (_restaurantsByFood[food.id] != null && 
                      _restaurantsByFood[food.id]!.isNotEmpty) ...[
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

