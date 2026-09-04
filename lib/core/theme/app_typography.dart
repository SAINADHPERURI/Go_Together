import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Typography definitions for GoTogether
class AppTypography {
  static TextStyle get displaySmall => GoogleFonts.outfit(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.8,
        height: 1.15,
      );

  static TextStyle get headlineLarge => GoogleFonts.outfit(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1.2,
      );

  static TextStyle get headlineMedium => GoogleFonts.outfit(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        height: 1.25,
      );

  static TextStyle get headlineSmall => GoogleFonts.outfit(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        height: 1.3,
      );

  static TextStyle get titleLarge => GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
        height: 1.35,
      );

  static TextStyle get titleMedium => GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.4,
      );

  static TextStyle get titleSmall => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.4,
      );

  static TextStyle get bodyLarge => GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.2,
        height: 1.5,
      );

  static TextStyle get bodyMedium => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.2,
        height: 1.5,
      );

  static TextStyle get bodySmall => GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.2,
        height: 1.5,
      );

  static TextStyle get labelLarge => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      );

  static TextStyle get labelMedium => GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
      );

  static TextStyle get labelSmall => GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      );

  // Senior Accessible typography variant with increased scale and higher contrast weight
  static TextTheme seniorTextTheme(bool isDark) {
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    return TextTheme(
      headlineLarge: headlineLarge.copyWith(fontSize: 36, fontWeight: FontWeight.w800, color: textColor),
      headlineMedium: headlineMedium.copyWith(fontSize: 30, fontWeight: FontWeight.w800, color: textColor),
      headlineSmall: headlineSmall.copyWith(fontSize: 26, fontWeight: FontWeight.w700, color: textColor),
      titleLarge: titleLarge.copyWith(fontSize: 22, fontWeight: FontWeight.w700, color: textColor),
      titleMedium: titleMedium.copyWith(fontSize: 19, fontWeight: FontWeight.w700, color: textColor),
      titleSmall: titleSmall.copyWith(fontSize: 17, fontWeight: FontWeight.w600, color: textColor),
      bodyLarge: bodyLarge.copyWith(fontSize: 18, fontWeight: FontWeight.w500, color: textColor),
      bodyMedium: bodyMedium.copyWith(fontSize: 16, fontWeight: FontWeight.w500, color: textColor),
      bodySmall: bodySmall.copyWith(fontSize: 14, fontWeight: FontWeight.w500, color: textColor),
      labelLarge: labelLarge.copyWith(fontSize: 16, fontWeight: FontWeight.w700, color: textColor),
      labelMedium: labelMedium.copyWith(fontSize: 14, fontWeight: FontWeight.w700, color: textColor),
      labelSmall: labelSmall.copyWith(fontSize: 13, fontWeight: FontWeight.w600, color: textColor),
    );
  }
}
