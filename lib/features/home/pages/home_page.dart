import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/home_provider.dart';
import '../../../core/providers/cart_provider.dart';
import '../../filters/pages/category_filter_page.dart';
import '../widgets/best_seller_card.dart';
import '../widgets/promo_banner.dart';
import '../widgets/recommend_card.dart';
import '../../profile/widgets/profile_drawer.dart';
import '../../common/widgets/custom_bottom_nav_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int selectedCategoryIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

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
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String q) async {
    final keyword = q.trim();
    if (keyword.isEmpty) return;
    final encoded = Uri.encodeComponent(keyword);
    if (!mounted) return;
    _searchFocus.unfocus();
    context.push('/search?q=' + encoded);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawer: const ProfileDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header section
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
                    // Search bar
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: TextField(
                                controller: _searchController,
                                focusNode: _searchFocus,
                                decoration: InputDecoration(
                                  hintText: 'Search',
                                  hintStyle: const TextStyle(
                                    color: Color(0xFF999999),
                                    fontSize: 16,
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.search,
                                    color: Color(0xFFFF6B35),
                                    size: 24,
                                  ),
                                  suffixIcon: GestureDetector(
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 12),
                                      child: Image.asset(
                                        'assets/images/filter.png',
                                        width: 25,
                                        height: 18,
                                        color: Color(0xFFFF6B35),
                                      ),
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const CategoryFilterPage(
                                            category: 'Snacks',
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10,
                                  ),
                                ),
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF2D2D2D),
                                ),
                                onSubmitted: _performSearch,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              context.push('/cart');
                            },
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: const Icon(Icons.shopping_cart_outlined, color: Color(0xFFFF6B35)),
                            ),
                          ),
                          // Bell Icon
                          const SizedBox(width: 8),
                          // Notification
                          GestureDetector(
                            onTap: () {
                              context.push('/notifications');
                            },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Icon(Icons.notifications_active_outlined, color: Color(0xFFFF6B35)),
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
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFFFFFF),
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

              // Dynamic suggestions
              // Cart notification banner
              Consumer<CartProvider>(
                builder: (context, cartProvider, child) {
                  if (cartProvider.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GestureDetector(
                      onTap: () => context.push('/cart'),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF4E3),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFFF6B35),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.shopping_cart_outlined,
                              color: Color(0xFFFF6B35),
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Items in cart',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF2D2D2D),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Tap to continue ordering',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right,
                              color: Color(0xFFFF6B35),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // Category section
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
                                // Map index -> categoryId trong DB
                                final categoryId = index == 0
                                    ? 'cat_1' // Snacks
                                    : index == 1
                                        ? 'cat_2' // Meal
                                        : index == 2
                                            ? 'cat_3' // Vegan
                                            : index == 3
                                                ? 'cat_4' // Dessert
                                                : 'cat_5'; // Drinks
                                context.push('/foods?categoryId=$categoryId');
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

              // Best Seller
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

              // Promo banner
              PromoBanner(),

              const SizedBox(height: 24),

              // Recommend
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
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 0),
    );
  }

  // Widget _buildCircleIcon(IconData icon) {
  //   return Container(
  //     width: 50,
  //     height: 50,
  //     decoration: BoxDecoration(
  //       color: Colors.white.withValues(alpha: 0.3),
  //       borderRadius: BorderRadius.circular(25),
  //       border: Border.all(color: const Color(0xFFFF6B35), width: 1),
  //     ),
  //     child: Icon(icon, color: const Color(0xFFFF6B35), size: 24),
  //   );
  // }

}
