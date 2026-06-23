import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/savings_goal_model.dart';
import '../providers/savings_goal_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/glass_container.dart';
import 'package:intl/intl.dart';
import 'package:finance_app/l10n/generated/app_localizations.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class SavingsGoalsScreen extends ConsumerWidget {
  const SavingsGoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(savingsGoalProvider);
    final currencyCode = ref.watch(settingsProvider).currencyCode;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final bgGradient = isDark
        ? const LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : const LinearGradient(
            colors: [Color(0xFFEEF2F6), Color(0xFFE2E8F0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          l10n.savingsGoals,
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: bgGradient,
        ),
        child: SafeArea(
          child: state.isLoading && state.goals.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : state.goals.isEmpty
                  ? _buildEmptyState(context, l10n, isDark)
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.goals.length,
                      itemBuilder: (context, index) {
                        final goal = state.goals[index];
                        return _buildGoalCard(context, ref, goal, currencyCode, l10n, isDark);
                      },
                    ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'savings_goals_fab',
        onPressed: () => _showAddEditGoalDialog(context, ref, null),
        backgroundColor: const Color(0xFF6366F1),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n, bool isDark) {
    final subTextColor = isDark ? Colors.white.withOpacity(0.5) : Colors.black.withOpacity(0.45);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.savings_outlined,
            size: 80,
            color: isDark ? Colors.white30 : Colors.black26,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noGoalsYet,
            style: TextStyle(color: subTextColor, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard(
    BuildContext context,
    WidgetRef ref,
    SavingsGoalModel goal,
    String defaultCurrency,
    AppLocalizations l10n,
    bool isDark,
  ) {
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subTextColor = isDark ? Colors.white.withOpacity(0.55) : Colors.black.withOpacity(0.5);

    final currencySymbol = goal.currency == 'KZT'
        ? '₸'
        : goal.currency == 'USD'
            ? '\$'
            : goal.currency == 'EUR'
                ? '€'
                : goal.currency == 'RUB'
                    ? '₽'
                    : goal.currency;

    final color = goal.colorValue != null
        ? Color(goal.colorValue!)
        : const Color(0xFF6366F1);

    final formatter = NumberFormat.currency(symbol: currencySymbol, decimalDigits: 0);
    final targetStr = formatter.format(goal.targetAmount);
    final currentStr = formatter.format(goal.currentAmount);

    final isCompleted = goal.isCompleted;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassContainer(
        borderRadius: 24.0,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: color.withOpacity(0.3), width: 1.5),
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.12),
                color.withOpacity(0.03),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            goal.name,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (goal.targetDate != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              '${l10n.targetDate}: ${DateFormat('dd.MM.yyyy').format(goal.targetDate!)}',
                              style: TextStyle(
                                color: subTextColor,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.more_vert, color: textColor.withOpacity(0.7)),
                      onPressed: () => _showGoalMenu(context, ref, goal, l10n),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.currentAmount,
                          style: TextStyle(
                            color: subTextColor,
                            fontSize: 11,
                          ),
                        ),
                        Text(
                          currentStr,
                          style: TextStyle(
                            color: color,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          l10n.targetAmount,
                          style: TextStyle(
                            color: subTextColor,
                            fontSize: 11,
                          ),
                        ),
                        Text(
                          targetStr,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Stack(
                  children: [
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      height: 8,
                      width: MediaQuery.of(context).size.width * 0.75 * goal.progress,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [color, color.withOpacity(0.5)],
                        ),
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.4),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${(goal.progress * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        color: color,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isCompleted)
                      Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.greenAccent[400], size: 16),
                          const SizedBox(width: 4),
                          Text(
                            l10n.goalCompleted,
                            style: TextStyle(
                              color: Colors.greenAccent[400],
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                    else
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: color,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          backgroundColor: color.withOpacity(0.1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.add_circle_outline, size: 16),
                        label: Text(l10n.addMoney, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        onPressed: () => _showAddMoneyDialog(context, ref, goal, l10n),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showGoalMenu(
    BuildContext context,
    WidgetRef ref,
    SavingsGoalModel goal,
    AppLocalizations l10n,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.white70),
              title: Text(l10n.editGoal, style: const TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(ctx);
                _showAddEditGoalDialog(context, ref, goal);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.redAccent),
              title: Text(l10n.deleteGoal, style: const TextStyle(color: Colors.redAccent)),
              onTap: () {
                Navigator.pop(ctx);
                _confirmDelete(context, ref, goal, l10n);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    SavingsGoalModel goal,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: Text(l10n.deleteGoal, style: const TextStyle(color: Colors.white)),
        content: Text('${l10n.delete} "${goal.name}"?', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            child: Text(l10n.cancel, style: TextStyle(color: Colors.white.withOpacity(0.5))),
            onPressed: () => Navigator.pop(ctx),
          ),
          TextButton(
            child: Text(l10n.delete, style: const TextStyle(color: Colors.redAccent)),
            onPressed: () {
              ref.read(savingsGoalProvider.notifier).deleteGoal(goal.id);
              Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }

  void _showAddMoneyDialog(
    BuildContext context,
    WidgetRef ref,
    SavingsGoalModel goal,
    AppLocalizations l10n,
  ) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('${l10n.addMoney}: ${goal.name}', style: const TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: l10n.amountToAdd,
            labelStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
            prefixText: '${goal.currency} ',
            prefixStyle: const TextStyle(color: Colors.white),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white30),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF6366F1)),
            ),
          ),
        ),
        actions: [
          TextButton(
            child: Text(l10n.cancel, style: TextStyle(color: Colors.white.withOpacity(0.5))),
            onPressed: () => Navigator.pop(ctx),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.send),
            onPressed: () {
              final amount = double.tryParse(controller.text);
              if (amount != null && amount > 0) {
                ref.read(savingsGoalProvider.notifier).addMoney(goal.id, amount);
                Navigator.pop(ctx);
              }
            },
          ),
        ],
      ),
    );
  }

  void _showAddEditGoalDialog(
    BuildContext context,
    WidgetRef ref,
    SavingsGoalModel? goal,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final nameCtrl = TextEditingController(text: goal?.name ?? '');
    final targetCtrl = TextEditingController(text: goal?.targetAmount.toString() ?? '');
    final currentCtrl = TextEditingController(text: goal?.currentAmount.toString() ?? '');
    String selectedCurrency = goal?.currency ?? ref.read(settingsProvider).currencyCode;
    DateTime? selectedDate = goal?.targetDate;
    
    int? selectedColorValue = goal?.colorValue;

    final colorOptions = [
      0xFF6366F1, // Indigo
      0xFFEC4899, // Pink
      0xFF10B981, // Emerald/Green
      0xFFF59E0B, // Amber/Orange
      0xFF3B82F6, // Blue
      0xFF8B5CF6, // Purple
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            goal == null ? l10n.addSavingsGoal : l10n.editGoal,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: l10n.savingsGoalName,
                    labelStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                    enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
                    focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF6366F1))),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: targetCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: l10n.targetAmount,
                    labelStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                    enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
                    focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF6366F1))),
                  ),
                ),
                if (goal == null) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: currentCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: l10n.currentAmount,
                      labelStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                      enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
                      focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF6366F1))),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Валюта:', style: TextStyle(color: Colors.white70)),
                    DropdownButton<String>(
                      value: selectedCurrency,
                      dropdownColor: const Color(0xFF1E293B),
                      underline: const SizedBox(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      items: const [
                        DropdownMenuItem(value: 'KZT', child: Text('₸ KZT')),
                        DropdownMenuItem(value: 'USD', child: Text('\$ USD')),
                        DropdownMenuItem(value: 'EUR', child: Text('€ EUR')),
                        DropdownMenuItem(value: 'RUB', child: Text('₽ RUB')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            selectedCurrency = val;
                          });
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Срок:', style: TextStyle(color: Colors.white70)),
                    TextButton(
                      child: Text(
                        selectedDate == null
                            ? 'Выбрать дату'
                            : DateFormat('dd.MM.yyyy').format(selectedDate!),
                        style: const TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.bold),
                      ),
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedDate ?? DateTime.now().add(const Duration(days: 30)),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 3650)),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.dark(
                                  primary: Color(0xFF6366F1),
                                  onPrimary: Colors.white,
                                  surface: Color(0xFF1E293B),
                                  onSurface: Colors.white,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (date != null) {
                          setState(() {
                            selectedDate = date;
                          });
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Цвет цели:', style: TextStyle(color: Colors.white70)),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ...colorOptions.map((cValue) {
                      final isSelected = selectedColorValue == cValue ||
                          (selectedColorValue == null && cValue == colorOptions[0]);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedColorValue = cValue;
                          });
                        },
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Color(cValue),
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(color: Colors.white, width: 2.5)
                                : null,
                          ),
                        ),
                      );
                    }).toList(),
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext ctx2) {
                            Color tempColor = Color(selectedColorValue ?? colorOptions[0]);
                            return AlertDialog(
                              backgroundColor: const Color(0xFF1E293B),
                              title: const Text('Выберите цвет', style: TextStyle(color: Colors.white)),
                              content: SingleChildScrollView(
                                child: ColorPicker(
                                  pickerColor: tempColor,
                                  onColorChanged: (Color color) {
                                    tempColor = color;
                                  },
                                  pickerAreaHeightPercent: 0.8,
                                  enableAlpha: false,
                                  labelTypes: const [],
                                ),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  child: Text('Готово', style: TextStyle(color: const Color(0xFF6366F1).withOpacity(0.8))),
                                  onPressed: () {
                                    setState(() {
                                      selectedColorValue = tempColor.value;
                                      if (!colorOptions.contains(selectedColorValue!)) {
                                        colorOptions.add(selectedColorValue!);
                                      }
                                    });
                                    Navigator.of(ctx2).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white54, width: 1),
                        ),
                        child: const Icon(Icons.palette, color: Colors.white70, size: 18),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text(l10n.cancel, style: TextStyle(color: Colors.white.withOpacity(0.5))),
              onPressed: () => Navigator.pop(ctx),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
              ),
              child: Text(l10n.save),
              onPressed: () async {
                final name = nameCtrl.text.trim();
                final target = double.tryParse(targetCtrl.text) ?? 0.0;
                final current = double.tryParse(currentCtrl.text) ?? 0.0;

                if (name.isNotEmpty && target > 0) {
                  if (goal == null) {
                    await ref.read(savingsGoalProvider.notifier).createGoal(
                          name: name,
                          targetAmount: target,
                          currency: selectedCurrency,
                          targetDate: selectedDate,
                          colorValue: selectedColorValue ?? colorOptions[0],
                        );
                    if (current > 0) {
                      // If user specified initial savings, deposit it
                      final state = ref.read(savingsGoalProvider);
                      if (state.goals.isNotEmpty) {
                        final createdGoal = state.goals.first;
                        await ref.read(savingsGoalProvider.notifier).addMoney(createdGoal.id, current);
                      }
                    }
                  } else {
                    await ref.read(savingsGoalProvider.notifier).updateGoal(
                      goal.id,
                      {
                        'name': name,
                        'targetAmount': target,
                        'currency': selectedCurrency,
                        'targetDate': selectedDate?.toIso8601String(),
                        'colorValue': selectedColorValue ?? colorOptions[0],
                      },
                    );
                  }
                  if (context.mounted) {
                    Navigator.pop(ctx);
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
