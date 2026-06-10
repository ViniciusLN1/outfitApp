import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../database/app_database.dart';
import 'clothing_controller.dart';

part 'constructor_controller.g.dart';

enum ClothingCategory {
  chapeu,
  camisa,
  blusa,
  cinto,
  calca,
  sapato,
  acessorios,
}

extension ClothingCategoryLabel on ClothingCategory {
  String get displayName => switch (this) {
        ClothingCategory.chapeu => 'Chapéu/Boné',
        ClothingCategory.camisa => 'Camisa',
        ClothingCategory.blusa => 'Blusa/Jaqueta',
        ClothingCategory.cinto => 'Cinto',
        ClothingCategory.calca => 'Calça',
        ClothingCategory.sapato => 'Sapato',
        ClothingCategory.acessorios => 'Acessórios',
      };
}

typedef CanvasState = Map<ClothingCategory, ClothingItem?>;

@riverpod
class ConstructorController extends _$ConstructorController {
  @override
  CanvasState build() => {
        ClothingCategory.chapeu: null,
        ClothingCategory.camisa: null,
        ClothingCategory.blusa: null,
        ClothingCategory.cinto: null,
        ClothingCategory.calca: null,
        ClothingCategory.sapato: null,
        ClothingCategory.acessorios: null,
      };

  void selectItem(ClothingCategory category, ClothingItem? item) {
    state = {...state, category: item};
  }

  void clearCategory(ClothingCategory category) {
    state = {...state, category: null};
  }

  void clearAll() {
    state = build();
  }

  Future<void> loadOutfit(String outfitId) async {
    final db = ref.read(appDatabaseProvider);
    final outfitItems = await db.outfitDao.getItemsForOutfit(outfitId);
    final itemIds = outfitItems.map((e) => e.itemId).toList();
    final allItems = await db.clothingDao.watchAll().first;
    final relevant = {
      for (final item in allItems.where((i) => itemIds.contains(i.id)))
        ClothingCategory.values.firstWhere(
          (c) => c.name == item.category,
          orElse: () => ClothingCategory.acessorios,
        ): item,
    };
    state = {...build(), ...relevant};
  }
}
