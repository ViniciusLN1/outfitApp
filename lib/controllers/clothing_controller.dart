import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../database/app_database.dart';

part 'clothing_controller.g.dart';

@Riverpod(keepAlive: true)
AppDatabase appDatabase(AppDatabaseRef ref) => AppDatabase();

@riverpod
Stream<List<ClothingItem>> clothingItems(ClothingItemsRef ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.clothingDao.watchAll();
}

@riverpod
Stream<List<ClothingItem>> clothingByCategory(ClothingByCategoryRef ref, String category) {
  final db = ref.watch(appDatabaseProvider);
  return db.clothingDao.watchByCategory(category);
}

@riverpod
Stream<List<ClothingItem>> recentClothing(RecentClothingRef ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.clothingDao.watchRecent(limit: 10);
}

@riverpod
Stream<List<OutfitPlacement>> outfitPlacements(
  OutfitPlacementsRef ref,
  String outfitId,
) {
  final db = ref.watch(appDatabaseProvider);
  return db.watchOutfitPlacements(outfitId);
}

@riverpod
class ClothingController extends _$ClothingController {
  @override
  FutureOr<void> build() {}

  Future<void> addItem({
    required String name,
    required String imagePath,
    required String category,
    String? color,
  }) async {
    final db = ref.read(appDatabaseProvider);
    await db.clothingDao.upsertItem(ClothingItemsCompanion(
      id: Value(const Uuid().v4()),
      name: Value(name),
      imagePath: Value(imagePath),
      category: Value(category),
      color: Value(color),
      dateAdded: Value(DateTime.now().millisecondsSinceEpoch),
    ));
  }

  Future<void> updateItem({
    required String id,
    required String name,
    required String category,
    String? color,
  }) async {
    final db = ref.read(appDatabaseProvider);
    await db.clothingDao
        .updateItem(id, name: name, category: category, color: color);
  }

  Future<void> deleteItem(String id) async {
    final db = ref.read(appDatabaseProvider);
    await db.clothingDao.deleteItem(id);
  }
}
