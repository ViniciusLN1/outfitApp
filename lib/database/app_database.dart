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
  AppDatabase() : this.open('outfit_app.db');

  /// Abre o banco em `documents/<fileName>` (um arquivo por usuário logado;
  /// `outfit_app.db` é o do modo convidado).
  AppDatabase.open(String fileName) : super(_openConnection(fileName));

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
            // Guarda contra migração anterior interrompida no meio (o ALTER
            // TABLE já aplicado não é revertido pelo SQLite).
            final hasColor = (await customSelect(
              "SELECT 1 FROM pragma_table_info('clothing_items') "
              "WHERE name = 'color'",
            ).get())
                .isNotEmpty;
            if (!hasColor) {
              await m.addColumn(clothingItems, clothingItems.color);
            }
            await m.createTable(outfitUsages);
            await customStatement(
              'CREATE INDEX IF NOT EXISTS idx_outfit_usages_outfit_id '
              'ON outfit_usages (outfit_id)',
            );
            await customStatement(
              'CREATE INDEX IF NOT EXISTS idx_outfit_usages_used_at '
              'ON outfit_usages (used_at)',
            );
            // Remove o contador materializado: uso passa a ser derivado do
            // histórico (outfit_usages). TableMigration recria a tabela sem a
            // coluna usage_count (e seu índice antigo).
            await customStatement(
              'DROP INDEX IF EXISTS idx_outfits_usage_date',
            );
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

/// Executado no isolate do banco antes de abrir. O isolate spawnado não herda
/// o `open.overrideFor` do main isolate; os testes no Linux injetam aqui o
/// override da libsqlite3 do sistema.
Future<void> Function()? databaseIsolateSetup;

LazyDatabase _openConnection(String fileName) {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, fileName));
    return NativeDatabase.createInBackground(
      file,
      isolateSetup: databaseIsolateSetup,
    );
  });
}
