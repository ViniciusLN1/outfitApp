import 'package:drift/drift.dart';

@TableIndex(name: 'idx_clothing_items_category', columns: {#category})
@TableIndex(name: 'idx_clothing_items_date_added', columns: {#dateAdded})
class ClothingItems extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get imagePath => text()();
  TextColumn get category => text()();
  TextColumn get color => text().nullable()();
  IntColumn get dateAdded => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
