import 'package:flutter/material.dart';
import '../../../core/database/food_database_helper.dart';
import '../../../core/models/food_model.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/favorites_provider.dart';
import 'package:go_router/go_router.dart';

class FilteredFoodsPage extends StatefulWidget {
  final String category; // Snacks, Meal, Vegan, Dessert, Drink
  final Set<String> options; // e.g., Bruschetta, Spring Rolls, ...
  final double? priceMin;
  final double? priceMax;
  final int? minRating; // 1..5

  const FilteredFoodsPage({
    super.key,
    required this.category,
    required this.options,
    this.priceMin,
    this.priceMax,
    this.minRating,
  });

  @override
  State<FilteredFoodsPage> createState() => _FilteredFoodsPageState();
}

class _FilteredFoodsPageState extends State<FilteredFoodsPage> {
  final FoodDatabaseHelper _db = FoodDatabaseHelper.instance;
  bool _isLoading = true;
  String? _error;
  List<FoodModel> _foods = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final normalizedCategory = _normalizeCategory(widget.category);
      final items = await _db.filterFoods(
        categoryName: normalizedCategory.toLowerCase(),
        nameOptions: widget.options,
        minRating: widget.minRating,
        priceMin: widget.priceMin,
        priceMax: widget.priceMax,
      );
      if (!mounted) return;
      setState(() {
        _foods = items;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _normalizeCategory(String raw) {
    switch (raw.trim().toLowerCase()) {
      case 'snacks':
        return 'Snacks';
      case 'meal':
      case 'meals':
        return 'Meal';
      case 'vegan':
        return 'Vegan';
      case 'dessert':
      case 'desserts':
        return 'Dessert';
      case 'drink':
      case 'drinks':
        return 'Drink';
      default:
        return 'Snacks';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text(_error!))
                : CustomScrollView(
                    slivers: [
                      // Header (match All Foods)
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
                                  onTap: () => Navigator.of(context).pop(),
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
                                const Expanded(
                                  child: Text(
                                    'Filtered Results',
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

                      if (_foods.isEmpty)
                        const SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.restaurant_menu, size: 64, color: Colors.grey),
                                SizedBox(height: 16),
                                Text('No items match your filters', style: TextStyle(color: Colors.grey, fontSize: 16)),
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
                                final f = _foods[index];
                                return _buildFoodCard(f);
                              },
                              childCount: _foods.length,
                            ),
                          ),
                        ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildFoodCard(FoodModel food) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          context.push('/food/' + food.id);
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFB800).withValues(alpha: 0.35), width: 0.8),
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
              child: Image.asset(
                food.image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(Icons.restaurant, size: 50, color: Colors.grey),
                    ),
                  );
                },
              ),
            ),
          ),
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
                      Row(
                        children: const [
                          Icon(Icons.star, size: 16, color: Color(0xFFFFB800)),
                          SizedBox(width: 4),
                        ],
                      ),
                      Text(
                        food.rating.toString(),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF2D2D2D),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        '\$' + food.price.toStringAsFixed(2),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF6B35),
                        ),
                      ),
                      const Spacer(),
                      Consumer<FavoritesProvider>(
                        builder: (context, favs, _) {
                          final isFav = favs.isFavorite(food.id);
                          return GestureDetector(
                            onTap: () => favs.toggleFavorite(food.id),
                            child: Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              color: isFav ? const Color(0xFFFF6B35) : Colors.grey[500],
                              size: 22,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
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


