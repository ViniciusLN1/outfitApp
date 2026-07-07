import 'dart:ffi';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:outfit_app/controllers/clothing_controller.dart';
import 'package:outfit_app/controllers/outfit_controller.dart';
import 'package:outfit_app/database/app_database.dart';
import 'package:outfit_app/models/item_transform.dart';
import 'package:sqlite3/open.dart';

void main() {
  if (Platform.isLinux) {
    open.overrideFor(
      OperatingSystem.linux,
      () => DynamicLibrary.open('libsqlite3.so.0'),
    );
  }

  late AppDatabase db;
  late ProviderContainer container;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
  });

  tearDown(() {
    container.dispose();
    return db.close();
  });

  Future<void> addItem(String id, String category) =>
      db.clothingDao.upsertItem(ClothingItemsCompanion(
        id: Value(id),
        name: Value('nome-$id'),
        imagePath: Value('/tmp/$id.png'),
        category: Value(category),
        dateAdded: Value(0),
      ));

  OutfitController controller() =>
      container.read(outfitControllerProvider.notifier);

  test('saveOutfit persiste o look com as peças e o posicionamento', () async {
    await addItem('camisa-1', 'camisa');
    const t = ItemTransform(centerX: 0.4, centerY: 0.6, size: 0.5, z: 2);

    final id = await controller().saveOutfit(
      name: 'Look A',
      placements: [(itemId: 'camisa-1', transform: t)],
    );

    final placements = await db.watchOutfitPlacements(id).first;
    expect(placements, hasLength(1));
    expect(placements.single.item.id, 'camisa-1');
    expect(placements.single.transform.centerX, 0.4);
    expect(placements.single.transform.size, 0.5);
    expect(placements.single.transform.z, 2);
  });

  test('saveOutfit em edição preserva favorito/uso e troca as peças', () async {
    await addItem('camisa-1', 'camisa');
    await addItem('calca-1', 'calca');
    const t = ItemTransform(centerX: 0.5, centerY: 0.5, size: 0.4);

    final id = await controller().saveOutfit(
      name: 'Original',
      placements: [(itemId: 'camisa-1', transform: t)],
    );
    await db.outfitDao.toggleFavorite(id, true);
    await db.outfitDao.incrementUsage(id);

    await controller().saveOutfit(
      name: 'Editado',
      placements: [(itemId: 'calca-1', transform: t)],
      existingId: id,
    );

    final outfit = await (db.select(db.outfits)
          ..where((t) => t.id.equals(id)))
        .getSingle();
    expect(outfit.name, 'Editado');
    expect(outfit.isFavorite, 1, reason: 'favorito deve ser preservado');
    expect(outfit.usageCount, 1, reason: 'contador de uso deve ser preservado');

    final placements = await db.watchOutfitPlacements(id).first;
    expect(placements.map((p) => p.item.id), ['calca-1']);
  });

  test('deleteOutfit remove o look e faz cascade nas peças', () async {
    await addItem('camisa-1', 'camisa');
    const t = ItemTransform(centerX: 0.5, centerY: 0.5, size: 0.4);
    final id = await controller().saveOutfit(
      name: 'Look',
      placements: [(itemId: 'camisa-1', transform: t)],
    );

    await controller().deleteOutfit(id);

    final outfits = await db.select(db.outfits).get();
    final links = await db.select(db.outfitItems).get();
    expect(outfits, isEmpty);
    expect(links, isEmpty);
  });
}
