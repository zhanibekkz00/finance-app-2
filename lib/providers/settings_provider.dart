import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  final ThemeMode themeMode;
  final Locale locale;
  final String currencyCode;
  final String geminiApiKey;

  AppSettings({
    this.themeMode = ThemeMode.system,
    this.locale = const Locale('kk'),
    this.currencyCode = 'USD',
    this.geminiApiKey = '',
  });

  AppSettings copyWith(
      {ThemeMode? themeMode, Locale? locale, String? currencyCode, String? geminiApiKey}) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
      currencyCode: currencyCode ?? this.currencyCode,
      geminiApiKey: geminiApiKey ?? this.geminiApiKey,
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
      final lang = prefs.getString('language_code') ?? 'kk';
      final theme = prefs.getString('theme_mode') ?? 'system';
      final currency = prefs.getString('currency_code') ?? 'USD';
      final apiKey = prefs.getString('gemini_api_key') ?? '';

      ThemeMode themeMode = ThemeMode.system;
      if (theme == 'dark') themeMode = ThemeMode.dark;
      if (theme == 'light') themeMode = ThemeMode.light;

      Intl.defaultLocale = lang;
      state = AppSettings(
        locale: Locale(lang),
        themeMode: themeMode,
        currencyCode: currency,
        geminiApiKey: apiKey,
      );
    } catch (e) {
      debugPrint('Error loading settings: $e');
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    try {
      final prefs = await SharedPreferences.getInstance();
      String themeStr = 'system';
      if (mode == ThemeMode.dark) themeStr = 'dark';
      if (mode == ThemeMode.light) themeStr = 'light';
      await prefs.setString('theme_mode', themeStr);
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

  Future<void> setGeminiApiKey(String key) async {
    state = state.copyWith(geminiApiKey: key);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('gemini_api_key', key);
    } catch (e) {
      debugPrint('Error saving Gemini API key: $e');
    }
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier();
});
