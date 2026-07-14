import 'dart:io';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

import '../../database/daos/stats_dao.dart';

/// Lista de barras horizontais proporcionais a partir de [LabelCount].
class BarList extends StatelessWidget {
  final List<LabelCount> entries;
  final String Function(String label)? labelFor;
  final Color Function(String label)? colorFor;
  const BarList({
    super.key,
    required this.entries,
    this.labelFor,
    this.colorFor,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (entries.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          'Sem dados.',
          style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13),
        ),
      );
    }
    final maxCount =
        entries.map((e) => e.count).fold<int>(1, (m, c) => c > m ? c : m);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          for (final e in entries)
            Semantics(
              label:
                  '${labelFor?.call(e.label) ?? e.label}: ${e.count}',
              child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  SizedBox(
                    width: 92,
                    child: Row(
                      children: [
                        if (colorFor != null) ...[
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: colorFor!(e.label),
                              shape: BoxShape.circle,
                              border: Border.all(color: scheme.outlineVariant),
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        Expanded(
                          child: Text(
                            labelFor?.call(e.label) ?? e.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 14,
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: e.count / maxCount,
                        child: Container(
                          decoration: BoxDecoration(
                            color: scheme.primary,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 26,
                    child: Text(
                      '${e.count}',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Faixa horizontal de miniaturas de peças com nome e valor opcional.
class ItemThumbStrip extends StatelessWidget {
  final List<ItemStat> items;
  final String Function(ItemStat)? badge;
  const ItemThumbStrip({super.key, required this.items, this.badge});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          'Sem dados.',
          style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13),
        ),
      );
    }
    return SizedBox(
      height: 132,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final it = items[i];
          return SizedBox(
            width: 92,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(6),
                    child: ExtendedImage.file(
                      File(it.imagePath),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  it.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12),
                ),
                if (badge != null)
                  Text(
                    badge!(it),
                    style: TextStyle(
                        fontSize: 11, color: scheme.onSurfaceVariant),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
