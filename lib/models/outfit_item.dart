import 'package:drift/drift.dart';

import 'clothing_item.dart';
import 'outfit.dart';

// O PK composto (outfitId, itemId) já indexa buscas por outfitId (prefixo);
// itemId precisa de índice próprio para o CASCADE de clothing_items e lookups reversos.
@TableIndex(name: 'idx_outfit_items_item_id', columns: {#itemId})
class OutfitItems extends Table {
  TextColumn get outfitId =>
      text().references(Outfits, #id, onDelete: KeyAction.cascade)();
  TextColumn get itemId =>
      text().references(ClothingItems, #id, onDelete: KeyAction.cascade)();

  // Layout normalizado (0..1) da peça dentro do canvas do look.
  // itemSize == 0 indica que o look não possui layout customizado (legado).
  RealColumn get centerX => real().withDefault(const Constant(0.5))();
  RealColumn get centerY => real().withDefault(const Constant(0.5))();
  RealColumn get itemSize => real().withDefault(const Constant(0.0))();
  IntColumn get zIndex => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {outfitId, itemId};
}
