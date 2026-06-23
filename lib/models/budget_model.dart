import 'category_model.dart';

class BudgetModel {
  final String id;
  final String categoryId;
  final double amount;
  final int month;
  final int year;
  final double spentAmount;
  final CategoryModel? category;

  BudgetModel({
    required this.id,
    required this.categoryId,
    required this.amount,
    required this.month,
    required this.year,
    this.spentAmount = 0.0,
    this.category,
  });

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      id: json['id'],
      categoryId: json['categoryId'],
      amount: (json['amount'] as num).toDouble(),
      month: json['month'],
      year: json['year'],
      spentAmount: (json['spentAmount'] as num?)?.toDouble() ?? 0.0,
      category: json['category'] != null ? CategoryModel.fromMap(json['category']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryId': categoryId,
      'amount': amount,
      'month': month,
      'year': year,
      'spentAmount': spentAmount,
    };
  }

  BudgetModel copyWith({
    String? id,
    String? categoryId,
    double? amount,
    int? month,
    int? year,
    double? spentAmount,
  }) {
    return BudgetModel(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      month: month ?? this.month,
      year: year ?? this.year,
      spentAmount: spentAmount ?? this.spentAmount,
    );
  }
}
