import 'package:flutter/material.dart';
import 'package:kultux/features/search/activity_search_page.dart';
import 'package:kultux/features/search/restaurant_search_page.dart';
import 'package:kultux/features/search/accommodation_search_page.dart';

import 'package:kultux/shared/widget/page_header.dart';

class SearchPage extends StatefulWidget {
  final Function(dynamic)? onSelectedDetail;
  final int selectedIndex;
  final Function(int) onIndexChanged;
  const SearchPage({
    super.key,
    this.onSelectedDetail,
    required this.selectedIndex,
    required this.onIndexChanged,
  });

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late int _selectedIndex = 0;

  final List<String> _categories = [
    "Actividades",
    "Restaurantes",
    "Alojamientos",
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PageHeader(
          title: 'Buscar ${_categories[_selectedIndex]}',
          subtitle: 'Conoce Extremadura',
          showRightImage: true,
        ),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              _categories.length,
              (index) => GestureDetector(
                onTap: () => setState(() {
                  _selectedIndex = index;
                  widget.onIndexChanged(index);
                }),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _selectedIndex == index
                        ? Color.fromARGB(255, 166, 226, 70)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _categories[index],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _selectedIndex == index
                          ? Colors.black
                          : Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        Expanded(child: _buildContent()),
      ],
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return ActivitySearchPage(
          onSelectedDetail: widget.onSelectedDetail,
        );
      case 1:
        return RestaurantSearchPage(
          onSelectedDetail: widget.onSelectedDetail,
        );
      case 2:
        return AccommodationSearchPage(
          onSelectedDetail: widget.onSelectedDetail,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
