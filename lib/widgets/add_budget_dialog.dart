import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/budget_provider.dart';
import '../providers/category_provider.dart';
import '../models/category_model.dart';
import 'package:finance_app/l10n/generated/app_localizations.dart';
import '../providers/settings_provider.dart';
import '../utils/debt_utils.dart';

class AddBudgetDialog extends ConsumerStatefulWidget {
  final String? categoryId;
  final double? initialAmount;

  const AddBudgetDialog({super.key, this.categoryId, this.initialAmount});

  @override
  ConsumerState<AddBudgetDialog> createState() => _AddBudgetDialogState();
}

class _AddBudgetDialogState extends ConsumerState<AddBudgetDialog> {
  final _amountCtrl = TextEditingController();
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.categoryId;
    if (widget.initialAmount != null) {
      _amountCtrl.text = widget.initialAmount.toString();
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (_selectedCategoryId == null || _amountCtrl.text.isEmpty) return;
    final amount = double.tryParse(_amountCtrl.text);
    if (amount == null || amount <= 0) return;

    ref.read(budgetProvider.notifier).upsertBudget(_selectedCategoryId!, amount);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.budgetSaved)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final categories = ref.watch(categoryProvider);
    final currencyCode = ref.watch(settingsProvider).currencyCode;
    final currencySymbol = DebtUtils.getCurrencySymbol(currencyCode);
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final bgColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark ? Colors.white.withOpacity(0.2) : Colors.black12;
    final labelColor = isDark ? Colors.grey : Colors.black54;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.addBudget,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            value: _selectedCategoryId,
            decoration: InputDecoration(
              labelText: l10n.category,
              labelStyle: TextStyle(color: labelColor),
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: borderColor)),
              focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
            ),
            dropdownColor: bgColor,
            style: TextStyle(color: textColor),
            items: categories.map((CategoryModel cat) {
              return DropdownMenuItem<String>(
                value: cat.id,
                child: Row(
                  children: [
                    cat.imageUrl != null
                        ? Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: NetworkImage(cat.imageUrl!),
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                        : Icon(
                            IconData(cat.iconCode, fontFamily: 'MaterialIcons'),
                            color: Color(cat.colorValue),
                          ),
                    const SizedBox(width: 12),
                    Text(cat.getLocalizedName(context)),
                  ],
                ),
              );
            }).toList(),
            onChanged: (val) {
              setState(() {
                _selectedCategoryId = val;
              });
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _amountCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: TextStyle(color: textColor),
            decoration: InputDecoration(
              labelText: l10n.monthlyLimit,
              labelStyle: TextStyle(color: labelColor),
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: borderColor)),
              focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
              prefixIcon: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  currencySymbol,
                  style: TextStyle(color: labelColor, fontSize: 18),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: const Color(0xFF6366F1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _save,
            child: Text(l10n.save, style: const TextStyle(fontSize: 16, color: Colors.white)),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
