import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/transaction_provider.dart';
import '../../models/transaction_model.dart';
import '../../models/category_model.dart';
import 'package:uuid/uuid.dart';
import '../../providers/category_provider.dart';
import 'package:finance_app/l10n/generated/app_localizations.dart';
import '../widgets/category_quick_selector.dart';
import 'package:flutter/services.dart';
import '../../providers/budget_provider.dart';
import '../../utils/debt_utils.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/gemini_service.dart';
import '../../providers/settings_provider.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  TransactionType _type = TransactionType.expense;
  bool _isRecurring = false;
  RecurrenceInterval _recurrenceInterval = RecurrenceInterval.monthly;
  int _reminderDaysBefore = 1;
  String? _selectedCategoryId;
  String _selectedCurrency = 'KZT';

  final _currencies = ['USD', 'EUR', 'RUB', 'KZT'];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final categories = ref.watch(categoryProvider);
    final selectedCategory = _selectedCategoryId == null
        ? null
        : categories.where((c) => c.id == _selectedCategoryId).firstOrNull;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.addTransaction),
        actions: [
          IconButton(
            icon: const Icon(Icons.document_scanner),
            onPressed: _scanReceipt,
            tooltip: 'Сканировать чек / выписку',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: RadioListTile<TransactionType>(
                    title: Text(l10n.expense),
                    value: TransactionType.expense,
                    groupValue: _type,
                    onChanged: (v) => setState(() => _type = v!),
                  ),
                ),
                Expanded(
                  child: RadioListTile<TransactionType>(
                    title: Text(l10n.income),
                    value: TransactionType.income,
                    groupValue: _type,
                    onChanged: (v) => setState(() => _type = v!),
                  ),
                ),
              ],
            ),

            // Currency Dropdown
            DropdownButtonFormField<String>(
              value: _selectedCurrency,
              decoration: const InputDecoration(
                  labelText:
                      'Валюта'),
              items: _currencies
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedCurrency = v!),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: _amountCtrl,
              decoration: InputDecoration(labelText: l10n.amount),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (v) => setState(() {}),
            ),
            
            if (_type == TransactionType.expense && _selectedCategoryId != null)
              Builder(
                builder: (context) {
                  final budget = ref.read(budgetProvider.notifier).getBudgetForCategory(_selectedCategoryId!);
                  if (budget != null) {
                    final currentAmount = double.tryParse(_amountCtrl.text) ?? 0.0;
                    final remaining = budget.amount - budget.spentAmount;
                    final isExceeded = currentAmount > remaining;
                    
                    if (isExceeded && currentAmount > 0) {
                      HapticFeedback.lightImpact();
                    }
                    
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                      child: Text(
                        isExceeded 
                          ? l10n.exceedsBudgetBy(DebtUtils.formatAmount(currentAmount - remaining, _selectedCurrency))
                          : l10n.remainingBudget(DebtUtils.formatAmount(remaining, _selectedCurrency)),
                        style: TextStyle(
                          color: isExceeded ? Colors.redAccent : Colors.white70,
                          fontWeight: isExceeded ? FontWeight.bold : FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }
              ),

            const SizedBox(height: 16),

            // Category Selector (Replacing Dropdown with Modal for better reliability)
            const SizedBox(height: 16),
            ListTile(
              title: Text(l10n.category),
              subtitle: Text(
                _selectedCategoryId == null
                    ? l10n.selectCategory
                    : categories
                            .where((c) => c.id == _selectedCategoryId)
                            .firstOrNull
                            ?.getLocalizedName(context) ??
                        l10n.selectCategory,
              ),
              leading: Container(
                width: 36,
                height: 36,
                padding: selectedCategory?.imageUrl != null ? EdgeInsets.zero : const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: selectedCategory == null
                      ? Colors.grey.withOpacity(0.2)
                      : (selectedCategory.imageUrl != null
                          ? null
                          : Color(selectedCategory.colorValue).withOpacity(0.2)),
                  shape: BoxShape.circle,
                  image: selectedCategory?.imageUrl != null
                      ? DecorationImage(
                          image: NetworkImage(selectedCategory!.imageUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: selectedCategory?.imageUrl != null
                    ? null
                    : Icon(
                        selectedCategory == null
                            ? Icons.category
                            : IconData(
                                selectedCategory.iconCode,
                                fontFamily: 'MaterialIcons',
                              ),
                        color: selectedCategory == null
                            ? Colors.grey
                            : Color(selectedCategory.colorValue),
                      ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.withOpacity(0.2)),
              ),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => CategoryQuickSelector(
                    currentCategoryId: _selectedCategoryId ?? '',
                    onCategorySelected: (id) {
                      setState(() => _selectedCategoryId = id);
                    },
                  ),
                );
              },
            ),

            const SizedBox(height: 10),

            TextField(
              controller: _noteCtrl,
              decoration: InputDecoration(labelText: l10n.note),
            ),
            const SizedBox(height: 10),
            SwitchListTile(
              title: Text(l10n.recurring),
              value: _isRecurring,
              onChanged: (v) => setState(() => _isRecurring = v),
            ),
            if (_isRecurring) ...[
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.billingCycle),
                  DropdownButton<RecurrenceInterval>(
                    value: _recurrenceInterval,
                    items: RecurrenceInterval.values
                        .where((e) => e != RecurrenceInterval.none)
                        .map((e) => DropdownMenuItem(
                              value: e,
                              child: Text(_formatInterval(e, l10n)),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _recurrenceInterval = v!),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.reminder),
                  DropdownButton<int>(
                    value: _reminderDaysBefore,
                    items: [
                      DropdownMenuItem(value: 0, child: Text(l10n.reminderToday)),
                      DropdownMenuItem(value: 1, child: Text(l10n.reminder1Day)),
                      DropdownMenuItem(value: 2, child: Text(l10n.reminder2Days)),
                      DropdownMenuItem(value: 3, child: Text(l10n.reminder3Days)),
                    ],
                    onChanged: (v) => setState(() => _reminderDaysBefore = v!),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_selectedCategoryId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Please select a category')));
                  return;
                }
                final tx = TransactionModel(
                  id: const Uuid().v4(),
                  type: _type,
                  amount: double.tryParse(_amountCtrl.text) ?? 0,
                  categoryId: _selectedCategoryId!,
                  date: DateTime.now(),
                  note: _noteCtrl.text,
                  isRecurring: _isRecurring,
                  recurrenceInterval: _isRecurring
                      ? _recurrenceInterval
                      : RecurrenceInterval.none,
                  currency: _selectedCurrency,
                  reminderDaysBefore: _isRecurring ? _reminderDaysBefore : 0,
                );

                ref.read(transactionProvider.notifier).add(tx);
                Navigator.pop(context);
              },
              child: Text(l10n.save),
            )
          ],
        ),
      ),
    );
  }

  String _formatInterval(RecurrenceInterval interval, AppLocalizations l10n) {
    switch (interval) {
      case RecurrenceInterval.daily:
        return l10n.daily;
      case RecurrenceInterval.weekly:
        return l10n.weekly;
      case RecurrenceInterval.monthly:
      default:
        return l10n.monthly;
    }
  }

  Future<void> _scanReceipt() async {
    final apiKey = ref.read(settingsProvider).geminiApiKey;
    if (apiKey.isEmpty) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('API Key'),
          content: const Text('Для сканирования чеков введите Gemini API Key в настройках.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Понятно'),
            ),
          ],
        ),
      );
      return;
    }

    final picker = ImagePicker();
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Источник изображения'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Камера'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Галерея (Скриншот)'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    final image = await picker.pickImage(source: source);
    if (image == null) return;

    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Expanded(child: Text('Нейросеть анализирует изображение...')),
            ],
          ),
        ),
      );
    }

    try {
      final geminiService = GeminiService();
      final result = await geminiService.analyzeReceipt(image, apiKey);

      if (context.mounted) {
        Navigator.pop(context); // close loading dialog
      }

      if (result != null) {
        setState(() {
          _amountCtrl.text = result.amount.toString();
          if (result.title.isNotEmpty) {
            _noteCtrl.text = result.title;
          }
          if (result.type == 'income') {
            _type = TransactionType.income;
          } else {
            _type = TransactionType.expense;
          }
        });
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Данные успешно распознаны!')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка распознавания. Попробуйте еще раз.')),
        );
      }
    }
  }
}
