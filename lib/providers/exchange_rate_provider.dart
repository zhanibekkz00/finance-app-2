import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/currency_service.dart';

/// Провайдер для загрузки актуальных курсов валют.
/// AsyncValue<Map<String, double>> — словарь вида {'USD': 1.0, 'KZT': 525.3, ...}
final exchangeRatesProvider =
    FutureProvider<Map<String, double>>((ref) async {
  return CurrencyService.getRates();
});

/// Провайдер для конвертации суммы из одной валюты в другую.
/// Использует уже загруженные курсы (синхронно).
double convertAmount(
    Map<String, double>? rates, double amount, String from, String to) {
  if (from.toUpperCase() == to.toUpperCase()) return amount;
  if (rates == null) return CurrencyService.convertSync(amount, from, to);
  final fromRate = rates[from.toUpperCase()] ?? 1.0;
  final toRate = rates[to.toUpperCase()] ?? 1.0;
  return (amount / fromRate) * toRate;
}
