import 'package:drift/drift.dart';

import '../app_database.dart';
import '../../models/clothing_item.dart';

part 'clothing_dao.g.dart';

@DriftAccessor(tables: [ClothingItems])
class ClothingDao extends DatabaseAccessor<AppDatabase>
    with _$ClothingDaoMixin {
  ClothingDao(super.db);

  Stream<List<ClothingItem>> watchAll() => select(clothingItems).watch();

  Stream<List<ClothingItem>> watchByCategory(String category) =>
      (select(clothingItems)
            ..where((t) => t.category.equals(category)))
          .watch();

  Future<void> upsertItem(ClothingItemsCompanion item) =>
      into(clothingItems).insertOnConflictUpdate(item);

  Future<void> updateItem(
    String id, {
    required String name,
    required String category,
    required String? color,
  }) =>
      (update(clothingItems)..where((t) => t.id.equals(id))).write(
        ClothingItemsCompanion(
          name: Value(name),
          category: Value(category),
          color: Value(color),
        ),
      );

  Stream<List<ClothingItem>> watchRecent({int limit = 10}) =>
      (select(clothingItems)
            ..orderBy([(t) => OrderingTerm.desc(t.dateAdded)])
            ..limit(limit))
          .watch();

  Future<int> deleteItem(String id) =>
      (delete(clothingItems)..where((t) => t.id.equals(id))).go();
}
