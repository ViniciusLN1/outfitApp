import 'package:drift/drift.dart';

import '../app_database.dart';
import '../../models/clothing_item.dart';
import '../../models/outfit.dart';
import '../../models/outfit_item.dart';
import '../../models/outfit_usage.dart';

part 'stats_dao.g.dart';

/// Par rótulo/contagem para distribuições e séries (categoria, cor, mês, dia).
class LabelCount {
  final String label;
  final int count;
  const LabelCount(this.label, this.count);
}

/// Peça com um valor agregado associado (usos, aparições ou último uso em ms).
class ItemStat {
  final String id;
  final String name;
  final String imagePath;
  final String category;
  final String? color;
  final int value;
  const ItemStat({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.category,
    required this.color,
    required this.value,
  });
}

/// Look com um valor agregado associado (usos ou último uso em ms).
class OutfitStat {
  final String id;
  final String name;
  final int value;
  const OutfitStat({required this.id, required this.name, required this.value});
}

/// Rotação do guarda-roupa: peças distintas já usadas sobre o total.
class RotationStat {
  final int total;
  final int used;
  const RotationStat(this.total, this.used);
  double get ratio => total == 0 ? 0 : used / total;
}

/// Acesso somente-leitura para as estatísticas. Toda métrica de "uso" é
/// derivada de outfit_usages (não há contador materializado).
@DriftAccessor(tables: [ClothingItems, Outfits, OutfitItems, OutfitUsages])
class StatsDao extends DatabaseAccessor<AppDatabase> with _$StatsDaoMixin {
  StatsDao(super.db);

  ItemStat _itemStat(QueryRow r) => ItemStat(
        id: r.read<String>('id'),
        name: r.read<String>('name'),
        imagePath: r.read<String>('image_path'),
        category: r.read<String>('category'),
        color: r.read<String?>('color'),
        value: r.read<int>('value'),
      );

  OutfitStat _outfitStat(QueryRow r) => OutfitStat(
        id: r.read<String>('id'),
        name: r.read<String>('name'),
        value: r.read<int>('value'),
      );

  LabelCount _labelCount(QueryRow r) =>
      LabelCount(r.read<String>('label'), r.read<int>('count'));

  // ── Contagens simples ───────────────────────────────────────────────────

  Stream<int> watchTotalCategories() => customSelect(
        'SELECT COUNT(DISTINCT category) AS c FROM clothing_items',
        readsFrom: {clothingItems},
      ).map((r) => r.read<int>('c')).watchSingle();

  Stream<int> watchTotalColors() => customSelect(
        "SELECT COUNT(DISTINCT color) AS c FROM clothing_items "
        "WHERE color IS NOT NULL AND color != ''",
        readsFrom: {clothingItems},
      ).map((r) => r.read<int>('c')).watchSingle();

  // ── Distribuições do acervo ─────────────────────────────────────────────

  Stream<List<LabelCount>> watchCategoryDistribution() => customSelect(
        'SELECT category AS label, COUNT(*) AS count FROM clothing_items '
        'GROUP BY category ORDER BY count DESC',
        readsFrom: {clothingItems},
      ).watch().map((rows) => rows.map(_labelCount).toList());

  Stream<List<LabelCount>> watchColorDistribution() => customSelect(
        "SELECT color AS label, COUNT(*) AS count FROM clothing_items "
        "WHERE color IS NOT NULL AND color != '' "
        "GROUP BY color ORDER BY count DESC",
        readsFrom: {clothingItems},
      ).watch().map((rows) => rows.map(_labelCount).toList());

  Stream<List<LabelCount>> watchMonthlyGrowth() => customSelect(
        "SELECT strftime('%Y-%m', date_added / 1000, 'unixepoch', 'localtime') "
        "AS label, COUNT(*) AS count FROM clothing_items "
        "GROUP BY label ORDER BY label",
        readsFrom: {clothingItems},
      ).watch().map((rows) => rows.map(_labelCount).toList());

  // ── Uso de peças (derivado do histórico) ────────────────────────────────

  Stream<List<ItemStat>> watchMostUsedItems({int limit = 10}) => customSelect(
        'SELECT ci.id, ci.name, ci.image_path, ci.category, ci.color, '
        'COUNT(ou.id) AS value FROM clothing_items ci '
        'JOIN outfit_items oi ON oi.item_id = ci.id '
        'JOIN outfit_usages ou ON ou.outfit_id = oi.outfit_id '
        'GROUP BY ci.id ORDER BY value DESC, ci.name ASC LIMIT ?',
        variables: [Variable.withInt(limit)],
        readsFrom: {clothingItems, outfitItems, outfitUsages},
      ).watch().map((rows) => rows.map(_itemStat).toList());

  Stream<List<ItemStat>> watchNeverUsedItems() => customSelect(
        'SELECT ci.id, ci.name, ci.image_path, ci.category, ci.color, '
        '0 AS value FROM clothing_items ci WHERE ci.id NOT IN ('
        'SELECT oi.item_id FROM outfit_items oi '
        'JOIN outfit_usages ou ON ou.outfit_id = oi.outfit_id) '
        'ORDER BY ci.date_added DESC',
        readsFrom: {clothingItems, outfitItems, outfitUsages},
      ).watch().map((rows) => rows.map(_itemStat).toList());

  /// Peças que aparecem no maior número de looks (repetição no acervo).
  Stream<List<ItemStat>> watchMostRepeatedItems({int limit = 10}) =>
      customSelect(
        'SELECT ci.id, ci.name, ci.image_path, ci.category, ci.color, '
        'COUNT(oi.outfit_id) AS value FROM clothing_items ci '
        'JOIN outfit_items oi ON oi.item_id = ci.id '
        'GROUP BY ci.id ORDER BY value DESC, ci.name ASC LIMIT ?',
        variables: [Variable.withInt(limit)],
        readsFrom: {clothingItems, outfitItems},
      ).watch().map((rows) => rows.map(_itemStat).toList());

  /// Peças esquecidas: nunca usadas ou sem uso desde [before] (ms epoch).
  /// `value` carrega o último uso (0 = nunca).
  Stream<List<ItemStat>> watchForgottenItems({
    required int before,
    int limit = 20,
  }) =>
      customSelect(
        'SELECT ci.id, ci.name, ci.image_path, ci.category, ci.color, '
        'COALESCE(MAX(ou.used_at), 0) AS value FROM clothing_items ci '
        'LEFT JOIN outfit_items oi ON oi.item_id = ci.id '
        'LEFT JOIN outfit_usages ou ON ou.outfit_id = oi.outfit_id '
        'GROUP BY ci.id '
        'HAVING MAX(ou.used_at) IS NULL OR MAX(ou.used_at) < ? '
        'ORDER BY value ASC LIMIT ?',
        variables: [Variable.withInt(before), Variable.withInt(limit)],
        readsFrom: {clothingItems, outfitItems, outfitUsages},
      ).watch().map((rows) => rows.map(_itemStat).toList());

  Stream<List<OutfitStat>> watchForgottenOutfits({
    required int before,
    int limit = 20,
  }) =>
      customSelect(
        'SELECT o.id, o.name, COALESCE(MAX(ou.used_at), 0) AS value '
        'FROM outfits o LEFT JOIN outfit_usages ou ON ou.outfit_id = o.id '
        'GROUP BY o.id '
        'HAVING MAX(ou.used_at) IS NULL OR MAX(ou.used_at) < ? '
        'ORDER BY value ASC LIMIT ?',
        variables: [Variable.withInt(before), Variable.withInt(limit)],
        readsFrom: {outfits, outfitUsages},
      ).watch().map((rows) => rows.map(_outfitStat).toList());

  /// Combinação (look) mais registrada no histórico.
  Stream<OutfitStat?> watchMostCommonOutfit() => customSelect(
        'SELECT o.id, o.name, COUNT(ou.id) AS value FROM outfits o '
        'JOIN outfit_usages ou ON ou.outfit_id = o.id '
        'GROUP BY o.id ORDER BY value DESC LIMIT 1',
        readsFrom: {outfits, outfitUsages},
      ).watch().map((rows) => rows.isEmpty ? null : _outfitStat(rows.first));

  // ── Uso por categoria/cor (derivado do histórico) ───────────────────────

  /// Uso por categoria incluindo categorias com zero usos (ordenado desc).
  /// A UI lê o primeiro como "mais usada" e o último como "menos usada".
  Stream<List<LabelCount>> watchCategoryUsage() => customSelect(
        'SELECT cat.category AS label, COALESCE(u.c, 0) AS count FROM '
        '(SELECT DISTINCT category FROM clothing_items) cat '
        'LEFT JOIN (SELECT ci.category, COUNT(*) c FROM outfit_usages ou '
        'JOIN outfit_items oi ON oi.outfit_id = ou.outfit_id '
        'JOIN clothing_items ci ON ci.id = oi.item_id '
        'GROUP BY ci.category) u ON u.category = cat.category '
        'ORDER BY count DESC, label ASC',
        readsFrom: {clothingItems, outfitItems, outfitUsages},
      ).watch().map((rows) => rows.map(_labelCount).toList());

  Stream<List<LabelCount>> watchColorUsage() => customSelect(
        "SELECT ci.color AS label, COUNT(*) AS count FROM outfit_usages ou "
        "JOIN outfit_items oi ON oi.outfit_id = ou.outfit_id "
        "JOIN clothing_items ci ON ci.id = oi.item_id "
        "WHERE ci.color IS NOT NULL AND ci.color != '' "
        "GROUP BY ci.color ORDER BY count DESC",
        readsFrom: {clothingItems, outfitItems, outfitUsages},
      ).watch().map((rows) => rows.map(_labelCount).toList());

  // ── Atividade temporal ──────────────────────────────────────────────────

  /// Atividade por dia da semana; label = '0'..'6' (0 = domingo).
  Stream<List<LabelCount>> watchWeekdayActivity() => customSelect(
        "SELECT strftime('%w', used_at / 1000, 'unixepoch', 'localtime') "
        "AS label, COUNT(*) AS count FROM outfit_usages GROUP BY label",
        readsFrom: {outfitUsages},
      ).watch().map((rows) => rows.map(_labelCount).toList());

  Stream<List<LabelCount>> watchMonthlyActivity() => customSelect(
        "SELECT strftime('%Y-%m', used_at / 1000, 'unixepoch', 'localtime') "
        "AS label, COUNT(*) AS count FROM outfit_usages "
        "GROUP BY label ORDER BY label",
        readsFrom: {outfitUsages},
      ).watch().map((rows) => rows.map(_labelCount).toList());

  /// Usos registrados no intervalo [start, end) em ms epoch.
  Stream<int> watchUsageCountBetween(int start, int end) => customSelect(
        'SELECT COUNT(*) AS c FROM outfit_usages '
        'WHERE used_at >= ? AND used_at < ?',
        variables: [Variable.withInt(start), Variable.withInt(end)],
        readsFrom: {outfitUsages},
      ).map((r) => r.read<int>('c')).watchSingle();

  // ── Rotação / percentual de uso ─────────────────────────────────────────

  Stream<RotationStat> watchRotation() => customSelect(
        'SELECT (SELECT COUNT(*) FROM clothing_items) AS total, '
        '(SELECT COUNT(DISTINCT oi.item_id) FROM outfit_items oi '
        'JOIN outfit_usages ou ON ou.outfit_id = oi.outfit_id) AS used',
        readsFrom: {clothingItems, outfitItems, outfitUsages},
      ).map((r) => RotationStat(r.read<int>('total'), r.read<int>('used')))
          .watchSingle();
}
