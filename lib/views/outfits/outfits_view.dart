import 'dart:io';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/clothing_controller.dart';
import '../../controllers/constructor_controller.dart';
import '../../controllers/nav_controller.dart';
import '../../controllers/outfit_controller.dart';
import '../../database/app_database.dart';
import '../../services/user_scope.dart';
import '../../utils/category_label.dart';
import '../../widgets/async_section.dart';
import '../../widgets/dialogs.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/outfit_layout_preview.dart';
import '../search/search_view.dart';
import 'detail_sheets.dart';

enum _ViewMode { outfits, items }

class OutfitsView extends ConsumerStatefulWidget {
  const OutfitsView({super.key});

  @override
  ConsumerState<OutfitsView> createState() => _OutfitsViewState();
}

class _OutfitsViewState extends ConsumerState<OutfitsView> {
  OutfitSortMode _sortMode = OutfitSortMode.favoritesFirst;
  _ViewMode _viewMode = _ViewMode.outfits;
  ClothingCategory? _itemCategoryFilter;

  Future<void> _confirmDeleteOutfit(String id, String name) async {
    final confirmed = await confirmDialog(
      context,
      title: 'Excluir outfit',
      message: 'Excluir "$name"? Esta ação não pode ser desfeita.',
      confirmLabel: 'Excluir',
      destructive: true,
    );
    if (confirmed && mounted) {
      await ref.read(outfitControllerProvider.notifier).deleteOutfit(id);
    }
  }

  Future<void> _confirmDeleteItem(ClothingItem item) async {
    final confirmed = await confirmDialog(
      context,
      title: 'Excluir peça',
      message: 'Excluir "${item.name}"? Esta ação não pode ser desfeita.',
      confirmLabel: 'Excluir',
      destructive: true,
    );
    if (confirmed && mounted) {
      await ref.read(clothingControllerProvider.notifier).deleteItem(item.id);
      await ref.read(imageStorageServiceProvider).deleteImage(item.imagePath);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Outfits'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Buscar',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SearchView()),
            ),
          ),
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
            )
          else
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: DropdownButton<ClothingCategory?>(
                value: _itemCategoryFilter,
                underline: const SizedBox.shrink(),
                onChanged: (v) => setState(() => _itemCategoryFilter = v),
                items: [
                  const DropdownMenuItem<ClothingCategory?>(
                    value: null,
                    child: Text('Todas'),
                  ),
                  ...ClothingCategory.values.map(
                    (c) => DropdownMenuItem<ClothingCategory?>(
                      value: c,
                      child: Text(c.displayName),
                    ),
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
              onSelectionChanged: (s) => setState(() => _viewMode = s.first),
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
    return AsyncSection(
      value: outfitsAsync,
      builder: (outfits) {
        if (outfits.isEmpty) {
          return EmptyState(
            icon: Icons.style_outlined,
            title: 'Nenhum outfit ainda',
            message: 'Monte seu primeiro look no Construtor.',
            actionLabel: 'Montar look',
            onAction: () =>
                ref.read(currentTabIndexProvider.notifier).setTab(3),
          );
        }
        return GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.68,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: outfits.length,
          itemBuilder: (context, index) => _OutfitCard(
            outfit: outfits[index],
            onDelete: _confirmDeleteOutfit,
            onTap: () => showOutfitDetailSheet(context, outfits[index]),
          ),
        );
      },
    );
  }

  Widget _buildItemsGrid() {
    final itemsAsync = ref.watch(clothingItemsProvider);
    return AsyncSection(
      value: itemsAsync,
      builder: (all) {
        final items = _itemCategoryFilter == null
            ? all
            : all
                .where((i) => i.category == _itemCategoryFilter!.name)
                .toList();
        if (items.isEmpty) {
          return _itemCategoryFilter == null
              ? EmptyState(
                  icon: Icons.checkroom_outlined,
                  title: 'Nenhuma peça ainda',
                  message: 'Fotografe suas roupas para começar o catálogo.',
                  actionLabel: 'Capturar peça',
                  onAction: () =>
                      ref.read(currentTabIndexProvider.notifier).setTab(2),
                )
              : EmptyState(
                  icon: Icons.filter_alt_off_outlined,
                  title: 'Nada nesta categoria',
                  message:
                      'Nenhuma peça em ${_itemCategoryFilter!.displayName}.',
                  actionLabel: 'Ver todas',
                  onAction: () =>
                      setState(() => _itemCategoryFilter = null),
                );
        }
        return GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.72,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) => _ClothingItemCard(
            item: items[index],
            onDelete: _confirmDeleteItem,
            onTap: () => showItemDetailSheet(context, items[index]),
          ),
        );
      },
    );
  }
}

// ─── Outfit Card ─────────────────────────────────────────────────────────────

class _OutfitCard extends ConsumerWidget {
  final Outfit outfit;
  final Future<void> Function(String id, String name) onDelete;
  final VoidCallback onTap;

  const _OutfitCard({
    required this.outfit,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isFav = outfit.isFavorite == 1;

    return Material(
      color: scheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Expanded(
            child: InkWell(
              onTap: onTap,
              child: OutfitLayoutPreview(outfitId: outfit.id),
            ),
          ),
          Container(
            color: scheme.surface,
            padding: const EdgeInsets.only(left: 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    outfit.name,
                    style: theme.textTheme.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  tooltip: isFav ? 'Desfavoritar' : 'Favoritar',
                  icon: Icon(
                    isFav ? Icons.star : Icons.star_border,
                    color: isFav ? Colors.amber : null,
                  ),
                  onPressed: () => ref
                      .read(outfitControllerProvider.notifier)
                      .toggleFavorite(outfit.id, isFav),
                ),
                MenuAnchor(
                  builder: (ctx, controller, _) => IconButton(
                    tooltip: 'Mais opções',
                    icon: const Icon(Icons.more_vert),
                    onPressed: () => controller.isOpen
                        ? controller.close()
                        : controller.open(),
                  ),
                  menuChildren: [
                    MenuItemButton(
                      leadingIcon: const Icon(Icons.edit_outlined, size: 18),
                      onPressed: () async {
                        await ref
                            .read(constructorControllerProvider.notifier)
                            .loadOutfit(outfit.id);
                        ref.read(currentTabIndexProvider.notifier).setTab(3);
                      },
                      child: const Text('Editar peças'),
                    ),
                    MenuItemButton(
                      leadingIcon:
                          Icon(Icons.delete_outline, size: 18,
                              color: scheme.error),
                      onPressed: () => onDelete(outfit.id, outfit.name),
                      child: Text('Excluir',
                          style: TextStyle(color: scheme.error)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Clothing Item Card ───────────────────────────────────────────────────────

class _ClothingItemCard extends StatelessWidget {
  final ClothingItem item;
  final Future<void> Function(ClothingItem) onDelete;
  final VoidCallback onTap;

  const _ClothingItemCard({
    required this.item,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Material(
      color: scheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Expanded(
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: ExtendedImage.file(
                  File(item.imagePath),
                  fit: BoxFit.contain,
                  width: double.infinity,
                ),
              ),
            ),
          ),
          Container(
            color: scheme.surface,
            padding: const EdgeInsets.only(left: 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item.name,
                        style: theme.textTheme.titleSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      _CategoryTag(label: catLabel(item.category)),
                    ],
                  ),
                ),
                MenuAnchor(
                  builder: (ctx, controller, _) => IconButton(
                    tooltip: 'Mais opções',
                    icon: const Icon(Icons.more_vert),
                    onPressed: () => controller.isOpen
                        ? controller.close()
                        : controller.open(),
                  ),
                  menuChildren: [
                    MenuItemButton(
                      leadingIcon: Icon(Icons.delete_outline, size: 18,
                          color: scheme.error),
                      onPressed: () => onDelete(item),
                      child: Text('Excluir',
                          style: TextStyle(color: scheme.error)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Etiqueta de categoria (chip com cara de tag de roupa).
class _CategoryTag extends StatelessWidget {
  final String label;
  const _CategoryTag({required this.label});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          letterSpacing: 1,
          color: scheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
