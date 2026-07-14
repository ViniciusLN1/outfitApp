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
import '../../utils/date_format.dart';
import '../../widgets/async_section.dart';
import '../../widgets/dialogs.dart';
import '../../widgets/outfit_layout_preview.dart';
import '../calendar/register_usage_dialog.dart';

/// Abre o detalhe/edição de uma peça. Compartilhado por Outfits, Home e Busca.
void showItemDetailSheet(BuildContext context, ClothingItem item) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => ItemDetailSheet(item: item),
  );
}

/// Abre o detalhe/edição de um outfit. Compartilhado por Outfits, Home e Busca.
void showOutfitDetailSheet(BuildContext context, Outfit outfit) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => OutfitDetailSheet(outfit: outfit),
  );
}

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
              // "Prancha": a foto vive num plano greige, sem borda.
              Container(
                height: MediaQuery.of(context).size.height * 0.34,
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(16),
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

class ItemDetailSheet extends ConsumerStatefulWidget {
  final ClothingItem item;
  const ItemDetailSheet({super.key, required this.item});

  @override
  ConsumerState<ItemDetailSheet> createState() => _ItemDetailSheetState();
}

class _ItemDetailSheetState extends ConsumerState<ItemDetailSheet> {
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
    _color =
        kItemColors.containsKey(widget.item.color) ? widget.item.color : null;
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
          decoration: const InputDecoration(labelText: 'Nome da peça'),
        ),
        const SizedBox(height: 12),
        InputDecorator(
          decoration: const InputDecoration(labelText: 'Categoria'),
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
          decoration: const InputDecoration(labelText: 'Cor (opcional)'),
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
          child: const Text('Salvar alterações'),
        ),
      ],
    );
  }
}

class OutfitDetailSheet extends ConsumerStatefulWidget {
  final Outfit outfit;
  const OutfitDetailSheet({super.key, required this.outfit});

  @override
  ConsumerState<OutfitDetailSheet> createState() => _OutfitDetailSheetState();
}

class _OutfitDetailSheetState extends ConsumerState<OutfitDetailSheet> {
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
            Expanded(
              child: Text(
                'Favoritar',
                style: Theme.of(context).textTheme.titleMedium,
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
          decoration: const InputDecoration(labelText: 'Nome do outfit'),
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

class _UsageSummary extends ConsumerWidget {
  final String outfitId;
  const _UsageSummary({required this.outfitId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final total = ref.watch(outfitUsageTotalProvider(outfitId)).value ?? 0;
    final lastMs = ref.watch(outfitLastUsageProvider(outfitId)).value;
    final scheme = Theme.of(context).colorScheme;
    final last = lastMs == null ? 'Nunca usado' : formatUsage(lastMs, false);
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
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(label, style: theme.textTheme.labelSmall),
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
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: scheme.onSurfaceVariant),
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
                  tooltip: 'Remover uso',
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    await ref
                        .read(usageControllerProvider.notifier)
                        .delete(u.id);
                    if (!context.mounted) return;
                    showUndoSnackBar(
                      context,
                      message: 'Uso removido.',
                      onUndo: () => ref
                          .read(usageControllerProvider.notifier)
                          .register(
                            outfitId: u.outfitId,
                            when: DateTime.fromMillisecondsSinceEpoch(
                                u.usedAt),
                            hasTime: u.hasTime,
                          ),
                    );
                  },
                ),
              );
            },
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const ErrorNotice(),
    );
  }
}
