import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/outfit_controller.dart';
import '../../controllers/stats_controller.dart';
import '../../database/daos/stats_dao.dart';
import '../../models/item_color.dart';
import '../../utils/category_label.dart';
import '../../utils/date_format.dart';
import '../../widgets/async_section.dart';
import '../../widgets/kpi_tile.dart';
import '../../widgets/section_label.dart';
import 'stat_widgets.dart';

class StatsView extends ConsumerWidget {
  const StatsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(totalClothingItemsProvider).value ?? 0;
    final outfits = ref.watch(totalOutfitsProvider).value ?? 0;
    final categories = ref.watch(totalCategoriesProvider).value ?? 0;
    final colors = ref.watch(totalColorsProvider).value ?? 0;

    return Scaffold(
      appBar: AppBar(title: const Text('Estatísticas')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 28),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                KpiTile(
                    value: '$items',
                    label: 'Peças',
                    icon: Icons.checkroom),
                KpiTile(
                    value: '$outfits', label: 'Outfits', icon: Icons.style),
                KpiTile(
                    value: '$categories',
                    label: 'Categorias',
                    icon: Icons.category_outlined),
                KpiTile(
                    value: '$colors',
                    label: 'Cores',
                    icon: Icons.palette_outlined),
              ],
            ),
          ),
          const SectionLabel('Distribuição por categoria'),
          _bars(ref.watch(categoryDistributionProvider), labelFor: catLabel),
          const SectionLabel('Distribuição por cor'),
          _bars(
            ref.watch(colorDistributionProvider),
            labelFor: colorLabel,
            colorFor: colorSwatch,
          ),
          const SectionLabel('Peças mais usadas'),
          _items(ref.watch(mostUsedItemsProvider),
              badge: (s) => '${s.value} usos'),
          const SectionLabel('Peças nunca usadas'),
          _items(ref.watch(neverUsedItemsProvider)),
          const SectionLabel('Crescimento do acervo por mês'),
          _bars(ref.watch(monthlyGrowthProvider), labelFor: formatYearMonth),
        ],
      ),
    );
  }

  Widget _bars(
    AsyncValue<List<LabelCount>> async, {
    String Function(String)? labelFor,
    Color Function(String)? colorFor,
  }) {
    return AsyncSection(
      value: async,
      builder: (data) =>
          BarList(entries: data, labelFor: labelFor, colorFor: colorFor),
    );
  }

  Widget _items(
    AsyncValue<List<ItemStat>> async, {
    String Function(ItemStat)? badge,
  }) {
    return AsyncSection(
      value: async,
      builder: (data) => ItemThumbStrip(items: data, badge: badge),
    );
  }
}
