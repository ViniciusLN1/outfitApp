import 'dart:io';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/clothing_controller.dart';
import '../../controllers/constructor_controller.dart';
import '../../controllers/nav_controller.dart';
import '../../controllers/outfit_controller.dart';
import '../../database/app_database.dart';
import '../../services/image_storage_service.dart';

const _categoryOrder = {
  'chapeu': 0, 'camisa': 1, 'blusa': 2,
  'cinto': 3, 'calca': 4, 'sapato': 5, 'complemento': 6,
};

List<ClothingItem> _sortAnatomically(List<ClothingItem> items) =>
    [...items]..sort((a, b) =>
        (_categoryOrder[a.category] ?? 9).compareTo(
          _categoryOrder[b.category] ?? 9));

enum _ViewMode { outfits, items }

class OutfitsView extends ConsumerStatefulWidget {
  const OutfitsView({super.key});

  @override
  ConsumerState<OutfitsView> createState() => _OutfitsViewState();
}

class _OutfitsViewState extends ConsumerState<OutfitsView> {
  OutfitSortMode _sortMode = OutfitSortMode.favoritesFirst;
  _ViewMode _viewMode = _ViewMode.outfits;

  Future<void> _confirmDeleteOutfit(String id, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir outfit'),
        content: Text('Excluir "$name"? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await ref.read(outfitControllerProvider.notifier).deleteOutfit(id);
    }
  }

  Future<void> _confirmDeleteItem(ClothingItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir peça'),
        content:
            Text('Excluir "${item.name}"? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await ref.read(clothingControllerProvider.notifier).deleteItem(item.id);
      await ImageStorageService().deleteImage(item.imagePath);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Outfits'),
        actions: [
          if (_viewMode == _ViewMode.outfits)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: DropdownButton<OutfitSortMode>(
                value: _sortMode,
                underline: const SizedBox.shrink(),
                onChanged: (v) => setState(() => _sortMode = v!),
                items: const [
                  DropdownMenuItem(
                    value: OutfitSortMode.favoritesFirst,
                    child: Text('Favoritos'),
                  ),
                  DropdownMenuItem(
                    value: OutfitSortMode.mostUsed,
                    child: Text('Mais Usados'),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: SegmentedButton<_ViewMode>(
              segments: const [
                ButtonSegment(
                  value: _ViewMode.outfits,
                  label: Text('Ver Outfits'),
                  icon: Icon(Icons.style_outlined),
                ),
                ButtonSegment(
                  value: _ViewMode.items,
                  label: Text('Ver Peças'),
                  icon: Icon(Icons.checkroom_outlined),
                ),
              ],
              selected: {_viewMode},
              onSelectionChanged: (s) =>
                  setState(() => _viewMode = s.first),
            ),
          ),
          Expanded(
            child: _viewMode == _ViewMode.outfits
                ? _buildOutfitsGrid()
                : _buildItemsGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildOutfitsGrid() {
    final outfitsAsync = ref.watch(outfitsSortedProvider(_sortMode));
    return outfitsAsync.when(
      data: (outfits) {
        if (outfits.isEmpty) {
          return const Center(child: Text('Nenhum outfit salvo ainda.'));
        }
        return GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.72,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: outfits.length,
          itemBuilder: (context, index) =>
              _OutfitCard(outfit: outfits[index], onDelete: _confirmDeleteOutfit),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Erro: $e')),
    );
  }

  Widget _buildItemsGrid() {
    final itemsAsync = ref.watch(clothingItemsProvider);
    return itemsAsync.when(
      data: (items) {
        if (items.isEmpty) {
          return const Center(child: Text('Nenhuma peça cadastrada ainda.'));
        }
        return GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) =>
              _ClothingItemCard(item: items[index], onDelete: _confirmDeleteItem),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Erro: $e')),
    );
  }
}

// ─── Outfit Card ─────────────────────────────────────────────────────────────

class _OutfitCard extends ConsumerWidget {
  final Outfit outfit;
  final Future<void> Function(String id, String name) onDelete;

  const _OutfitCard({required this.outfit, required this.onDelete});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFav = outfit.isFavorite == 1;
    final itemsAsync = ref.watch(clothingItemsForOutfitProvider(outfit.id));

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Expanded(
            child: itemsAsync.when(
              data: (items) {
                if (items.isEmpty) {
                  return Center(
                    child: Icon(Icons.style_outlined,
                        size: 48, color: Colors.grey.shade300),
                  );
                }
                return LayoutBuilder(
                  builder: (ctx, constraints) {
                    final visible = _sortAnatomically(items).take(3).toList();
                    final slotH = constraints.maxHeight / visible.length;
                    return Column(
                      children: visible
                          .map(
                            (it) => SizedBox(
                              width: constraints.maxWidth,
                              height: slotH,
                              child: ExtendedImage.file(
                                File(it.imagePath),
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                          .toList(),
                    );
                  },
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => const SizedBox.shrink(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8, right: 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    outfit.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  iconSize: 20,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    isFav ? Icons.star : Icons.star_border,
                    color: isFav ? Colors.amber : null,
                  ),
                  onPressed: () => ref
                      .read(outfitControllerProvider.notifier)
                      .toggleFavorite(outfit.id, isFav),
                ),
                IconButton(
                  iconSize: 20,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    await ref
                        .read(constructorControllerProvider.notifier)
                        .loadOutfit(outfit.id);
                    ref.read(currentTabIndexProvider.notifier).setTab(3);
                  },
                ),
                IconButton(
                  iconSize: 20,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => onDelete(outfit.id, outfit.name),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

// ─── Clothing Item Card ───────────────────────────────────────────────────────

class _ClothingItemCard extends StatelessWidget {
  final ClothingItem item;
  final Future<void> Function(ClothingItem) onDelete;

  const _ClothingItemCard({required this.item, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Expanded(
            child: ExtendedImage.file(
              File(item.imagePath),
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 4, 4),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 2),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item.category,
                          style: TextStyle(
                              fontSize: 10,
                              color: colorScheme.onPrimaryContainer),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  iconSize: 20,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => onDelete(item),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}
