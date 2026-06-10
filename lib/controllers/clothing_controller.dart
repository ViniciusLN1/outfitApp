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

final recentClothingProvider = StreamProvider<List<ClothingItem>>((ref) {
  return ref.watch(appDatabaseProvider).clothingDao.watchRecent(limit: 10);
});

final clothingItemsForOutfitProvider =
    StreamProvider.family<List<ClothingItem>, String>((ref, outfitId) {
  return ref.watch(appDatabaseProvider).watchClothingItemsForOutfit(outfitId);
});

@riverpod
class ClothingController extends _$ClothingController {
  @override
  FutureOr<void> build() {}

  Future<void> addItem({
    required String name,
    required String imagePath,
    required String category,
  }) async {
    final db = ref.read(appDatabaseProvider);
    await db.clothingDao.upsertItem(ClothingItemsCompanion(
      id: Value(const Uuid().v4()),
      name: Value(name),
      imagePath: Value(imagePath),
      category: Value(category),
      dateAdded: Value(DateTime.now().millisecondsSinceEpoch),
    ));
  }

  Future<void> updateItem({
    required String id,
    required String name,
    required String category,
  }) async {
    final db = ref.read(appDatabaseProvider);
    await db.clothingDao.updateItem(id, name: name, category: category);
  }

  Future<void> deleteItem(String id) async {
    final db = ref.read(appDatabaseProvider);
    await db.clothingDao.deleteItem(id);
  }
}
