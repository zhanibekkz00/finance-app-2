import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/debt_provider.dart';
import '../../models/debt_model.dart';
import '../../utils/debt_utils.dart';
import '../../widgets/glass_container.dart';
import 'package:finance_app/l10n/generated/app_localizations.dart';
import '../../utils/kaspi_calculator.dart';
import 'package:intl/intl.dart';
class DebtsScreen extends ConsumerWidget {
  const DebtsScreen({super.key});

  void _showPayModal(BuildContext context, WidgetRef ref, DebtModel debt) {
    final ctrl = TextEditingController();
    final l10n = AppLocalizations.of(context)!;
    final formattedRemaining = DebtUtils.formatAmount(debt.remainingAmount, debt.currency);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subTextColor = isDark ? Colors.white.withOpacity(0.7) : Colors.black.withOpacity(0.65);
    final dialogBg = isDark ? const Color(0xFF1E1E2C) : Colors.white;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: dialogBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.confirm, style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${l10n.amount} (${l10n.amountDetails(formattedRemaining)})',
              style: TextStyle(color: subTextColor),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              style: TextStyle(color: textColor),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: '0.00',
                hintStyle: TextStyle(color: isDark ? Colors.white.withOpacity(0.3) : Colors.black.withOpacity(0.35)),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: isDark ? Colors.white38 : Colors.black26),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blueAccent),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel, style: const TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              final val = double.tryParse(ctrl.text);
              if (val != null && val > 0 && val <= debt.remainingAmount) {
                Navigator.pop(ctx);
                await ref.read(debtProvider.notifier).payDebt(debt.id, val);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.invalidPaymentAmount)),
                );
              }
            },
            child: Text(l10n.confirm, style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showKaspiCalculatorModal(BuildContext context, DebtModel debt) {
    if (debt.annualRate == null || debt.termMonths == null || debt.startDate == null) return;
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subTextColor = isDark ? Colors.white.withOpacity(0.7) : Colors.black.withOpacity(0.65);
    final dialogBg = isDark ? const Color(0xFF1E1E2C) : Colors.white;

    final now = DateTime.now();
    int monthsPassed = (now.year - debt.startDate!.year) * 12 + now.month - debt.startDate!.month;
    if (monthsPassed < 0) monthsPassed = 0;

    final savings = KaspiCalculator.calculateEarlyRepaymentSavings(
        debt.totalAmount, debt.annualRate!, debt.termMonths!, monthsPassed);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: dialogBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.kaspiCalculator, style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.earlyRepaymentSavings,
              style: TextStyle(color: subTextColor),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.greenAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.greenAccent.withOpacity(0.5)),
              ),
              child: Center(
                child: Text(
                  DebtUtils.formatAmount(savings, debt.currency),
                  style: const TextStyle(
                    color: Colors.greenAccent,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.earlyRepaymentNote,
              style: TextStyle(color: isDark ? Colors.white38 : Colors.black45, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.close, style: TextStyle(color: textColor)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(debtProvider);
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subTextColor = isDark ? Colors.white.withOpacity(0.7) : Colors.black.withOpacity(0.65);
    final hintColor = isDark ? Colors.white.withOpacity(0.4) : Colors.black.withOpacity(0.4);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(l10n.debts, style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: state.isLoading && state.debts.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : state.debts.isEmpty
              ? Center(
                  child: Text(
                    l10n.noDebts,
                    style: TextStyle(color: subTextColor, fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 88),
                  itemCount: state.debts.length,
                  itemBuilder: (context, index) {
                    final d = state.debts[index];
                    final progress = 1 - (d.remainingAmount / d.totalAmount);
                    final formattedRemaining = DebtUtils.formatAmount(d.remainingAmount, d.currency);
                    final formattedTotal = DebtUtils.formatAmount(d.totalAmount, d.currency);
                    final title = DebtUtils.getDebtTitle(l10n, d.creditorName, d.type);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: GlassContainer(
                        borderRadius: 20,
                        padding: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    DebtUtils.getDebtIcon(d.creditorName, d.type, size: 20),
                                    const SizedBox(width: 12),
                                    Text(
                                      title,
                                      style: TextStyle(
                                        color: textColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: subTextColor),
                                  onPressed: () {
                                    ref.read(debtProvider.notifier).deleteDebt(d.id);
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: progress.clamp(0.0, 1.0),
                                minHeight: 6,
                                backgroundColor: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
                                valueColor: const AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${l10n.remaining}: $formattedRemaining',
                                  style: TextStyle(color: subTextColor, fontSize: 14),
                                ),
                                Text(
                                  '${l10n.total}: $formattedTotal',
                                  style: TextStyle(color: hintColor, fontSize: 14),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            
                            // Kaspi specific section
                            if (d.bankProduct != null) ...[
                              Container(
                                padding: const EdgeInsets.all(12),
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: Colors.redAccent.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.info_outline, color: Colors.redAccent, size: 16),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            d.bankProduct == 'kaspi_installment' 
                                              ? l10n.kaspiInstallmentInfo(d.termMonths.toString())
                                              : l10n.kaspiCreditInfo(d.annualRate.toString(), d.termMonths.toString()),
                                            style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 12),
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (d.annualRate != null && d.termMonths != null && d.annualRate! > 0) ...[
                                      const SizedBox(height: 8),
                                      InkWell(
                                        onTap: () => _showKaspiCalculatorModal(context, d),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.calculate, color: Colors.greenAccent, size: 16),
                                            const SizedBox(width: 8),
                                            Text(
                                              l10n.earlyRepayment,
                                              style: const TextStyle(color: Colors.greenAccent, fontSize: 12, decoration: TextDecoration.underline),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],

                            if (d.remainingAmount > 0)
                              Align(
                                alignment: Alignment.centerRight,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blueAccent,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () => _showPayModal(context, ref, d),
                                  child: Text(l10n.makePayment),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'debts_fab',
        onPressed: () => Navigator.pushNamed(context, '/add_debt'),
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
