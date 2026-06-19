import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/debt_provider.dart';
import '../../providers/settings_provider.dart';
import 'package:intl/intl.dart';
import 'package:finance_app/l10n/generated/app_localizations.dart';

class AddDebtScreen extends ConsumerStatefulWidget {
  const AddDebtScreen({super.key});

  @override
  ConsumerState<AddDebtScreen> createState() => _AddDebtScreenState();
}

class _AddDebtScreenState extends ConsumerState<AddDebtScreen> {
  final _amountCtrl = TextEditingController();
  final _creditorCtrl = TextEditingController();
  final _rateCtrl = TextEditingController();
  
  String _type = 'Кредит';
  final List<String> _types = ['Кредит', 'Ипотека', 'Рассрочка', 'Частный долг'];
  String _currency = 'USD';
  final List<String> _currencies = ['USD', 'KZT', 'RUB', 'EUR'];
  bool _isLoading = false;

  // Kaspi specific
  bool get _isKaspi => _creditorCtrl.text.toLowerCase().contains('kaspi') || 
                       _creditorCtrl.text.toLowerCase().contains('каспи');
  String _kaspiProduct = 'kaspi_credit'; // 'kaspi_credit' or 'kaspi_installment'
  int _termMonths = 12;
  final List<int> _termOptions = [3, 6, 12, 24, 36, 48, 60];
  DateTime _startDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _currency = ref.read(settingsProvider).currencyCode;
      });
    });
    
    _creditorCtrl.addListener(() {
      setState(() {}); // Rebuild to show/hide Kaspi fields
    });
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _creditorCtrl.dispose();
    _rateCtrl.dispose();
    super.dispose();
  }

  void _saveDebt() async {
    final l10n = AppLocalizations.of(context)!;
    final amount = double.tryParse(_amountCtrl.text);
    if (amount == null || amount <= 0 || _creditorCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.invalidInputData)),
      );
      return;
    }

    setState(() => _isLoading = true);

    String? bankProduct;
    double? annualRate;
    int? termMonths;
    String? startDateStr;

    if (_isKaspi) {
      bankProduct = _kaspiProduct;
      termMonths = _termMonths;
      startDateStr = _startDate.toIso8601String();
      if (_kaspiProduct == 'kaspi_installment') {
        annualRate = 0.0;
        termMonths = 12; // Fixed for Kaspi Friday
      } else {
        annualRate = double.tryParse(_rateCtrl.text) ?? 24.0;
      }
    }

    final success = await ref.read(debtProvider.notifier).addDebt(
      _type,
      _creditorCtrl.text.trim(),
      amount,
      _currency,
      bankProduct: bankProduct,
      annualRate: annualRate,
      termMonths: termMonths,
      startDate: startDateStr,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      Navigator.pop(context);
    } else {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.addDebtError)),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Widget _buildKaspiFields(AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.redAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.redAccent.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.kaspiProduct,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _kaspiProduct,
            items: [
              DropdownMenuItem(value: 'kaspi_credit', child: Text(l10n.kaspiCredit)),
              DropdownMenuItem(value: 'kaspi_installment', child: Text(l10n.kaspiInstallment)),
            ],
            onChanged: (val) => setState(() {
              _kaspiProduct = val!;
              if (_kaspiProduct == 'kaspi_installment') {
                _termMonths = 12;
              }
            }),
            decoration: const InputDecoration(
              isDense: true,
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          if (_kaspiProduct == 'kaspi_credit') ...[
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _rateCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: l10n.annualRateLabel,
                      hintText: l10n.rateHint,
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _termMonths,
                    items: _termOptions.map((e) => DropdownMenuItem(value: e, child: Text(l10n.monthsCount(e.toString())))).toList(),
                    onChanged: (val) => setState(() => _termMonths = val!),
                    decoration: InputDecoration(
                      labelText: l10n.termLabel,
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: TextField(
                    enabled: false,
                    decoration: InputDecoration(
                      labelText: l10n.annualRateLabel,
                      hintText: '0',
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    enabled: false,
                    decoration: InputDecoration(
                      labelText: l10n.termLabel,
                      hintText: l10n.monthsCount('12'),
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          InkWell(
            onTap: () => _selectDate(context),
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: l10n.dateOfIssue,
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(DateFormat('dd.MM.yyyy').format(_startDate)),
                  const Icon(Icons.calendar_today, size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getLocalizedType(AppLocalizations l10n, String type) {
    switch (type) {
      case 'Кредит':
        return l10n.debtBankLoan;
      case 'Ипотека':
        return l10n.debtMortgage;
      case 'Рассрочка':
        return l10n.debtInstallment;
      case 'Частный долг':
        return l10n.debtPrivate;
      default:
        return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.addDebt)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _type,
              items: _types.map((e) => DropdownMenuItem(value: e, child: Text(_getLocalizedType(l10n, e)))).toList(),
              onChanged: (val) => setState(() => _type = val!),
              decoration: InputDecoration(labelText: l10n.debtType),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _creditorCtrl,
              decoration: InputDecoration(labelText: l10n.creditor),
            ),
            if (_isKaspi) _buildKaspiFields(l10n),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _amountCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(labelText: l10n.amount),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    value: _currency,
                    items: _currencies.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (val) => setState(() => _currency = val!),
                    decoration: InputDecoration(labelText: l10n.currency),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveDebt,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : Text(l10n.save),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
