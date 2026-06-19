import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/savings_goal_model.dart';
import 'api_service.dart';

class SavingsGoalService {
  final ApiService _apiService = ApiService();

  Future<List<SavingsGoalModel>> fetchSavingsGoals() async {
    try {
      final response = await _apiService.get('/savings-goals');
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => SavingsGoalModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching savings goals: $e');
      return [];
    }
  }

  Future<SavingsGoalModel?> createSavingsGoal({
    required String name,
    required double targetAmount,
    required String currency,
    DateTime? targetDate,
    int? colorValue,
  }) async {
    try {
      final Map<String, dynamic> body = {
        'name': name,
        'targetAmount': targetAmount,
        'currency': currency,
        if (targetDate != null) 'targetDate': targetDate.toIso8601String(),
        if (colorValue != null) 'colorValue': colorValue,
      };

      final response = await _apiService.post('/savings-goals', body);
      if (response.statusCode == 201) {
        return SavingsGoalModel.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      debugPrint('Error creating savings goal: $e');
      return null;
    }
  }

  Future<SavingsGoalModel?> addMoney(String goalId, double amount) async {
    try {
      final response = await _apiService.patch(
        '/savings-goals/$goalId/add-money',
        {'amount': amount},
      );
      if (response.statusCode == 200) {
        return SavingsGoalModel.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      debugPrint('Error adding money to savings goal: $e');
      return null;
    }
  }

  Future<SavingsGoalModel?> updateSavingsGoal(String goalId, Map<String, dynamic> data) async {
    try {
      final response = await _apiService.patch('/savings-goals/$goalId', data);
      if (response.statusCode == 200) {
        return SavingsGoalModel.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      debugPrint('Error updating savings goal: $e');
      return null;
    }
  }

  Future<bool> deleteSavingsGoal(String goalId) async {
    try {
      final response = await _apiService.delete('/savings-goals/$goalId');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint('Error deleting savings goal: $e');
      return false;
    }
  }
}
