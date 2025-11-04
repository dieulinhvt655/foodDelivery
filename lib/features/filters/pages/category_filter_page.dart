import 'package:flutter/material.dart';
import '../../foods/pages/filtered_foods_page.dart';

class CategoryFilterResult {
  final String category;
  final Set<String> options;
  final RangeValues? priceRange;
  final int? minRating;
  const CategoryFilterResult({required this.category, required this.options, this.priceRange, this.minRating});
}

class CategoryFilterPage extends StatefulWidget {
  final String category;
  const CategoryFilterPage({super.key, required this.category});

  @override
  State<CategoryFilterPage> createState() => _CategoryFilterPageState();
}

class _CategoryFilterPageState extends State<CategoryFilterPage> {
  late String _currentCategory;

  // Option sets per category (aligned to examples from Figma description)
  late final Map<String, List<String>> optionSets = {
    'Snacks': ['Bruschetta', 'Spring Rolls', 'Crepes', 'Wings', 'Skewers', 'Salmon', 'Baked'],
    'Meal': ['Burger', 'Pizza', 'Pasta', 'Sushi', 'Rice Bowl', 'Steak'],
    'Vegan': ['Salad', 'Tofu', 'Vegan Burger', 'Vegan Pizza', 'Wraps'],
    'Dessert': ['Cake', 'Cupcake', 'Donut', 'Ice Cream', 'Pudding', 'Brownie', 'Pie'],
    'Drink': ['Coffee', 'Tea', 'Juice', 'Smoothie', 'Soda', 'Milkshake'],
  };

  final Set<String> _selected = {};
  RangeValues _price = const RangeValues(10, 60);
  static const double _minPrice = 1;
  static const double _maxPrice = 100;
  int _minRating = 0; // default: no selection

  bool get _showPrice => _currentCategory == 'Meal' || _currentCategory == 'Dessert' || _currentCategory == 'Drink' || _currentCategory == 'Snacks' || _currentCategory == 'Vegan';

  @override
  void initState() {
    super.initState();
    _currentCategory = _normalizeCategory(widget.category);
  }

  String _normalizeCategory(String raw) {
    switch (raw.toLowerCase()) {
      case 'snacks':
        return 'Snacks';
      case 'meal':
      case 'meals':
        return 'Meal';
      case 'vegan':
        return 'Vegan';
      case 'dessert':
      case 'desserts':
        return 'Dessert';
      case 'drink':
      case 'drinks':
        return 'Drink';
      default:
        return 'Snacks';
    }
  }

  void _reset() {
    setState(() {
      _selected.clear();
      _price = const RangeValues(10, 60);
      _minRating = 0;
    });
  }

  void _apply() {
    // Navigate directly to results so back returns here (Filter page)
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FilteredFoodsPage(
          category: _currentCategory,
          options: _selected,
          priceMin: _showPrice ? _price.start : null,
          priceMax: _showPrice ? _price.end : null,
          minRating: _minRating > 0 ? _minRating : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<String> options = optionSets[_currentCategory] ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Yellow header with centered Filter title and actions
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: const BoxDecoration(
                color: Color(0xFFFFB800),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  // Back
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(Icons.arrow_back_ios_new, color: Color(0xFFFF6B35)),
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'Filter',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFFFFF),
                    ),
                  ),
                  const Spacer(),
                  // Empty space to balance the back button
                  const SizedBox(width: 44),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category icon row (quick switch)
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _categoryIcon('Snacks', Icons.fastfood),
                        _categoryIcon('Meal', Icons.restaurant),
                        _categoryIcon('Vegan', Icons.eco),
                        _categoryIcon('Dessert', Icons.cake),
                        _categoryIcon('Drink', Icons.local_drink),
                      ],
                    ),

                    const SizedBox(height: 24),
                    // Sort by Top Rated (interactive)
                    Row(
                      children: [
                        const Text(
                          'Top Rated',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2D2D2D),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ...List.generate(5, (index) {
                          final starIndex = index + 1;
                          final filled = starIndex <= _minRating;
                          return GestureDetector(
                            onTap: () {
                              setState(() { _minRating = starIndex; });
                            },
                            child: Icon(
                              filled ? Icons.star : Icons.star_border,
                              size: 18,
                              color: const Color(0xFFFFB800),
                            ),
                          );
                        }),
                        if (_minRating > 0) ...[
                          const SizedBox(width: 8),
                          Text(
                            _minRating == 5 ? '5' : '${_minRating}+',
                            style: const TextStyle(color: Color(0xFF666666)),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 20),
                    const Text(
                      'Categories',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D2D2D)),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: options.map((o) => _FilterChip(
                        label: o,
                        selected: _selected.contains(o),
                        onTap: () {
                          setState(() {
                            if (_selected.contains(o)) {
                              _selected.remove(o);
                            } else {
                              _selected.add(o);
                            }
                          });
                        },
                      )).toList(),
                    ),

                    if (_showPrice) ...[
                      const SizedBox(height: 24),
                      const Text(
                        'Price',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D2D2D)),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_formatPrice(_price.start), style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2D2D2D))),
                          Text(_formatPrice(_price.end), style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2D2D2D))),
                        ],
                      ),
                      RangeSlider(
                        values: _price,
                        min: _minPrice,
                        max: _maxPrice,
                        divisions: 99,
                        activeColor: const Color(0xFFFF6B35),
                        inactiveColor: const Color(0xFFFFE0D1),
                        onChanged: (v) {
                          // Force integer steps 1..100
                          final start = v.start.round().toDouble().clamp(_minPrice, _maxPrice);
                          final end = v.end.round().toDouble().clamp(_minPrice, _maxPrice);
                          setState(() { _price = RangeValues(start, end); });
                        },
                      ),
                      const SizedBox(height: 6),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('\$1', style: TextStyle(color: Color(0xFF888888), fontSize: 12)),
                          Text('\$50', style: TextStyle(color: Color(0xFF888888), fontSize: 12)),
                          Text('\$100+', style: TextStyle(color: Color(0xFF888888), fontSize: 12)),
                        ],
                      ),
                    ],

                    const SizedBox(height: 64),
                    Center(
                      child: FractionallySizedBox(
                        widthFactor: 0.5,
                        child: SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF6B35),
                              shape: const StadiumBorder(),
                            ),
                            onPressed: _apply,
                            child: const Text('Apply', style: TextStyle(fontSize: 20, color: Colors.white)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoryIcon(String label, IconData icon) {
    final bool isActive = _currentCategory == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentCategory = label;
          _selected.clear();
        });
      },
      child: Column(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1E6),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFFF6B35), width: isActive ? 3 : 1),
            ),
            child: Icon(icon, color: const Color(0xFFFF6B35)),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isActive ? const Color(0xFFFF6B35) : const Color(0xFF666666),
            ),
          ),
        ],
      ),
    );
  }

  Widget _priceBadge(double value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Text('${value.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }

  String _formatPrice(double v) {
    final intVal = v.round();
    if (intVal >= 100) return '100+';
    return '${intVal.toString()}';
  }

  double _snapToMilestone(double value) {
    if (value >= 75) return 100;
    if (value >= 25) return 50;
    return 1;
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFF6B35) : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: selected ? const Color(0xFFFF6B35) : const Color(0xFFE0E0E0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : const Color(0xFF555555),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
