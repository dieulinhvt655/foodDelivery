import 'package:flutter/material.dart';

class ProfileDrawer extends StatelessWidget {
  const ProfileDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFFF6B35),
      child: SafeArea(
        child: Column(
          children: [
            // Close button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
            
            // Profile section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'John Smith',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Loremipsum@email.com',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Menu items
            Expanded(
              child: Column(
                children: [
                  _buildMenuItem(Icons.shopping_bag, 'My Orders', () {}),
                  Divider(color: Colors.white.withValues(alpha: 0.2), height: 1),
                  _buildMenuItem(Icons.person_outline, 'My Profile', () {}),
                  Divider(color: Colors.white.withValues(alpha: 0.2), height: 1),
                  _buildMenuItem(Icons.location_on, 'Delivery Address', () {}),
                  Divider(color: Colors.white.withValues(alpha: 0.2), height: 1),
                  _buildMenuItem(Icons.credit_card, 'Payment Methods', () {}),
                  Divider(color: Colors.white.withValues(alpha: 0.2), height: 1),
                  _buildMenuItem(Icons.phone, 'Contact Us', () {}),
                  Divider(color: Colors.white.withValues(alpha: 0.2), height: 1),
                  _buildMenuItem(Icons.help_outline, 'Help & FAQs', () {}),
                  Divider(color: Colors.white.withValues(alpha: 0.2), height: 1),
                  _buildMenuItem(Icons.settings, 'Settings', () {}),
                  Divider(color: Colors.white.withValues(alpha: 0.2), height: 1),
                  _buildMenuItem(Icons.logout, 'Log Out', () {
                    // Handle logout
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

