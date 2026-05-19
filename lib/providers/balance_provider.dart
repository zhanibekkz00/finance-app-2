import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'transaction_provider.dart';
import 'settings_provider.dart';
import '../models/transaction_model.dart';
import '../utils/debt_utils.dart';

final balanceProvider = Provider<double>((ref) {
  final txState = ref.watch(transactionProvider);
  final settings = ref.watch(settingsProvider);
  final targetCurrency = settings.currencyCode;
  
  double total = 0.0;
  for (var tx in txState.transactions) {
    final convertedAmount = DebtUtils.convertCurrency(tx.amount, tx.currency, targetCurrency);
    if (tx.type == TransactionType.income) {
      total += convertedAmount;
    } else if (tx.type == TransactionType.expense) {
      total -= convertedAmount;
    }
  }
  return total;
});
