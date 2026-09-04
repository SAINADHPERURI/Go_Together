import 'package:flutter/material.dart';

/// FAANG-inspired Luxury Travel Palette for GoTogether
/// Blending Electric Indigo, Vibrant Sunset Coral, and Obsidian Dark Tokens
class AppColors {
  // Primary Brand Gradients & Accents (FAANG / Airbnb / Stripe Inspired)
  static const Color primary = Color(0xFF6366F1); // Radiant Electric Indigo
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryContainer = Color(0xFFEEF2FF);

  // Secondary Accent (Sunset Coral / Radiant Rose)
  static const Color secondary = Color(0xFFFF5A5F); // Iconic Coral Pink
  static const Color secondaryLight = Color(0xFFFF7E82);
  static const Color secondaryContainer = Color(0xFFFFF1F2);

  // Tertiary Accent (Cyan Azure)
  static const Color accent = Color(0xFF06B6D4); // Vibrant Cyan
  static const Color accentContainer = Color(0xFFECFEFF);

  // Gradient definitions for UI headers, logos, and hero badges
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFFFF5A5F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient logoGradient = LinearGradient(
    colors: [Color(0xFF4F46E5), Color(0xFF7C3AED), Color(0xFFFF5A5F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroCardGradient = LinearGradient(
    colors: [Color(0xFF1E1B4B), Color(0xFF312E81), Color(0xFF4338CA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient sunsetGradient = LinearGradient(
    colors: [Color(0xFFFF5A5F), Color(0xFFF59E0B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Light Theme Surfaces & Neutrals
  static const Color backgroundLight = Color(0xFFF8FAFC); // Clean Slate-50
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardBorderLight = Color(0xFFE2E8F0); // Slate-200
  static const Color borderLight = Color(0xFFE2E8F0); // Slate-200
  static const Color dividerLight = Color(0xFFE2E8F0);

  // Dark Theme Surfaces & Neutrals
  static const Color backgroundDark = Color(0xFF0B0F19); // Midnight Obsidian
  static const Color surfaceDark = Color(0xFF111827); // Deep Slate-900
  static const Color cardDark = Color(0xFF1F2937); // Slate-800
  static const Color cardBorderDark = Color(0xFF374151); // Slate-700
  static const Color borderDark = Color(0xFF374151); // Slate-700
  static const Color dividerDark = Color(0xFF1F2937);

  // Shimmer animation tokens
  static const Color shimmerBaseLight = Color(0xFFE2E8F0);
  static const Color shimmerHighlightLight = Color(0xFFF1F5F9);
  static const Color shimmerBaseDark = Color(0xFF1F2937);
  static const Color shimmerHighlightDark = Color(0xFF374151);

  // Typography Tokens
  static const Color textPrimaryLight = Color(0xFF0F172A); // Slate-900
  static const Color textSecondaryLight = Color(0xFF475569); // Slate-600
  static const Color textMutedLight = Color(0xFF94A3B8); // Slate-400

  static const Color textPrimaryDark = Color(0xFFF8FAFC); // Slate-50
  static const Color textSecondaryDark = Color(0xFFCBD5E1); // Slate-300
  static const Color textMutedDark = Color(0xFF64748B); // Slate-500

  // Semantic Status Colors
  static const Color success = Color(0xFF10B981); // Emerald 500
  static const Color successContainer = Color(0xFFECFDF5);
  static const Color warning = Color(0xFFF59E0B); // Amber 500
  static const Color warningContainer = Color(0xFFFFFBEB);
  static const Color error = Color(0xFFEF4444); // Red 500
  static const Color errorContainer = Color(0xFFFEF2F2);
  static const Color info = Color(0xFF3B82F6); // Blue 500

  // Age Group Specialized Accent Colors (Dynamic cohort branding)
  static const Color ageGroup18_24 = Color(0xFFEC4899); // Electric Pink / Youth Explorer
  static const Color ageGroup25_31 = Color(0xFF8B5CF6); // Violet / Active Adventurer
  static const Color ageGroup32_40 = Color(0xFF3B82F6); // Royal Blue / Prime Explorer
  static const Color ageGroup41_50 = Color(0xFF0D9488); // Teal / Seasoned Wanderer
  // ignore: constant_identifier_names
  static const Color ageGroup51_Plus = Color(0xFFD97706); // Golden Amber / Heritage & Pilgrim
  static const Color ageGroup51Plus = ageGroup51_Plus; // CamelCase alias for linter
}
