import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/home_provider.dart';
import '../widgets/category_chip.dart';
import '../widgets/best_seller_card.dart';
import '../widgets/promo_banner.dart';
import '../widgets/recommend_card.dart';
import '../../profile/widgets/profile_drawer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedCategoryIndex = 0;
  
  final List<Map<String, String>> categories = [
    {'title': 'Snacks', 'icon': 'assets/icons/chip-home/Snacks.svg'},
    {'title': 'Meal', 'icon': 'assets/icons/chip-home/Meals.svg'},
    {'title': 'Vegan', 'icon': 'assets/icons/chip-home/Vegan.svg'},
    {'title': 'Dessert', 'icon': 'assets/icons/chip-home/Desserts.svg'},
    {'title': 'Drinks', 'icon': 'assets/icons/chip-home/Drinks.svg'},
  ];

  final List<Map<String, String>> bestSellers = [
    {'name': 'Sushi Roll', 'price': '\$103.0', 'image': 'assets/images/dishes-square/Rectangle 128.svg'},
    {'name': 'Curry Rice', 'price': '\$50.0', 'image': 'assets/images/dishes-square/Rectangle 128-1.svg'},
    {'name': 'Lasagna', 'price': '\$12.99', 'image': 'assets/images/dishes-square/Rectangle 128-2.svg'},
    {'name': 'Berry Cupcake', 'price': '\$8.20', 'image': 'assets/images/dishes-square/Rectangle 133.svg'},
  ];

  final List<Map<String, String>> recommends = [
    {'name': 'Chicken Burger', 'price': '\$10.0', 'rating': '5.0', 'image': 'assets/images/dishes-square/Rectangle 128.svg'},
    {'name': 'Spring Rolls', 'price': '\$25.0', 'rating': '5.0', 'image': 'assets/images/dishes-square/Rectangle 128-1.svg'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeProvider>().loadRestaurants();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const ProfileDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
          children: [
              // Yellow Header Section
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFFFB800),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    // Search Bar
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: const TextField(
                                decoration: InputDecoration(
                                  hintText: 'Search',
                                  hintStyle: TextStyle(
                                    color: Color(0xFF999999),
                                    fontSize: 16,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.search,
                                    color: Color(0xFFFF6B35),
                                    size: 24,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                ),
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF2D2D2D),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Cart Icon
                          Container(
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
                              Icons.shopping_cart_outlined,
                              color: Color(0xFFFF6B35),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Bell Icon
                          Container(
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
                          const SizedBox(width: 8),
                          // Profile Icon
                          Container(
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
                              Icons.person_outline,
                              color: Color(0xFFFF6B35),
                              size: 24,
                  ),
            ),
          ],
        ),
                    ),
                    // Greeting
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Good Morning',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D2D2D),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Rise And Shine! It\'s Breakfast Time',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFFFF6B35),
                              ),
          ),
        ],
      ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Category Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Category',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D2D2D),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedCategoryIndex = index;
                                });
                              },
                              child: Column(
        children: [
                                  Container(
                                    width: 70,
                                    height: 70,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: selectedCategoryIndex == index
                                            ? const Color(0xFFFF6B35)
                                            : const Color(0xFFFF6B35).withValues(alpha: 0.3),
                                        width: selectedCategoryIndex == index ? 3 : 1,
                                      ),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        index == 0
                                            ? Icons.fastfood
                                            : index == 1
                                                ? Icons.restaurant
                                                : index == 2
                                                    ? Icons.eco
                                                    : index == 3
                                                        ? Icons.cake
                                                        : Icons.local_drink,
                                        color: const Color(0xFFFF6B35),
                                        size: 30,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    categories[index]['title']!,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: selectedCategoryIndex == index
                                          ? const Color(0xFFFF6B35)
                                          : const Color(0xFF666666),
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
              
              const SizedBox(height: 24),
              
              // Best Seller Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Best Seller',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D2D2D),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {},
                          child: const Row(
                            children: [
                              Text(
                                'View All',
                                style: TextStyle(
                                  color: Color(0xFFFF6B35),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: Color(0xFFFF6B35),
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: bestSellers.length,
                  itemBuilder: (context, index) {
                          return BestSellerCard(
                            imagePath: bestSellers[index]['image']!,
                            price: bestSellers[index]['price']!,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Promo Banner
              const PromoBanner(),
              
              const SizedBox(height: 24),
              
              // Recommend Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Recommend',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D2D2D),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 180,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: recommends.length,
                        itemBuilder: (context, index) {
                          return RecommendCard(
                            imagePath: recommends[index]['image']!,
                            price: recommends[index]['price']!,
                            rating: recommends[index]['rating']!,
                );
              },
            ),
          ),
        ],
      ),
              ),
              
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFF6B35),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              spreadRadius: 0,
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
                _buildNavItem(Icons.home, true, () {}),
                _buildNavItem(Icons.restaurant, false, () {}),
                _buildNavItem(Icons.favorite_outline, false, () {}),
                _buildNavItem(Icons.list_alt, false, () {}),
                _buildNavItem(Icons.person_outline, false, () {
                  Scaffold.of(context).openDrawer();
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, bool isSelected, VoidCallback onTap) {
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