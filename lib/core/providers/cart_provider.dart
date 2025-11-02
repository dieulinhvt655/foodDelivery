import 'package:flutter/material.dart';
import '../models/cart_item_model.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItemModel> _cartItems = [];

  List<CartItemModel> get cartItems => _cartItems;

  int get totalItems => _cartItems.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => _cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);

  bool get isEmpty => _cartItems.isEmpty;

  // Add item to cart
  void addToCart(CartItemModel item) {
    final existingIndex = _cartItems.indexWhere((cartItem) => cartItem.foodId == item.foodId);
    
    if (existingIndex != -1) {
      // Item already exists, increase quantity
      _cartItems[existingIndex] = _cartItems[existingIndex].copyWith(
        quantity: _cartItems[existingIndex].quantity + item.quantity,
      );
    } else {
      // New item
      _cartItems.add(item);
    }
    
    notifyListeners();
  }

  // Update quantity
  void updateQuantity(String itemId, int quantity) {
    if (quantity <= 0) {
      removeFromCart(itemId);
      return;
    }
    
    final index = _cartItems.indexWhere((item) => item.id == itemId);
    if (index != -1) {
      _cartItems[index] = _cartItems[index].copyWith(quantity: quantity);
      notifyListeners();
    }
  }

  // Remove item from cart
  void removeFromCart(String itemId) {
    _cartItems.removeWhere((item) => item.id == itemId);
    notifyListeners();
  }

  // Clear cart
  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  // Get item quantity by foodId
  int getItemQuantity(String foodId) {
    final item = _cartItems.firstWhere(
      (item) => item.foodId == foodId,
      orElse: () => CartItemModel(
        id: '',
        foodId: foodId,
        foodName: '',
        foodImage: '',
        price: 0,
        quantity: 0,
        restaurantId: '',
        restaurantName: '',
      ),
    );
    return item.quantity;
  }
}

