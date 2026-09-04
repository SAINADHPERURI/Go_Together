import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_dimensions.dart';
import 'app_typography.dart';

/// AppTheme configuration for GoTogether
class AppTheme {
  static ThemeData lightTheme({bool isSeniorMode = false}) {
    final textTheme = isSeniorMode
        ? AppTypography.seniorTextTheme(false)
        : GoogleFonts.plusJakartaSansTextTheme().copyWith(
            headlineLarge: AppTypography.headlineLarge.copyWith(color: AppColors.textPrimaryLight),
            headlineMedium: AppTypography.headlineMedium.copyWith(color: AppColors.textPrimaryLight),
            headlineSmall: AppTypography.headlineSmall.copyWith(color: AppColors.textPrimaryLight),
            titleLarge: AppTypography.titleLarge.copyWith(color: AppColors.textPrimaryLight),
            titleMedium: AppTypography.titleMedium.copyWith(color: AppColors.textPrimaryLight),
            titleSmall: AppTypography.titleSmall.copyWith(color: AppColors.textPrimaryLight),
            bodyLarge: AppTypography.bodyLarge.copyWith(color: AppColors.textPrimaryLight),
            bodyMedium: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondaryLight),
            bodySmall: AppTypography.bodySmall.copyWith(color: AppColors.textMutedLight),
            labelLarge: AppTypography.labelLarge.copyWith(color: AppColors.textPrimaryLight),
            labelMedium: AppTypography.labelMedium.copyWith(color: AppColors.textSecondaryLight),
            labelSmall: AppTypography.labelSmall.copyWith(color: AppColors.textMutedLight),
          );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: AppColors.primaryDark,
        secondary: AppColors.secondary,
        onSecondary: Colors.white,
        secondaryContainer: AppColors.secondaryContainer,
        surface: AppColors.surfaceLight,
        onSurface: AppColors.textPrimaryLight,
        error: AppColors.error,
        onError: Colors.white,
        outline: AppColors.borderLight,
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surfaceLight,
        foregroundColor: AppColors.textPrimaryLight,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: isSeniorMode
            ? AppTypography.headlineSmall.copyWith(color: AppColors.textPrimaryLight, fontWeight: FontWeight.w700)
            : AppTypography.titleLarge.copyWith(color: AppColors.textPrimaryLight),
        iconTheme: const IconThemeData(color: AppColors.textPrimaryLight, size: 24),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          side: const BorderSide(color: AppColors.dividerLight, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: Size(double.infinity, isSeniorMode ? AppDimensions.buttonHeightSenior : AppDimensions.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
          textStyle: isSeniorMode
              ? AppTypography.labelLarge.copyWith(fontSize: 17, fontWeight: FontWeight.w700)
              : AppTypography.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: Size(double.infinity, isSeniorMode ? AppDimensions.buttonHeightSenior : AppDimensions.buttonHeight),
          side: BorderSide(color: AppColors.primary, width: isSeniorMode ? 2 : 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
          textStyle: isSeniorMode
              ? AppTypography.labelLarge.copyWith(fontSize: 17, fontWeight: FontWeight.w700)
              : AppTypography.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: const BorderSide(color: AppColors.borderLight, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: const BorderSide(color: AppColors.borderLight, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textMutedLight),
        labelStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondaryLight),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.backgroundLight,
        selectedColor: AppColors.primaryContainer,
        side: const BorderSide(color: AppColors.borderLight, width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        ),
        labelStyle: AppTypography.labelMedium,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.dividerLight,
        thickness: 1,
        space: 1,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceLight,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textMutedLight,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }

  static ThemeData darkTheme({bool isSeniorMode = false}) {
    final textTheme = isSeniorMode
        ? AppTypography.seniorTextTheme(true)
        : GoogleFonts.plusJakartaSansTextTheme(ThemeData.dark().textTheme).copyWith(
            headlineLarge: AppTypography.headlineLarge.copyWith(color: AppColors.textPrimaryDark),
            headlineMedium: AppTypography.headlineMedium.copyWith(color: AppColors.textPrimaryDark),
            headlineSmall: AppTypography.headlineSmall.copyWith(color: AppColors.textPrimaryDark),
            titleLarge: AppTypography.titleLarge.copyWith(color: AppColors.textPrimaryDark),
            titleMedium: AppTypography.titleMedium.copyWith(color: AppColors.textPrimaryDark),
            titleSmall: AppTypography.titleSmall.copyWith(color: AppColors.textPrimaryDark),
            bodyLarge: AppTypography.bodyLarge.copyWith(color: AppColors.textPrimaryDark),
            bodyMedium: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondaryDark),
            bodySmall: AppTypography.bodySmall.copyWith(color: AppColors.textMutedDark),
            labelLarge: AppTypography.labelLarge.copyWith(color: AppColors.textPrimaryDark),
            labelMedium: AppTypography.labelMedium.copyWith(color: AppColors.textSecondaryDark),
            labelSmall: AppTypography.labelSmall.copyWith(color: AppColors.textMutedDark),
          );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primaryLight,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryLight,
        onPrimary: AppColors.backgroundDark,
        primaryContainer: AppColors.primaryDark,
        onPrimaryContainer: Colors.white,
        secondary: AppColors.secondaryLight,
        onSecondary: Colors.white,
        surface: AppColors.surfaceDark,
        onSurface: AppColors.textPrimaryDark,
        error: AppColors.error,
        onError: Colors.white,
        outline: AppColors.borderDark,
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surfaceDark,
        foregroundColor: AppColors.textPrimaryDark,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: isSeniorMode
            ? AppTypography.headlineSmall.copyWith(color: AppColors.textPrimaryDark, fontWeight: FontWeight.w700)
            : AppTypography.titleLarge.copyWith(color: AppColors.textPrimaryDark),
        iconTheme: const IconThemeData(color: AppColors.textPrimaryDark, size: 24),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          side: const BorderSide(color: AppColors.dividerDark, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryLight,
          foregroundColor: AppColors.backgroundDark,
          elevation: 0,
          minimumSize: Size(double.infinity, isSeniorMode ? AppDimensions.buttonHeightSenior : AppDimensions.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
          textStyle: isSeniorMode
              ? AppTypography.labelLarge.copyWith(fontSize: 17, fontWeight: FontWeight.w700)
              : AppTypography.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryLight,
          minimumSize: Size(double.infinity, isSeniorMode ? AppDimensions.buttonHeightSenior : AppDimensions.buttonHeight),
          side: BorderSide(color: AppColors.primaryLight, width: isSeniorMode ? 2 : 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
          textStyle: isSeniorMode
              ? AppTypography.labelLarge.copyWith(fontSize: 17, fontWeight: FontWeight.w700)
              : AppTypography.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: const BorderSide(color: AppColors.borderDark, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: const BorderSide(color: AppColors.borderDark, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textMutedDark),
        labelStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondaryDark),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceDark,
        selectedColor: AppColors.primaryDark,
        side: const BorderSide(color: AppColors.borderDark, width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        ),
        labelStyle: AppTypography.labelMedium,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.dividerDark,
        thickness: 1,
        space: 1,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceDark,
        selectedItemColor: AppColors.primaryLight,
        unselectedItemColor: AppColors.textMutedDark,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
