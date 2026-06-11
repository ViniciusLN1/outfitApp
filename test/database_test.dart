import 'dart:ffi';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:outfit_app/database/app_database.dart';
import 'package:sqlite3/open.dart';

void main() {
  if (Platform.isLinux) {
    open.overrideFor(
      OperatingSystem.linux,
      () => DynamicLibrary.open('libsqlite3.so.0'),
    );
  }

  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  Future<void> seedOutfitWithItem() async {
    await db.clothingDao.upsertItem(
      const ClothingItemsCompanion(
        id: Value('item-1'),
        name: Value('Camisa'),
        imagePath: Value('/tmp/c.png'),
        category: Value('camisa'),
        dateAdded: Value(0),
      ),
    );
    await db.outfitDao.upsertOutfit(
      const OutfitsCompanion(
        id: Value('outfit-1'),
        name: Value('Look 1'),
        dateCreated: Value(0),
      ),
    );
    await db.outfitDao.insertOutfitItem(
      const OutfitItemsCompanion(
        outfitId: Value('outfit-1'),
        itemId: Value('item-1'),
      ),
    );
  }

  test('deleting an outfit cascades to outfit_items', () async {
    await seedOutfitWithItem();
    await db.outfitDao.deleteOutfit('outfit-1');
    final remaining = await db.select(db.outfitItems).get();
    expect(remaining, isEmpty);
  });

  test('deleting a clothing item cascades to outfit_items', () async {
    await seedOutfitWithItem();
    await db.clothingDao.deleteItem('item-1');
    final remaining = await db.select(db.outfitItems).get();
    expect(remaining, isEmpty);
  });

  test('incrementUsage increments atomically without prior read', () async {
    await seedOutfitWithItem();
    await db.outfitDao.incrementUsage('outfit-1');
    await db.outfitDao.incrementUsage('outfit-1');
    final outfit = await (db.select(db.outfits)
          ..where((t) => t.id.equals('outfit-1')))
        .getSingle();
    expect(outfit.usageCount, 2);
  });

  test('schema creates the v4 indexes', () async {
    final rows = await db
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'index' "
          "AND name LIKE 'idx_%'",
        )
        .get();
    final names = rows.map((r) => r.read<String>('name')).toSet();
    expect(
      names,
      containsAll({
        'idx_outfit_items_item_id',
        'idx_outfits_date_created',
        'idx_outfits_favorite_date',
        'idx_outfits_usage_date',
        'idx_clothing_items_category',
        'idx_clothing_items_date_added',
      }),
    );
  });
}
