import 'package:flutter/material.dart';
import '../database/favorites_database_helper.dart';

class FavoritesProvider extends ChangeNotifier {
  final Set<String> _favoriteFoodIds = <String>{};

  Set<String> get favoriteFoodIds => _favoriteFoodIds;

  bool isFavorite(String foodId) => _favoriteFoodIds.contains(foodId);

  Future<void> loadFavorites() async {
    final ids = await FavoritesDatabaseHelper.instance.loadFavoriteFoodIds();
    _favoriteFoodIds
      ..clear()
      ..addAll(ids);
    notifyListeners();
  }

  Future<void> toggleFavorite(String foodId) async {
    if (isFavorite(foodId)) {
      _favoriteFoodIds.remove(foodId);
      await FavoritesDatabaseHelper.instance.removeFavorite(foodId);
    } else {
      _favoriteFoodIds.add(foodId);
      await FavoritesDatabaseHelper.instance.addFavorite(foodId);
    }
    notifyListeners();
  }
}


