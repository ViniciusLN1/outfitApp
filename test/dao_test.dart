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

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<void> addItem(String id, String category) =>
      db.clothingDao.upsertItem(ClothingItemsCompanion(
        id: Value(id),
        name: Value('nome-$id'),
        imagePath: Value('/tmp/$id.png'),
        category: Value(category),
        dateAdded: Value(0),
      ));

  Future<void> addOutfit(
    String id, {
    int favorite = 0,
    int usage = 0,
    int date = 0,
  }) =>
      db.outfitDao.upsertOutfit(OutfitsCompanion(
        id: Value(id),
        name: Value('look-$id'),
        isFavorite: Value(favorite),
        usageCount: Value(usage),
        dateCreated: Value(date),
      ));

  group('ClothingDao', () {
    test('watchByCategory filtra pela categoria', () async {
      await addItem('a', 'camisa');
      await addItem('b', 'calca');
      await addItem('c', 'camisa');
      final camisas = await db.clothingDao.watchByCategory('camisa').first;
      expect(camisas.map((e) => e.id).toSet(), {'a', 'c'});
    });

    test('watchRecent ordena por dateAdded desc e respeita o limite', () async {
      await db.clothingDao.upsertItem(const ClothingItemsCompanion(
        id: Value('old'),
        name: Value('old'),
        imagePath: Value('/tmp/old.png'),
        category: Value('camisa'),
        dateAdded: Value(1),
      ));
      await db.clothingDao.upsertItem(const ClothingItemsCompanion(
        id: Value('new'),
        name: Value('new'),
        imagePath: Value('/tmp/new.png'),
        category: Value('camisa'),
        dateAdded: Value(2),
      ));
      final recent = await db.clothingDao.watchRecent(limit: 1).first;
      expect(recent.single.id, 'new');
    });
  });

  group('OutfitDao', () {
    test('watchFavoritesFirst coloca favoritos no topo', () async {
      await addOutfit('a', favorite: 0, date: 2);
      await addOutfit('b', favorite: 1, date: 1);
      final ordered = await db.outfitDao.watchFavoritesFirst().first;
      expect(ordered.first.id, 'b');
    });

    test('watchMostUsed ordena por usageCount desc', () async {
      await addOutfit('a', usage: 1);
      await addOutfit('b', usage: 5);
      final ordered = await db.outfitDao.watchMostUsed().first;
      expect(ordered.first.id, 'b');
    });

    test('toggleFavorite persiste o novo valor', () async {
      await addOutfit('a');
      await db.outfitDao.toggleFavorite('a', true);
      final row = await (db.select(db.outfits)
            ..where((t) => t.id.equals('a')))
          .getSingle();
      expect(row.isFavorite, 1);
    });

    test('renameOutfit altera apenas o nome', () async {
      await addOutfit('a', favorite: 1, usage: 3);
      await db.outfitDao.renameOutfit('a', 'novo nome');
      final row = await (db.select(db.outfits)
            ..where((t) => t.id.equals('a')))
          .getSingle();
      expect(row.name, 'novo nome');
      expect(row.isFavorite, 1);
      expect(row.usageCount, 3);
    });
  });
}
