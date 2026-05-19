import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app.dart';
import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';
import 'package:intl/intl.dart';
import 'package:finance_app/l10n/generated/app_localizations.dart';
import 'edit_transaction_screen.dart';
import 'category_stats_screen.dart';
import '../widgets/category_quick_selector.dart';
import '../widgets/transaction_share_helper.dart';
import '../widgets/glass_container.dart';
import '../providers/balance_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/debt_utils.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  bool _isBalanceVisible = true;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _showTransactionMenu(BuildContext context, TransactionModel tx) {
    final l10n = AppLocalizations.of(context)!;
    final category =
        ref.read(categoryProvider.notifier).getCategoryById(tx.categoryId);

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: Text(l10n.edit),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        EditTransactionScreen(transaction: tx),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: Text(l10n.delete),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(context, tx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: Text(l10n.share),
              onTap: () {
                Navigator.pop(context);
                TransactionShareHelper.shareTransaction(
                  context,
                  tx,
                  category?.getLocalizedName(context) ?? l10n.unknown,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.category),
              title: Text(l10n.changeCategory),
              onTap: () {
                Navigator.pop(context);
                _showCategorySelector(context, tx);
              },
            ),
            ListTile(
              leading:
                  Icon(tx.isPinned ? Icons.push_pin : Icons.push_pin_outlined),
              title: Text(tx.isPinned ? l10n.unpin : l10n.pin),
              onTap: () {
                Navigator.pop(context);
                ref.read(transactionProvider.notifier).togglePin(tx.id);
              },
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart),
              title: Text(l10n.viewCategoryStats),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        CategoryStatsScreen(categoryId: tx.categoryId),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, TransactionModel tx) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteConfirmTitle),
        content: Text(l10n.deleteConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              ref.read(transactionProvider.notifier).delete(tx.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.transactionDeleted)),
              );
            },
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  void _showCategorySelector(BuildContext context, TransactionModel tx) {
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => CategoryQuickSelector(
        currentCategoryId: tx.categoryId,
        onCategorySelected: (categoryId) {
          final updatedTx = tx.copyWith(categoryId: categoryId);
          ref.read(transactionProvider.notifier).update(updatedTx);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.categoryChanged)),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final txState = ref.watch(transactionProvider);
    ref.watch(categoryProvider); // Watch for category changes
    final totalBalance = ref.watch(balanceProvider);
    final currencyCode = ref.watch(settingsProvider).currencyCode;

    final l10n = AppLocalizations.of(context)!;

    // Filter logic
    final transactions = txState.transactions.where((tx) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      final category =
          ref.read(categoryProvider.notifier).getCategoryById(tx.categoryId);
      final catName = category?.getLocalizedName(context).toLowerCase() ?? '';

      return tx.note.toLowerCase().contains(q) ||
          tx.amount.toString().contains(q) ||
          tx.currency.toLowerCase().contains(q) ||
          catName.contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(l10n.dashboard, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
              icon: const Icon(Icons.account_balance_wallet, color: Colors.white),
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.debts)),
          IconButton(
              icon: const Icon(Icons.pie_chart_outline, color: Colors.white),
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.groupStats)),
          IconButton(
              icon: const Icon(Icons.person_outline, color: Colors.white),
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.profile)),
          IconButton(
              icon: const Icon(Icons.settings, color: Colors.white),
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.settings)),
        ],
      ),
      body: Column(
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOut,
            builder: (context, animValue, child) {
              return Opacity(
                opacity: animValue,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - animValue)),
                  child: child,
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
              child: GlassContainer(
                borderRadius: 24,
                padding: 16.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.totalBalance,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AnimatedSize(
                          duration: const Duration(milliseconds: 200),
                          child: Text(
                            _isBalanceVisible
                                ? NumberFormat.simpleCurrency(
                                        locale: Localizations.localeOf(context).toString(),
                                        name: currencyCode)
                                    .format(totalBalance)
                                : '••••••',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            _isBalanceVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.white.withOpacity(0.7),
                          ),
                          onPressed: () {
                            setState(() {
                              _isBalanceVisible = !_isBalanceVisible;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GlassContainer(
              borderRadius: 16,
              padding: 0,
              child: TextField(
                controller: _searchCtrl,
                decoration: InputDecoration(
                  labelText: l10n.search,
                  labelStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                  prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.4)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: (v) => setState(() => _searchQuery = v),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final tx = transactions[index];
                final category = ref
                    .read(categoryProvider.notifier)
                    .getCategoryById(tx.categoryId);
                final debtInfo = DebtUtils.parseDebtTransaction(l10n, tx);

                // Styling configuration
                final isDebt = debtInfo != null;
                final displayTitle = isDebt ? debtInfo.title : (category?.getLocalizedName(context) ?? l10n.unknown);
                final displaySubtitle = isDebt ? debtInfo.subtitle : tx.note;
                
                // Color formatting
                Color amountColor;
                if (isDebt) {
                  amountColor = Colors.amberAccent; // Amber/Gold for debt related transactions
                } else if (tx.type == TransactionType.income) {
                  amountColor = const Color(0xFF32D74B); // Mint
                } else {
                  amountColor = const Color(0xFFFF375F); // Pink
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GlassContainer(
                    padding: 8,
                    child: ListTile(
                      leading: Stack(
                        children: [
                          if (isDebt)
                            DebtUtils.getDebtIcon(debtInfo.creditorName, debtInfo.type, size: 22)
                          else
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: category != null
                                      ? [
                                          Color(category.colorValue).withOpacity(0.3),
                                          Color(category.colorValue).withOpacity(0.85),
                                        ]
                                      : [Colors.grey.withOpacity(0.3), Colors.grey.withOpacity(0.85)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: category != null
                                        ? Color(category.colorValue).withOpacity(0.15)
                                        : Colors.grey.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  )
                                ],
                              ),
                              child: Icon(
                                category != null
                                    ? IconData(category.iconCode, fontFamily: 'MaterialIcons')
                                    : Icons.help_outline,
                                color: Colors.white,
                              ),
                            ),
                          if (tx.isPinned)
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Colors.orange,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.push_pin,
                                  size: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                      title: Row(
                        children: [
                          Expanded(
                              child: Text(
                            displayTitle,
                            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                          )),
                          if (tx.isPinned)
                            const Icon(
                              Icons.push_pin,
                              size: 16,
                              color: Colors.orange,
                            ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (displaySubtitle.isNotEmpty)
                            Text(displaySubtitle,
                                style: TextStyle(
                                    fontSize: 12, color: Colors.white.withOpacity(0.65))),
                          Text(
                            DateFormat.yMMMd(Localizations.localeOf(context).toString())
                                .format(tx.date),
                            style: TextStyle(color: Colors.white.withOpacity(0.4)),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${tx.type == TransactionType.income ? '+' : '-'}${DebtUtils.formatAmount(tx.amount, tx.currency)}',
                                style: TextStyle(
                                  color: amountColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.more_vert, color: Colors.grey),
                            onPressed: () => _showTransactionMenu(context, tx),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [
              Color(0xFF6366F1), // Indigo
              Color(0xFFEC4899), // Pink
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6366F1).withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: const Color(0xFFEC4899).withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () => Navigator.pushNamed(context, AppRoutes.addTransaction),
          backgroundColor: Colors.transparent,
          elevation: 0,
          highlightElevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}
