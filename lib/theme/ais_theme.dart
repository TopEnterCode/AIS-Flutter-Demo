import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AISColors {
  static const Color primaryGreen = Color(0xFF003B2E);
  static const Color darkGreen = Color(0xFF002820);
  static const Color navGreen = Color(0xFF00291D);
  static const Color limeGreen = Color(0xFFAECC40);
  static const Color lime2 = Color(0xFF8DC63F);
  static const Color mediumGreen = Color(0xFF4A7C59);
  static const Color lightGreen = Color(0xFFE8F5E9);
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Colors.white;
  static const Color cardBg = Color(0xFFFAFAFA);
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textMedium = Color(0xFF555555);
  static const Color textLight = Color(0xFF999999);
  static const Color divider = Color(0xFFE0E0E0);
  static const Color errorRed = Color(0xFFD32F2F);
  static const Color successGreen = Color(0xFF2E7D32);
  static const Color warningOrange = Color(0xFFF57F17);
  static const Color infoBlue = Color(0xFF0288D1);
  static const Color gold = Color(0xFFFFCC00);

  // LaunchDarkly brand colors
  static const Color ldBlue = Color(0xFF405BFF);
  static const Color ldPurple = Color(0xFF7B61FF);
  static const Color ldPink = Color(0xFFFF5B7A);
  static const Color ldOrange = Color(0xFFFF7628);
  static const Color ldTeal = Color(0xFF00C7B1);
  static const Color ldYellow = Color(0xFFFFCC00);
}

class AISTheme {
  static ThemeData get theme {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: AISColors.primaryGreen,
        onPrimary: Colors.white,
        secondary: AISColors.limeGreen,
        onSecondary: AISColors.primaryGreen,
        error: AISColors.errorRed,
        onError: Colors.white,
        surface: AISColors.surface,
        onSurface: AISColors.textDark,
      ),
      scaffoldBackgroundColor: AISColors.background,
    );

    return base.copyWith(
      textTheme: GoogleFonts.notoSansThaiTextTheme(base.textTheme).copyWith(
        displayLarge: GoogleFonts.notoSansThai(
            fontSize: 32, fontWeight: FontWeight.bold, color: AISColors.textDark),
        displayMedium: GoogleFonts.notoSansThai(
            fontSize: 26, fontWeight: FontWeight.bold, color: AISColors.textDark),
        headlineLarge: GoogleFonts.notoSansThai(
            fontSize: 22, fontWeight: FontWeight.bold, color: AISColors.textDark),
        headlineMedium: GoogleFonts.notoSansThai(
            fontSize: 18, fontWeight: FontWeight.w600, color: AISColors.textDark),
        titleLarge: GoogleFonts.notoSansThai(
            fontSize: 16, fontWeight: FontWeight.w600, color: AISColors.textDark),
        titleMedium: GoogleFonts.notoSansThai(
            fontSize: 14, fontWeight: FontWeight.w600, color: AISColors.textDark),
        bodyLarge: GoogleFonts.notoSansThai(fontSize: 15, color: AISColors.textDark),
        bodyMedium: GoogleFonts.notoSansThai(fontSize: 13, color: AISColors.textMedium),
        labelLarge: GoogleFonts.notoSansThai(
            fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.5),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AISColors.navGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 2,
        titleTextStyle: GoogleFonts.notoSansThai(
            fontSize: 17, fontWeight: FontWeight.w600, color: Colors.white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AISColors.limeGreen,
          foregroundColor: AISColors.primaryGreen,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: GoogleFonts.notoSansThai(
              fontSize: 15, fontWeight: FontWeight.bold),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AISColors.primaryGreen,
          side: const BorderSide(color: AISColors.primaryGreen, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: GoogleFonts.notoSansThai(
              fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AISColors.primaryGreen,
          textStyle: GoogleFonts.notoSansThai(
              fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.white,
        margin: EdgeInsets.zero,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AISColors.lightGreen,
        labelStyle: GoogleFonts.notoSansThai(
            fontSize: 12, color: AISColors.primaryGreen),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AISColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AISColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AISColors.primaryGreen, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        labelStyle: GoogleFonts.notoSansThai(color: AISColors.textMedium),
      ),
      dividerTheme: const DividerThemeData(
        color: AISColors.divider,
        thickness: 1,
        space: 1,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: AISColors.primaryGreen,
        unselectedLabelColor: AISColors.textMedium,
        indicatorColor: AISColors.limeGreen,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: GoogleFonts.notoSansThai(
            fontSize: 14, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.notoSansThai(fontSize: 14),
      ),
    );
  }
}
