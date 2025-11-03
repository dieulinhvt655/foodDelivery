import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/voucher_model.dart';
import '../../../core/providers/cart_provider.dart';

class VoucherDialog extends StatelessWidget {
  const VoucherDialog({super.key});

  static final List<VoucherModel> vouchers = [
    VoucherModel(
      id: '1',
      name: '36% discount for customers from Thanh Hoa',
      description: '36% discount',
      type: VoucherType.percentage,
      value: 36,
      requiresThanhHoa: true,
    ),
    VoucherModel(
      id: '2',
      name: '\$2 off on orders over \$36',
      description: '\$2 off',
      type: VoucherType.fixed,
      value: 2,
      minOrderAmount: 36,
    ),
    VoucherModel(
      id: '3',
      name: 'Free shipping on orders over \$136',
      description: 'Free shipping',
      type: VoucherType.freeShipping,
      value: 0,
      minOrderAmount: 136,
    ),
    VoucherModel(
      id: '4',
      name: '36-hour flash sale',
      description: '\$3.6 off',
      type: VoucherType.fixed,
      value: 3.6,
    ),
    VoucherModel(
      id: '5',
      name: 'Discount in celebration of Vietnamese Women\'s Day (October 20th)',
      description: 'Special discount',
      type: VoucherType.percentage,
      value: 20,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final subtotal = cartProvider.subtotal;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 550),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Select Voucher - Apply',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2D2D2D),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Color(0xFF2D2D2D)),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: vouchers.length,
                itemBuilder: (context, index) {
                  final voucher = vouchers[index];
                  final canApply = voucher.canBeApplied(subtotal);
                  final isApplied = cartProvider.appliedVoucher?.id == voucher.id;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isApplied
                            ? const Color(0xFFFF6B35)
                            : canApply
                                ? const Color(0xFFFFE0B3)
                                : Colors.grey[300]!,
                        width: isApplied ? 2 : 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  voucher.name,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: canApply
                                        ? const Color(0xFF2D2D2D)
                                        : Colors.grey[600]!,
                                  ),
                                ),
                                if (voucher.minOrderAmount != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'Min order: \$${voucher.minOrderAmount!.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 80,
                            height: 32,
                            child: ElevatedButton(
                              onPressed: canApply
                                  ? () {
                                      if (isApplied) {
                                        cartProvider.removeVoucher();
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Voucher removed'),
                                            backgroundColor: Color(0xFFFF6B35),
                                          ),
                                        );
                                      } else {
                                        final success = cartProvider.applyVoucher(voucher);
                                        if (success) {
                                          Navigator.of(context).pop();
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Applied: ${voucher.name}'),
                                              backgroundColor: const Color(0xFFFF6B35),
                                            ),
                                          );
                                        }
                                      }
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isApplied
                                    ? const Color(0xFFFF6B35)
                                    : canApply
                                        ? const Color(0xFFFF6B35)
                                        : Colors.grey[300],
                                foregroundColor: isApplied || canApply
                                    ? Colors.white
                                    : Colors.grey[600],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                isApplied ? 'Applied' : 'Apply',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

