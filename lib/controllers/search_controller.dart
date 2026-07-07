import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'preferences.dart';

part 'search_controller.g.dart';

/// Últimas buscas (no máximo 3), persistidas localmente.
@Riverpod(keepAlive: true)
class RecentSearches extends _$RecentSearches {
  static const _key = 'recent_searches';
  static const _max = 3;

  @override
  List<String> build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getStringList(_key) ?? const [];
  }

  Future<void> add(String term) async {
    final t = term.trim();
    if (t.isEmpty) return;
    final list = <String>[
      t,
      ...state.where((e) => e.toLowerCase() != t.toLowerCase()),
    ].take(_max).toList();
    state = list;
    await ref.read(sharedPreferencesProvider).setStringList(_key, list);
  }
}
