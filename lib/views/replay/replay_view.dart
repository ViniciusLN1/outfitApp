import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/stats_controller.dart';
import '../../database/daos/stats_dao.dart';
import '../../models/item_color.dart';
import '../../utils/date_format.dart';
import '../stats/stat_widgets.dart';
import '../stats/stats_view.dart' show catLabel;

class ReplayView extends ConsumerWidget {
  const ReplayView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rotation = ref.watch(wardrobeRotationProvider).value;
    final monthUsage = ref.watch(currentMonthUsageProvider).value ?? 0;
    final categoryUsage = ref.watch(categoryUsageProvider).value ?? const [];
    final colorUsage = ref.watch(colorUsageProvider).value ?? const [];
    final commonOutfit = ref.watch(mostCommonOutfitProvider).value;

    final usedCats = categoryUsage.where((e) => e.count > 0).toList();
    final mostCat = usedCats.isEmpty ? null : usedCats.first;
    final leastCat = categoryUsage.isEmpty ? null : categoryUsage.last;
    final mostColor = colorUsage.isEmpty ? null : colorUsage.first;

    return Scaffold(
      appBar: AppBar(title: const Text('Closet Replay')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 28),
        children: [
          const SectionLabel('Uso do guarda-roupa'),
          if (rotation != null)
            _ProgressCard(
              title: 'Rotação / percentual de uso',
              current: rotation.used,
              total: rotation.total == 0 ? 1 : rotation.total,
              caption:
                  '${rotation.used} de ${rotation.total} peças já usadas '
                  '(${(rotation.ratio * 100).round()}%)',
            ),
          _ProgressCard(
            title: 'Meta mensal de usos',
            current: monthUsage,
            total: kMonthlyUsageGoal,
            caption: '$monthUsage de $kMonthlyUsageGoal usos neste mês',
          ),
          const SectionLabel('Destaques'),
          _FactRow(children: [
            _FactCard(
              title: 'Cor mais usada',
              value: mostColor == null ? '—' : colorLabel(mostColor.label),
              dotColor: mostColor == null ? null : colorSwatch(mostColor.label),
            ),
            _FactCard(
              title: 'Categoria mais usada',
              value: mostCat == null ? '—' : catLabel(mostCat.label),
            ),
          ]),
          _FactRow(children: [
            _FactCard(
              title: 'Categoria menos usada',
              value: leastCat == null ? '—' : catLabel(leastCat.label),
            ),
            _FactCard(
              title: 'Combinação mais repetida',
              value: commonOutfit?.name ?? '—',
              subtitle:
                  commonOutfit == null ? null : '${commonOutfit.value} usos',
            ),
          ]),
          const SectionLabel('Atividade semanal'),
          _bars(_weekly(ref.watch(weekdayActivityProvider))),
          const SectionLabel('Atividade mensal'),
          _bars(ref.watch(monthlyActivityProvider), labelFor: formatYearMonth),
          const SectionLabel('Peças mais repetidas'),
          _items(ref.watch(mostRepeatedItemsProvider),
              badge: (s) => '${s.value} looks'),
          const SectionLabel('Peças esquecidas'),
          _items(ref.watch(forgottenItemsProvider)),
          const SectionLabel('Outfits esquecidos'),
          _forgottenOutfits(ref.watch(forgottenOutfitsProvider)),
        ],
      ),
    );
  }

  /// Normaliza a atividade por dia da semana em 7 entradas ordenadas (Dom→Sáb).
  AsyncValue<List<LabelCount>> _weekly(AsyncValue<List<LabelCount>> async) {
    return async.whenData((data) {
      final counts = {for (final e in data) e.label: e.count};
      return [
        for (var i = 0; i < 7; i++)
          LabelCount(kWeekdaysShort[i], counts['$i'] ?? 0),
      ];
    });
  }

  Widget _bars(
    AsyncValue<List<LabelCount>> async, {
    String Function(String)? labelFor,
  }) {
    return async.when(
      data: (data) => BarList(entries: data, labelFor: labelFor),
      loading: () => const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text('Erro: $e'),
      ),
    );
  }

  Widget _items(
    AsyncValue<List<ItemStat>> async, {
    String Function(ItemStat)? badge,
  }) {
    return async.when(
      data: (data) => ItemThumbStrip(items: data, badge: badge),
      loading: () => const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text('Erro: $e'),
      ),
    );
  }

  Widget _forgottenOutfits(AsyncValue<List<OutfitStat>> async) {
    return async.when(
      data: (data) {
        if (data.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('Sem dados.'),
          );
        }
        return Column(
          children: [
            for (final o in data)
              ListTile(
                leading: const Icon(Icons.style_outlined),
                title: Text(o.name),
                subtitle: Text(
                  o.value == 0
                      ? 'Nunca usado'
                      : 'Último uso: ${formatUsage(o.value, false)}',
                ),
              ),
          ],
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text('Erro: $e'),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final String title;
  final int current;
  final int total;
  final String caption;
  const _ProgressCard({
    required this.title,
    required this.current,
    required this.total,
    required this.caption,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final ratio = total == 0 ? 0.0 : (current / total).clamp(0.0, 1.0);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: ratio.toDouble(),
              minHeight: 10,
              backgroundColor: scheme.surfaceContainerHighest,
            ),
          ),
          const SizedBox(height: 8),
          Text(caption,
              style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _FactRow extends StatelessWidget {
  final List<Widget> children;
  const _FactRow({required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: children[0]),
            const SizedBox(width: 12),
            Expanded(child: children[1]),
          ],
        ),
      ),
    );
  }
}

class _FactCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final Color? dotColor;
  const _FactCard({
    required this.title,
    required this.value,
    this.subtitle,
    this.dotColor,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (dotColor != null) ...[
                ColorDot(color: dotColor!),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(subtitle!,
                style:
                    TextStyle(fontSize: 11, color: scheme.onSurfaceVariant)),
          ],
        ],
      ),
    );
  }
}
