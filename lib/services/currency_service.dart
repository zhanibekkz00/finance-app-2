import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Сервис для получения актуальных курсов валют.
/// Использует бесплатный API open.er-api.com.
/// Кэширует курсы на 24 часа в SharedPreferences.
class CurrencyService {
  static const String _baseUrl = 'https://open.er-api.com/v6/latest/USD';
  static const String _prefRates = 'exchange_rates_json';
  static const String _prefTimestamp = 'exchange_rates_timestamp';
  static const int _cacheDurationHours = 24;

  // Резервные курсы на случай отсутствия интернета
  static const Map<String, double> _fallbackRates = {
    'USD': 1.0,
    'KZT': 525.0,
    'RUB': 83.0,
    'EUR': 0.93,
  };

  static Map<String, double> _rates = Map.from(_fallbackRates);
  static bool _isLoaded = false;

  /// Получить текущие курсы (загрузить с API или из кэша).
  static Future<Map<String, double>> getRates() async {
    if (_isLoaded) return _rates;
    await _loadRates();
    return _rates;
  }

  /// Конвертировать сумму из одной валюты в другую.
  static Future<double> convert(
      double amount, String from, String to) async {
    if (from.toUpperCase() == to.toUpperCase()) return amount;
    final rates = await getRates();
    final fromRate = rates[from.toUpperCase()] ?? 1.0;
    final toRate = rates[to.toUpperCase()] ?? 1.0;
    // Конвертируем через USD
    final amountInUsd = amount / fromRate;
    return amountInUsd * toRate;
  }

  /// Синхронная конвертация с уже загруженными курсами.
  static double convertSync(double amount, String from, String to) {
    if (from.toUpperCase() == to.toUpperCase()) return amount;
    final fromRate = _rates[from.toUpperCase()] ?? 1.0;
    final toRate = _rates[to.toUpperCase()] ?? 1.0;
    final amountInUsd = amount / fromRate;
    return amountInUsd * toRate;
  }

  /// Принудительно обновить курсы с API.
  static Future<bool> refreshRates() async {
    return await _fetchFromApi();
  }

  /// Дата последнего обновления курсов.
  static Future<DateTime?> getLastUpdateTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ts = prefs.getInt(_prefTimestamp);
      if (ts != null) {
        return DateTime.fromMillisecondsSinceEpoch(ts);
      }
    } catch (_) {}
    return null;
  }

  static Future<void> _loadRates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ts = prefs.getInt(_prefTimestamp);
      final json = prefs.getString(_prefRates);

      // Если кэш свежий (< 24 часов) — использовать его
      if (ts != null && json != null) {
        final cacheAge = DateTime.now().millisecondsSinceEpoch - ts;
        const maxAge = _cacheDurationHours * 60 * 60 * 1000;
        if (cacheAge < maxAge) {
          _parseRates(json);
          _isLoaded = true;
          debugPrint('[CurrencyService] Loaded rates from cache');
          return;
        }
      }
    } catch (e) {
      debugPrint('[CurrencyService] Cache read error: $e');
    }

    // Иначе — загрузить с API
    await _fetchFromApi();
    _isLoaded = true;
  }

  static Future<bool> _fetchFromApi() async {
    try {
      final response = await http
          .get(Uri.parse(_baseUrl))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final json = response.body;
        _parseRates(json);

        // Сохранить в кэш
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_prefRates, json);
        await prefs.setInt(
            _prefTimestamp, DateTime.now().millisecondsSinceEpoch);

        debugPrint('[CurrencyService] Rates updated from API: $_rates');
        return true;
      } else {
        debugPrint('[CurrencyService] API error: ${response.statusCode}');
        _useFallback();
        return false;
      }
    } catch (e) {
      debugPrint('[CurrencyService] Network error: $e');
      _useFallback();
      return false;
    }
  }

  static void _parseRates(String json) {
    try {
      final data = jsonDecode(json) as Map<String, dynamic>;
      final rawRates = data['rates'] as Map<String, dynamic>?;
      if (rawRates != null) {
        _rates = {
          'USD': 1.0,
          'KZT': (rawRates['KZT'] as num?)?.toDouble() ?? _fallbackRates['KZT']!,
          'RUB': (rawRates['RUB'] as num?)?.toDouble() ?? _fallbackRates['RUB']!,
          'EUR': (rawRates['EUR'] as num?)?.toDouble() ?? _fallbackRates['EUR']!,
        };
      }
    } catch (e) {
      debugPrint('[CurrencyService] Parse error: $e');
      _useFallback();
    }
  }

  static void _useFallback() {
    _rates = Map.from(_fallbackRates);
    debugPrint('[CurrencyService] Using fallback rates: $_rates');
  }
}
