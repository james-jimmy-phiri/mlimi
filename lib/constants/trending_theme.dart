import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Light theme design tokens for Mlimi Trending Stories.
class TrendingTheme {
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF1F5F9);
  static const Color surfaceContainer = Color(0xFFE2E8F0);
  static const Color surfaceContainerHigh = Color(0xFFCBD5E1);
  static const Color surfaceContainerHighest = Color(0xFF94A3B8);
  static const Color onBackground = Color(0xFF0F172A);
  static const Color onSurface = Color(0xFF0F172A);
  static const Color onSurfaceVariant = Color(0xFF475569);
  static const Color outline = Color(0xFF64748B);
  static const Color outlineVariant = Color(0xFFE2E8F0);
  static const Color primary = Color(0xFF006B29);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFE8F5E9);
  static const Color tertiary = Color(0xFF0284C7);
  static const Color tertiaryContainer = Color(0xFFE0F2FE);
  static const Color pureBlack = Color(0xFF000000);

  static const double appBarHeight = 64;
  static const double horizontalPadding = 16;

  static TextStyle displayLgMobile() => GoogleFonts.inter(
        fontSize: 28,
        height: 34 / 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.02,
        color: onBackground,
      );

  static TextStyle headlineMd({Color? color}) => GoogleFonts.inter(
        fontSize: 24,
        height: 32 / 24,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.01,
        color: color ?? onBackground,
      );

  static TextStyle headlineSm({Color? color}) => GoogleFonts.inter(
        fontSize: 20,
        height: 28 / 20,
        fontWeight: FontWeight.w600,
        color: color ?? onBackground,
      );

  static TextStyle bodyLg({Color? color}) => GoogleFonts.inter(
        fontSize: 16,
        height: 24 / 16,
        fontWeight: FontWeight.w400,
        color: color ?? onSurfaceVariant,
      );

  static TextStyle bodyMd({Color? color}) => GoogleFonts.inter(
        fontSize: 14,
        height: 20 / 14,
        fontWeight: FontWeight.w400,
        color: color ?? onSurfaceVariant,
      );

  static TextStyle labelMd({Color? color}) => GoogleFonts.inter(
        fontSize: 12,
        height: 16 / 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.05,
        color: color ?? onSurface,
      );

  static TextStyle labelSm({Color? color}) => GoogleFonts.inter(
        fontSize: 11,
        height: 14 / 11,
        fontWeight: FontWeight.w500,
        color: color ?? outline,
      );

  static BoxDecoration glass({double radius = 999}) => BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: outlineVariant),
      );

  static BoxDecoration scrimBottom() => const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Color(0xCC000000), Color(0x55000000), Colors.transparent],
          stops: [0, 0.45, 1],
        ),
      );
}
