import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/savings_goal_model.dart';
import '../services/savings_goal_service.dart';
import 'transaction_provider.dart';
import 'auth_provider.dart';

class SavingsGoalState {
  final bool isLoading;
  final List<SavingsGoalModel> goals;
  final String? error;

  SavingsGoalState({
    this.isLoading = false,
    this.goals = const [],
    this.error,
  });

  SavingsGoalState copyWith({
    bool? isLoading,
    List<SavingsGoalModel>? goals,
    String? error,
  }) {
    return SavingsGoalState(
      isLoading: isLoading ?? this.isLoading,
      goals: goals ?? this.goals,
      error: error,
    );
  }
}

class SavingsGoalNotifier extends StateNotifier<SavingsGoalState> {
  final SavingsGoalService _service;
  final Ref _ref;

  SavingsGoalNotifier(this._service, this._ref, AuthState authState) : super(SavingsGoalState()) {
    if (authState.status == AuthStatus.authenticated) {
      fetchGoals();
    }
  }

  Future<void> fetchGoals() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final goals = await _service.fetchSavingsGoals();
      state = state.copyWith(isLoading: false, goals: goals);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> createGoal({
    required String name,
    required double targetAmount,
    required String currency,
    DateTime? targetDate,
    int? colorValue,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final newGoal = await _service.createSavingsGoal(
        name: name,
        targetAmount: targetAmount,
        currency: currency,
        targetDate: targetDate,
        colorValue: colorValue,
      );
      if (newGoal != null) {
        state = state.copyWith(
          isLoading: false,
          goals: [newGoal, ...state.goals],
        );
        return true;
      } else {
        state = state.copyWith(isLoading: false, error: 'Failed to create savings goal');
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> addMoney(String goalId, double amount) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final updatedGoal = await _service.addMoney(goalId, amount);
      if (updatedGoal != null) {
        state = state.copyWith(
          isLoading: false,
          goals: state.goals.map((g) => g.id == goalId ? updatedGoal : g).toList(),
        );
        // Refresh transaction provider to show the new expense transaction on Dashboard
        _ref.read(transactionProvider.notifier).fetchTransactions();
        return true;
      } else {
        state = state.copyWith(isLoading: false, error: 'Failed to add money');
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> updateGoal(String goalId, Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final updatedGoal = await _service.updateSavingsGoal(goalId, data);
      if (updatedGoal != null) {
        state = state.copyWith(
          isLoading: false,
          goals: state.goals.map((g) => g.id == goalId ? updatedGoal : g).toList(),
        );
        return true;
      } else {
        state = state.copyWith(isLoading: false, error: 'Failed to update goal');
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> deleteGoal(String goalId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final success = await _service.deleteSavingsGoal(goalId);
      if (success) {
        state = state.copyWith(
          isLoading: false,
          goals: state.goals.where((g) => g.id != goalId).toList(),
        );
        return true;
      } else {
        state = state.copyWith(isLoading: false, error: 'Failed to delete goal');
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}

final savingsGoalServiceProvider = Provider<SavingsGoalService>((ref) {
  return SavingsGoalService();
});

final savingsGoalProvider = StateNotifierProvider<SavingsGoalNotifier, SavingsGoalState>((ref) {
  final service = ref.read(savingsGoalServiceProvider);
  final authState = ref.watch(authProvider);
  return SavingsGoalNotifier(service, ref, authState);
});
