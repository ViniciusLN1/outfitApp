import 'dart:io';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/clothing_controller.dart';
import '../../controllers/outfit_controller.dart';
import '../../controllers/search_controller.dart';
import '../../database/app_database.dart';
import '../../utils/category_label.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/outfit_layout_preview.dart';
import '../../widgets/section_label.dart';
import '../outfits/detail_sheets.dart';

/// Busca global por nome (peças e outfits): case-insensitive, parcial, instantânea.
class SearchView extends ConsumerStatefulWidget {
  const SearchView({super.key});

  @override
  ConsumerState<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends ConsumerState<SearchView> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _run(String term) {
    _controller.text = term;
    _controller.selection =
        TextSelection.collapsed(offset: term.length);
    setState(() => _query = term);
    ref.read(recentSearchesProvider.notifier).add(term);
  }

  @override
  Widget build(BuildContext context) {
    final q = _query.trim().toLowerCase();
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.search,
          decoration: const InputDecoration(
            hintText: 'Buscar peças e outfits...',
            border: InputBorder.none,
          ),
          onChanged: (v) => setState(() => _query = v),
          onSubmitted: (v) {
            if (v.trim().isNotEmpty) {
              ref.read(recentSearchesProvider.notifier).add(v.trim());
            }
          },
        ),
        actions: [
          if (_query.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _controller.clear();
                setState(() => _query = '');
              },
            ),
        ],
      ),
      body: q.isEmpty ? _buildRecent() : _buildResults(q),
    );
  }

  Widget _buildRecent() {
    final recent = ref.watch(recentSearchesProvider);
    if (recent.isEmpty) {
      return const EmptyState(
        icon: Icons.search,
        title: 'Buscar no closet',
        message: 'Digite para encontrar peças e outfits pelo nome.',
      );
    }
    return ListView(
      children: [
        const SectionLabel(
          'Buscas recentes',
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
        ),
        for (final term in recent)
          ListTile(
            leading: const Icon(Icons.history),
            title: Text(term),
            onTap: () => _run(term),
          ),
      ],
    );
  }

  Widget _buildResults(String q) {
    final itemsAsync = ref.watch(clothingItemsProvider);
    final outfitsAsync =
        ref.watch(outfitsSortedProvider(OutfitSortMode.favoritesFirst));

    final items = itemsAsync.value
            ?.where((i) => i.name.toLowerCase().contains(q))
            .toList() ??
        const [];
    final outfits = outfitsAsync.value
            ?.where((o) => o.name.toLowerCase().contains(q))
            .toList() ??
        const [];

    if (items.isEmpty && outfits.isEmpty) {
      return EmptyState(
        icon: Icons.search_off,
        title: 'Nenhum resultado',
        message: 'Nada com esse nome no seu closet.',
        actionLabel: 'Limpar busca',
        onAction: () {
          _controller.clear();
          setState(() => _query = '');
        },
      );
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        if (items.isNotEmpty) ...[
          _GroupHeader(label: 'Peças', count: items.length),
          ...items.map((i) => _ItemResultTile(item: i)),
        ],
        if (outfits.isNotEmpty) ...[
          _GroupHeader(label: 'Outfits', count: outfits.length),
          ...outfits.map((o) => _OutfitResultTile(outfit: o)),
        ],
      ],
    );
  }
}

class _GroupHeader extends StatelessWidget {
  final String label;
  final int count;
  const _GroupHeader({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return SectionLabel(
      '$label · $count',
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
    );
  }
}

class _ItemResultTile extends StatelessWidget {
  final ClothingItem item;
  const _ItemResultTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: SizedBox(
        width: 44,
        height: 44,
        child: ExtendedImage.file(File(item.imagePath), fit: BoxFit.contain),
      ),
      title: Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(catLabel(item.category)),
      onTap: () => showItemDetailSheet(context, item),
    );
  }
}

class _OutfitResultTile extends StatelessWidget {
  final Outfit outfit;
  const _OutfitResultTile({required this.outfit});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: SizedBox(
        width: 44,
        height: 44,
        child: OutfitLayoutPreview(
          outfitId: outfit.id,
          padding: EdgeInsets.zero,
        ),
      ),
      title: Text(outfit.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      onTap: () => showOutfitDetailSheet(context, outfit),
    );
  }
}
