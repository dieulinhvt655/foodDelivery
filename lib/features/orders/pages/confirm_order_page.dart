import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/cart_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/models/cart_item_model.dart';
import '../../../core/models/address_model.dart';
import '../../../core/database/address_database_helper.dart';
import '../../../core/models/voucher_model.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/models/order_model.dart';
import '../../../core/models/notification_model.dart';
import '../../../core/database/order_database_helper.dart';
import '../../../core/database/notification_database_helper.dart';
import '../widgets/payment_method_dialog.dart';

class ConfirmOrderPage extends StatefulWidget {
  const ConfirmOrderPage({super.key});

  @override
  State<ConfirmOrderPage> createState() => _ConfirmOrderPageState();
}

class _ConfirmOrderPageState extends State<ConfirmOrderPage> {
  AddressModel? _selectedAddress;
  String? _selectedPaymentMethod;
  String? _orderCode;

  // Generate unique order code
  Future<String> _generateUniqueOrderCode() async {
    final random = DateTime.now().millisecondsSinceEpoch;
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    
    // Generate order code and check if it exists
    String orderCode;
    int attempts = 0;
    do {
      final randomString = StringBuffer();
      final randomizer = (random + attempts) % 1000000;
      
      // Generate 6 random characters
      for (int i = 0; i < 6; i++) {
        randomString.write(chars[(randomizer + i) % chars.length]);
      }
      
      // Mix with timestamp to ensure uniqueness
      final timestampStr = (random + attempts).toString();
      final timestampPart = timestampStr.length >= 4
          ? timestampStr.substring(timestampStr.length - 4)
          : timestampStr.padLeft(4, '0');
      final mixed = (randomString.toString() + timestampPart).substring(0, 8);
      orderCode = '#$mixed';
      
      // Check if code already exists
      final exists = await OrderDatabaseHelper.instance.orderCodeExists(orderCode);
      if (!exists) break;
      
      attempts++;
      // Prevent infinite loop
      if (attempts > 100) {
        // Fallback: use timestamp as part of code
        orderCode = '#${(random + DateTime.now().microsecondsSinceEpoch).toString().substring(0, 8)}';
        break;
      }
    } while (true);
    
    return orderCode;
  }

  @override
  void initState() {
    super.initState();
    _loadDefaultAddress();
    _loadOrderCode();
  }

  Future<void> _loadOrderCode() async {
    final code = await _generateUniqueOrderCode();
    if (mounted) {
      setState(() {
        _orderCode = code;
      });
    }
  }

  Future<void> _loadDefaultAddress() async {
    final auth = context.read<AuthProvider>();
    final account = auth.currentAccount;
    if (account?.id != null) {
      final addresses = await AddressDatabaseHelper.instance.fetchAddresses(account!.id!);
      if (mounted) {
        setState(() {
          if (addresses.isNotEmpty) {
            _selectedAddress = addresses.firstWhere(
              (addr) => addr.isDefault,
              orElse: () => addresses.first,
            );
          }
        });
      }
    }
  }

  Future<void> _placeOrder() async {
    final auth = context.read<AuthProvider>();
    final cartProvider = context.read<CartProvider>();
    final account = auth.currentAccount;
    
    if (account?.id == null) return;
    
    final cartItems = cartProvider.cartItems;
    final subtotal = cartProvider.subtotal;
    final discount = cartProvider.discountAmount;
    final deliveryFee = cartProvider.appliedVoucher?.type == VoucherType.freeShipping 
        ? 0.0 
        : 4.50;
    final vat = subtotal * 0.10;
    final total = subtotal - discount + deliveryFee + vat;
    
    // Get current time
    final now = DateTime.now();
    
    // Calculate delivery date (2 days from now, 4:00 PM)
    var deliveryDate = now.add(const Duration(days: 2));
    deliveryDate = DateTime(
      deliveryDate.year,
      deliveryDate.month,
      deliveryDate.day,
      16, // 4:00 PM
      0,
    );
    
    // Use the order code generated in initState or generate a new one
    final orderCode = _orderCode ?? await _generateUniqueOrderCode();

    // If QR payment selected, navigate to QR payment page and handle expiry; do not place order yet
    if (_selectedPaymentMethod == 'qr') {
      final result = await context.push('/qr-payment?amount=${total.toStringAsFixed(2)}&orderCode=$orderCode');
      if (!mounted) return;
      if (result == 'expired') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('QR code expired. Please choose your payment method again.'),
            backgroundColor: Color(0xFFFF6B35),
          ),
        );
        setState(() {
          _selectedPaymentMethod = null;
        });
      }
      return;
    }
    
    // Create order
    final orderId = DateTime.now().millisecondsSinceEpoch.toString();
    final orderItems = cartItems.map((item) => OrderItem(
      foodId: item.foodId,
      foodName: item.foodName,
      foodImage: item.foodImage,
      price: item.price,
      quantity: item.quantity,
      restaurantId: item.restaurantId,
      restaurantName: item.restaurantName,
    )).toList();
    
    final order = OrderModel(
      id: orderId,
      orderCode: orderCode,
      userId: account!.id!.toString(),
      addressId: _selectedAddress?.id?.toString() ?? '',
      paymentMethod: _selectedPaymentMethod ?? '',
      subtotal: subtotal,
      discount: discount,
      deliveryFee: deliveryFee,
      vat: vat,
      total: total,
      status: 'active',
      orderDate: now,
      deliveryDate: deliveryDate,
      items: orderItems,
    );
    
    // Save order
    await OrderDatabaseHelper.instance.saveOrder(order);
    
    // Create notification
    final notificationId = DateTime.now().millisecondsSinceEpoch.toString();
    final hour = now.hour > 12 ? now.hour - 12 : now.hour;
    final amPm = now.hour >= 12 ? 'PM' : 'AM';
    final minute = now.minute.toString().padLeft(2, '0');
    
    final notification = NotificationModel(
      id: notificationId,
      userId: account.id!.toString(),
      title: 'Đặt hàng thành công',
      message: 'Đơn hàng của bạn đã được đặt thành công vào lúc $hour:$minute $amPm',
      createdAt: now,
      isRead: false,
      icon: Icons.check_circle_outline,
    );
    
    // Save notification
    await NotificationDatabaseHelper.instance.saveNotification(notification);
    
    // Check payment method
    if (_selectedPaymentMethod == 'cod') {
      // Cash on Delivery - show order confirmed page
      cartProvider.clearCart();
      context.go('/order-confirmed?deliveryDate=${deliveryDate.toIso8601String()}');
    } else {
      // Other non-QR methods (e.g., linked wallets) not implemented: prompt selection again
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This payment method is not available. Please choose another.'),
          backgroundColor: Color(0xFFFF6B35),
        ),
      );
    }
  }

  String _getPaymentMethodName(String methodId) {
    final method = PaymentMethodDialog.paymentMethods.firstWhere(
      (m) => m['id'] == methodId,
      orElse: () => {'title': 'Unknown'},
    );
    return method['title'] as String;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFB800),
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            decoration: const BoxDecoration(
              color: Color(0xFFFFB800),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'Confirm Order',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 40),
                ],
              ),
            ),
          ),
          // Content
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Consumer<CartProvider>(
                  builder: (context, cartProvider, child) {
                    if (cartProvider.isEmpty) {
                      return const Center(
                        child: Text('Cart is empty'),
                      );
                    }

                    final cartItems = cartProvider.cartItems;
                    final subtotal = cartProvider.subtotal;
                    final discount = cartProvider.discountAmount;
                    final deliveryFee = cartProvider.appliedVoucher?.type == VoucherType.freeShipping 
                        ? 0.0 
                        : 4.50;
                    final vat = subtotal * 0.10;
                    final taxAndFees = vat;
                    final total = subtotal - discount + deliveryFee + vat;

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Shipping Address
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Shipping Address',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF2D2D2D),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit, size: 18, color: Color(0xFF7A7A7A)),
                                onPressed: () {
                                  context.push('/addresses').then((_) {
                                    _loadDefaultAddress();
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF4E3),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFFFD9A0),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _selectedAddress?.address ?? 'No address selected',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF2D2D2D),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          // Order Code
                          if (_orderCode != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF4E3),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFFFD9A0),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Text(
                                    'Order Code: ',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF2D2D2D),
                                    ),
                                  ),
                                  Text(
                                    _orderCode!,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFFFF6B35),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (_orderCode != null) const SizedBox(height: 24),
                          // Order Summary
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Order Summary',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF2D2D2D),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF0E1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'Edit',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFFF6B35),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Cart Items
                          ...List.generate(cartItems.length, (index) {
                            final item = cartItems[index];
                            return _OrderItemTile(
                              item: item,
                              onIncrement: () {
                                cartProvider.updateQuantity(item.id, item.quantity + 1);
                              },
                              onDecrement: () {
                                if (item.quantity > 1) {
                                  cartProvider.updateQuantity(item.id, item.quantity - 1);
                                } else {
                                  cartProvider.removeFromCart(item.id);
                                }
                              },
                              onRemove: () {
                                cartProvider.removeFromCart(item.id);
                              },
                            );
                          }),
                          const SizedBox(height: 24),
                          // Order Totals
                          const Text(
                            'Order Totals',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2D2D2D),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _TotalRow(label: 'Subtotal', value: subtotal),
                          _TotalRow(label: 'Tax and Fees', value: taxAndFees),
                          _TotalRow(label: 'Delivery', value: deliveryFee),
                          if (discount > 0)
                            _TotalRow(
                              label: 'Discount',
                              value: -discount,
                              isDiscount: true,
                            ),
                          const Divider(height: 32, color: Color(0xFFFFD9A0), thickness: 1),
                          _TotalRow(
                            label: 'Total',
                            value: total,
                            emphasis: true,
                          ),
                          const SizedBox(height: 32),
                          // Choose Payment Method
                          const Text(
                            'Choose a payment method',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2D2D2D),
                            ),
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => PaymentMethodDialog(
                                  selectedMethod: _selectedPaymentMethod,
                                  orderTotal: total,
                                  onSelect: (methodId) {
                                    setState(() {
                                      _selectedPaymentMethod = methodId;
                                    });
                                  },
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: _selectedPaymentMethod != null
                                    ? const Color(0xFFFFF4E3)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: _selectedPaymentMethod != null
                                      ? const Color(0xFFFF6B35)
                                      : const Color(0xFFFFE0B3),
                                  width: _selectedPaymentMethod != null ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _selectedPaymentMethod != null
                                        ? Icons.check_circle
                                        : Icons.payment_outlined,
                                    color: const Color(0xFFFF6B35),
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _selectedPaymentMethod != null
                                          ? _getPaymentMethodName(_selectedPaymentMethod!)
                                          : 'Select payment method',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: _selectedPaymentMethod != null
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                        color: _selectedPaymentMethod != null
                                            ? const Color(0xFF2D2D2D)
                                            : const Color(0xFF7A7A7A),
                                      ),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.chevron_right,
                                    color: Color(0xFFFF6B35),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          // Place Order Button
                          Center(
                            child: FractionallySizedBox(
                              widthFactor: 0.6,
                              child: SizedBox(
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: _selectedAddress != null && _selectedPaymentMethod != null
                                      ? _placeOrder
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFFF0E1),
                                    foregroundColor: const Color(0xFFFF6B35),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: const Text(
                                    'Place Order',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderItemTile extends StatelessWidget {
  final CartItemModel item;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  const _OrderItemTile({
    required this.item,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateStr = '${now.day} ${_getMonthName(now.month)}, ${now.hour}:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'pm' : 'am'}';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFFE0B3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Food Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 80,
              height: 80,
              child: () {
                final img = item.foodImage;
                if (img.startsWith('http')) {
                  return Image.network(
                    img,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) => Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.orange.shade100, Colors.orange.shade200],
                        ),
                      ),
                      child: const Icon(Icons.fastfood, color: Color(0xFFFF6B35), size: 40),
                    ),
                  );
                }
                if (img.toLowerCase().endsWith('.svg')) {
                  return SvgPicture.asset(img, fit: BoxFit.cover);
                }
                return Image.asset(
                  img,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stack) => Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.orange.shade100, Colors.orange.shade200],
                      ),
                    ),
                    child: const Icon(Icons.fastfood, color: Color(0xFFFF6B35), size: 40),
                  ),
                );
              }(),
            ),
          ),
          const SizedBox(width: 12),
          // Food Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.foodName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2D2D2D),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dateStr,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF0E1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Cancel Order',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFFF6B35),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Right side - Controls
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Color(0xFF7A7A7A), size: 20),
                onPressed: onRemove,
              ),
              const SizedBox(height: 8),
              Text(
                '\$${item.price.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2D2D2D),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${item.quantity} ${item.quantity == 1 ? 'item' : 'items'}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, size: 16, color: Color(0xFF7A7A7A)),
                    onPressed: () {},
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  _QuantityButton(
                    icon: Icons.remove,
                    onTap: onDecrement,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    item.quantity.toString(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _QuantityButton(
                    icon: Icons.add,
                    onTap: onIncrement,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QuantityButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: const Color(0xFFFFF0E1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: const Color(0xFFFF6B35)),
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  final String label;
  final double value;
  final bool emphasis;
  final bool isDiscount;

  const _TotalRow({
    required this.label,
    required this.value,
    this.emphasis = false,
    this.isDiscount = false,
  });

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

