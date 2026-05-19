import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/debt_provider.dart';
import '../../models/debt_model.dart';
import '../../utils/debt_utils.dart';
import '../../widgets/glass_container.dart';
import 'package:finance_app/l10n/generated/app_localizations.dart';

class DebtsScreen extends ConsumerWidget {
  const DebtsScreen({super.key});

  void _showPayModal(BuildContext context, WidgetRef ref, DebtModel debt) {
    final ctrl = TextEditingController();
    final l10n = AppLocalizations.of(context)!;
    final formattedRemaining = DebtUtils.formatAmount(debt.remainingAmount, debt.currency);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.confirm, style: const TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${l10n.amount} (${l10n.amountDetails(formattedRemaining)})',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              style: const TextStyle(color: Colors.white),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: '0.00',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white38),
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
                  const SnackBar(content: Text('Неверная сумма платежа')),
                );
              }
            },
            child: Text(l10n.confirm, style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(debtProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.sharedWallet, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: state.isLoading && state.debts.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : state.debts.isEmpty
              ? const Center(
                  child: Text(
                    'Нет активных долгов',
                    style: TextStyle(color: Colors.white60, fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
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
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.white60),
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
                                backgroundColor: Colors.white10,
                                valueColor: const AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Осталось: $formattedRemaining',
                                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                                ),
                                Text(
                                  'Всего: $formattedTotal',
                                  style: const TextStyle(color: Colors.white38, fontSize: 14),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
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
                                  child: const Text('Внести платеж'),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/add_debt'),
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
