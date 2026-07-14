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
import '../../widgets/async_section.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/kpi_tile.dart';
import '../../widgets/outfit_layout_preview.dart';
import '../../widgets/section_label.dart';
import '../outfits/detail_sheets.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final username =
        ref.watch(profileControllerProvider.select((p) => p.username));
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
            child: Text(
              _greeting(username),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          const _SuggestionCard(),
          const SizedBox(height: 8),
          const _ClosetMetrics(),
          const SectionLabel('Peças recentes'),
          const _ItemsCarousel(),
          const SectionLabel('Seus outfits'),
          const _OutfitsCarousel(),
        ],
      ),
    );
  }

  String _greeting(String name) {
    final h = DateTime.now().hour;
    final base = h < 12 ? 'Bom dia' : h < 18 ? 'Boa tarde' : 'Boa noite';
    return '$base, $name';
  }
}

// ─── Sugestão do Dia ─────────────────────────────────────────────────────────

class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final (icon, message) = _suggestion(DateTime.now().hour);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: scheme.primary, size: 26),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SUGESTÃO DO DIA',
                    style: theme.textTheme.labelSmall
                        ?.copyWith(color: scheme.primary),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    message,
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.35),
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel(
            'Seu closet',
            padding: EdgeInsets.fromLTRB(0, 14, 0, 8),
          ),
          Row(
            children: [
              Expanded(
                child: KpiTile(
                  value: '${items.value ?? '—'}',
                  label: 'Peças catalogadas',
                  icon: Icons.checkroom,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: KpiTile(
                  value: '${outfits.value ?? '—'}',
                  label: 'Looks montados',
                  icon: Icons.style,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Carrossel genérico com auto-scroll, pausa ao toque e indicadores ────────

class _AutoCarousel extends StatefulWidget {
  final int itemCount;
  final Widget Function(BuildContext, int index) itemBuilder;

  const _AutoCarousel({required this.itemCount, required this.itemBuilder});

  @override
  State<_AutoCarousel> createState() => _AutoCarouselState();
}

class _AutoCarouselState extends State<_AutoCarousel> {
  static const _basePage = 5000;
  late final PageController _ctrl;
  Timer? _timer;
  int _page = _basePage;
  bool _touching = false;

  @override
  void initState() {
    super.initState();
    _ctrl = PageController(initialPage: _basePage, viewportFraction: 0.78);
    _ctrl.addListener(() {
      final p = _ctrl.page?.round();
      if (p != null && p != _page) setState(() => _page = p);
    });
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    if (widget.itemCount <= 1) return;
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!_ctrl.hasClients || _touching) return;
      _ctrl.animateToPage(
        _page + 1,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final current = _page % widget.itemCount;
    return Column(
      children: [
        SizedBox(
          height: 170,
          child: Listener(
            // Pausa o auto-scroll enquanto o dedo está no carrossel.
            onPointerDown: (_) => _touching = true,
            onPointerUp: (_) => _touching = false,
            onPointerCancel: (_) => _touching = false,
            child: PageView.builder(
              controller: _ctrl,
              itemBuilder: (ctx, i) =>
                  widget.itemBuilder(ctx, i % widget.itemCount),
            ),
          ),
        ),
        if (widget.itemCount > 1) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < widget.itemCount; i++)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: i == current ? 16 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: i == current
                        ? scheme.primary
                        : scheme.outlineVariant,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _ItemsCarousel extends ConsumerWidget {
  const _ItemsCarousel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(recentClothingProvider);
    return AsyncSection(
      value: async,
      builder: (items) {
        if (items.isEmpty) {
          return EmptyState(
            icon: Icons.checkroom_outlined,
            title: 'Nenhuma peça ainda',
            message: 'Fotografe suas roupas e elas aparecerão aqui.',
            actionLabel: 'Capturar peça',
            onAction: () =>
                ref.read(currentTabIndexProvider.notifier).setTab(2),
          );
        }
        return _AutoCarousel(
          itemCount: items.length,
          itemBuilder: (_, i) => _ItemCard(item: items[i]),
        );
      },
    );
  }
}

class _OutfitsCarousel extends ConsumerWidget {
  const _OutfitsCarousel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(recentOutfitsProvider);
    return AsyncSection(
      value: async,
      builder: (outfits) {
        if (outfits.isEmpty) {
          return EmptyState(
            icon: Icons.style_outlined,
            title: 'Nenhum look ainda',
            message: 'Monte seu primeiro look na aba Construtor.',
            actionLabel: 'Montar look',
            onAction: () =>
                ref.read(currentTabIndexProvider.notifier).setTab(3),
          );
        }
        return _AutoCarousel(
          itemCount: outfits.length,
          itemBuilder: (_, i) => _OutfitCard(outfit: outfits[i]),
        );
      },
    );
  }
}

// ─── Cards ──────────────────────────────────────────────────────────────────

class _ItemCard extends StatelessWidget {
  final ClothingItem item;
  const _ItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return _CarouselCard(
      name: item.name,
      onTap: () => showItemDetailSheet(context, item),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: ExtendedImage.file(
          File(item.imagePath),
          fit: BoxFit.contain,
          width: double.infinity,
        ),
      ),
    );
  }
}

class _OutfitCard extends StatelessWidget {
  final Outfit outfit;
  const _OutfitCard({required this.outfit});

  @override
  Widget build(BuildContext context) {
    return _CarouselCard(
      name: outfit.name,
      onTap: () => showOutfitDetailSheet(context, outfit),
      child: OutfitLayoutPreview(outfitId: outfit.id),
    );
  }
}

/// "Prancha" do carrossel: foto sobre greige + faixa de nome na superfície.
class _CarouselCard extends StatelessWidget {
  final String name;
  final VoidCallback onTap;
  final Widget child;

  const _CarouselCard({
    required this.name,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Material(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            children: [
              Expanded(child: child),
              Container(
                width: double.infinity,
                color: scheme.surface,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                child: Text(
                  name,
                  style: theme.textTheme.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
