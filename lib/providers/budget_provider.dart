import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/budget_model.dart';
import '../repositories/budget_repository.dart';

class BudgetState {
  final bool isLoading;
  final List<BudgetModel> budgets;
  final String? error;
  final int month;
  final int year;

  BudgetState({
    this.isLoading = false,
    this.budgets = const [],
    this.error,
    required this.month,
    required this.year,
  });

  BudgetState copyWith({
    bool? isLoading,
    List<BudgetModel>? budgets,
    String? error,
    int? month,
    int? year,
  }) {
    return BudgetState(
      isLoading: isLoading ?? this.isLoading,
      budgets: budgets ?? this.budgets,
      error: error,
      month: month ?? this.month,
      year: year ?? this.year,
    );
  }
}

class BudgetNotifier extends StateNotifier<BudgetState> {
  final BudgetRepository _repository;

  BudgetNotifier(this._repository) : super(BudgetState(month: DateTime.now().month, year: DateTime.now().year)) {
    loadBudgets(state.month, state.year);
  }

  Future<void> loadBudgets(int month, int year) async {
    state = state.copyWith(isLoading: true, month: month, year: year, error: null);
    try {
      final budgets = await _repository.getBudgets(month, year);
      state = state.copyWith(isLoading: false, budgets: budgets);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> upsertBudget(String categoryId, double amount) async {
    try {
      await _repository.upsertBudget(categoryId, amount, state.month, state.year);
      await loadBudgets(state.month, state.year);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteBudget(String id) async {
    try {
      await _repository.deleteBudget(id);
      await loadBudgets(state.month, state.year);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  BudgetModel? getBudgetForCategory(String categoryId) {
    try {
      return state.budgets.firstWhere((b) => b.categoryId == categoryId);
    } catch (e) {
      return null;
    }
  }
}

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  return BudgetRepository();
});

final budgetProvider = StateNotifierProvider<BudgetNotifier, BudgetState>((ref) {
  final repo = ref.read(budgetRepositoryProvider);
  return BudgetNotifier(repo);
});
