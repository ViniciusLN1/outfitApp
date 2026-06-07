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

  Future<int> deleteItem(String id) =>
      (delete(clothingItems)..where((t) => t.id.equals(id))).go();
}
