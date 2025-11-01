import 'package:flutter/material.dart';
import '../pages/notifications_page.dart';

class NotificationBell extends StatelessWidget {
  final EdgeInsetsGeometry? margin;
  const NotificationBell({super.key, this.margin});

  void _showNotificationsSidebar(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const NotificationsPage();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          )),
          child: Align(
            alignment: Alignment.centerRight,
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: GestureDetector(
        onTap: () => _showNotificationsSidebar(context),
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: const Color(0xFFFF6B35),
              width: 1,
            ),
          ),
          child: const Icon(
            Icons.notifications_outlined,
            color: Color(0xFFFF6B35),
            size: 24,
          ),
        ),
      ),
    );
  }
}


