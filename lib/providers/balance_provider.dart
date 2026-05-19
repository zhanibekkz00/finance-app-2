import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'transaction_provider.dart';
import '../models/transaction_model.dart';

final balanceProvider = Provider<double>((ref) {
  final txState = ref.watch(transactionProvider);
  double total = 0.0;
  for (var tx in txState.transactions) {
    if (tx.type == TransactionType.income) {
      total += tx.amount;
    } else if (tx.type == TransactionType.expense) {
      total -= tx.amount;
    }
  }
  return total;
});
