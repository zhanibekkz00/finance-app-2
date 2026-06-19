import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category_model.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';

class CategoryNotifier extends StateNotifier<List<CategoryModel>> {
  final ApiService _apiService = ApiService();
  final Ref _ref;

  CategoryNotifier(this._ref, AuthState authState) : super([]) {
    if (authState.status == AuthStatus.authenticated) {
      fetchCategories();
    }
  }


  Future<void> fetchCategories() async {
    try {
      final response = await _apiService.get('/categories');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final categories = data.map((json) => CategoryModel.fromMap(json)).toList();

        if (categories.isEmpty) {
          state = _getDefaultList();
        } else {
          state = categories;
        }
      } else {
        debugPrint('Failed to fetch categories: ${response.statusCode}');
        if (state.isEmpty) state = _getDefaultList();
      }
    } catch (e) {
      debugPrint('Error fetching categories: $e');
      if (state.isEmpty) state = _getDefaultList();
    }
  }

  List<CategoryModel> _getDefaultList() {
    return [
      CategoryModel(
        id: '00000000-0000-0000-0000-000000000001',
        name: 'Еда',
        colorValue: 0xFFF44336,
        iconCode: 0xe25a,
        isDefault: true,
        type: 'expense',
      ),
      CategoryModel(
        id: '00000000-0000-0000-0000-000000000002',
        name: 'Развлечения',
        colorValue: 0xFF9C27B0,
        iconCode: 0xe338,
        isDefault: true,
        type: 'expense',
      ),
      CategoryModel(
        id: '00000000-0000-0000-0000-000000000003',
        name: 'Поездки',
        colorValue: 0xFF2196F3,
        iconCode: 0xe539,
        isDefault: true,
        type: 'expense',
      ),
      CategoryModel(
        id: '00000000-0000-0000-0000-000000000004',
        name: 'Зарплата',
        colorValue: 0xFF4CAF50,
        iconCode: 0xe263,
        isDefault: true,
        type: 'income',
      ),
    ];
  }

  Future<void> add(CategoryModel category) async {
    try {
      final response = await _apiService.post('/categories', {
        'name': category.name,
        'colorValue': category.colorValue,
        'iconCode': category.iconCode,
        'imageUrl': category.imageUrl,
        'type': category.type,
      });

      if (response.statusCode == 201) {
        await fetchCategories();
      }
    } catch (e) {
      debugPrint('CategoryNotifier: Error adding category: $e');
    }
  }

  Future<void> updateCategory(String id, CategoryModel category) async {
    try {
      final response = await _apiService.patch('/categories/$id', {
        'name': category.name,
        'colorValue': category.colorValue,
        'iconCode': category.iconCode,
        'imageUrl': category.imageUrl,
        'type': category.type,
      });

      if (response.statusCode == 200) {
        await fetchCategories();
      }
    } catch (e) {
      debugPrint('CategoryNotifier: Error updating category: $e');
    }
  }

  Future<void> delete(String id) async {
    try {
      final response = await _apiService.delete('/categories/$id');
      if (response.statusCode == 200) {
        await fetchCategories();
      }
    } catch (e) {
      debugPrint('CategoryNotifier: Error deleting category: $id');
    }
  }

  CategoryModel? getCategoryById(String id) {
    if (state.isEmpty) return null;
    try {
      return state.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}

final categoryProvider =
    StateNotifierProvider<CategoryNotifier, List<CategoryModel>>((ref) {
  final authState = ref.watch(authProvider);
  return CategoryNotifier(ref, authState);
});
