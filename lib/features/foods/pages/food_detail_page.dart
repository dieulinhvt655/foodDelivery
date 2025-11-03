import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/database/food_database_helper.dart';
import '../../../core/models/food_model.dart';
import '../../../core/models/restaurants_model.dart';
import '../../../core/providers/cart_provider.dart';
import '../../../core/models/cart_item_model.dart';

class FoodDetailPage extends StatefulWidget {
  final String foodId;
  final String? restaurantId;
  const FoodDetailPage({super.key, required this.foodId, this.restaurantId});

  @override
  State<FoodDetailPage> createState() => _FoodDetailPageState();
}

class _FoodDetailPageState extends State<FoodDetailPage> {
  final FoodDatabaseHelper _db = FoodDatabaseHelper.instance;
  FoodModel? _food;
  RestaurantModel? _restaurant;
  bool _loading = true;
  int _quantity = 1;
  List<FoodModel> _otherFoodsSameRestaurant = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final food = await _db.getFoodById(widget.foodId);
    List<RestaurantModel> restaurants = [];
    if (food != null) {
      restaurants = await _db.getRestaurantsByFoodId(food.id);
    }
    List<FoodModel> others = [];
    if (restaurants.isNotEmpty) {
      final rid = restaurants.first.id;
      final list = await _db.getFoodsByRestaurantId(rid);
      others = list.where((f) => f.id != widget.foodId).toList();
    }
    if (!mounted) return;
    setState(() {
      _food = food;
      _restaurant = restaurants.isNotEmpty ? restaurants.first : null;
      _otherFoodsSameRestaurant = others;
      _loading = false;
    });
  }

  void _addToCart() {
    if (_food == null) return;
    final cart = context.read<CartProvider>();
    final item = CartItemModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      foodId: _food!.id,
      foodName: _food!.name,
      foodImage: _food!.image,
      price: _food!.price,
      quantity: _quantity,
      restaurantId: _restaurant?.id ?? '',
      restaurantName: _restaurant?.name ?? '',
    );
    cart.addToCart(item);
    // If this page was opened from a restaurant context, go straight to confirm order
    if (widget.restaurantId != null && widget.restaurantId!.isNotEmpty) {
      context.push('/confirm-order');
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Added to cart')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Food Detail',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        backgroundColor: const Color(0xFFFFB800),
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => context.push('/cart'),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Icon(
                    Icons.shopping_cart_outlined,
                    color: Color(0xFFFF6B35),
                    size: 22,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF6B35)))
          : (_food == null)
              ? const Center(child: Text('Food not found'))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Ảnh đồ ăn
                      if (_food!.image.isNotEmpty)
                        AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Image.asset(_food!.image, fit: BoxFit.cover),
                        ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 2. Tên đồ ăn (header)
                            Text(
                              _food!.name,
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF2D2D2D)),
                            ),
                            const SizedBox(height: 8),
                            // 3. Tên nhà hàng + địa chỉ
                            Text(
                              (_restaurant?.name ?? '') + ((_restaurant?.address?.isNotEmpty ?? false) ? ' • ${_restaurant!.address}' : ''),
                              style: const TextStyle(fontSize: 14, color: Color(0xFF666666)),
                            ),
                            const SizedBox(height: 8),
                            // 4. Đánh giá sao
                            Row(
                              children: [
                                const Icon(Icons.star, size: 18, color: Color(0xFFFFB800)),
                                const SizedBox(width: 6),
                                Text(_food!.rating.toString(), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // 5. Mở cửa - giờ
                            Row(
                              children: const [
                                Icon(Icons.circle, size: 10, color: Color(0xFF2ECC71)),
                                SizedBox(width: 6),
                                Text('Open', style: TextStyle(fontSize: 14, color: Color(0xFF2D2D2D))),
                                SizedBox(width: 8),
                                Icon(Icons.schedule, size: 16, color: Color(0xFF666666)),
                                SizedBox(width: 4),
                                Text('00:00 - 23:59', style: TextStyle(fontSize: 14, color: Color(0xFF666666))),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // 6. Giá tiền
                            Text(
                              '\$' + _food!.price.toStringAsFixed(2),
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFFFF6B35)),
                            ),
                            const SizedBox(height: 16),
                            // 7. Tăng/giảm số lượng + Add to cart
                            Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: const Color(0xFFFFE0B3)),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove),
                                        color: const Color(0xFFFF6B35),
                                        onPressed: () {
                                          if (_quantity > 1) {
                                            setState(() => _quantity -= 1);
                                          }
                                        },
                                      ),
                                      Text(_quantity.toString(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                                      IconButton(
                                        icon: const Icon(Icons.add),
                                        color: const Color(0xFFFF6B35),
                                        onPressed: () {
                                          setState(() => _quantity += 1);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFFF6B35),
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    onPressed: _addToCart,
                                    child: const Text('Add to cart', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            // 8. Bình luận/đánh giá
                            const Text('Reviews', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF2D2D2D))),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF8ED),
                                border: Border.all(color: const Color(0xFFFFE0B3)),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text('No reviews yet.'),
                            ),
                            const SizedBox(height: 24),
                            // 9. Món ăn khác
                            if (_otherFoodsSameRestaurant.isNotEmpty) ...[
                              const Text('Other dishes from this restaurant', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF2D2D2D))),
                              const SizedBox(height: 12),
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _otherFoodsSameRestaurant.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final other = _otherFoodsSameRestaurant[index];
                                  return GestureDetector(
                                    onTap: () {
                                      context.push('/food/${other.id}');
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: const Color(0xFFFFE0B3)),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 64,
                                            height: 64,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(8),
                                              color: const Color(0xFFFFF4E3),
                                            ),
                                            child: const Icon(Icons.fastfood, color: Color(0xFFFF6B35)),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(other.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                                                const SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    const Icon(Icons.star, size: 14, color: Color(0xFFFFB800)),
                                                    const SizedBox(width: 4),
                                                    Text(other.rating.toString(), style: const TextStyle(fontSize: 12)),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text('\$' + other.price.toStringAsFixed(2), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFFFF6B35))),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}


