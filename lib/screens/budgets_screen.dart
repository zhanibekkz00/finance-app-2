import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/budget_provider.dart';
import '../providers/category_provider.dart';
import '../models/category_model.dart';
import '../providers/settings_provider.dart';
import '../widgets/glass_container.dart';
import '../widgets/add_budget_dialog.dart';
import '../utils/debt_utils.dart';
import 'package:finance_app/l10n/generated/app_localizations.dart';

class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final budgetState = ref.watch(budgetProvider);
    final currencyCode = ref.watch(settingsProvider).currencyCode;
    final categories = ref.watch(categoryProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subTextColor = isDark ? Colors.white.withOpacity(0.7) : Colors.black.withOpacity(0.6);
    final cardBgColor = isDark ? Colors.white.withOpacity(0.03) : Colors.white.withOpacity(0.85);
    final cardBorderColor = isDark ? Colors.white.withOpacity(0.15) : Colors.black.withOpacity(0.08);
    final iconColor = isDark ? Colors.white : const Color(0xFF0F172A);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(l10n.budgets, style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: iconColor),
        actions: [
          DropdownButton<String>(
            value: currencyCode,
            dropdownColor: isDark ? const Color(0xFF1E1E2C) : Colors.white,
            icon: Icon(Icons.keyboard_arrow_down, color: subTextColor, size: 16),
            underline: const SizedBox(),
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            items: const [
              DropdownMenuItem(value: 'KZT', child: Text('₸ KZT')),
              DropdownMenuItem(value: 'USD', child: Text('\$ USD')),
              DropdownMenuItem(value: 'EUR', child: Text('€ EUR')),
              DropdownMenuItem(value: 'RUB', child: Text('₽ RUB')),
            ],
            onChanged: (newCurrency) {
              if (newCurrency != null) {
                ref.read(settingsProvider.notifier).setCurrency(newCurrency);
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: budgetState.isLoading && budgetState.budgets.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: budgetState.budgets.length,
                itemBuilder: (context, index) {
                  final budget = budgetState.budgets[index];
                  final category = ref.read(categoryProvider.notifier).getCategoryById(budget.categoryId);
                  if (category == null) return const SizedBox.shrink();

                  final double progress = budget.amount > 0 ? (budget.spentAmount / budget.amount) : 0;
                  final bool isExceeded = progress >= 1.0;
                  final bool isWarning = progress >= 0.75 && !isExceeded;

                  Color progressColor;
                  if (isExceeded) {
                    progressColor = Colors.redAccent;
                  } else if (isWarning) {
                    progressColor = Colors.orangeAccent;
                  } else {
                    progressColor = Colors.greenAccent;
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: GestureDetector(
                      onLongPress: () {
                        // Show menu to edit or delete
                        showModalBottomSheet(
                          context: context,
                          builder: (ctx) => Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: const Icon(Icons.edit),
                                title: Text(l10n.editBudget),
                                onTap: () {
                                  Navigator.pop(ctx);
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                                    builder: (_) => AddBudgetDialog(categoryId: budget.categoryId, initialAmount: budget.amount),
                                  );
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.delete, color: Colors.red),
                                title: Text(l10n.deleteBudget, style: const TextStyle(color: Colors.red)),
                                onTap: () {
                                  Navigator.pop(ctx);
                                  ref.read(budgetProvider.notifier).deleteBudget(budget.id);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                      child: GlassContainer(
                        borderRadius: 20,
                        padding: 16,
                        backgroundColor: cardBgColor,
                        borderGradient: LinearGradient(colors: [cardBorderColor, cardBorderColor]),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                category.imageUrl != null
                                    ? Container(
                                        width: 28,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                            image: NetworkImage(category.imageUrl!),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      )
                                    : Icon(
                                        IconData(category.iconCode, fontFamily: 'MaterialIcons'),
                                        color: Color(category.colorValue),
                                        size: 28,
                                      ),
                                const SizedBox(width: 12),
                                Text(
                                  category.getLocalizedName(context),
                                  style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                const Spacer(),
                                Text(
                                  DebtUtils.formatAmount(budget.amount, currencyCode),
                                  style: TextStyle(color: subTextColor),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${l10n.spent}: ${DebtUtils.formatAmount(budget.spentAmount, currencyCode)}', style: TextStyle(color: isExceeded ? Colors.redAccent : subTextColor)),
                                Text('${l10n.remaining}: ${DebtUtils.formatAmount((budget.amount - budget.spentAmount).clamp(0.0, double.infinity), currencyCode)}', style: TextStyle(color: subTextColor.withOpacity(0.7))),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: progress.clamp(0.0, 1.0),
                                backgroundColor: textColor.withOpacity(0.1),
                                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                                minHeight: 10,
                              ),
                            ),
                            if (isExceeded)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  l10n.exceedsBudgetBy(DebtUtils.formatAmount(budget.spentAmount - budget.amount, currencyCode)),
                                  style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'budgets_fab',
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
            builder: (_) => const AddBudgetDialog(),
          );
        },
        backgroundColor: const Color(0xFF6366F1),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
