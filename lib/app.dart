import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'controllers/nav_controller.dart';
import 'controllers/theme_controller.dart';
import 'views/capture/capture_view.dart';
import 'views/constructor/constructor_view.dart';
import 'views/home/home_view.dart';
import 'views/outfits/outfits_view.dart';
import 'views/profile/profile_view.dart';

const _seedColor = Color(0xFF1A237E);

ThemeData _lightTheme() => ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: _seedColor,
        brightness: Brightness.light,
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        toolbarHeight: 45,
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF1A237E),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      navigationBarTheme: const NavigationBarThemeData(height: 60),
    );

ThemeData _darkTheme() => ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: _seedColor,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        toolbarHeight: 45,
        centerTitle: true,
        backgroundColor: Color(0xFF0D1B4B),
        foregroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      navigationBarTheme: const NavigationBarThemeData(height: 60),
    );

class OutfitApp extends ConsumerWidget {
  const OutfitApp({super.key});

  static const List<Widget> _tabs = [
    HomeView(),
    OutfitsView(),
    CaptureView(),
    ConstructorView(),
    ProfileView(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(currentTabIndexProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'OutfitApp',
      debugShowCheckedModeBanner: false,
      theme: _lightTheme(),
      darkTheme: _darkTheme(),
      themeMode: themeMode,
      home: Scaffold(
        body: IndexedStack(
          index: currentIndex,
          children: _tabs,
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: (i) =>
              ref.read(currentTabIndexProvider.notifier).setTab(i),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.checkroom_outlined),
              selectedIcon: Icon(Icons.checkroom),
              label: 'Outfits',
            ),
            NavigationDestination(
              icon: Icon(Icons.camera_alt_outlined),
              selectedIcon: Icon(Icons.camera_alt),
              label: 'Capturar',
            ),
            NavigationDestination(
              icon: Icon(Icons.construction_outlined),
              selectedIcon: Icon(Icons.construction),
              label: 'Construtor',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}
