import 'dart:io';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/clothing_controller.dart';
import '../../controllers/constructor_controller.dart';
import '../../controllers/nav_controller.dart';
import '../../controllers/outfit_controller.dart';
import '../../controllers/usage_controller.dart';
import '../../database/app_database.dart';
import '../../models/item_color.dart';
import '../../services/image_storage_service.dart';
import '../../utils/date_format.dart';
import '../../widgets/outfit_layout_preview.dart';
import '../calendar/register_usage_dialog.dart';
import '../search/search_view.dart';

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

  void _openOutfitDetail(Outfit outfit) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _OutfitDetailSheet(outfit: outfit),
    );
  }

  void _openItemDetail(ClothingItem item) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _ItemDetailSheet(item: item),
    );
  }

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
          itemBuilder: (context, index) => _OutfitCard(
            outfit: outfits[index],
            onDelete: _confirmDeleteOutfit,
            onTap: () => _openOutfitDetail(outfits[index]),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Erro: $e')),
    );
  }

  Widget _buildItemsGrid() {
    final itemsAsync = ref.watch(clothingItemsProvider);
    return itemsAsync.when(
      data: (all) {
        final items = _itemCategoryFilter == null
            ? all
            : all
                .where((i) => i.category == _itemCategoryFilter!.name)
                .toList();
        if (items.isEmpty) {
          return Center(
            child: Text(
              _itemCategoryFilter == null
                  ? 'Nenhuma peça cadastrada ainda.'
                  : 'Nenhuma peça nesta categoria.',
            ),
          );
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
          itemBuilder: (context, index) => _ClothingItemCard(
            item: items[index],
            onDelete: _confirmDeleteItem,
            onTap: () => _openItemDetail(items[index]),
          ),
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
  final VoidCallback onTap;

  const _OutfitCard({
    required this.outfit,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFav = outfit.isFavorite == 1;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              behavior: HitTestBehavior.opaque,
              child: OutfitLayoutPreview(outfitId: outfit.id),
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
  final VoidCallback onTap;

  const _ClothingItemCard({
    required this.item,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              behavior: HitTestBehavior.opaque,
              child: ExtendedImage.file(
                File(item.imagePath),
                fit: BoxFit.cover,
                width: double.infinity,
              ),
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

// ─── Detalhes / Edição (BottomSheet) ──────────────────────────────────────────

class _DetailSheetScaffold extends StatelessWidget {
  final Widget preview;
  final List<Widget> children;

  const _DetailSheetScaffold({required this.preview, required this.children});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: scheme.outlineVariant,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Container(
                height: MediaQuery.of(context).size.height * 0.34,
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  border: Border.all(color: scheme.outlineVariant),
                  borderRadius: BorderRadius.circular(4),
                ),
                padding: const EdgeInsets.all(12),
                child: preview,
              ),
              const SizedBox(height: 18),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

class _ItemDetailSheet extends ConsumerStatefulWidget {
  final ClothingItem item;
  const _ItemDetailSheet({required this.item});

  @override
  ConsumerState<_ItemDetailSheet> createState() => _ItemDetailSheetState();
}

class _ItemDetailSheetState extends ConsumerState<_ItemDetailSheet> {
  late final TextEditingController _nameCtrl;
  late String _category;
  late String? _color;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.item.name);
    _category =
        ClothingCategory.values.any((c) => c.name == widget.item.category)
            ? widget.item.category
            : ClothingCategory.camisa.name;
    _color = kItemColors.containsKey(widget.item.color) ? widget.item.color : null;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite um nome para a peça.')),
      );
      return;
    }
    setState(() => _saving = true);
    await ref.read(clothingControllerProvider.notifier).updateItem(
          id: widget.item.id,
          name: name,
          category: _category,
          color: _color,
        );
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Peça atualizada!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _DetailSheetScaffold(
      preview: ExtendedImage.file(
        File(widget.item.imagePath),
        fit: BoxFit.contain,
      ),
      children: [
        TextField(
          controller: _nameCtrl,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            labelText: 'Nome da peça',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        InputDecorator(
          decoration: const InputDecoration(
            labelText: 'Categoria',
            border: OutlineInputBorder(),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _category,
              isDense: true,
              isExpanded: true,
              onChanged: (v) => setState(() => _category = v!),
              items: ClothingCategory.values
                  .map((c) => DropdownMenuItem(
                        value: c.name,
                        child: Text(c.displayName),
                      ))
                  .toList(),
            ),
          ),
        ),
        const SizedBox(height: 12),
        InputDecorator(
          decoration: const InputDecoration(
            labelText: 'Cor (opcional)',
            border: OutlineInputBorder(),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String?>(
              value: _color,
              isDense: true,
              isExpanded: true,
              onChanged: (v) => setState(() => _color = v),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Sem cor'),
                ),
                ...kItemColors.entries.map(
                  (e) => DropdownMenuItem<String?>(
                    value: e.key,
                    child: Row(
                      children: [
                        ColorDot(color: e.value),
                        const SizedBox(width: 10),
                        Text(colorLabel(e.key)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _saving ? null : _save,
          child: const Text('Salvar Alterações'),
        ),
      ],
    );
  }
}

class _OutfitDetailSheet extends ConsumerStatefulWidget {
  final Outfit outfit;
  const _OutfitDetailSheet({required this.outfit});

  @override
  ConsumerState<_OutfitDetailSheet> createState() => _OutfitDetailSheetState();
}

class _OutfitDetailSheetState extends ConsumerState<_OutfitDetailSheet> {
  late final TextEditingController _nameCtrl;
  late bool _isFav;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.outfit.name);
    _isFav = widget.outfit.isFavorite == 1;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _toggleFav() async {
    final wasFav = _isFav;
    setState(() => _isFav = !wasFav); // feedback visual instantâneo
    await ref
        .read(outfitControllerProvider.notifier)
        .toggleFavorite(widget.outfit.id, wasFav);
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite um nome para o outfit.')),
      );
      return;
    }
    await ref
        .read(outfitControllerProvider.notifier)
        .renameOutfit(widget.outfit.id, name);
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Outfit atualizado!')),
    );
  }

  Future<void> _editInConstructor() async {
    await ref
        .read(constructorControllerProvider.notifier)
        .loadOutfit(widget.outfit.id);
    if (!mounted) return;
    Navigator.pop(context);
    ref.read(currentTabIndexProvider.notifier).setTab(3);
  }

  @override
  Widget build(BuildContext context) {
    return _DetailSheetScaffold(
      preview: OutfitLayoutPreview(outfitId: widget.outfit.id),
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Favoritar',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
            ),
            IconButton(
              iconSize: 28,
              icon: Icon(
                _isFav ? Icons.star : Icons.star_border,
                color: _isFav ? Colors.amber : null,
              ),
              onPressed: _toggleFav,
            ),
          ],
        ),
        const SizedBox(height: 4),
        TextField(
          controller: _nameCtrl,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            labelText: 'Nome do outfit',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 20),
        const Divider(),
        const SizedBox(height: 8),
        _UsageSummary(outfitId: widget.outfit.id),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => showRegisterUsageDialog(
            context: context,
            ref: ref,
            outfitId: widget.outfit.id,
          ),
          icon: const Icon(Icons.event_available_outlined, size: 18),
          label: const Text('Registrar uso'),
        ),
        const SizedBox(height: 8),
        _UsageHistoryList(outfitId: widget.outfit.id),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _editInConstructor,
                child: const Text('Editar peças'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _save,
                child: const Text('Salvar'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Uso do outfit (histórico / último / total) ───────────────────────────────

class _UsageSummary extends ConsumerWidget {
  final String outfitId;
  const _UsageSummary({required this.outfitId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final total = ref.watch(outfitUsageTotalProvider(outfitId)).value ?? 0;
    final lastMs = ref.watch(outfitLastUsageProvider(outfitId)).value;
    final scheme = Theme.of(context).colorScheme;
    final last = lastMs == null
        ? 'Nunca usado'
        : formatUsage(lastMs, false);
    return Row(
      children: [
        Expanded(
          child: _UsageMetric(label: 'Total de usos', value: '$total'),
        ),
        Container(width: 1, height: 34, color: scheme.outlineVariant),
        Expanded(
          child: _UsageMetric(label: 'Último uso', value: last),
        ),
      ],
    );
  }
}

class _UsageMetric extends StatelessWidget {
  final String label;
  final String value;
  const _UsageMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _UsageHistoryList extends ConsumerWidget {
  final String outfitId;
  const _UsageHistoryList({required this.outfitId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(outfitUsageHistoryProvider(outfitId));
    final scheme = Theme.of(context).colorScheme;
    return history.when(
      data: (usages) {
        if (usages.isEmpty) {
          return Text(
            'Sem registros de uso.',
            style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
          );
        }
        return ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 180),
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: usages.length,
            separatorBuilder: (_, _) => Divider(
              height: 1,
              color: scheme.outlineVariant,
            ),
            itemBuilder: (_, i) {
              final u = usages[i];
              return ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event_note_outlined, size: 20),
                title: Text(
                  formatUsage(u.usedAt, u.hasTime),
                  style: const TextStyle(fontSize: 13),
                ),
                trailing: IconButton(
                  iconSize: 18,
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () =>
                      ref.read(usageControllerProvider.notifier).delete(u.id),
                ),
              );
            },
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (e, _) => Text('Erro: $e'),
    );
  }
}
