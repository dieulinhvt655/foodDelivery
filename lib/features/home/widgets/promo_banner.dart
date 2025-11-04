import 'package:flutter/material.dart';

class PromoBanner extends StatefulWidget {
  const PromoBanner({super.key});

  @override
  State<PromoBanner> createState() => _PromoBannerState();
}

class _PromoBannerState extends State<PromoBanner> {
  final PageController _pageController = PageController(viewportFraction: 1);
  int _current = 0;
  late final List<_BannerData> _banners;

  @override
  void initState() {
    super.initState();
    _banners = [
      _BannerData(
        title1: 'Taste the best',
        title2: 'grilled salmon',
        highlight: '18% OFF',
        image: 'assets/images/dishes-square/grilled_salmon.jpg',
      ),
      _BannerData(
        title1: 'Sweet treats',
        title2: 'for your day',
        highlight: 'Buy 1 Get 1',
        image: 'assets/images/dishes-square/berry_cheesecake.jpg',
      ),
      _BannerData(
        title1: 'Fresh & healthy',
        title2: 'vegan bowls',
        highlight: '36% OFF',
        image: 'assets/images/dishes-square/quinoa_kale_bowl.jpg',
      ),

    ];

    // No auto-advance; user action only (tap or swipe)
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            final next = (_current + 1) % _banners.length;
            _pageController.animateToPage(
              next,
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOut,
            );
          },
          child: SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _current = i),
            itemCount: _banners.length,
            itemBuilder: (context, index) {
              final b = _banners[index];
              return _buildBanner(context, b);
            },
          ),
        ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_banners.length, (i) => _buildIndicator(i == _current)),
        ),
      ],
    );
  }

  Widget _buildBanner(BuildContext context, _BannerData b) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFF6B35),
        borderRadius: BorderRadius.circular(24),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Right image
            Align(
                alignment: Alignment.centerRight,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.55,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(b.image),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
            ),
            // Left content panel
            Positioned.fill(
              left: 0,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.5,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  color: const Color(0xFFFF6B35),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        b.title1,
                        style: const TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        b.title2,
                        style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFB800),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          b.highlight,
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicator(bool active) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.symmetric(horizontal: 6),
      width: active ? 42 : 28,
      height: 8,
      decoration: BoxDecoration(
        color: active ? const Color(0xFFFF6B35) : const Color(0xFFEED9B9),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

class _BannerData {
  final String title1;
  final String title2;
  final String highlight;
  final String image;
  _BannerData({required this.title1, required this.title2, required this.highlight, required this.image});
}

