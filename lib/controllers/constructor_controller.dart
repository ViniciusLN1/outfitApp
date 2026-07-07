import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../database/app_database.dart';
import '../models/item_transform.dart';
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

/// Estado do construtor: peça escolhida por categoria + seu layout normalizado.
class ConstructorState {
  final Map<ClothingCategory, ClothingItem?> items;
  final Map<ClothingCategory, ItemTransform> transforms;

  /// Id do outfit em edição. Quando preenchido, salvar deve ATUALIZAR este
  /// outfit em vez de criar um novo.
  final String? editingOutfitId;

  /// Nome atual do outfit em edição (para pré-preencher o diálogo de salvar).
  final String? editingOutfitName;

  const ConstructorState({
    required this.items,
    required this.transforms,
    this.editingOutfitId,
    this.editingOutfitName,
  });

  /// Categorias que possuem peça alocada.
  Iterable<ClothingCategory> get occupied =>
      items.entries.where((e) => e.value != null).map((e) => e.key);

  ConstructorState copyWith({
    Map<ClothingCategory, ClothingItem?>? items,
    Map<ClothingCategory, ItemTransform>? transforms,
  }) =>
      ConstructorState(
        items: items ?? this.items,
        transforms: transforms ?? this.transforms,
        editingOutfitId: editingOutfitId,
        editingOutfitName: editingOutfitName,
      );
}

@Riverpod(keepAlive: true)
class ConstructorController extends _$ConstructorController {
  @override
  ConstructorState build() => ConstructorState(
        items: {for (final c in ClothingCategory.values) c: null},
        transforms: {
          for (final c in ClothingCategory.values) c: defaultTransformFor(c.name)
        },
      );

  void selectItem(ClothingCategory category, ClothingItem? item) {
    state = state.copyWith(items: {...state.items, category: item});
  }

  void clearAll() {
    state = build();
  }

  /// Aplica o arranjo definido no editor de ajuste.
  void setTransforms(Map<ClothingCategory, ItemTransform> transforms) {
    state = state.copyWith(transforms: {...state.transforms, ...transforms});
  }

  Future<void> loadOutfit(String outfitId) async {
    final db = ref.read(appDatabaseProvider);
    final placements = await db.watchOutfitPlacements(outfitId).first;
    final outfit = await (db.select(db.outfits)
          ..where((t) => t.id.equals(outfitId)))
        .getSingleOrNull();
    final fresh = build();
    final items = {...fresh.items};
    final transforms = {...fresh.transforms};
    for (final p in placements) {
      final category = ClothingCategory.values.firstWhere(
        (c) => c.name == p.item.category,
        orElse: () => ClothingCategory.acessorios,
      );
      items[category] = p.item;
      transforms[category] = p.transform;
    }
    state = ConstructorState(
      items: items,
      transforms: transforms,
      editingOutfitId: outfitId,
      editingOutfitName: outfit?.name,
    );
  }
}
