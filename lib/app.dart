import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'controllers/nav_controller.dart';
import 'controllers/theme_controller.dart';
import 'views/capture/capture_view.dart';
import 'views/constructor/constructor_view.dart';
import 'views/home/home_view.dart';
import 'views/outfits/outfits_view.dart';
import 'views/profile/profile_view.dart';

// Paleta editorial: azul-escuro profundo + branco. Sem gradientes.
const _navy = Color(0xFF14213D); // azul-escuro profundo (primária)
const _navyDeep = Color(0xFF0B1426); // fundo do tema escuro
const _navySurface = Color(0xFF18233F); // superfícies elevadas no escuro

// Linguagem geométrica: cantos semi-retos (4) e modais levemente maiores (6).
const _radius = BorderRadius.all(Radius.circular(4));
const _radiusShape = RoundedRectangleBorder(borderRadius: _radius);

ThemeData _buildTheme(Brightness brightness) {
  final isLight = brightness == Brightness.light;
  final base = ColorScheme.fromSeed(seedColor: _navy, brightness: brightness);
  final scheme = isLight
      ? base.copyWith(
          primary: _navy,
          onPrimary: Colors.white,
          surface: Colors.white,
          surfaceContainerHighest: const Color(0xFFF1F3F8),
          outlineVariant: const Color(0xFFE2E5EC),
        )
      : base.copyWith(
          surface: _navySurface,
          surfaceContainerHighest: const Color(0xFF202C4C),
          outlineVariant: const Color(0xFF2C3A5C),
        );

  final fg = isLight ? _navy : Colors.white;
  final bg = isLight ? Colors.white : _navyDeep;

  return ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    scaffoldBackgroundColor: bg,
    appBarTheme: AppBarTheme(
      toolbarHeight: 45,
      centerTitle: true,
      backgroundColor: bg,
      foregroundColor: fg,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        color: fg,
        fontSize: 17,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 60,
      backgroundColor: bg,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      indicatorColor: scheme.primary.withValues(alpha: isLight ? 0.10 : 0.22),
      indicatorShape: _radiusShape,
      labelTextStyle: WidgetStatePropertyAll(
        TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
          color: fg,
        ),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: scheme.surface,
      surfaceTintColor: Colors.transparent,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: _radius,
        side: BorderSide(color: scheme.outlineVariant),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        shape: _radiusShape,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: scheme.primary,
        side: BorderSide(color: scheme.primary, width: 1.2),
        shape: _radiusShape,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          letterSpacing: 0.4,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: scheme.primary,
        shape: _radiusShape,
      ),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        shape: const WidgetStatePropertyAll(_radiusShape),
        textStyle: const WidgetStatePropertyAll(
          TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.2),
        ),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
      ),
    ),
    dialogTheme: DialogThemeData(
      elevation: 0,
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(6)),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: _radius),
      enabledBorder: OutlineInputBorder(borderRadius: _radius),
      focusedBorder: OutlineInputBorder(borderRadius: _radius),
    ),
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: _radiusShape,
    ),
    dividerTheme: DividerThemeData(color: scheme.outlineVariant, thickness: 1),
  );
}

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
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      themeMode: themeMode,
      home: Scaffold(
        body: IndexedStack(
          index: currentIndex,
          children: _tabs,
        ),
        bottomNavigationBar: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
          ),
          child: NavigationBar(
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
      ),
    );
  }
}
