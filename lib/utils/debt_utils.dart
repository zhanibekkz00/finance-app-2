import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';
import 'package:finance_app/l10n/generated/app_localizations.dart';
import '../services/currency_service.dart';

class DebtUtils {
  /// Converts an amount from one currency to another using live exchange rates.
  /// Uses CurrencyService which fetches rates from open.er-api.com (cached 24h).
  static double convertCurrency(double amount, String fromCurrency, String toCurrency) {
    return CurrencyService.convertSync(amount, fromCurrency, toCurrency);
  }

  /// Get appropriate symbol for each currency.
  static String getCurrencySymbol(String currency) {
    switch (currency.toUpperCase()) {
      case 'KZT':
        return '₸';
      case 'RUB':
        return '₽';
      case 'EUR':
        return '€';
      case 'USD':
      default:
        return '\$';
    }
  }

  /// Format amount with thousands separator.
  static String formatAmount(double amount, String currency) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    String formatted = formatter.format(amount);
    if (formatted.endsWith('.00')) {
      formatted = formatted.substring(0, formatted.length - 3);
    }
    formatted = formatted.replaceAll(',', ' ').replaceAll('.', ',');
    return '$formatted ${getCurrencySymbol(currency)}';
  }

  /// Check if the creditor is Kaspi.
  static bool isKaspi(String name) {
    return name.toLowerCase().contains('kaspi');
  }

  /// Generates the best visual avatar/icon for a debt provider or lender.
  static Widget getDebtIcon(String name, String type, {double size = 24}) {
    final cleanName = name.trim();
    if (isKaspi(cleanName)) {
      return Container(
        width: size * 1.6,
        height: size * 1.6,
        decoration: const BoxDecoration(
          color: Color(0xFFF14635), // Kaspi Red
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          'K',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: size * 0.9,
            fontFamily: 'Montserrat',
          ),
        ),
      );
    }

    // Check if it's a private individual
    final isPrivate = type == 'Частный долг' || type.toLowerCase().contains('private') || type.toLowerCase().contains('частн');
    if (isPrivate) {
      if (cleanName.isNotEmpty && cleanName != 'Неизвестно') {
        final firstLetter = cleanName[0].toUpperCase();
        return CircleAvatar(
          radius: size * 0.8,
          backgroundColor: Colors.blueAccent.withOpacity(0.2),
          child: Text(
            firstLetter,
            style: TextStyle(
              color: Colors.blueAccent,
              fontWeight: FontWeight.bold,
              fontSize: size * 0.8,
            ),
          ),
        );
      }
      return CircleAvatar(
        radius: size * 0.8,
        backgroundColor: Colors.grey.withOpacity(0.2),
        child: Icon(Icons.person, size: size, color: Colors.grey),
      );
    }

    // Default bank/credit icon
    return CircleAvatar(
      radius: size * 0.8,
      backgroundColor: Colors.amber.withOpacity(0.2),
      child: Icon(Icons.account_balance, size: size, color: Colors.amber),
    );
  }

  /// Exposes standard naming logic for banks vs private individuals.
  static String getDebtTitle(AppLocalizations l10n, String name, String type) {
    final cleanName = name.trim().isEmpty || name == 'Неизвестно' ? l10n.unknown : name.trim();
    if (cleanName == l10n.unknown) {
      return l10n.unknown;
    }

    final isPrivate = type == 'Частный долг' || type.toLowerCase().contains('private') || type.toLowerCase().contains('частн');
    if (isPrivate) {
      return l10n.debtTo(cleanName);
    } else {
      return l10n.creditFrom(cleanName);
    }
  }

  /// Parses transaction note to find out if it's a debt transaction, returning details if so.
  static DebtTxInfo? parseDebtTransaction(AppLocalizations l10n, TransactionModel tx) {
    final note = tx.note;
    if (note.startsWith('Долг / кредит от:')) {
      // Format: "Долг / кредит от: [Creditor] ([Type])"
      // Let's parse
      try {
        final fromIndex = note.indexOf('от:') + 3;
        final typeIndex = note.lastIndexOf('(');
        if (typeIndex > fromIndex) {
          final creditor = note.substring(fromIndex, typeIndex).trim();
          final type = note.substring(typeIndex + 1, note.length - 1).trim();
          return DebtTxInfo(
            creditorName: creditor,
            type: type,
            isPayment: false,
            title: getDebtTitle(l10n, creditor, type),
            subtitle: l10n.gettingLoan,
          );
        }
      } catch (_) {}
    } else if (note.startsWith('Погашение долга:')) {
      // Format: "Погашение долга: [Creditor]"
      try {
        final fromIndex = note.indexOf(':') + 1;
        final creditor = note.substring(fromIndex).trim();
        return DebtTxInfo(
          creditorName: creditor,
          type: 'Кредит', // fallback
          isPayment: true,
          title: getDebtTitle(l10n, creditor, 'Кредит'),
          subtitle: l10n.paymentOfDebt,
        );
      } catch (_) {}
    }
    return null;
  }
}

class DebtTxInfo {
  final String creditorName;
  final String type;
  final bool isPayment;
  final String title;
  final String subtitle;

  DebtTxInfo({
    required this.creditorName,
    required this.type,
    required this.isPayment,
    required this.title,
    required this.subtitle,
  });
}
