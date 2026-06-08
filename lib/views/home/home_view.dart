import 'dart:async';
import 'dart:io';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/clothing_controller.dart';
import '../../controllers/outfit_controller.dart';
import '../../controllers/profile_controller.dart';
import '../../database/app_database.dart';

const _categoryOrder = {
  'chapeu': 0, 'camisa': 1, 'blusa': 2,
  'cinto': 3, 'calca': 4, 'sapato': 5, 'complemento': 6,
};

List<ClothingItem> _sortAnatomically(List<ClothingItem> items) =>
    [...items]..sort((a, b) =>
        (_categoryOrder[a.category] ?? 9).compareTo(
          _categoryOrder[b.category] ?? 9));

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final username = ref.watch(profileProvider).username;
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Text(
              _greeting(username),
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          _SectionLabel(label: 'Peças Recentes'),
          const _RecentItemsCarousel(),
          const SizedBox(height: 20),
          _SectionLabel(label: 'Seus Outfits'),
          const _RecentOutfitsCarousel(),
        ],
      ),
    );
  }

  String _greeting(String name) {
    final h = DateTime.now().hour;
    final base = h < 12 ? 'Bom dia' : h < 18 ? 'Boa tarde' : 'Boa noite';
    return '$base, $name!';
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Text(
        label,
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}

// ─── Carousel base ─────────────────────────────────────────────────────────

class _RecentItemsCarousel extends ConsumerStatefulWidget {
  const _RecentItemsCarousel();

  @override
  ConsumerState<_RecentItemsCarousel> createState() =>
      _RecentItemsCarouselState();
}

class _RecentItemsCarouselState extends ConsumerState<_RecentItemsCarousel> {
  late final PageController _ctrl;
  Timer? _timer;
  int _page = 500;

  @override
  void initState() {
    super.initState();
    _ctrl = PageController(initialPage: _page, viewportFraction: 0.78);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  void _scheduleAutoScroll(int count) {
    if (_timer != null || count <= 1) return;
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!_ctrl.hasClients) return;
      _page++;
      _ctrl.animateToPage(
        _page,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(recentClothingProvider);
    return SizedBox(
      height: 170,
      child: async.when(
        data: (items) {
          if (items.isEmpty) {
            return _EmptyCard(
              message:
                  'Suas primeiras peças aparecerão aqui assim que você as fotografar.',
              icon: Icons.checkroom_outlined,
            );
          }
          _scheduleAutoScroll(items.length);
          return PageView.builder(
            controller: _ctrl,
            itemBuilder: (_, i) => _ItemCard(item: items[i % items.length]),
          );
        },
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
      ),
    );
  }
}

class _RecentOutfitsCarousel extends ConsumerStatefulWidget {
  const _RecentOutfitsCarousel();

  @override
  ConsumerState<_RecentOutfitsCarousel> createState() =>
      _RecentOutfitsCarouselState();
}

class _RecentOutfitsCarouselState
    extends ConsumerState<_RecentOutfitsCarousel> {
  late final PageController _ctrl;
  Timer? _timer;
  int _page = 500;

  @override
  void initState() {
    super.initState();
    _ctrl = PageController(initialPage: _page, viewportFraction: 0.78);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  void _scheduleAutoScroll(int count) {
    if (_timer != null || count <= 1) return;
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!_ctrl.hasClients) return;
      _page++;
      _ctrl.animateToPage(
        _page,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(recentOutfitsProvider);
    return SizedBox(
      height: 170,
      child: async.when(
        data: (outfits) {
          if (outfits.isEmpty) {
            return _EmptyCard(
              message:
                  'Monte seu primeiro look na aba Construtor e ele aparecerá aqui.',
              icon: Icons.style_outlined,
            );
          }
          _scheduleAutoScroll(outfits.length);
          return PageView.builder(
            controller: _ctrl,
            itemBuilder: (_, i) =>
                _OutfitCard(outfit: outfits[i % outfits.length]),
          );
        },
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
      ),
    );
  }
}

// ─── Cards ──────────────────────────────────────────────────────────────────

class _ItemCard extends StatelessWidget {
  final ClothingItem item;
  const _ItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Card(
        elevation: 2,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            SizedBox(
              width: 110,
              child: ExtendedImage.file(
                File(item.imagePath),
                fit: BoxFit.cover,
                height: double.infinity,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 15),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.category,
                        style: TextStyle(
                            fontSize: 12, color: colorScheme.onPrimaryContainer),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OutfitCard extends ConsumerWidget {
  final Outfit outfit;
  const _OutfitCard({required this.outfit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(clothingItemsForOutfitProvider(outfit.id));
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Card(
        elevation: 2,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            Expanded(
              child: itemsAsync.when(
                data: (items) {
                  if (items.isEmpty) {
                    return Center(
                      child: Icon(Icons.style_outlined,
                          size: 48, color: Colors.grey.shade400),
                    );
                  }
                  return LayoutBuilder(
                    builder: (ctx, constraints) {
                      final sorted = _sortAnatomically(items);
                      final visible = sorted.take(3).toList();
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
                error: (e, st) => const SizedBox.shrink(),
              ),
            ),
            Container(
              width: double.infinity,
              color: colorScheme.surfaceContainerHighest,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Text(
                outfit.name,
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final String message;
  final IconData icon;
  const _EmptyCard({required this.message, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade300),
        ),
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(icon, size: 40, color: Colors.grey.shade400),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
