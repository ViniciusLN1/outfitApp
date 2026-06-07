import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../database/app_database.dart';
import 'clothing_controller.dart';

part 'constructor_controller.g.dart';

enum ClothingCategory { camisa, calca, sapato, cinto, complemento }

typedef CanvasState = Map<ClothingCategory, ClothingItem?>;

@riverpod
class ConstructorController extends _$ConstructorController {
  @override
  CanvasState build() => {
        ClothingCategory.camisa: null,
        ClothingCategory.calca: null,
        ClothingCategory.sapato: null,
        ClothingCategory.cinto: null,
        ClothingCategory.complemento: null,
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

  /// Popula o canvas com as peças de um outfit existente para edição.
  /// Deve ser chamado antes de navegar para a aba do Construtor.
  Future<void> loadOutfit(String outfitId) async {
    final db = ref.read(appDatabaseProvider);
    final outfitItems = await db.outfitDao.getItemsForOutfit(outfitId);
    final itemIds = outfitItems.map((e) => e.itemId).toList();
    final allItems = await db.clothingDao.watchAll().first;
    final relevant = {
      for (final item in allItems.where((i) => itemIds.contains(i.id)))
        ClothingCategory.values.firstWhere(
          (c) => c.name == item.category,
          orElse: () => ClothingCategory.complemento,
        ): item,
    };
    state = {...build(), ...relevant};
  }
}
