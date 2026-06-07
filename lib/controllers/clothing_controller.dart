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

  Future<void> deleteItem(String id) async {
    final db = ref.read(appDatabaseProvider);
    await db.clothingDao.deleteItem(id);
  }
}
