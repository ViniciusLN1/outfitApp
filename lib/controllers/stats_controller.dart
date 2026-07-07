import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../database/daos/stats_dao.dart';
import 'clothing_controller.dart';

part 'stats_controller.g.dart';

/// Janela (dias) sem uso a partir da qual uma peça/look é considerado esquecido.
const int kForgottenThresholdDays = 30;

/// Meta mensal (visual) de usos de look — apenas para a barra de progresso.
const int kMonthlyUsageGoal = 20;

int _forgottenBefore() => DateTime.now()
    .subtract(const Duration(days: kForgottenThresholdDays))
    .millisecondsSinceEpoch;

@riverpod
Stream<int> totalCategories(TotalCategoriesRef ref) =>
    ref.watch(appDatabaseProvider).statsDao.watchTotalCategories();

@riverpod
Stream<int> totalColors(TotalColorsRef ref) =>
    ref.watch(appDatabaseProvider).statsDao.watchTotalColors();

@riverpod
Stream<List<LabelCount>> categoryDistribution(CategoryDistributionRef ref) =>
    ref.watch(appDatabaseProvider).statsDao.watchCategoryDistribution();

@riverpod
Stream<List<LabelCount>> colorDistribution(ColorDistributionRef ref) =>
    ref.watch(appDatabaseProvider).statsDao.watchColorDistribution();

@riverpod
Stream<List<LabelCount>> monthlyGrowth(MonthlyGrowthRef ref) =>
    ref.watch(appDatabaseProvider).statsDao.watchMonthlyGrowth();

@riverpod
Stream<List<ItemStat>> mostUsedItems(MostUsedItemsRef ref) =>
    ref.watch(appDatabaseProvider).statsDao.watchMostUsedItems();

@riverpod
Stream<List<ItemStat>> neverUsedItems(NeverUsedItemsRef ref) =>
    ref.watch(appDatabaseProvider).statsDao.watchNeverUsedItems();

@riverpod
Stream<List<ItemStat>> mostRepeatedItems(MostRepeatedItemsRef ref) =>
    ref.watch(appDatabaseProvider).statsDao.watchMostRepeatedItems();

@riverpod
Stream<List<ItemStat>> forgottenItems(ForgottenItemsRef ref) => ref
    .watch(appDatabaseProvider)
    .statsDao
    .watchForgottenItems(before: _forgottenBefore());

@riverpod
Stream<List<OutfitStat>> forgottenOutfits(ForgottenOutfitsRef ref) => ref
    .watch(appDatabaseProvider)
    .statsDao
    .watchForgottenOutfits(before: _forgottenBefore());

@riverpod
Stream<OutfitStat?> mostCommonOutfit(MostCommonOutfitRef ref) =>
    ref.watch(appDatabaseProvider).statsDao.watchMostCommonOutfit();

@riverpod
Stream<List<LabelCount>> categoryUsage(CategoryUsageRef ref) =>
    ref.watch(appDatabaseProvider).statsDao.watchCategoryUsage();

@riverpod
Stream<List<LabelCount>> colorUsage(ColorUsageRef ref) =>
    ref.watch(appDatabaseProvider).statsDao.watchColorUsage();

@riverpod
Stream<List<LabelCount>> weekdayActivity(WeekdayActivityRef ref) =>
    ref.watch(appDatabaseProvider).statsDao.watchWeekdayActivity();

@riverpod
Stream<List<LabelCount>> monthlyActivity(MonthlyActivityRef ref) =>
    ref.watch(appDatabaseProvider).statsDao.watchMonthlyActivity();

@riverpod
Stream<RotationStat> wardrobeRotation(WardrobeRotationRef ref) =>
    ref.watch(appDatabaseProvider).statsDao.watchRotation();

/// Usos registrados no mês corrente (para a meta mensal visual).
@riverpod
Stream<int> currentMonthUsage(CurrentMonthUsageRef ref) {
  final now = DateTime.now();
  final start = DateTime(now.year, now.month).millisecondsSinceEpoch;
  final end = DateTime(now.year, now.month + 1).millisecondsSinceEpoch;
  return ref.watch(appDatabaseProvider).statsDao.watchUsageCountBetween(
        start,
        end,
      );
}
