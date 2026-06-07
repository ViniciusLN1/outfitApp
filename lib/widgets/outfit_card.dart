import 'package:flutter/material.dart';

import '../database/app_database.dart';

class OutfitCard extends StatelessWidget {
  final Outfit outfit;
  final VoidCallback onFavorite;
  final VoidCallback onEdit;

  const OutfitCard({
    super.key,
    required this.outfit,
    required this.onFavorite,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Center(
              child: Text(
                outfit.name,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: Icon(
                  outfit.isFavorite == 1
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: outfit.isFavorite == 1 ? Colors.red : null,
                ),
                onPressed: onFavorite,
              ),
              TextButton.icon(
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('Editar'),
                onPressed: onEdit,
              ),
            ],
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}
