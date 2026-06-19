class DebtModel {
  final String id;
  final String type;
  final String creditorName;
  final double totalAmount;
  final double remainingAmount;
  final String currency;
  final String? bankProduct;
  final double? annualRate;
  final int? termMonths;
  final DateTime? startDate;

  DebtModel({
    required this.id,
    required this.type,
    required this.creditorName,
    required this.totalAmount,
    required this.remainingAmount,
    required this.currency,
    this.bankProduct,
    this.annualRate,
    this.termMonths,
    this.startDate,
  });

  factory DebtModel.fromJson(Map<String, dynamic> json) {
    return DebtModel(
      id: json['id'],
      type: json['type'],
      creditorName: json['creditorName'] ?? 'Неизвестно',
      totalAmount: double.tryParse(json['totalAmount'].toString()) ?? 0.0,
      remainingAmount: double.tryParse(json['remainingAmount'].toString()) ?? 0.0,
      currency: json['currency'] ?? 'USD',
      bankProduct: json['bankProduct'],
      annualRate: json['annualRate'] != null ? double.tryParse(json['annualRate'].toString()) : null,
      termMonths: json['termMonths'] != null ? int.tryParse(json['termMonths'].toString()) : null,
      startDate: json['startDate'] != null ? DateTime.tryParse(json['startDate']) : null,
    );
  }
}
