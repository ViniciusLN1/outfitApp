import 'package:drift/drift.dart';

class ClothingItems extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get imagePath => text()();
  TextColumn get category => text()();
  IntColumn get dateAdded => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
