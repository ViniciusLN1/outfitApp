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

  test('deleting an outfit cascades to outfit_usages', () async {
    await seedOutfitWithItem();
    await db.usageDao.registerUsage(
      outfitId: 'outfit-1',
      when: DateTime.fromMillisecondsSinceEpoch(0),
      hasTime: false,
    );
    await db.outfitDao.deleteOutfit('outfit-1');
    final remaining = await db.select(db.outfitUsages).get();
    expect(remaining, isEmpty);
  });

  test('schema creates the expected indexes', () async {
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
        'idx_clothing_items_category',
        'idx_clothing_items_date_added',
        'idx_outfit_usages_outfit_id',
        'idx_outfit_usages_used_at',
      }),
    );
  });
}
