import 'dart:async';
import 'dart:io';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/clothing_controller.dart';
import '../../controllers/nav_controller.dart';
import '../../controllers/outfit_controller.dart';
import '../../controllers/profile_controller.dart';
import '../../database/app_database.dart';

const _categoryOrder = {
  'chapeu': 0, 'camisa': 1, 'blusa': 2,
  'cinto': 3, 'calca': 4, 'sapato': 5, 'acessorios': 6,
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
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
            child: Text(
              _greeting(username),
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const _SuggestionCard(),
          const SizedBox(height: 22),
          const _ClosetMetrics(),
          const SizedBox(height: 26),
          _SectionLabel(label: 'Peças Recentes'),
          const _RecentItemsCarousel(),
          const SizedBox(height: 22),
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

// ─── Sugestão do Dia ─────────────────────────────────────────────────────────

class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (icon, message) = _suggestion(DateTime.now().hour);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: scheme.primary,
          borderRadius: BorderRadius.circular(4),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: scheme.onPrimary, size: 28),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SUGESTÃO DO DIA',
                    style: TextStyle(
                      color: scheme.onPrimary.withValues(alpha: 0.7),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    message,
                    style: TextStyle(
                      color: scheme.onPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  (IconData, String) _suggestion(int hour) {
    if (hour < 12) {
      return (
        Icons.wb_twilight,
        'Manhã fresca. Comece com peças leves e camadas fáceis de tirar.'
      );
    }
    if (hour < 18) {
      return (
        Icons.wb_sunny_outlined,
        'Tarde em cheio. Que tal apostar em sobreposições e um tom de destaque?'
      );
    }
    return (
      Icons.nightlight_outlined,
      'Noite chegando. Vá de peças mais sóbrias e um acessório marcante.'
    );
  }
}

// ─── Métricas do Closet ───────────────────────────────────────────────────────

class _ClosetMetrics extends ConsumerWidget {
  const _ClosetMetrics();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(totalClothingItemsProvider);
    final outfits = ref.watch(totalOutfitsProvider);
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8, left: 2),
            child: Text(
              'MÉTRICAS DO SEU CLOSET',
              style: TextStyle(
                color: scheme.onSurfaceVariant,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: scheme.surface,
              border: Border.all(color: scheme.outlineVariant),
              borderRadius: BorderRadius.circular(4),
            ),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                    child: _MetricCell(
                      value: items,
                      label: 'Peças catalogadas',
                      icon: Icons.checkroom,
                    ),
                  ),
                  VerticalDivider(width: 1, color: scheme.outlineVariant),
                  Expanded(
                    child: _MetricCell(
                      value: outfits,
                      label: 'Looks montados',
                      icon: Icons.style,
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

class _MetricCell extends StatelessWidget {
  final AsyncValue<int> value;
  final String label;
  final IconData icon;

  const _MetricCell({
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Column(
        children: [
          Icon(icon, size: 22, color: scheme.primary),
          const SizedBox(height: 8),
          value.when(
            data: (v) => Text(
              '$v',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: scheme.onSurface,
              ),
            ),
            loading: () => const SizedBox(
              height: 26,
              width: 26,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            error: (_, _) => const Text('--', style: TextStyle(fontSize: 26)),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
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

class _ItemCard extends ConsumerWidget {
  final ClothingItem item;
  const _ItemCard({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: GestureDetector(
        onTap: () =>
            ref.read(currentTabIndexProvider.notifier).setTab(1),
        child: Card(
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: ExtendedImage.file(
                    File(item.imagePath),
                    fit: BoxFit.contain,
                    width: double.infinity,
                  ),
                ),
              ),
              _CardNameStrip(name: item.name),
            ],
          ),
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: GestureDetector(
        onTap: () =>
            ref.read(currentTabIndexProvider.notifier).setTab(1),
        child: Card(
          child: Column(
            children: [
              Expanded(
                child: itemsAsync.when(
                  data: (items) {
                    if (items.isEmpty) {
                      return Icon(Icons.style_outlined,
                          size: 48,
                          color: Theme.of(context).colorScheme.onSurfaceVariant);
                    }
                    final visible = _sortAnatomically(items).take(3).toList();
                    return Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        children: visible
                            .map(
                              (it) => Expanded(
                                child: ExtendedImage.file(
                                  File(it.imagePath),
                                  fit: BoxFit.contain,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, st) => const SizedBox.shrink(),
                ),
              ),
              _CardNameStrip(name: outfit.name),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardNameStrip extends StatelessWidget {
  final String name;
  const _CardNameStrip({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      child: Text(
        name,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
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
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(icon, size: 40, color: scheme.onSurfaceVariant),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
