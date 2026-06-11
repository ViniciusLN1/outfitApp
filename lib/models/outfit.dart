import 'package:drift/drift.dart';

@TableIndex(name: 'idx_outfits_date_created', columns: {#dateCreated})
@TableIndex(name: 'idx_outfits_favorite_date', columns: {#isFavorite, #dateCreated})
@TableIndex(name: 'idx_outfits_usage_date', columns: {#usageCount, #dateCreated})
class Outfits extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get isFavorite => integer().withDefault(const Constant(0))();
  IntColumn get usageCount => integer().withDefault(const Constant(0))();
  IntColumn get dateCreated => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
