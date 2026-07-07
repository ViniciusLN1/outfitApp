import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../models/clothing_item.dart';
import '../models/item_transform.dart';
import '../models/outfit.dart';
import '../models/outfit_item.dart';
import '../models/outfit_usage.dart';
import 'daos/clothing_dao.dart';
import 'daos/outfit_dao.dart';
import 'daos/stats_dao.dart';
import 'daos/usage_dao.dart';

part 'app_database.g.dart';

/// Peça de um look já resolvida com seu posicionamento normalizado.
class OutfitPlacement {
  final ClothingItem item;
  final ItemTransform transform;
  const OutfitPlacement({required this.item, required this.transform});
}

/// Registro de uso resolvido com o look correspondente (para calendário/histórico).
class UsageEntry {
  final OutfitUsage usage;
  final Outfit outfit;
  const UsageEntry({required this.usage, required this.outfit});
}

@DriftDatabase(
  tables: [ClothingItems, Outfits, OutfitItems, OutfitUsages],
  daos: [ClothingDao, OutfitDao, UsageDao, StatsDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await customStatement(
              "UPDATE clothing_items SET category = 'acessorios' "
              "WHERE category = 'complemento'",
            );
          }
          if (from < 3) {
            await m.addColumn(outfitItems, outfitItems.centerX);
            await m.addColumn(outfitItems, outfitItems.centerY);
            await m.addColumn(outfitItems, outfitItems.itemSize);
            await m.addColumn(outfitItems, outfitItems.zIndex);
          }
          if (from < 4) {
            await m.createIndex(idxOutfitItemsItemId);
            await m.createIndex(idxOutfitsDateCreated);
            await m.createIndex(idxOutfitsFavoriteDate);
            await m.createIndex(idxClothingItemsCategory);
            await m.createIndex(idxClothingItemsDateAdded);
          }
          if (from < 5) {
            await m.addColumn(clothingItems, clothingItems.color);
            await m.createTable(outfitUsages);
            await m.createIndex(idxOutfitUsagesOutfitId);
            await m.createIndex(idxOutfitUsagesUsedAt);
            // Remove o contador materializado: uso passa a ser derivado do
            // histórico (outfit_usages). TableMigration recria a tabela sem a
            // coluna usage_count (e seu índice antigo).
            // ignore: experimental_member_use
            await m.alterTable(TableMigration(outfits));
          }
        },
        beforeOpen: (details) async {
          // SQLite exige este pragma por conexão; sem ele o ON DELETE CASCADE
          // declarado nas tabelas é ignorado.
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  /// Peças de um look com o posicionamento salvo (ordenadas por z).
  /// Looks legados (itemSize == 0) recebem o layout anatômico padrão.
  Stream<List<OutfitPlacement>> watchOutfitPlacements(String outfitId) {
    final query = select(clothingItems).join([
      innerJoin(outfitItems, outfitItems.itemId.equalsExp(clothingItems.id)),
    ])
      ..where(outfitItems.outfitId.equals(outfitId))
      ..orderBy([OrderingTerm.asc(outfitItems.zIndex)]);
    return query.watch().map(
          (rows) => rows.map((r) {
            final item = r.readTable(clothingItems);
            final oi = r.readTable(outfitItems);
            final transform = oi.itemSize > 0
                ? ItemTransform(
                    centerX: oi.centerX,
                    centerY: oi.centerY,
                    size: oi.itemSize,
                    z: oi.zIndex,
                  )
                : defaultTransformFor(item.category);
            return OutfitPlacement(item: item, transform: transform);
          }).toList(),
        );
  }

  /// Registros de uso resolvidos com o look, do mais recente ao mais antigo.
  /// Se [outfitId] for informado, filtra apenas aquele look.
  Stream<List<UsageEntry>> watchUsageEntries({String? outfitId}) {
    final query = select(outfitUsages).join([
      innerJoin(outfits, outfits.id.equalsExp(outfitUsages.outfitId)),
    ])
      ..orderBy([OrderingTerm.desc(outfitUsages.usedAt)]);
    if (outfitId != null) {
      query.where(outfitUsages.outfitId.equals(outfitId));
    }
    return query.watch().map(
          (rows) => rows
              .map((r) => UsageEntry(
                    usage: r.readTable(outfitUsages),
                    outfit: r.readTable(outfits),
                  ))
              .toList(),
        );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'outfit_app.db'));
    return NativeDatabase.createInBackground(file);
  });
}
