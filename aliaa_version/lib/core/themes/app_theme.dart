// Smart Heritage — shared design tokens
//
// Ported 1:1 from the DESIGN.md design system (colors, typography, radii,
// spacing) so every screen widget looks consistent.
//
// Dependencies required in pubspec.yaml:
//   google_fonts: ^6.2.1
//
// Fonts used: Montserrat (headlines/display), Inter (body/labels).

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Color tokens, ported from DESIGN.md.
class AppColors {
  AppColors._();

  static const surface = Color(0xFFF8F9FA);
  static const surfaceDim = Color(0xFFD9DADB);
  static const surfaceBright = Color(0xFFF8F9FA);
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const surfaceContainerLow = Color(0xFFF3F4F5);
  static const surfaceContainer = Color(0xFFEDEEEF);
  static const surfaceContainerHigh = Color(0xFFE7E8E9);
  static const surfaceContainerHighest = Color(0xFFE1E3E4);

  static const onSurface = Color(0xFF191C1D);
  static const onSurfaceVariant = Color(0xFF44474E);
  static const inverseSurface = Color(0xFF2E3132);
  static const inverseOnSurface = Color(0xFFF0F1F2);

  static const outline = Color(0xFF74777F);
  static const outlineVariant = Color(0xFFC4C6CF);

  static const primary = Color(0xFF002046); // Deep Navy
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryContainer = Color(0xFF1B365D);
  static const onPrimaryContainer = Color(0xFF87A0CD);
  static const inversePrimary = Color(0xFFAEC7F7);

  static const secondary = Color(0xFF7C571E); // Sandstone
  static const onSecondary = Color(0xFFFFFFFF);
  static const secondaryContainer = Color(0xFFFECC87); // Gold accent
  static const onSecondaryContainer = Color(0xFF79551B);

  static const tertiary = Color(0xFF735C00);
  static const onTertiary = Color(0xFFFFFFFF);
  static const tertiaryContainer = Color(0xFFCBA72F);
  static const onTertiaryContainer = Color(0xFF4E3D00);

  static const error = Color(0xFFBA1A1A);
  static const onError = Color(0xFFFFFFFF);
  static const errorContainer = Color(0xFFFFDAD6);
  static const onErrorContainer = Color(0xFF93000A);

  static const background = Color(0xFFF8F9FA);
  static const onBackground = Color(0xFF191C1D);
  static const surfaceVariant = Color(0xFFE1E3E4);

  /// Gold gradient used on primary CTAs, chips, badges.
  static const goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7C571E), Color(0xFFFECC87)],
  );

  /// Navy gradient used on user chat bubbles / active surfaces.
  static const navyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF002046), Color(0xFF1B365D)],
  );
}

/// Spacing tokens (multiples of the 8px base unit).
class AppSpacing {
  AppSpacing._();

  static const xs = 4.0;
  static const base = 8.0;
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;
  static const containerMargin = 20.0;
  static const gutter = 16.0;
}

/// Corner radius tokens.
class AppRadius {
  AppRadius._();

  static const sm = 8.0;
  static const dflt = 16.0;
  static const md = 24.0;
  static const lg = 32.0;
  static const xl = 48.0;
  static const full = 999.0;
}

/// Typography tokens. Montserrat for display/headline, Inter for
/// body/title/label, matching DESIGN.md.
class AppText {
  AppText._();

  static TextStyle displayLg({Color? color}) => GoogleFonts.montserrat(
        fontSize: 48,
        fontWeight: FontWeight.w700,
        height: 56 / 48,
        letterSpacing: -0.02 * 48,
        color: color ?? AppColors.onSurface,
      );

  static TextStyle headlineLg({Color? color}) => GoogleFonts.montserrat(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        height: 40 / 32,
        color: color ?? AppColors.onSurface,
      );

  static TextStyle headlineLgMobile({Color? color}) => GoogleFonts.montserrat(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        height: 36 / 28,
        color: color ?? AppColors.onSurface,
      );

  static TextStyle titleLg({Color? color}) => GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        height: 28 / 22,
        color: color ?? AppColors.onSurface,
      );

  static TextStyle bodyLg({Color? color}) => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 24 / 16,
        color: color ?? AppColors.onSurface,
      );

  static TextStyle bodyMd({Color? color}) => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 20 / 14,
        color: color ?? AppColors.onSurfaceVariant,
      );

  static TextStyle labelMd({Color? color}) => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 16 / 12,
        letterSpacing: 0.05 * 12,
        color: color ?? AppColors.onSurfaceVariant,
      );
}

/// App-wide ThemeData, in case a host app wants to use this as its base theme.
ThemeData buildSmartHeritageTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.surface,
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      secondary: AppColors.secondary,
      onSecondary: AppColors.onSecondary,
      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
      error: AppColors.error,
      onError: AppColors.onError,
    ),
    fontFamily: GoogleFonts.inter().fontFamily,
  );
}