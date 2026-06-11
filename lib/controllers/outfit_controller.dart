import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../database/app_database.dart';
import '../models/item_transform.dart';
import 'clothing_controller.dart';

part 'outfit_controller.g.dart';

/// Peça + posicionamento a ser persistido junto ao look.
typedef OutfitItemPlacement = ({String itemId, ItemTransform transform});

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
    required List<OutfitItemPlacement> placements,
    String? existingId,
  }) async {
    final db = ref.read(appDatabaseProvider);
    final id = existingId ?? const Uuid().v4();
    await db.outfitDao.upsertOutfit(OutfitsCompanion(
      id: Value(id),
      name: Value(name),
      dateCreated: Value(DateTime.now().millisecondsSinceEpoch),
    ));
    for (final p in placements) {
      await db.outfitDao.insertOutfitItem(OutfitItemsCompanion(
        outfitId: Value(id),
        itemId: Value(p.itemId),
        centerX: Value(p.transform.centerX),
        centerY: Value(p.transform.centerY),
        itemSize: Value(p.transform.size),
        zIndex: Value(p.transform.z),
      ));
    }
    return id;
  }

  Future<void> toggleFavorite(String id, bool currentValue) async {
    final db = ref.read(appDatabaseProvider);
    await db.outfitDao.toggleFavorite(id, !currentValue);
  }

  Future<void> renameOutfit(String id, String name) async {
    final db = ref.read(appDatabaseProvider);
    await db.outfitDao.renameOutfit(id, name);
  }

  Future<void> deleteOutfit(String id) async {
    final db = ref.read(appDatabaseProvider);
    await db.outfitDao.deleteOutfit(id);
  }
}
