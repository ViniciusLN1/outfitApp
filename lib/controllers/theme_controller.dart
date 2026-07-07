import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'preferences.dart';

part 'theme_controller.g.dart';

@Riverpod(keepAlive: true)
class ThemeModeController extends _$ThemeModeController {
  static const _key = 'themeMode';

  @override
  ThemeMode build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getString(_key) == 'dark' ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    await ref
        .read(sharedPreferencesProvider)
        .setString(_key, mode == ThemeMode.dark ? 'dark' : 'light');
  }
}
