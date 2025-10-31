import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const SizedBox(height: 56),
              // Logo hoặc illustration ảnh lớn theo figma, tạm thay bằng icon đại diện
              const Icon(Icons.food_bank, size: 120, color: Color(0xFFFF6B35)),
              const SizedBox(height: 40),
              const Text(
                'Welcome to Yummy!',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF242424)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Order delicious food from top local restaurants! Discover new flavors right at home.',
                style: TextStyle(fontSize: 18, color: Color(0xFF757575)),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B35),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () {
                    context.go('/login');
                  },
                  child: const Text('Log in', style: TextStyle(fontSize: 20, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFFF6B35), width: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () {
                    context.go('/signup');
                  },
                  child: const Text('Sign up', style: TextStyle(fontSize: 20, color: Color(0xFFFF6B35))),
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
