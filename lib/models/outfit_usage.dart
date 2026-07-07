import 'package:drift/drift.dart';

import 'outfit.dart';

/// Histórico de uso dos looks. Toda estatística de "uso" é derivada desta
/// tabela — não há contador materializado.
@TableIndex(name: 'idx_outfit_usages_outfit_id', columns: {#outfitId})
@TableIndex(name: 'idx_outfit_usages_used_at', columns: {#usedAt})
class OutfitUsages extends Table {
  TextColumn get id => text()();
  TextColumn get outfitId =>
      text().references(Outfits, #id, onDelete: KeyAction.cascade)();

  /// Timestamp (ms) do uso. Quando [hasTime] é falso, representa só a data
  /// (meia-noite local) e a hora não deve ser exibida.
  IntColumn get usedAt => integer()();
  BoolColumn get hasTime => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
