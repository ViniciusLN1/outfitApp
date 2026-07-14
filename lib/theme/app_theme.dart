import 'package:flutter/material.dart';

/// Design system "Lookbook de Atelier".
/// As fotos das peças são as protagonistas; a UI é a galeria: fundos quentes
/// neutros (porcelain/greige), um único acento oxblood e tipografia didone
/// (Marcellus) sobre uma base geométrica (Outfit). Elevation 0 em tudo;
/// profundidade vem de tom sobre tom, não de sombra nem de borda.

// Paleta light
const _ink = Color(0xFF201D1A);
const _porcelain = Color(0xFFFAF8F5);
const _greige = Color(0xFFEEEAE3);
const _hairline = Color(0xFFE3DDD3);
const _oxblood = Color(0xFF6E2B3A);
const _moss = Color(0xFF66705B);

// Paleta dark (espresso quente)
const _espresso = Color(0xFF16130F);
const _espressoSurface = Color(0xFF211D18);
const _espressoContainer = Color(0xFF2C2620);
const _espressoHairline = Color(0xFF3A332B);
const _bone = Color(0xFFF0EBE2);
const _rosewood = Color(0xFFD08E9C);
const _mossLight = Color(0xFFA9B399);

// Marcellus é romana lapidar de peso único (400): hierarquia vem de corpo e
// letterSpacing, nunca de fontWeight (o Flutter não sintetiza negrito).
const kDisplayFont = 'Marcellus';
const kBodyFont = 'Outfit';

/// Estilo "eyebrow" (rótulo editorial de seção): use via
/// `Theme.of(context).textTheme.labelSmall`.
TextStyle _eyebrow(Color color) => TextStyle(
      fontFamily: kBodyFont,
      fontSize: 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 2,
      color: color,
    );

ThemeData buildAppTheme(Brightness brightness) {
  final isLight = brightness == Brightness.light;
  final base = ColorScheme.fromSeed(seedColor: _oxblood, brightness: brightness);
  final scheme = isLight
      ? base.copyWith(
          primary: _oxblood,
          onPrimary: _porcelain,
          secondary: _moss,
          onSecondary: _porcelain,
          surface: Colors.white,
          onSurface: _ink,
          onSurfaceVariant: const Color(0xFF6F6759),
          surfaceContainerHighest: _greige,
          surfaceContainerHigh: const Color(0xFFF3F0EA),
          outline: const Color(0xFFB9AF9F),
          outlineVariant: _hairline,
        )
      : base.copyWith(
          primary: _rosewood,
          onPrimary: const Color(0xFF2A161C),
          secondary: _mossLight,
          onSecondary: const Color(0xFF1E2317),
          surface: _espressoSurface,
          onSurface: _bone,
          onSurfaceVariant: const Color(0xFFB0A695),
          surfaceContainerHighest: _espressoContainer,
          surfaceContainerHigh: const Color(0xFF262019),
          outline: const Color(0xFF6A5F50),
          outlineVariant: _espressoHairline,
        );

  final bg = isLight ? _porcelain : _espresso;
  final fg = scheme.onSurface;

  const display = TextStyle(
    fontFamily: kDisplayFont,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.6,
    height: 1.15,
  );
  final textTheme = TextTheme(
    displayLarge: display.copyWith(fontSize: 46),
    displayMedium: display.copyWith(fontSize: 38),
    displaySmall: display.copyWith(fontSize: 31),
    headlineLarge: display.copyWith(fontSize: 29),
    headlineMedium: display.copyWith(fontSize: 26),
    headlineSmall: display.copyWith(fontSize: 23),
    titleLarge: display.copyWith(fontSize: 20, letterSpacing: 0.8),
    titleMedium: const TextStyle(
        fontFamily: kBodyFont,
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2),
    titleSmall: const TextStyle(
        fontFamily: kBodyFont,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2),
    bodyLarge: const TextStyle(fontFamily: kBodyFont, fontSize: 15),
    bodyMedium: const TextStyle(fontFamily: kBodyFont, fontSize: 13.5),
    bodySmall: const TextStyle(fontFamily: kBodyFont, fontSize: 12),
    labelLarge: const TextStyle(
        fontFamily: kBodyFont,
        fontSize: 13.5,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.6),
    labelMedium: const TextStyle(
        fontFamily: kBodyFont,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.4),
    labelSmall: _eyebrow(scheme.onSurfaceVariant),
  ).apply(bodyColor: fg, displayColor: fg);

  const stadium = StadiumBorder();
  const sheetRadius = BorderRadius.vertical(top: Radius.circular(12));

  return ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    fontFamily: kBodyFont,
    textTheme: textTheme,
    scaffoldBackgroundColor: bg,
    appBarTheme: AppBarTheme(
      toolbarHeight: 52,
      centerTitle: true,
      backgroundColor: bg,
      foregroundColor: fg,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        fontFamily: kDisplayFont,
        color: fg,
        fontSize: 21,
        fontWeight: FontWeight.w400,
        letterSpacing: 1.5,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 62,
      backgroundColor: bg,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      indicatorColor: scheme.primary.withValues(alpha: isLight ? 0.10 : 0.20),
      indicatorShape: stadium,
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          size: 22,
          color: states.contains(WidgetState.selected)
              ? scheme.primary
              : scheme.onSurfaceVariant,
        ),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          fontFamily: kBodyFont,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.4,
          color: states.contains(WidgetState.selected)
              ? fg
              : scheme.onSurfaceVariant,
        ),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: scheme.surface,
      surfaceTintColor: Colors.transparent,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        shape: stadium,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: textTheme.labelLarge,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        elevation: 0,
        shape: stadium,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: textTheme.labelLarge,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: scheme.primary,
        side: BorderSide(color: scheme.outline),
        shape: stadium,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: textTheme.labelLarge,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: scheme.primary,
        shape: stadium,
        textStyle: textTheme.labelLarge,
      ),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        shape: const WidgetStatePropertyAll(stadium),
        side: WidgetStatePropertyAll(BorderSide(color: scheme.outlineVariant)),
        textStyle: WidgetStatePropertyAll(textTheme.labelMedium),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: scheme.surfaceContainerHighest,
      side: BorderSide(color: scheme.outlineVariant),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(2)),
      ),
      labelStyle: TextStyle(
        fontFamily: kBodyFont,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1,
        color: fg,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: bg,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: const RoundedRectangleBorder(borderRadius: sheetRadius),
    ),
    dialogTheme: DialogThemeData(
      elevation: 0,
      backgroundColor: bg,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      titleTextStyle: textTheme.headlineSmall,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: scheme.primary, width: 1.4),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: isLight ? _ink : _greige,
      contentTextStyle: TextStyle(
        fontFamily: kBodyFont,
        fontSize: 13.5,
        color: isLight ? _porcelain : _ink,
      ),
      actionTextColor: isLight ? _rosewood : _oxblood,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    dividerTheme: DividerThemeData(color: scheme.outlineVariant, thickness: 1),
    listTileTheme: ListTileThemeData(
      iconColor: scheme.onSurfaceVariant,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: scheme.primary,
      linearTrackColor: scheme.surfaceContainerHighest,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      elevation: 0,
      highlightElevation: 0,
      backgroundColor: scheme.primary,
      foregroundColor: scheme.onPrimary,
      shape: stadium,
    ),
  );
}
