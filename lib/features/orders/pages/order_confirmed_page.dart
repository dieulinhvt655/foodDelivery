import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OrderConfirmedPage extends StatefulWidget {
  final DateTime deliveryDate;
  
  const OrderConfirmedPage({
    super.key,
    required this.deliveryDate,
  });

  @override
  State<OrderConfirmedPage> createState() => _OrderConfirmedPageState();
}

class _OrderConfirmedPageState extends State<OrderConfirmedPage> with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize fade animation
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));
    
    // Start fade out after 1.5 seconds (total 2 seconds: 1.5s wait + 0.5s fade)
    Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        _fadeController.forward();
        // Navigate after fade completes
        Timer(const Duration(milliseconds: 500), () {
          if (mounted) {
            context.go('/home');
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  String _getDeliveryDate() {
    final deliveryDate = widget.deliveryDate;
    
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    
    final weekday = weekdays[deliveryDate.weekday - 1];
    final day = deliveryDate.day;
    final hour = deliveryDate.hour;
    final minute = deliveryDate.minute;
    
    final hour12 = hour > 12 ? hour - 12 : hour;
    final amPm = hour >= 12 ? 'PM' : 'AM';
    final minuteStr = minute.toString().padLeft(2, '0');
    
    return 'Delivery by $weekday, ${day}th, $hour12:$minuteStr $amPm';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A), // Dark gray background
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFFFB800), // Light yellow content area
          borderRadius: BorderRadius.all(Radius.circular(28)),
        ),
        margin: const EdgeInsets.all(16),
        child: SafeArea(
          child: Column(
            children: [
              // Header (no back button)
              const SizedBox(height: 20),
              
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      
                      // Confirmation Graphic
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          // Large hollow orange circle
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFFFF6B35),
                                width: 4,
                              ),
                            ),
                          ),
                          // Small solid orange circle
                          Container(
                            width: 60,
                            height: 60,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFF6B35),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Order Confirmed Text
                      const Text(
                        '¡Order Confirmed!',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2D2D2D),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Confirmation Message
                      const Text(
                        'Your order has been placed successfully',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF2D2D2D),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Delivery Details
                      Text(
                        _getDeliveryDate(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF2D2D2D),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Track Order Button
                      GestureDetector(
                        onTap: () => context.go('/orders'),
                        child: const Text(
                          'Track my order',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFFF6B35),
                            decoration: TextDecoration.underline,
                            decorationColor: Color(0xFFFF6B35),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 60),
                    ],
                  ),
                ),
              ),
              
              // Footer
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'If you have any questions, please reach out directly to our customer support',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[700],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}

