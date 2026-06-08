import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'controllers/profile_controller.dart';
import 'controllers/theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  final isDark = prefs.getString('themeMode') == 'dark';
  final username = prefs.getString('username') ?? 'Usuário';
  final photoPath = prefs.getString('photoPath');

  runApp(
    ProviderScope(
      overrides: [
        themeModeProvider.overrideWith(
          (ref) => ThemeModeNotifier(isDark ? ThemeMode.dark : ThemeMode.light),
        ),
        profileProvider.overrideWith(
          (ref) => ProfileNotifier(
            ProfileState(username: username, photoPath: photoPath),
          ),
        ),
      ],
      child: const OutfitApp(),
    ),
  );
}
