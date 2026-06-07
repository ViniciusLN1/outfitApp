import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../models/clothing_item.dart';
import '../models/outfit.dart';
import '../models/outfit_item.dart';
import 'daos/clothing_dao.dart';
import 'daos/outfit_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [ClothingItems, Outfits, OutfitItems],
  daos: [ClothingDao, OutfitDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'outfit_app.db'));
    return NativeDatabase.createInBackground(file);
  });
}
