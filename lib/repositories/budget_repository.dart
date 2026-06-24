import 'dart:convert';
import '../services/api_service.dart';
import '../models/budget_model.dart';

class BudgetRepository {
  final ApiService _apiService = ApiService();

  Future<List<BudgetModel>> getBudgets(int month, int year) async {
    final response = await _apiService.get('/budgets?month=$month&year=$year');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => BudgetModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load budgets');
    }
  }

  Future<BudgetModel> upsertBudget(String categoryId, double amount, int month, int year) async {
    final response = await _apiService.post('/budgets', {
      'categoryId': categoryId,
      'amount': amount,
      'month': month,
      'year': year,
    });
    if (response.statusCode == 200 || response.statusCode == 201) {
      return BudgetModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to save budget');
    }
  }

  Future<void> deleteBudget(String id) async {
    final response = await _apiService.delete('/budgets/$id');
    if (response.statusCode != 200) {
      throw Exception('Failed to delete budget');
    }
  }

  Future<void> copyBudgets(int fromMonth, int fromYear, int toMonth, int toYear) async {
    final response = await _apiService.post('/budgets/copy', {
      'fromMonth': fromMonth,
      'fromYear': fromYear,
      'toMonth': toMonth,
      'toYear': toYear,
    });
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to copy budgets');
    }
  }
}
