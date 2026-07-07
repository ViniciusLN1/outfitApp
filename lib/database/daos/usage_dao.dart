import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../app_database.dart';
import '../../models/outfit_usage.dart';

part 'usage_dao.g.dart';

@DriftAccessor(tables: [OutfitUsages])
class UsageDao extends DatabaseAccessor<AppDatabase> with _$UsageDaoMixin {
  UsageDao(super.db);

  Future<void> registerUsage({
    required String outfitId,
    required DateTime when,
    required bool hasTime,
  }) =>
      into(outfitUsages).insert(OutfitUsagesCompanion.insert(
        id: const Uuid().v4(),
        outfitId: outfitId,
        usedAt: when.millisecondsSinceEpoch,
        hasTime: Value(hasTime),
      ));

  Future<int> deleteUsage(String id) =>
      (delete(outfitUsages)..where((t) => t.id.equals(id))).go();

  Stream<List<OutfitUsage>> watchForOutfit(String outfitId) =>
      (select(outfitUsages)
            ..where((t) => t.outfitId.equals(outfitId))
            ..orderBy([(t) => OrderingTerm.desc(t.usedAt)]))
          .watch();

  Stream<int> watchTotalForOutfit(String outfitId) {
    final count = outfitUsages.id.count();
    final q = selectOnly(outfitUsages)
      ..addColumns([count])
      ..where(outfitUsages.outfitId.equals(outfitId));
    return q.map((r) => r.read(count) ?? 0).watchSingle();
  }

  Stream<int?> watchLastForOutfit(String outfitId) {
    final last = outfitUsages.usedAt.max();
    final q = selectOnly(outfitUsages)
      ..addColumns([last])
      ..where(outfitUsages.outfitId.equals(outfitId));
    return q.map((r) => r.read(last)).watchSingle();
  }
}
