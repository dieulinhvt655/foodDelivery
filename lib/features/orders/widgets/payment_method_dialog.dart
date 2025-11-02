import 'package:flutter/material.dart';

class PaymentMethodDialog extends StatelessWidget {
  final String? selectedMethod;
  final Function(String) onSelect;
  final double? orderTotal;

  const PaymentMethodDialog({
    super.key,
    this.selectedMethod,
    required this.onSelect,
    this.orderTotal,
  });

  static final List<Map<String, dynamic>> paymentMethods = const [
    {
      'title': 'Credit Card',
      'icon': Icons.credit_card,
      'subtitle': 'Credit/Debit card',
      'id': 'card',
      'requiresLink': true,
      'errorMessage': 'Your account has not been linked to a credit card.',
    },
    {
      'title': 'ZaloPay',
      'icon': Icons.account_balance_wallet,
      'subtitle': 'ZaloPay e-wallet',
      'id': 'zalopay',
      'requiresLink': true,
      'errorMessage': 'Your account has not been linked to ZaloPay.',
    },
    {
      'title': 'Momo',
      'icon': Icons.account_balance_wallet,
      'subtitle': 'Momo e-wallet',
      'id': 'momo',
      'requiresLink': true,
      'errorMessage': 'Your account has not been linked to Momo.',
    },
    {
      'title': 'Cash on Delivery',
      'icon': Icons.local_shipping,
      'subtitle': 'COD - Cash on Delivery',
      'id': 'cod',
      'requiresLink': false,
    },
    {
      'title': 'QR Code Payment',
      'icon': Icons.qr_code,
      'subtitle': 'Scan QR code to pay',
      'id': 'qr',
      'requiresLink': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 500),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔧 Sửa đoạn Row ở đây
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Choose Payment Method',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2D2D2D),
                    ),
                    overflow: TextOverflow.ellipsis, // tránh tràn
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
                itemCount: paymentMethods.length,
                itemBuilder: (context, index) {
                  final method = paymentMethods[index];
                  final methodId = method['id'] as String;
                  final isSelected = selectedMethod == methodId;
                  final isLast = index == paymentMethods.length - 1;

                  return Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          final method = paymentMethods.firstWhere(
                            (m) => m['id'] == methodId,
                          );
                          final requiresLink = method['requiresLink'] as bool? ?? false;
                          
                          if (requiresLink) {
                            // Show error dialog - show on top of current dialog
                            showDialog(
                              context: context,
                              barrierDismissible: true,
                              builder: (dialogContext) => AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                title: const Text(
                                  'Payment Method Not Linked',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF2D2D2D),
                                  ),
                                ),
                                content: Text(
                                  method['errorMessage'] as String,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF6F6F6F),
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(dialogContext).pop(); // Close error dialog
                                    },
                                    child: const Text(
                                      'OK',
                                      style: TextStyle(
                                        color: Color(0xFFFF6B35),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            // Select payment method (COD or QR)
                            onSelect(methodId);
                            Navigator.of(context).pop();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFFFF4E3)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFFFF6B35)
                                  : const Color(0xFFFFE0B3),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF4E3),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  method['icon'] as IconData,
                                  color: const Color(0xFFFF6B35),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      method['title'] as String,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF333333),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      method['subtitle'] as String,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF666666),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              if (isSelected)
                                const Icon(
                                  Icons.check_circle,
                                  color: Color(0xFFFF6B35),
                                  size: 24,
                                ),
                            ],
                          ),
                        ),
                      ),
                      if (!isLast) const SizedBox(height: 12),
                    ],
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
