import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';
import 'transaction_provider.dart';
import 'category_provider.dart';

enum ChartFilter { week, month, year, all }

class Debt {
  final String from;
  final String to;
  final double amount;

  Debt({required this.from, required this.to, required this.amount});
}

class ChartData {
  final Map<String, double> categorySpend;
  final Map<String, double> dateSpend;
  final Map<String, double> userSpend;
  final List<Debt> debts;
  final double totalSpend;
  
  ChartData({
    required this.categorySpend,
    required this.dateSpend,
    required this.userSpend,
    required this.debts,
    required this.totalSpend,
  });
}

class ChartState {
  final ChartFilter filter;
  final ChartData data;
  
  ChartState({required this.filter, required this.data});
}

final chartFilterProvider = StateProvider<ChartFilter>((ref) => ChartFilter.month);

final chartProvider = Provider<ChartState>((ref) {
  final txs = ref.watch(transactionProvider).transactions;
  final filter = ref.watch(chartFilterProvider);
  final now = DateTime.now();
  
  DateTime? startDate;
  switch (filter) {
    case ChartFilter.week:
      startDate = now.subtract(const Duration(days: 7));
      break;
    case ChartFilter.month:
      startDate = DateTime(now.year, now.month - 1, now.day);
      break;
    case ChartFilter.year:
      startDate = DateTime(now.year - 1, now.month, now.day);
      break;
    case ChartFilter.all:
      startDate = null;
      break;
  }

  final filteredTxs = txs.where((tx) {
    if (tx.type != TransactionType.expense) return false;
    if (startDate != null && tx.date.isBefore(startDate)) return false;
    return true;
  }).toList();

  final Map<String, double> catMap = {};
  final Map<String, double> dateMap = {};
  final Map<String, double> userMap = {};
  double total = 0;

  for (var tx in filteredTxs) {
    catMap[tx.categoryId] = (catMap[tx.categoryId] ?? 0) + tx.amount;
    final dateKey = DateFormat('yyyy-MM-dd').format(tx.date);
    dateMap[dateKey] = (dateMap[dateKey] ?? 0) + tx.amount;
    userMap[tx.userId] = (userMap[tx.userId] ?? 0) + tx.amount;
    total += tx.amount;
  }

  // Calculate debts
  final debts = <Debt>[];
  if (userMap.isNotEmpty) {
    final average = total / userMap.length;
    List<Map<String, dynamic>> balances = userMap.entries.map((e) {
      return {'name': e.key, 'balance': e.value - average};
    }).toList();

    balances.sort((a, b) => a['balance'].compareTo(b['balance']));

    int i = 0;
    int j = balances.length - 1;
    while (i < j) {
      double owe = balances[i]['balance'];
      double owed = balances[j]['balance'];

      if (owe >= -0.01) {
        i++;
        continue;
      }
      if (owed <= 0.01) {
        j--;
        continue;
      }

      double amount = (-owe < owed) ? -owe : owed;
      debts.add(Debt(from: balances[i]['name'], to: balances[j]['name'], amount: amount));

      balances[i]['balance'] += amount;
      balances[j]['balance'] -= amount;

      if (balances[i]['balance'] >= -0.01) i++;
      if (balances[j]['balance'] <= 0.01) j--;
    }
  }

  return ChartState(
    filter: filter,
    data: ChartData(
      categorySpend: catMap,
      dateSpend: dateMap,
      userSpend: userMap,
      debts: debts,
      totalSpend: total,
    ),
  );
});
