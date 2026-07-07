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

  Future<void> addItem(String id, String category, {String? color}) =>
      db.clothingDao.upsertItem(ClothingItemsCompanion(
        id: Value(id),
        name: Value('nome-$id'),
        imagePath: Value('/tmp/$id.png'),
        category: Value(category),
        color: Value(color),
        dateAdded: Value(0),
      ));

  Future<void> addOutfit(String id) => db.outfitDao.upsertOutfit(
        OutfitsCompanion(id: Value(id), name: Value('look-$id'), dateCreated: const Value(0)),
      );

  Future<void> link(String outfitId, String itemId) =>
      db.outfitDao.insertOutfitItem(
        OutfitItemsCompanion(outfitId: Value(outfitId), itemId: Value(itemId)),
      );

  Future<void> use(String outfitId, int ms) => db.usageDao.registerUsage(
        outfitId: outfitId,
        when: DateTime.fromMillisecondsSinceEpoch(ms),
        hasTime: false,
      );

  test('registro e histórico de uso por outfit', () async {
    await addOutfit('o1');
    await use('o1', 100);
    await use('o1', 200);
    expect(await db.usageDao.watchTotalForOutfit('o1').first, 2);
    expect(await db.usageDao.watchLastForOutfit('o1').first, 200);
    final hist = await db.usageDao.watchForOutfit('o1').first;
    expect(hist.map((u) => u.usedAt), [200, 100]); // desc
  });

  test('most used items deriva do histórico', () async {
    await addItem('camisa', 'camisa');
    await addItem('calca', 'calca');
    await addOutfit('o1');
    await addOutfit('o2');
    await link('o1', 'camisa');
    await link('o2', 'camisa');
    await link('o2', 'calca');
    await use('o1', 1);
    await use('o2', 2);
    final top = await db.statsDao.watchMostUsedItems().first;
    expect(top.first.id, 'camisa'); // camisa aparece em 2 usos
    expect(top.first.value, 2);
  });

  test('never used items lista peças fora de looks usados', () async {
    await addItem('camisa', 'camisa');
    await addItem('sapato', 'sapato');
    await addOutfit('o1');
    await link('o1', 'camisa');
    await use('o1', 1);
    final never = await db.statsDao.watchNeverUsedItems().first;
    expect(never.map((i) => i.id), ['sapato']);
  });

  test('distribuições de categoria e cor', () async {
    await addItem('a', 'camisa', color: 'azul');
    await addItem('b', 'camisa', color: 'azul');
    await addItem('c', 'calca', color: 'preto');
    final cats = await db.statsDao.watchCategoryDistribution().first;
    expect(cats.first.label, 'camisa');
    expect(cats.first.count, 2);
    final colors = await db.statsDao.watchColorDistribution().first;
    expect(colors.first.label, 'azul');
    expect(colors.first.count, 2);
    expect(await db.statsDao.watchTotalColors().first, 2);
  });

  test('rotação conta peças distintas usadas sobre o total', () async {
    await addItem('camisa', 'camisa');
    await addItem('sapato', 'sapato');
    await addOutfit('o1');
    await link('o1', 'camisa');
    await use('o1', 1);
    final rot = await db.statsDao.watchRotation().first;
    expect(rot.total, 2);
    expect(rot.used, 1);
    expect(rot.ratio, 0.5);
  });
}
