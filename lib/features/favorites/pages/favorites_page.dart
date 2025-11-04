import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/favorites_provider.dart';
import '../../../core/database/food_database_helper.dart';
import '../../../core/models/food_model.dart';
import '../../common/widgets/custom_bottom_nav_bar.dart';


class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final FoodDatabaseHelper _dbHelper = FoodDatabaseHelper.instance;
  bool _loading = true;
  List<FoodModel> _foods = [];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final favs = context.read<FavoritesProvider>();
    await favs.loadFavorites();
    final allFoods = await _dbHelper.getAllFoods();
    final ids = favs.favoriteFoodIds;
    setState(() {
      _foods = allFoods.where((f) => ids.contains(f.id)).toList();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _foods.isEmpty
              ? const Center(child: Text('No favorites yet'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (ctx, i) {
                    final food = _foods[i];
                    return ListTile(
                      onTap: () {
                        context.push('/food/${food.id}');
                      },
                      leading: food.image.startsWith('http')
                          ? Image.network(food.image, width: 48, height: 48, fit: BoxFit.cover)
                          : Image.asset(food.image, width: 48, height: 48, fit: BoxFit.cover),
                      title: Text(food.name),
                      subtitle: Text('\$${food.price.toStringAsFixed(2)}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.favorite, color: Color(0xFFFF6B35)),
                        onPressed: () async {
                          await context.read<FavoritesProvider>().toggleFavorite(food.id);
                          setState(() {
                            _foods.removeAt(i);
                          });
                        },
                      ),
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemCount: _foods.length,
                ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 2),
    );
  }
}


