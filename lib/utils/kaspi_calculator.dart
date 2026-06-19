import 'dart:math';

class KaspiCalculator {
  /// Рассчитывает ежемесячный аннуитетный платеж.
  /// A = P * (r * (1 + r)^n) / ((1 + r)^n - 1)
  /// P - сумма кредита
  /// annualRate - годовая ставка в процентах (например, 24.0)
  /// termMonths - срок в месяцах
  static double calculateMonthlyPayment(
      double amount, double annualRate, int termMonths) {
    if (annualRate <= 0) return amount / termMonths;
    if (termMonths <= 0) return amount;

    double monthlyRate = (annualRate / 100) / 12;
    double mathPower = pow(1 + monthlyRate, termMonths).toDouble();
    return amount * (monthlyRate * mathPower) / (mathPower - 1);
  }

  /// Генерирует график платежей.
  static List<PaymentScheduleItem> generateSchedule(
      double amount, double annualRate, int termMonths) {
    List<PaymentScheduleItem> schedule = [];
    double remaining = amount;
    double monthlyRate = (annualRate / 100) / 12;
    double monthlyPayment =
        calculateMonthlyPayment(amount, annualRate, termMonths);

    for (int i = 1; i <= termMonths; i++) {
      double interestPayment = remaining * monthlyRate;
      double principalPayment = monthlyPayment - interestPayment;

      // Для последнего платежа корректируем возможные погрешности округления
      if (i == termMonths) {
        principalPayment = remaining;
        monthlyPayment = principalPayment + interestPayment;
      }

      remaining -= principalPayment;
      if (remaining < 0) remaining = 0;

      schedule.add(PaymentScheduleItem(
        month: i,
        paymentAmount: monthlyPayment,
        principalPayment: principalPayment,
        interestPayment: interestPayment,
        remainingDebt: remaining,
      ));
    }

    return schedule;
  }

  /// Рассчитывает экономию при досрочном погашении.
  /// amount - изначальная сумма кредита
  /// currentRemaining - текущий остаток по основному долгу
  /// totalPaidInterest - сколько уже уплачено процентов
  /// schedule - график платежей (если известен) или можно вычислить по параметрам
  static double calculateEarlyRepaymentSavings(
      double amount, double annualRate, int termMonths, int monthsPassed) {
    if (annualRate <= 0) return 0.0;

    List<PaymentScheduleItem> schedule =
        generateSchedule(amount, annualRate, termMonths);

    double totalPlannedInterest = 0;
    for (var item in schedule) {
      totalPlannedInterest += item.interestPayment;
    }

    double paidInterest = 0;
    for (int i = 0; i < monthsPassed && i < schedule.length; i++) {
      paidInterest += schedule[i].interestPayment;
    }

    return totalPlannedInterest - paidInterest;
  }
}

class PaymentScheduleItem {
  final int month;
  final double paymentAmount;
  final double principalPayment;
  final double interestPayment;
  final double remainingDebt;

  PaymentScheduleItem({
    required this.month,
    required this.paymentAmount,
    required this.principalPayment,
    required this.interestPayment,
    required this.remainingDebt,
  });
}
