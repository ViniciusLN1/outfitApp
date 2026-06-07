import 'package:drift/drift.dart';

class Outfits extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get isFavorite => integer().withDefault(const Constant(0))();
  IntColumn get usageCount => integer().withDefault(const Constant(0))();
  IntColumn get dateCreated => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
