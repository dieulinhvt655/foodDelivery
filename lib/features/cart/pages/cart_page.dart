import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/cart_provider.dart';
import '../../../core/models/cart_item_model.dart';
import '../../../core/models/voucher_model.dart';
import '../widgets/voucher_dialog.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  static const double _deliveryFee = 4.50;
  static const double _vatRate = 0.10; // 10% VAT

  void _incrementQuantity(BuildContext context, CartItemModel item) {
    context.read<CartProvider>().updateQuantity(item.id, item.quantity + 1);
  }

  void _decrementQuantity(BuildContext context, CartItemModel item) {
    if (item.quantity > 1) {
      context.read<CartProvider>().updateQuantity(item.id, item.quantity - 1);
    } else {
      context.read<CartProvider>().removeFromCart(item.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        final cartItems = cartProvider.cartItems;
        final subtotal = cartProvider.subtotal;
        final discount = cartProvider.discountAmount;
        final deliveryFee = cartProvider.appliedVoucher?.type == VoucherType.freeShipping 
            ? 0.0 
            : _deliveryFee;
        final vat = subtotal * _vatRate;
        final total = subtotal - discount + deliveryFee + vat;

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: cartProvider.isEmpty
                      ? const _EmptyCartState()
                      : SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ...List.generate(cartItems.length, (index) {
                                final item = cartItems[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: _CartItemTile(
                                    title: item.foodName,
                                    subtitle: item.restaurantName,
                                    price: item.price,
                                    quantity: item.quantity,
                                    onIncrement: () => _incrementQuantity(context, item),
                                    onDecrement: () => _decrementQuantity(context, item),
                                  ),
                                );
                              }),
                              const SizedBox(height: 12),
                              _VoucherInput(
                                appliedVoucher: cartProvider.appliedVoucher,
                              ),
                              const SizedBox(height: 24),
                              _SummaryRow(label: 'Subtotal', value: subtotal),
                              _SummaryRow(label: 'Delivery fee', value: deliveryFee),
                              if (discount > 0)
                                _SummaryRow(
                                  label: 'Discount',
                                  value: -discount,
                                  isDiscount: true,
                                ),
                              _SummaryRow(label: 'VAT (10%)', value: vat),
                              const Divider(height: 32, color: Color(0xFFFFD9A0), thickness: 1.2),
                              _SummaryRow(label: 'Total', value: total, emphasis: true),
                              const SizedBox(height: 24),
                              _CheckoutButton(
                                onPressed: () {
                                  context.push('/confirm-order');
                                },
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: const BoxDecoration(
        color: Color(0xFFFFB800),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 44,
              height: 44,
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
          const Spacer(),
          const Text(
            'My Cart',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  const _CartItemTile({
    required this.title,
    required this.subtitle,
    required this.price,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
  });

  final String title;
  final String subtitle;
  final double price;
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.orange.shade100,
                  Colors.orange.shade200,
                ],
              ),
            ),
            child: const Icon(Icons.fastfood, color: Color(0xFFFF6B35), size: 36),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2D2D2D),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF7A7A7A),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '\$${price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFFF6B35),
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              _QuantityButton(icon: Icons.add, onTap: onIncrement),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(
                  quantity.toString(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D2D2D),
                  ),
                ),
              ),
              _QuantityButton(icon: Icons.remove, onTap: onDecrement),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  const _QuantityButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: const Color(0xFFFFF0E1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: const Color(0xFFFF6B35)),
      ),
    );
  }
}

class _VoucherInput extends StatelessWidget {
  final VoucherModel? appliedVoucher;

  const _VoucherInput({this.appliedVoucher});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => const VoucherDialog(),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: appliedVoucher != null
              ? const Color(0xFFFFF4E3)
              : const Color(0xFFFFF4E3),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: appliedVoucher != null
                ? const Color(0xFFFF6B35)
                : const Color(0xFFFFD9A0),
            width: appliedVoucher != null ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.card_giftcard, color: Color(0xFFFF6B35)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appliedVoucher != null
                        ? appliedVoucher!.name
                        : 'Add your promo code',
                    style: TextStyle(
                      fontSize: appliedVoucher != null ? 13 : 15,
                      fontWeight: appliedVoucher != null
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: appliedVoucher != null
                          ? const Color(0xFF2D2D2D)
                          : const Color(0xFF7A7A7A),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (appliedVoucher != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Tap to change',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B35),
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              child: const Text(
                'Apply',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.emphasis = false,
    this.isDiscount = false,
  });

  final String label;
  final double value;
  final bool emphasis;
  final bool isDiscount;

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      fontSize: emphasis ? 18 : 15,
      fontWeight: emphasis ? FontWeight.w700 : FontWeight.w500,
      color: emphasis
          ? const Color(0xFF2D2D2D)
          : isDiscount
              ? const Color(0xFFFF6B35)
              : const Color(0xFF6F6F6F),
    );

    final formatted = value < 0
        ? '-\$${value.abs().toStringAsFixed(2)}'
        : '\$${value.toStringAsFixed(2)}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(label, style: textStyle),
          const Spacer(),
          Text(formatted, style: textStyle),
        ],
      ),
    );
  }
}

class _CheckoutButton extends StatelessWidget {
  const _CheckoutButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FractionallySizedBox(
        widthFactor: 0.5,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF6B35),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            elevation: 3,
          ),
          child: const Center(
            child: Text(
              'Checkout',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyCartState extends StatelessWidget {
  const _EmptyCartState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF4E3),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(Icons.shopping_basket_outlined, color: Color(0xFFFF6B35), size: 72),
          ),
          const SizedBox(height: 32),
          const Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2D2D2D),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Text(
            'Browse our delicious menu and add your favourites.',
            style: TextStyle(
              fontSize: 15,
              color: Color(0xFF7A7A7A),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

        ],
      ),
    );
  }
}

