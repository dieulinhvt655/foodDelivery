import 'package:flutter/material.dart';
import '../../../core/database/food_database_helper.dart';
import '../../../core/models/food_model.dart';
import 'dart:async';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SearchResultsPage extends StatefulWidget {
  final String initialQuery;
  const SearchResultsPage({super.key, this.initialQuery = ''});

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  final FoodDatabaseHelper _db = FoodDatabaseHelper.instance;
  final TextEditingController _controller = TextEditingController();
  List<FoodModel> _results = [];
  bool _isLoading = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller.text = widget.initialQuery;
    _search(widget.initialQuery);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search(String q) async {
    setState(() => _isLoading = true);
    final items = q.trim().isEmpty ? <FoodModel>[] : await _db.searchFoods(q.trim());
    if (!mounted) return;
    setState(() {
      _results = items;
      _isLoading = false;
    });
  }

  void _onSubmitted(String q) {
    _search(q);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFB800),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            decoration: const BoxDecoration(
              color: Color(0xFFFFB800),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: Color(0xFFFF6B35)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              textInputAction: TextInputAction.search,
                              decoration: const InputDecoration(
                                hintText: 'Search foods...',
                                border: InputBorder.none,
                              ),
                              onSubmitted: _onSubmitted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF6B35)))
                  : _results.isEmpty
                      ? const Center(child: Text('No results'))
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemBuilder: (context, index) {
                            final f = _results[index];
                            return InkWell(
                              onTap: () {
                                context.push('/food/${f.id}');
                              },
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFFFE0B3), width: 1),
                                ),
                                child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: SizedBox(
                                      width: 64,
                                      height: 64,
                                      child: () {
                                        final img = f.image;
                                        if (img.startsWith('http')) {
                                          return Image.network(
                                            img,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stack) => Container(
                                              color: const Color(0xFFFFF4E3),
                                              child: const Icon(Icons.fastfood, color: Color(0xFFFF6B35)),
                                            ),
                                          );
                                        }
                                        if (img.toLowerCase().endsWith('.svg')) {
                                          return SvgPicture.asset(img, fit: BoxFit.cover);
                                        }
                                        return Image.asset(
                                          img,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stack) => Container(
                                            color: const Color(0xFFFFF4E3),
                                            child: const Icon(Icons.fastfood, color: Color(0xFFFF6B35)),
                                          ),
                                        );
                                      }(),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(f.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF2D2D2D))),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(Icons.star, size: 16, color: Color(0xFFFFC107)),
                                            const SizedBox(width: 4),
                                            Text(f.rating.toStringAsFixed(1), style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text('\$' + f.price.toStringAsFixed(2), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFFFF6B35))),
                                ],
                              ),
                              ),
                            );
                          },
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemCount: _results.length,
                        ),
            ),
          ),
        ],
      ),
    );
  }
}


