import 'package:drift/drift.dart';

import 'clothing_item.dart';
import 'outfit.dart';

class OutfitItems extends Table {
  TextColumn get outfitId =>
      text().references(Outfits, #id, onDelete: KeyAction.cascade)();
  TextColumn get itemId =>
      text().references(ClothingItems, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {outfitId, itemId};
}
