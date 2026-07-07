import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../database/app_database.dart';
import 'clothing_controller.dart';

part 'usage_controller.g.dart';

/// Registros de uso resolvidos com o look (calendário/histórico global).
/// [outfitId] nulo = todos os looks.
@riverpod
Stream<List<UsageEntry>> usageEntries(UsageEntriesRef ref, String? outfitId) {
  final db = ref.watch(appDatabaseProvider);
  return db.watchUsageEntries(outfitId: outfitId);
}

@riverpod
Stream<List<OutfitUsage>> outfitUsageHistory(
  OutfitUsageHistoryRef ref,
  String outfitId,
) {
  final db = ref.watch(appDatabaseProvider);
  return db.usageDao.watchForOutfit(outfitId);
}

@riverpod
Stream<int> outfitUsageTotal(OutfitUsageTotalRef ref, String outfitId) {
  final db = ref.watch(appDatabaseProvider);
  return db.usageDao.watchTotalForOutfit(outfitId);
}

@riverpod
Stream<int?> outfitLastUsage(OutfitLastUsageRef ref, String outfitId) {
  final db = ref.watch(appDatabaseProvider);
  return db.usageDao.watchLastForOutfit(outfitId);
}

@riverpod
class UsageController extends _$UsageController {
  @override
  FutureOr<void> build() {}

  Future<void> register({
    required String outfitId,
    required DateTime when,
    required bool hasTime,
  }) =>
      ref.read(appDatabaseProvider).usageDao.registerUsage(
            outfitId: outfitId,
            when: when,
            hasTime: hasTime,
          );

  Future<void> delete(String id) =>
      ref.read(appDatabaseProvider).usageDao.deleteUsage(id);
}
