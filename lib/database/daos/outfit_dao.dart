import 'package:drift/drift.dart';

import '../app_database.dart';
import '../../models/outfit.dart';
import '../../models/outfit_item.dart';

part 'outfit_dao.g.dart';

@DriftAccessor(tables: [Outfits, OutfitItems])
class OutfitDao extends DatabaseAccessor<AppDatabase> with _$OutfitDaoMixin {
  OutfitDao(super.db);

  Stream<List<Outfit>> watchAll() => select(outfits).watch();

  Stream<List<Outfit>> watchRecent({int limit = 10}) =>
      (select(outfits)
            ..orderBy([(t) => OrderingTerm.desc(t.dateCreated)])
            ..limit(limit))
          .watch();

  Stream<List<Outfit>> watchFavoritesFirst() =>
      (select(outfits)
            ..orderBy([
              (t) => OrderingTerm.desc(t.isFavorite),
              (t) => OrderingTerm.desc(t.dateCreated),
            ]))
          .watch();

  Stream<List<Outfit>> watchMostUsed() =>
      (select(outfits)
            ..orderBy([
              (t) => OrderingTerm.desc(t.usageCount),
              (t) => OrderingTerm.desc(t.dateCreated),
            ]))
          .watch();

  Future<void> upsertOutfit(OutfitsCompanion companion) =>
      into(outfits).insertOnConflictUpdate(companion);

  Future<void> insertOutfitItem(OutfitItemsCompanion companion) =>
      into(outfitItems).insertOnConflictUpdate(companion);

  Future<int> deleteOutfit(String id) =>
      (delete(outfits)..where((t) => t.id.equals(id))).go();

  Future<int> deleteOutfitItems(String outfitId) =>
      (delete(outfitItems)..where((t) => t.outfitId.equals(outfitId))).go();

  Future<void> toggleFavorite(String id, bool newValue) =>
      (update(outfits)..where((t) => t.id.equals(id)))
          .write(OutfitsCompanion(isFavorite: Value(newValue ? 1 : 0)));

  Future<void> renameOutfit(String id, String name) =>
      (update(outfits)..where((t) => t.id.equals(id)))
          .write(OutfitsCompanion(name: Value(name)));

  Future<void> incrementUsage(String id) =>
      (update(outfits)..where((t) => t.id.equals(id))).write(
        OutfitsCompanion.custom(
          usageCount: outfits.usageCount + const Constant(1),
        ),
      );
}
