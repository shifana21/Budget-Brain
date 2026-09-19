import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Fintech color palette and Material 3 theme configuration.
abstract final class AppColors {
  static const primary = Color(0xFF6366F1);
  static const primaryDark = Color(0xFF4F46E5);
  static const secondary = Color(0xFF06B6D4);
  static const accent = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const danger = Color(0xFFEF4444);
  static const surfaceLight = Color(0xFFF8FAFC);
  static const surfaceDark = Color(0xFF0F172A);
  static const cardDark = Color(0xFF1E293B);
  static const glassLight = Color(0xCCFFFFFF);
  static const glassDark = Color(0x991E293B);
}

abstract final class AppTheme {
  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.surfaceLight,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.surfaceLight,
      textTheme: _textTheme(Brightness.light),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: Colors.white,
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        height: 72,
        backgroundColor: Colors.white.withValues(alpha: 0.92),
        indicatorColor: AppColors.primary.withValues(alpha: 0.12),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return GoogleFonts.inter(
            fontSize: 11,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          );
        }),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
    );
  }

  static ThemeData get dark {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.surfaceDark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.surfaceDark,
      textTheme: _textTheme(Brightness.dark),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: AppColors.cardDark,
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.secondary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        height: 72,
        backgroundColor: AppColors.cardDark.withValues(alpha: 0.95),
        indicatorColor: AppColors.secondary.withValues(alpha: 0.18),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return GoogleFonts.inter(
            fontSize: 11,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          );
        }),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
    );
  }

  static TextTheme _textTheme(Brightness brightness) {
    final base = brightness == Brightness.dark
        ? ThemeData.dark().textTheme
        : ThemeData.light().textTheme;

    return TextTheme(
      displayLarge: GoogleFonts.inter(textStyle: base.displayLarge),
      displayMedium: GoogleFonts.inter(textStyle: base.displayMedium),
      displaySmall: GoogleFonts.inter(textStyle: base.displaySmall),
      headlineLarge: GoogleFonts.inter(textStyle: base.headlineLarge),
      headlineMedium: GoogleFonts.inter(
        textStyle: base.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
      headlineSmall: GoogleFonts.inter(
        textStyle: base.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
      ),
      titleLarge: GoogleFonts.inter(
        textStyle: base.titleLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      titleMedium: GoogleFonts.inter(textStyle: base.titleMedium),
      titleSmall: GoogleFonts.inter(textStyle: base.titleSmall),
      bodyLarge: GoogleFonts.inter(textStyle: base.bodyLarge),
      bodyMedium: GoogleFonts.inter(textStyle: base.bodyMedium),
      bodySmall: GoogleFonts.inter(textStyle: base.bodySmall),
      labelLarge: GoogleFonts.inter(textStyle: base.labelLarge),
      labelMedium: GoogleFonts.inter(textStyle: base.labelMedium),
      labelSmall: GoogleFonts.inter(textStyle: base.labelSmall),
    );
  }

  static List<Color> chartPalette = const [
    AppColors.primary,
    AppColors.secondary,
    AppColors.accent,
    AppColors.warning,
    AppColors.danger,
    Color(0xFF8B5CF6),
    Color(0xFFEC4899),
    Color(0xFF14B8A6),
  ];
}
