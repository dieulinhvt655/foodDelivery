import 'package:flutter/material.dart';
import '../../features/home/models/restaurant_model.dart';
import '../../features/home/services/restaurant_service.dart';

class HomeProvider extends ChangeNotifier {
  final RestaurantService _service = RestaurantService();
  
  List<RestaurantModel> _restaurants = [];
  bool _isLoading = false;
  String? _error;

  List<RestaurantModel> get restaurants => _restaurants;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadRestaurants() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _restaurants = await _service.getRestaurants();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}


