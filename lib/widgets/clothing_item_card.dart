import 'dart:io';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

import '../database/app_database.dart';

class ClothingItemCard extends StatelessWidget {
  final ClothingItem item;
  final VoidCallback? onTap;

  const ClothingItemCard({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Expanded(
              child: ExtendedImage.file(
                File(item.imagePath),
                fit: BoxFit.contain,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                item.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
