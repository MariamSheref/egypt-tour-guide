import 'package:flutter/material.dart';
import '../models/heritage_place.dart';

class CategoryChips extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onSelected;

  const CategoryChips({
    super.key,
    required this.selectedCategory,
    required this.onSelected,
  });

  static const _icons = <String, IconData>{
    'All Sites': Icons.explore,
    'Museums': Icons.account_balance,
    'Temples': Icons.temple_hindu,
    'Mosques': Icons.mosque,
    'Monuments': Icons.location_city,
  };

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 46,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: HeritagePlace.categories.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (context, index) {
            final category = HeritagePlace.categories[index];
            final selected = category == selectedCategory;
            return ChoiceChip(
              avatar: Icon(_icons[category], size: 17,
                  color: selected ? Colors.white : Colors.black87),
              label: Text(category),
              selected: selected,
              showCheckmark: false,
              selectedColor: const Color(0xff7c571e),
              labelStyle: TextStyle(color: selected ? Colors.white : Colors.black87),
              onSelected: (_) => onSelected(category),
            );
          },
        ),
      );
}
