import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PaymentMethodsPage extends StatelessWidget {
  const PaymentMethodsPage({super.key});

  final List<Map<String, dynamic>> _paymentMethods = const [
    {
      'title': 'Thanh toán bằng thẻ',
      'icon': Icons.credit_card,
      'subtitle': 'Thẻ tín dụng/ghi nợ',
    },
    {
      'title': 'Thanh toán bằng ZaloPay',
      'icon': Icons.account_balance_wallet,
      'subtitle': 'Ví điện tử ZaloPay',
    },
    {
      'title': 'Thanh toán qua Momo',
      'icon': Icons.account_balance_wallet,
      'subtitle': 'Ví điện tử Momo',
    },
    {
      'title': 'Thanh toán khi nhận hàng',
      'icon': Icons.local_shipping,
      'subtitle': 'COD - Cash on Delivery',
    },
    {
      'title': 'Thanh toán bằng mã QR',
      'icon': Icons.qr_code,
      'subtitle': 'Quét mã QR để thanh toán',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFB800),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFB800),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFFFF6B35)),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Payment Methods',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: SafeArea(
          top: false,
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 8),
            itemCount: _paymentMethods.length,
            itemBuilder: (context, index) {
              final method = _paymentMethods[index];
              final isLast = index == _paymentMethods.length - 1;
              return Padding(
                padding: EdgeInsets.only(
                  bottom: isLast ? 0 : 19, // 0.5cm ≈ 19 pixels
                ),
                child: _PaymentMethodCard(
                  title: method['title'] as String,
                  subtitle: method['subtitle'] as String,
                  icon: method['icon'] as IconData,
                  showDivider: !isLast,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  const _PaymentMethodCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.showDivider,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon on the left
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4E3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFFFF6B35),
                  size: 24,
                ),
              ),
              const SizedBox(width: 20),
              // Payment method info in the middle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title (bold, dark gray)
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Subtitle (lighter gray, smaller font)
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Arrow icon on the right
              const Icon(
                Icons.chevron_right,
                color: Color(0xFFFF6B35),
                size: 24,
              ),
            ],
          ),
        ),
        // Divider (light orange)
        if (showDivider)
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 30),
            color: const Color(0xFFFFE0B3),
          ),
      ],
    );
  }
}
