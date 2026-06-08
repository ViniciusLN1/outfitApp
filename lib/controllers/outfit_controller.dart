import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../database/app_database.dart';
import 'clothing_controller.dart';

part 'outfit_controller.g.dart';

enum OutfitSortMode { favoritesFirst, mostUsed }

@riverpod
Stream<List<Outfit>> outfitsSorted(OutfitsSortedRef ref, OutfitSortMode mode) {
  final db = ref.watch(appDatabaseProvider);
  return switch (mode) {
    OutfitSortMode.favoritesFirst => db.outfitDao.watchFavoritesFirst(),
    OutfitSortMode.mostUsed => db.outfitDao.watchMostUsed(),
  };
}

@riverpod
Stream<int> totalClothingItems(TotalClothingItemsRef ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.clothingItems.count().watchSingle();
}

@riverpod
Stream<int> totalOutfits(TotalOutfitsRef ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.outfits.count().watchSingle();
}

final recentOutfitsProvider = StreamProvider<List<Outfit>>((ref) {
  return ref.watch(appDatabaseProvider).outfitDao.watchRecent(limit: 10);
});

@riverpod
class OutfitController extends _$OutfitController {
  @override
  FutureOr<void> build() {}

  Future<String> saveOutfit({
    required String name,
    required List<String> itemIds,
    String? existingId,
  }) async {
    final db = ref.read(appDatabaseProvider);
    final id = existingId ?? const Uuid().v4();
    await db.outfitDao.upsertOutfit(OutfitsCompanion(
      id: Value(id),
      name: Value(name),
      dateCreated: Value(DateTime.now().millisecondsSinceEpoch),
    ));
    for (final itemId in itemIds) {
      await db.outfitDao.insertOutfitItem(OutfitItemsCompanion(
        outfitId: Value(id),
        itemId: Value(itemId),
      ));
    }
    return id;
  }

  Future<void> toggleFavorite(String id, bool currentValue) async {
    final db = ref.read(appDatabaseProvider);
    await db.outfitDao.toggleFavorite(id, !currentValue);
  }

  Future<void> deleteOutfit(String id) async {
    final db = ref.read(appDatabaseProvider);
    await db.outfitDao.deleteOutfit(id);
  }
}
