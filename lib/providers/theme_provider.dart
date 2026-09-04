import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeSettingsState {
  final ThemeMode themeMode;
  final bool isSeniorAccessibleMode;

  const ThemeSettingsState({
    this.themeMode = ThemeMode.light,
    this.isSeniorAccessibleMode = false,
  });

  ThemeSettingsState copyWith({
    ThemeMode? themeMode,
    bool? isSeniorAccessibleMode,
  }) {
    return ThemeSettingsState(
      themeMode: themeMode ?? this.themeMode,
      isSeniorAccessibleMode: isSeniorAccessibleMode ?? this.isSeniorAccessibleMode,
    );
  }
}

class ThemeSettingsNotifier extends StateNotifier<ThemeSettingsState> {
  ThemeSettingsNotifier() : super(const ThemeSettingsState()) {
    _loadFromPrefs();
  }

  static const String _keyThemeMode = 'app_theme_mode';
  static const String _keySeniorMode = 'app_senior_mode';

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final modeIndex = prefs.getInt(_keyThemeMode) ?? 0;
      final isSenior = prefs.getBool(_keySeniorMode) ?? false;

      ThemeMode mode = ThemeMode.light;
      if (modeIndex == 1) mode = ThemeMode.dark;
      if (modeIndex == 2) mode = ThemeMode.system;

      state = ThemeSettingsState(
        themeMode: mode,
        isSeniorAccessibleMode: isSenior,
      );
    } catch (_) {}
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    try {
      final prefs = await SharedPreferences.getInstance();
      int modeIndex = 0;
      if (mode == ThemeMode.dark) modeIndex = 1;
      if (mode == ThemeMode.system) modeIndex = 2;
      await prefs.setInt(_keyThemeMode, modeIndex);
    } catch (_) {}
  }

  Future<void> toggleSeniorMode(bool enabled) async {
    state = state.copyWith(isSeniorAccessibleMode: enabled);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keySeniorMode, enabled);
    } catch (_) {}
  }
}

final themeSettingsProvider =
    StateNotifierProvider<ThemeSettingsNotifier, ThemeSettingsState>((ref) {
  return ThemeSettingsNotifier();
});
