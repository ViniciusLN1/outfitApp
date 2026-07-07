import 'dart:ffi';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:outfit_app/controllers/clothing_controller.dart';
import 'package:outfit_app/controllers/constructor_controller.dart';
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

  Future<ClothingItem> addItem(String id, String category) async {
    await db.clothingDao.upsertItem(ClothingItemsCompanion(
      id: Value(id),
      name: Value('nome-$id'),
      imagePath: Value('/tmp/$id.png'),
      category: Value(category),
      dateAdded: Value(0),
    ));
    return (db.select(db.clothingItems)..where((t) => t.id.equals(id)))
        .getSingle();
  }

  ConstructorController controller() =>
      container.read(constructorControllerProvider.notifier);

  test('estado inicial tem todas as categorias vazias', () {
    final state = container.read(constructorControllerProvider);
    expect(state.occupied, isEmpty);
    expect(state.items.keys.toSet(), ClothingCategory.values.toSet());
  });

  test('selectItem aloca a peça e occupied reflete a mudança', () async {
    final item = await addItem('camisa-1', 'camisa');
    controller().selectItem(ClothingCategory.camisa, item);

    final state = container.read(constructorControllerProvider);
    expect(state.items[ClothingCategory.camisa]?.id, 'camisa-1');
    expect(state.occupied, [ClothingCategory.camisa]);
  });

  test('clearAll restaura o estado inicial', () async {
    final item = await addItem('camisa-1', 'camisa');
    controller().selectItem(ClothingCategory.camisa, item);
    controller().clearAll();

    final state = container.read(constructorControllerProvider);
    expect(state.occupied, isEmpty);
    expect(state.editingOutfitId, null);
  });

  test('loadOutfit reidrata o canvas para edição', () async {
    await addItem('camisa-1', 'camisa');
    const t = ItemTransform(centerX: 0.3, centerY: 0.4, size: 0.5, z: 1);
    final id = await container.read(outfitControllerProvider.notifier).saveOutfit(
          name: 'Look edição',
          placements: [(itemId: 'camisa-1', transform: t)],
        );

    await controller().loadOutfit(id);

    final state = container.read(constructorControllerProvider);
    expect(state.editingOutfitId, id);
    expect(state.editingOutfitName, 'Look edição');
    expect(state.items[ClothingCategory.camisa]?.id, 'camisa-1');
    expect(state.transforms[ClothingCategory.camisa]?.centerX, 0.3);
    expect(state.transforms[ClothingCategory.camisa]?.size, 0.5);
  });
}
