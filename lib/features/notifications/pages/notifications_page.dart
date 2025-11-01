import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<_AppNotification> notifications = const [
      _AppNotification(
        title: 'Chúng tôi vừa thêm một sản phẩm có thể bạn sẽ thích.',
        icon: Icons.new_releases_outlined,
      ),
      _AppNotification(
        title: 'Món bạn thích đang giảm giá – đặt ngay trước khi hết ưu đãi!',
        icon: Icons.local_offer_outlined,
      ),
      _AppNotification(
        title: 'Thử ngay hương vị mới từ quán yêu thích của bạn.',
        icon: Icons.restaurant_menu_outlined,
      ),
      _AppNotification(
        title: 'Đơn hàng của bạn đã được giao thành công.',
        icon: Icons.check_circle_outline,
      ),
      _AppNotification(
        title: 'Đơn giao hàng đang trên đường giao tới bạn.',
        icon: Icons.delivery_dining_outlined,
      ),
    ];

    return SafeArea(
      right: false,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          color: const Color(0xFFE95322),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(70),
            bottomLeft: Radius.circular(70)
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(-2, 0),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 50),
                      const Icon(
                        Icons.notifications_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Notifications',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            // Notifications List
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: notifications.length,
                separatorBuilder: (_, __) => const Divider(
                  color: Colors.white,
                  height: 1,
                  thickness: 1,
                ),
                itemBuilder: (context, index) {
                  final item = notifications[index];
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {},
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(item.icon, color: const Color(0xFFE95322), size: 32),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                item.title,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
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

class _AppNotification {
  final String title;
  final IconData icon;

  const _AppNotification({required this.title, required this.icon});
}


