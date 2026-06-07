import 'package:drift/drift.dart';

import '../app_database.dart';
import '../../models/outfit.dart';
import '../../models/outfit_item.dart';

part 'outfit_dao.g.dart';

@DriftAccessor(tables: [Outfits, OutfitItems])
class OutfitDao extends DatabaseAccessor<AppDatabase> with _$OutfitDaoMixin {
  OutfitDao(super.db);

  Stream<List<Outfit>> watchAll() => select(outfits).watch();

  Stream<List<Outfit>> watchFavoritesFirst() =>
      (select(outfits)
            ..orderBy([(t) => OrderingTerm.desc(t.isFavorite)]))
          .watch();

  Stream<List<Outfit>> watchMostUsed() =>
      (select(outfits)
            ..orderBy([(t) => OrderingTerm.desc(t.usageCount)]))
          .watch();

  Future<List<OutfitItem>> getItemsForOutfit(String outfitId) =>
      (select(outfitItems)..where((t) => t.outfitId.equals(outfitId))).get();

  Future<void> upsertOutfit(OutfitsCompanion companion) =>
      into(outfits).insertOnConflictUpdate(companion);

  Future<void> insertOutfitItem(OutfitItemsCompanion companion) =>
      into(outfitItems).insertOnConflictUpdate(companion);

  Future<int> deleteOutfit(String id) =>
      (delete(outfits)..where((t) => t.id.equals(id))).go();

  Future<void> toggleFavorite(String id, bool newValue) =>
      (update(outfits)..where((t) => t.id.equals(id)))
          .write(OutfitsCompanion(isFavorite: Value(newValue ? 1 : 0)));

  Future<void> incrementUsage(String id) async {
    final outfit =
        await (select(outfits)..where((t) => t.id.equals(id))).getSingle();
    await (update(outfits)..where((t) => t.id.equals(id)))
        .write(OutfitsCompanion(usageCount: Value(outfit.usageCount + 1)));
  }
}
