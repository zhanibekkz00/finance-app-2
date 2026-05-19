import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  final ThemeMode themeMode;
  final Locale locale;
  final String currencyCode;

  AppSettings({
    this.themeMode = ThemeMode.system,
    this.locale = const Locale('ru'),
    this.currencyCode = 'USD',
  });

  AppSettings copyWith(
      {ThemeMode? themeMode, Locale? locale, String? currencyCode}) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
      currencyCode: currencyCode ?? this.currencyCode,
    );
  }
}

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(AppSettings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lang = prefs.getString('language_code') ?? 'ru';
      final theme = prefs.getString('theme_mode') ?? 'system';
      final currency = prefs.getString('currency_code') ?? 'USD';

      ThemeMode themeMode = ThemeMode.system;
      if (theme == 'dark') themeMode = ThemeMode.dark;
      if (theme == 'light') themeMode = ThemeMode.light;

      Intl.defaultLocale = lang;
      state = AppSettings(
        locale: Locale(lang),
        themeMode: themeMode,
        currencyCode: currency,
      );
    } catch (e) {
      debugPrint('Error loading settings: $e');
    }
  }

  Future<void> toggleTheme() async {
    final newMode =
        state.themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    state = state.copyWith(themeMode: newMode);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('theme_mode', newMode == ThemeMode.dark ? 'dark' : 'light');
    } catch (e) {
      debugPrint('Error saving theme: $e');
    }
  }

  Future<void> setLocale(Locale cx) async {
    Intl.defaultLocale = cx.languageCode;
    state = state.copyWith(locale: cx);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language_code', cx.languageCode);
    } catch (e) {
      debugPrint('Error saving locale: $e');
    }
  }

  Future<void> setCurrency(String code) async {
    state = state.copyWith(currencyCode: code);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('currency_code', code);
    } catch (e) {
      debugPrint('Error saving currency: $e');
    }
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier();
});
