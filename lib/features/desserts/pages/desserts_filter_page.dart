import 'package:flutter/material.dart';

class DessertsFilterResult {
  final Set<String> options;
  final RangeValues priceRange;
  const DessertsFilterResult({required this.options, required this.priceRange});
}

class DessertsFilterPage extends StatefulWidget {
  const DessertsFilterPage({super.key});

  @override
  State<DessertsFilterPage> createState() => _DessertsFilterPageState();
}

class _DessertsFilterPageState extends State<DessertsFilterPage> {
  final List<String> _options = [
    'Cake', 'Cupcake', 'Donut', 'Ice Cream', 'Pudding', 'Brownie', 'Pie'
  ];
  final Set<String> _selected = {};
  RangeValues _price = const RangeValues(5, 50);
  static const double _minPrice = 0;
  static const double _maxPrice = 100;

  void _reset() {
    setState(() {
      _selected.clear();
      _price = const RangeValues(5, 50);
    });
  }

  void _apply() {
    Navigator.of(context).pop(
      DessertsFilterResult(options: _selected, priceRange: _price),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text('Desserts Filter', style: TextStyle(color: Color(0xFF2D2D2D))),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2D2D2D)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: _reset,
            child: const Text('Reset', style: TextStyle(color: Color(0xFFFF6B35), fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Categories',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D2D2D)),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _options.map((o) => _FilterChip(
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
              const SizedBox(height: 24),
              const Text(
                'Price Range',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D2D2D)),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _priceBadge(_price.start),
                  _priceBadge(_price.end),
                ],
              ),
              RangeSlider(
                values: _price,
                min: _minPrice,
                max: _maxPrice,
                divisions: 20,
                activeColor: const Color(0xFFFF6B35),
                inactiveColor: const Color(0xFFFFE0D1),
                labels: RangeLabels(
                  '${_price.start.toStringAsFixed(0)}',
                  '${_price.end.toStringAsFixed(0)}',
                ),
                onChanged: (v) {
                  setState(() { _price = v; });
                },
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
                  onPressed: _apply,
                  child: const Text('Apply', style: TextStyle(fontSize: 20, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
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
