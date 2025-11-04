import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFF6B35),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context,
                Icons.home,
                currentIndex == 0,
                () {
                  context.go('/home');
                },
              ),
              _buildNavItem(
                context,
                Icons.restaurant,
                currentIndex == 1,
                () {
                  context.go('/restaurants');
                },
              ),
              _buildNavItem(
                context,
                Icons.favorite_outline,
                currentIndex == 2,
                () {
                  context.go('/favorites');
                },
              ),
              _buildNavItem(
                context,
                Icons.list_alt,
                currentIndex == 3,
                () {
                  context.go('/foods');
                },
              ),
              _buildNavItem(
                context,
                Icons.person_outline,
                currentIndex == 4,
                () {
                  context.go('/profile');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isSelected ? const Color(0xFFFF6B35) : Colors.white,
          size: 28,
        ),
      ),
    );
  }
}

