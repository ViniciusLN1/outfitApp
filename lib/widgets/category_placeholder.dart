import 'package:flutter/material.dart';

import '../controllers/constructor_controller.dart';

class CategoryPlaceholder extends StatelessWidget {
  final ClothingCategory category;
  final bool isOccupied;

  const CategoryPlaceholder({
    super.key,
    required this.category,
    required this.isOccupied,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) =>
          FadeTransition(opacity: animation, child: child),
      child: isOccupied
          ? const SizedBox.shrink(key: ValueKey('occupied'))
          : Container(
              key: const ValueKey('empty'),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey.shade400,
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  category.name[0].toUpperCase() + category.name.substring(1),
                  style: TextStyle(color: Colors.grey.shade500),
                ),
              ),
            ),
    );
  }
}
