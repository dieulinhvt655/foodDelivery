import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/models/order_model.dart';
import '../../../core/models/address_model.dart';
import '../../../core/database/order_database_helper.dart';
import '../../../core/database/address_database_helper.dart';
import 'package:intl/intl.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  String _selectedTab = 'Active';
  List<OrderModel> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOrders();
    });
  }

  Future<void> _loadOrders() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final account = auth.currentAccount;
    
    if (account?.id != null) {
      final userId = account!.id!.toString();
      
      // Convert status from UI to database format
      String? status;
      switch (_selectedTab) {
        case 'Active':
          status = 'active';
          break;
        case 'Completed':
          status = 'completed';
          break;
        case 'Cancelled':
          status = 'cancelled';
          break;
      }

      // Seed sample completed orders if on Completed tab and no orders exist
      if (_selectedTab == 'Completed' && status == 'completed') {
        await OrderDatabaseHelper.instance.seedSampleCompletedOrders(userId);
      }

      final orders = await OrderDatabaseHelper.instance.getOrdersByUserId(
        userId,
        status: status,
      );

      if (mounted) {
        setState(() {
          _orders = orders;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _orders = [];
          _isLoading = false;
        });
      }
    }
  }

  void _onTabChanged(String tab) {
    setState(() {
      _selectedTab = tab;
    });
    _loadOrders();
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
                  // Back button
                  GestureDetector(
                    onTap: () {
                      if (context.canPop()) {
                        context.pop(); // preserves native back animation (left -> right)
                      } else {
                        context.go('/profile');
                      }
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(Icons.arrow_back_ios_new, color: Color(0xFFFF6B35)),
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'My Orders',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  // Balance space for back button
                  const SizedBox(width: 40),
                ],
              ),
            ),
          ),
          // Content area
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
                child: Column(
                  children: [
                    // Tabs
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildTab('Active', _selectedTab == 'Active', () => _onTabChanged('Active')),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTab('Completed', _selectedTab == 'Completed', () => _onTabChanged('Completed')),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTab('Cancelled', _selectedTab == 'Cancelled', () => _onTabChanged('Cancelled')),
                          ),
                        ],
                      ),
                    ),
                    // Orders list or empty state
                    Expanded(
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF6B35)))
                          : _orders.isEmpty
                              ? _buildEmptyState()
                              : _buildOrdersList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF6B35) : const Color(0xFFFFF1E6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : const Color(0xFFFF6B35),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    String emptyText;
    switch (_selectedTab) {
      case 'Active':
        emptyText = 'active orders at this';
        break;
      case 'Completed':
        emptyText = 'completed orders';
        break;
      case 'Cancelled':
        emptyText = 'cancelled orders';
        break;
      default:
        emptyText = 'orders';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 120,
            color: const Color(0xFFFF6B35).withOpacity(0.3),
          ),
          const SizedBox(height: 32),
          const Text(
            'You don\'t have any',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFFFF6B35),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            emptyText,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFFFF6B35),
            ),
          ),
          if (_selectedTab == 'Active') ...[
            const SizedBox(height: 4),
            const Text(
              'time',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFFFF6B35),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOrdersList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _orders.length,
      itemBuilder: (context, index) {
        final order = _orders[index];
        return _buildOrderCard(order);
      },
    );
  }

  Future<AddressModel?> _getAddress(String addressId) async {
    if (addressId.isEmpty) return null;
    final id = int.tryParse(addressId);
    if (id == null) return null;
    return await AddressDatabaseHelper.instance.getAddressById(id);
  }

  String _getPaymentMethodName(String paymentMethod) {
    switch (paymentMethod.toLowerCase()) {
      case 'card':
        return 'Credit Card';
      case 'zalopay':
        return 'ZaloPay';
      case 'momo':
        return 'Momo';
      case 'cod':
        return 'Cash on Delivery';
      case 'qr':
        return 'QR Code Payment';
      default:
        return paymentMethod;
    }
  }

  Map<String, String> _getPaymentStatus(String paymentMethod) {
    // Online payment methods (paid)
    final onlineMethods = ['card', 'zalopay', 'momo', 'qr'];
    
    if (onlineMethods.contains(paymentMethod.toLowerCase())) {
      return {
        'status': 'Paid',
        'statusText': 'Paid',
      };
    } else if (paymentMethod.toLowerCase() == 'cod') {
      // Cash on Delivery (not paid yet)
      return {
        'status': 'Not paid',
        'statusText': 'Not paid',
      };
    }
    
    // Default
    return {
      'status': 'Unknown',
      'statusText': 'Unknown',
    };
  }

  Widget _buildOrderCard(OrderModel order) {
    final dateFormat = DateFormat('dd MMM, h:mm a');
    
    // Get first item name or "Order" if empty
    final itemName = order.items.isNotEmpty 
        ? order.items.first.foodName 
        : 'Order';
    final totalItems = order.items.fold<int>(0, (sum, item) => sum + item.quantity);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFE0B3), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Code
          Text(
            order.orderCode,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFFFF6B35),
            ),
          ),
          const SizedBox(height: 12),
          
          // Item Name (Top Left) and Price (Top Right)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Item Name
              Expanded(
                child: Text(
                  itemName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2D2D2D),
                  ),
                ),
              ),
              // Price
              Text(
                '\$${order.total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2D2D2D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Date and Time (ordered + cancel/completed) and Number of Items
          if (order.status.toLowerCase() == 'cancelled' || order.status.toLowerCase() == 'completed') ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ordered: ' + dateFormat.format(order.orderDate),
                        style: const TextStyle(fontSize: 13, color: Color(0xFF7A7A7A)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          (order.status.toLowerCase() == 'cancelled'
                                  ? 'Cancelled: '
                                  : 'Completed: ') +
                              dateFormat.format((order.deliveryDate ?? order.orderDate)),
                          style: const TextStyle(fontSize: 13, color: Color(0xFF7A7A7A)),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '$totalItems ${totalItems == 1 ? 'item' : 'items'}',
                  style: const TextStyle(fontSize: 13, color: Color(0xFF7A7A7A)),
                ),
              ],
            ),
          ] else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Date and Time
                Text(
                  dateFormat.format(order.orderDate),
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF7A7A7A),
                  ),
                ),
                // Number of Items
                Text(
                  '$totalItems ${totalItems == 1 ? 'item' : 'items'}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF7A7A7A),
                  ),
                ),
              ],
            ),
          ],
          
          // Address
          FutureBuilder<AddressModel?>(
            future: _getAddress(order.addressId),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                final address = snapshot.data!;
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: Color(0xFF7A7A7A),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          address.address,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF7A7A7A),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          
          // Payment Method and Status
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Payment Method
                Row(
                  children: [
                    const Icon(
                      Icons.payment,
                      size: 16,
                      color: Color(0xFF7A7A7A),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _getPaymentMethodName(order.paymentMethod),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF7A7A7A),
                      ),
                    ),
                  ],
                ),
                // Payment Status
                _getPaymentStatus(order.paymentMethod)['status'] == 'Paid'
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFF81C784),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          _getPaymentStatus(order.paymentMethod)['statusText']!,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF388E3C),
                          ),
                        ),
                      )
                    : Text(
                        _getPaymentStatus(order.paymentMethod)['statusText']!,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFFF6B35),
                        ),
                      ),
              ],
            ),
          ),
          
          // Status and Cancel Order Button (only for active orders)
          if (order.status.toLowerCase() == 'active') ...[
            const SizedBox(height: 16),
            Row(
              children: [
                // Driver Status
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF1E6),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFFFD9A0), width: 1),
                    ),
                    child: const Text(
                      'Finding driver',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFFF6B35),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Cancel Order Button
                SizedBox(
                  width: 120,
                  child: ElevatedButton(
                    onPressed: () => _showCancelOrderDialog(order),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B35),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Cancel Order',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _showCancelOrderDialog(OrderModel order) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final account = auth.currentAccount;
    final userName = account?.name ?? 'User';

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Cancel Order',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2D2D2D),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$userName, are you sure you want to cancel this order?',
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF2D2D2D),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF4E3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFD9A0), width: 1),
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
                    order.orderCode,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFFF6B35),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'No',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF7A7A7A),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'Yes',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );

    if (result == true) {
      // Cancel the order
      await OrderDatabaseHelper.instance.updateOrderStatus(order.id, 'cancelled');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order cancelled successfully'),
            backgroundColor: Color(0xFFFF6B35),
            duration: Duration(seconds: 2),
          ),
        );
        
        // Reload orders
        _loadOrders();
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return const Color(0xFFFF6B35);
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
