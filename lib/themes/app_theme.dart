import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme => _criar(Brightness.light);
  static ThemeData get darkTheme => _criar(Brightness.dark);
  static ThemeData _criar(Brightness brilho) {
    final escuro = brilho == Brightness.dark;
    final cores = ColorScheme.fromSeed(
            seedColor: const Color(0xFFD50062), brightness: brilho)
        .copyWith(
      primary: escuro ? const Color(0xFFFF8EBD) : const Color(0xFFD50062),
      onPrimary: escuro ? const Color(0xFF500023) : Colors.white,
      primaryContainer:
          escuro ? const Color(0xFF54152F) : const Color(0xFFFFE0ED),
      onPrimaryContainer:
          escuro ? const Color(0xFFFFD9E9) : const Color(0xFF740031),
      secondary: escuro ? const Color(0xFFF2B1CE) : const Color(0xFF8E2351),
      surface: escuro ? const Color(0xFF26151F) : Colors.white,
      onSurface: escuro ? const Color(0xFFFFEDF5) : const Color(0xFF351522),
      onSurfaceVariant:
          escuro ? const Color(0xFFE1BDCD) : const Color(0xFF745260),
      outline: escuro ? const Color(0xFFAA8094) : const Color(0xFFBA8C9F),
      outlineVariant:
          escuro ? const Color(0xFF593448) : const Color(0xFFEFCFDA),
    );
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Roboto',
      textTheme: (escuro
              ? Typography.material2021(platform: TargetPlatform.android).white
              : Typography.material2021(platform: TargetPlatform.android).black)
          .apply(
              fontFamily: 'Roboto',
              bodyColor: cores.onSurface,
              displayColor: cores.onSurface),
      colorScheme: cores,
      scaffoldBackgroundColor:
          escuro ? const Color(0xFF190F16) : const Color(0xFFFFF6FA),
      appBarTheme: AppBarTheme(
          centerTitle: false,
          elevation: 0,
          backgroundColor:
              escuro ? const Color(0xFF190F16) : const Color(0xFFFFF6FA),
          foregroundColor: cores.onSurface),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: cores.primary),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: cores.primary, foregroundColor: cores.onPrimary),
      drawerTheme: DrawerThemeData(backgroundColor: cores.surface),
      listTileTheme: ListTileThemeData(
          selectedColor: cores.primary,
          selectedTileColor: cores.primaryContainer),
      inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: cores.surface,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: cores.outlineVariant)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: cores.primary, width: 2))),
      filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
              minimumSize: const Size(0, 52),
              textStyle: const TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)))),
      cardTheme: CardThemeData(
          elevation: 0,
          color: cores.surface,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: cores.outlineVariant))),
    );
  }
}
