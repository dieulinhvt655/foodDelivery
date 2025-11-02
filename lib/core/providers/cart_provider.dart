import 'package:flutter/material.dart';
import '../models/cart_item_model.dart';
import '../models/voucher_model.dart';
import '../database/cart_database_helper.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItemModel> _cartItems = [];
  final CartDatabaseHelper _databaseHelper = CartDatabaseHelper.instance;
  String? _currentUserEmail;
  VoucherModel? _appliedVoucher;

  List<CartItemModel> get cartItems => _cartItems;

  int get totalItems => _cartItems.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => _cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);

  bool get isEmpty => _cartItems.isEmpty;

  VoucherModel? get appliedVoucher => _appliedVoucher;

  double get discountAmount {
    if (_appliedVoucher == null) return 0.0;
    return _appliedVoucher!.calculateDiscount(subtotal);
  }

  double get total {
    final sub = subtotal;
    final discount = discountAmount;
    return sub - discount;
  }

  // Load cart from database when user logs in
  Future<void> loadCartFromDatabase(String userEmail) async {
    _currentUserEmail = userEmail;
    try {
      final savedItems = await _databaseHelper.loadCart(userEmail);
      _cartItems.clear();
      _cartItems.addAll(savedItems);
      notifyListeners();
    } catch (e) {
      // If error, start with empty cart
      _cartItems.clear();
      notifyListeners();
    }
  }

  // Save cart to database
  Future<void> saveCartToDatabase(String userEmail) async {
    try {
      await _databaseHelper.saveCart(userEmail, _cartItems);
    } catch (e) {
      // Handle error silently or log it
    }
  }

  // Auto-save cart when items change
  void _autoSave() {
    if (_currentUserEmail != null) {
      saveCartToDatabase(_currentUserEmail!);
    }
  }

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
    _autoSave();
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
      _autoSave();
    }
  }

  // Remove item from cart
  void removeFromCart(String itemId) {
    _cartItems.removeWhere((item) => item.id == itemId);
    notifyListeners();
    _autoSave();
  }

  // Clear cart
  void clearCart() {
    _cartItems.clear();
    if (_currentUserEmail != null) {
      _databaseHelper.clearCart(_currentUserEmail!);
    }
    _currentUserEmail = null;
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

  // Apply voucher
  bool applyVoucher(VoucherModel voucher, {String? userAddress}) {
    if (voucher.canBeApplied(subtotal, userAddress: userAddress)) {
      _appliedVoucher = voucher;
      notifyListeners();
      return true;
    }
    return false;
  }

  // Remove voucher
  void removeVoucher() {
    _appliedVoucher = null;
    notifyListeners();
  }
}

