import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors from design.md YAML
  static const Color surface = Color(0xFFF8FAFC);
  static const Color surfaceDim = Color(0xFFCFDCE6);
  static const Color surfaceBright = Color(0xFFF8FAFC);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFEAF5FF);
  static const Color surfaceContainer = Color(0xFFE3F0FA);
  static const Color surfaceContainerHigh = Color(0xFFDDEAF5);
  static const Color surfaceContainerHighest = Color(0xFFD7E4EF);
  static const Color onSurface = Color(0xFF111D25);
  static const Color onSurfaceVariant = Color(0xFF40484C);
  static const Color inverseSurface = Color(0xFF26323A);
  static const Color inverseOnSurface = Color(0xFFE6F2FD);
  static const Color outline = Color(0xFF70787C);
  static const Color outlineVariant = Color(0xFFBFC8CC);
  static const Color surfaceTint = Color(0xFF1C667B);
  static const Color primary = Color(0xFF004656);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF0F5F73);
  static const Color onPrimaryContainer = Color(0xFF95D7EE);
  static const Color inversePrimary = Color(0xFF8FD0E7);
  static const Color secondary = Color(0xFF2E685D);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFB0EBDD);
  static const Color onSecondaryContainer = Color(0xFF336C61);
  static const Color tertiary = Color(0xFF543C00);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFF725200);
  static const Color onTertiaryContainer = Color(0xFFF8C662);
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);
  static const Color primaryFixed = Color(0xFFB4EBFF);
  static const Color primaryFixedDim = Color(0xFF8FD0E7);
  static const Color onPrimaryFixed = Color(0xFF001F28);
  static const Color onPrimaryFixedVariant = Color(0xFF004E5F);
  static const Color secondaryFixed = Color(0xFFB3EEE0);
  static const Color secondaryFixedDim = Color(0xFF98D2C4);
  static const Color onSecondaryFixed = Color(0xFF00201B);
  static const Color onSecondaryFixedVariant = Color(0xFF115045);
  static const Color tertiaryFixed = Color(0xFFFFDEA4);
  static const Color tertiaryFixedDim = Color(0xFFF0BF5C);
  static const Color onTertiaryFixed = Color(0xFF261900);
  static const Color onTertiaryFixedVariant = Color(0xFF5D4200);
  static const Color background = Color(0xFFF8FAFC);
  static const Color onBackground = Color(0xFF111D25);
  static const Color surfaceVariant = Color(0xFFD7E4EF);
  
  // Radial Gradient Colors for Splash Background
  static const Color gradientStart = Color(0xFF005C70);
  static const Color gradientEnd = Color(0xFF002D38);

  // Rounded Corner Radii from design.md YAML
  static const double roundedSm = 4.0;       // 0.25rem
  static const double roundedDefault = 8.0;  // 0.5rem
  static const double roundedMd = 12.0;      // 0.75rem
  static const double roundedLg = 16.0;      // 1rem
  static const double roundedXl = 24.0;      // 1.5rem
  static const double roundedFull = 9999.0;

  // Spacing from design.md YAML
  static const double baseUnit = 4.0;
  static const double containerMargin = 20.0;
  static const double gutterMd = 16.0;
  static const double stackSm = 8.0;
  static const double stackMd = 16.0;
  static const double stackLg = 24.0;
  static const double stackXl = 48.0;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: primary,
        onPrimary: onPrimary,
        primaryContainer: primaryContainer,
        onPrimaryContainer: onPrimaryContainer,
        secondary: secondary,
        onSecondary: onSecondary,
        secondaryContainer: secondaryContainer,
        onSecondaryContainer: onSecondaryContainer,
        tertiary: tertiary,
        onTertiary: onTertiary,
        tertiaryContainer: tertiaryContainer,
        onTertiaryContainer: onTertiaryContainer,
        surface: surface,
        onSurface: onSurface,
        onSurfaceVariant: onSurfaceVariant,
        outline: outline,
        outlineVariant: outlineVariant,
        error: error,
        onError: onError,
        errorContainer: errorContainer,
        onErrorContainer: onErrorContainer,
      ),
      textTheme: TextTheme(
        // headline-xl
        headlineLarge: GoogleFonts.manrope(
          fontSize: 32.0,
          fontWeight: FontWeight.w700,
          height: 40.0 / 32.0,
          letterSpacing: -0.02 * 32.0,
          color: primary,
        ),
        // headline-lg
        headlineMedium: GoogleFonts.manrope(
          fontSize: 24.0,
          fontWeight: FontWeight.w600,
          height: 32.0 / 24.0,
          letterSpacing: -0.01 * 24.0,
          color: primary,
        ),
        // headline-md
        headlineSmall: GoogleFonts.manrope(
          fontSize: 20.0,
          fontWeight: FontWeight.w600,
          height: 28.0 / 20.0,
          color: primary,
        ),
        // body-lg
        bodyLarge: GoogleFonts.sourceSans3(
          fontSize: 18.0,
          fontWeight: FontWeight.w400,
          height: 28.0 / 18.0,
          color: onBackground,
        ),
        // body-md
        bodyMedium: GoogleFonts.sourceSans3(
          fontSize: 16.0,
          fontWeight: FontWeight.w400,
          height: 24.0 / 16.0,
          color: onBackground,
        ),
        // body-sm
        bodySmall: GoogleFonts.sourceSans3(
          fontSize: 14.0,
          fontWeight: FontWeight.w400,
          height: 20.0 / 14.0,
          color: onSurfaceVariant,
        ),
        // label-md
        labelLarge: GoogleFonts.manrope(
          fontSize: 14.0,
          fontWeight: FontWeight.w600,
          height: 16.0 / 14.0,
          letterSpacing: 0.02 * 14.0,
          color: primary,
        ),
        // label-sm
        labelMedium: GoogleFonts.manrope(
          fontSize: 12.0,
          fontWeight: FontWeight.w700,
          height: 14.0 / 12.0,
          color: onSurfaceVariant,
        ),
      ),
    );
  }
}
