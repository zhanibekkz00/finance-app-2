class SavingsGoalModel {
  final String id;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final String currency;
  final DateTime? targetDate;
  final int? colorValue;

  SavingsGoalModel({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.currency,
    this.targetDate,
    this.colorValue,
  });

  factory SavingsGoalModel.fromJson(Map<String, dynamic> json) {
    return SavingsGoalModel(
      id: json['id'],
      name: json['name'],
      targetAmount: double.tryParse(json['targetAmount'].toString()) ?? 0.0,
      currentAmount: double.tryParse(json['currentAmount'].toString()) ?? 0.0,
      currency: json['currency'] ?? 'USD',
      targetDate: json['targetDate'] != null ? DateTime.parse(json['targetDate']) : null,
      colorValue: json['colorValue'] != null ? int.tryParse(json['colorValue'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'currency': currency,
      'targetDate': targetDate?.toIso8601String(),
      'colorValue': colorValue,
    };
  }

  double get progress => targetAmount > 0 ? (currentAmount / targetAmount).clamp(0.0, 1.0) : 0.0;
  bool get isCompleted => currentAmount >= targetAmount;
}
