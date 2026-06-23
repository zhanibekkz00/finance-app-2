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
import '../providers/notification_provider.dart';
import '../models/notification_model.dart';
import 'budgets_screen.dart';
import 'debts/debts_screen.dart';
import 'profile_screen.dart';
import '../providers/savings_goal_provider.dart';
import 'split_transaction_screen.dart';
import 'analytics_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _currentIndex = 0;
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  bool _isBalanceVisible = true;
  bool _isCollapsed = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _showTransactionMenu(BuildContext context, TransactionModel tx) {
    final l10n = AppLocalizations.of(context)!;
    final category = tx.category ??
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
              leading: const Icon(Icons.call_split_rounded),
              title: Text(l10n.splitTransaction),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SplitTransactionScreen(transaction: tx),
                  ),
                );
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

  void _showNotificationDetail(BuildContext context, NotificationModel notification) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E2C),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1).withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.campaign,
                      color: Color(0xFF6366F1),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      notification.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                DateFormat.yMMMd(Localizations.localeOf(context).toString())
                    .add_Hm()
                    .format(notification.createdAt),
                style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
              ),
              const Divider(color: Colors.white12, height: 24),
              Text(
                notification.body,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: Container(
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
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ref.read(notificationsProvider.notifier).markAsRead(notification.id);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      l10n.ok,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final txState = ref.watch(transactionProvider);
    ref.watch(categoryProvider); // Watch for category changes
    final totalBalance = ref.watch(balanceProvider);
    final currencyCode = ref.watch(settingsProvider).currencyCode;
    final notificationsAsync = ref.watch(notificationsProvider);

    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Theme-aware colors
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subTextColor = isDark ? Colors.white.withOpacity(0.7) : Colors.black.withOpacity(0.65);
    final hintColor = isDark ? Colors.white.withOpacity(0.4) : Colors.black.withOpacity(0.4);
    final dividerColor = isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.12);
    final cardBgColor = isDark ? Colors.white.withOpacity(0.03) : Colors.white.withOpacity(0.85);
    final cardBorderColor = isDark ? Colors.white.withOpacity(0.15) : Colors.black.withOpacity(0.08);
    final iconColor = isDark ? Colors.white : const Color(0xFF0F172A);

    // Get unread notifications
    final unreadNotifications = notificationsAsync.maybeWhen(
      data: (list) => list.where((n) => !n.isRead).toList(),
      orElse: () => <NotificationModel>[],
    );

    // Filter logic
    final transactions = txState.transactions.where((tx) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      final category = tx.category ??
          ref.read(categoryProvider.notifier).getCategoryById(tx.categoryId);
      final catName = category?.getLocalizedName(context).toLowerCase() ?? '';

      return tx.note.toLowerCase().contains(q) ||
          tx.amount.toString().contains(q) ||
          tx.currency.toLowerCase().contains(q) ||
          catName.contains(q);
    }).toList();

    // --- Monthly stats ---
    final now = DateTime.now();
    double monthIncome = 0;
    double monthExpense = 0;
    for (final tx in txState.transactions) {
      if (tx.date.year == now.year && tx.date.month == now.month) {
        if (tx.type == TransactionType.income) {
          monthIncome += tx.amount;
        } else {
          monthExpense += tx.amount;
        }
      }
    }

    // --- Group transactions by date ---
    final Map<String, List<TransactionModel>> grouped = {};
    for (final tx in transactions) {
      final txDate = DateTime(tx.date.year, tx.date.month, tx.date.day);
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      String label;
      if (tx.isPinned) {
        label = l10n.pinnedTransactions;
      } else if (txDate == today) {
        label = _today(l10n);
      } else if (txDate == yesterday) {
        label = _yesterday(l10n);
      } else {
        label = DateFormat.yMMMd(Localizations.localeOf(context).toString()).format(tx.date);
      }
      grouped.putIfAbsent(label, () => []).add(tx);
    }

    // Original Dashboard Tab Content
    final Widget dashboardHome = Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: iconColor),
        title: Text(
          l10n.dashboard,
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: iconColor),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.notifications),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
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
                backgroundColor: cardBgColor,
                borderGradient: LinearGradient(colors: [cardBorderColor, cardBorderColor]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.totalBalance,
                          style: TextStyle(
                            color: subTextColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        // Currency Selector Dropdown
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
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AnimatedSize(
                          duration: const Duration(milliseconds: 200),
                          child: Text(
                            _isBalanceVisible
                                ? DebtUtils.formatAmount(totalBalance, currencyCode)
                                : '••••••',
                            style: TextStyle(
                              color: textColor,
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
                            color: subTextColor,
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
          // --- Monthly Stats Row (collapsible on search focus) ---
          AnimatedSize(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            child: AnimatedOpacity(
              opacity: _isCollapsed ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 300),
              child: _isCollapsed
                  ? const SizedBox.shrink()
                  : Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              label: l10n.income,
                              amount: DebtUtils.formatAmount(monthIncome, currencyCode),
                              icon: Icons.arrow_downward_rounded,
                              color: const Color(0xFF32D74B),
                              isVisible: _isBalanceVisible,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              label: l10n.expense,
                              amount: DebtUtils.formatAmount(monthExpense, currencyCode),
                              icon: Icons.arrow_upward_rounded,
                              color: const Color(0xFFFF375F),
                              isVisible: _isBalanceVisible,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
          // --- Notifications banner (collapsible on search focus) ---
          AnimatedSize(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            child: AnimatedOpacity(
              opacity: _isCollapsed ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 300),
              child: _isCollapsed || unreadNotifications.isEmpty
                  ? const SizedBox.shrink()
                  : Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOut,
                        builder: (context, animVal, child) {
                          return Opacity(
                            opacity: animVal,
                            child: Transform.translate(
                              offset: Offset(0, -10 * (1 - animVal)),
                              child: child,
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF6366F1).withOpacity(0.15),
                                const Color(0xFFEC4899).withOpacity(0.08),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            border: Border.all(
                              color: const Color(0xFF6366F1).withOpacity(0.25),
                              width: 1.5,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Material(
                              color: Colors.transparent,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF6366F1).withOpacity(0.2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.campaign_outlined,
                                        color: Color(0xFF818CF8),
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            l10n.adminAnnouncement,
                                            style: TextStyle(
                                              color: textColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            unreadNotifications.first.title,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: subTextColor,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    TextButton(
                                      onPressed: () => _showNotificationDetail(
                                        context,
                                        unreadNotifications.first,
                                      ),
                                      style: TextButton.styleFrom(
                                        foregroundColor: const Color(0xFF818CF8),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: Text(
                                        l10n.viewDetails,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.close,
                                        color: textColor.withOpacity(0.5),
                                        size: 18,
                                      ),
                                      onPressed: () {
                                        ref
                                            .read(notificationsProvider.notifier)
                                            .markAsRead(unreadNotifications.first.id);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
          ),
          
          // --- Savings Goals Section (collapsible on search focus) ---
          AnimatedSize(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            child: AnimatedOpacity(
              opacity: _isCollapsed ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 300),
              child: _isCollapsed
                  ? const SizedBox.shrink()
                  : Consumer(
                      builder: (context, ref, child) {
                        final goalsState = ref.watch(savingsGoalProvider);
                        final l10n = AppLocalizations.of(context)!;
                        if (goalsState.goals.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.savingsGoals,
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                GestureDetector(
                                  onTap: () => Navigator.pushNamed(context, AppRoutes.savingsGoals),
                                  child: GlassContainer(
                                    borderRadius: 16,
                                    padding: 16.0,
                                    backgroundColor: cardBgColor,
                                    borderGradient: LinearGradient(colors: [cardBorderColor, cardBorderColor]),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.savings_outlined, color: Color(0xFF6366F1)),
                                        const SizedBox(width: 8),
                                        Text(
                                          l10n.addSavingsGoal,
                                          style: const TextStyle(
                                            color: Color(0xFF6366F1),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    l10n.savingsGoals,
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => Navigator.pushNamed(context, AppRoutes.savingsGoals),
                                    child: Text(
                                      l10n.savingsGoalsManage,
                                      style: const TextStyle(
                                        color: Color(0xFF6366F1),
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                height: 110,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: goalsState.goals.length,
                                  itemBuilder: (context, index) {
                                    final goal = goalsState.goals[index];
                                    final color = goal.colorValue != null ? Color(goal.colorValue!) : const Color(0xFF6366F1);
                                    final currencySymbol = goal.currency == 'KZT'
                                        ? '₸'
                                        : goal.currency == 'USD'
                                            ? '\$'
                                            : goal.currency == 'EUR'
                                                ? '€'
                                                : goal.currency == 'RUB'
                                                    ? '₽'
                                                    : goal.currency;
                                    return Container(
                                      width: 170,
                                      margin: const EdgeInsets.only(right: 12),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        color: color.withOpacity(isDark ? 0.08 : 0.05),
                                        border: Border.all(color: color.withOpacity(0.2), width: 1),
                                      ),
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  goal.name,
                                                  style: TextStyle(
                                                    color: textColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Text(
                                                '${(goal.progress * 100).toStringAsFixed(0)}%',
                                                style: TextStyle(
                                                  color: color,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${goal.currentAmount.toStringAsFixed(0)} / ${goal.targetAmount.toStringAsFixed(0)} $currencySymbol',
                                                style: TextStyle(
                                                  color: subTextColor,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              ClipRRect(
                                                borderRadius: BorderRadius.circular(2),
                                                child: LinearProgressIndicator(
                                                  value: goal.progress,
                                                  backgroundColor: textColor.withOpacity(0.05),
                                                  valueColor: AlwaysStoppedAnimation<Color>(color),
                                                  minHeight: 4,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ),

          // --- Toggle Button ---
          GestureDetector(
            onTap: () => setState(() => _isCollapsed = !_isCollapsed),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: AnimatedRotation(
                turns: _isCollapsed ? 0.5 : 0.0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  decoration: BoxDecoration(
                    color: textColor.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.keyboard_arrow_up_rounded,
                    color: textColor.withOpacity(0.4),
                    size: 22,
                  ),
                ),
              ),
            ),
          ),



          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GlassContainer(
              borderRadius: 16,
              padding: 0,
              backgroundColor: cardBgColor,
              borderGradient: LinearGradient(colors: [cardBorderColor, cardBorderColor]),
              child: TextField(
                controller: _searchCtrl,
                decoration: InputDecoration(
                  labelText: l10n.search,
                  labelStyle: TextStyle(color: hintColor),
                  prefixIcon: Icon(Icons.search, color: hintColor),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                style: TextStyle(color: textColor),
                onChanged: (v) => setState(() => _searchQuery = v),
              ),
            ),
          ),
          grouped.isEmpty
              ? SizedBox(
                  height: 200,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long_outlined,
                            size: 64, color: textColor.withOpacity(0.2)),
                        const SizedBox(height: 16),
                        Text(
                          l10n.search,
                          style: TextStyle(
                              color: textColor.withOpacity(0.3),
                              fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: grouped.length,
                    itemBuilder: (context, groupIndex) {
                      final dateLabel = grouped.keys.elementAt(groupIndex);
                      final dayTxs = grouped[dateLabel]!;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // --- Date Group Header ---
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              children: [
                                Text(
                                  dateLabel,
                                  style: TextStyle(
                                    color: subTextColor.withOpacity(0.8),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    color: dividerColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // --- Transactions for this date ---
                          ...dayTxs.map((tx) {
                            final category = tx.category ?? ref
                                .read(categoryProvider.notifier)
                                .getCategoryById(tx.categoryId);
                            final debtInfo = DebtUtils.parseDebtTransaction(l10n, tx);
                            final isDebt = debtInfo != null;
                            final isSavings = tx.note.startsWith('Накопление:');
                            final displayTitle = isDebt
                                ? debtInfo.title
                                : isSavings
                                    ? l10n.savingsGoals
                                    : (category?.getLocalizedName(context) ?? l10n.unknown);
                            String subtitle = isDebt ? debtInfo.subtitle : tx.note;
                            if (tx.userName != null && tx.userName!.isNotEmpty) {
                              if (subtitle.isNotEmpty) {
                                subtitle = '${tx.userName} • $subtitle';
                              } else {
                                subtitle = tx.userName!;
                              }
                            }
                            final displaySubtitle = subtitle;

                            Color amountColor;
                            if (isDebt) {
                              amountColor = Colors.amberAccent;
                            } else if (tx.type == TransactionType.income) {
                              amountColor = const Color(0xFF32D74B);
                            } else {
                              amountColor = const Color(0xFFFF375F);
                            }

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: GlassContainer(
                                padding: 8,
                                backgroundColor: cardBgColor,
                                borderGradient: LinearGradient(colors: [cardBorderColor, cardBorderColor]),
                                child: ListTile(
                                  leading: Stack(
                                    children: [
                                      if (isDebt)
                                        DebtUtils.getDebtIcon(
                                            debtInfo.creditorName, debtInfo.type,
                                            size: 22)
                                      else
                                        Container(
                                          width: 44,
                                          height: 44,
                                          padding: (!isSavings && category?.imageUrl != null) ? EdgeInsets.zero : const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            image: (!isSavings && category?.imageUrl != null)
                                                ? DecorationImage(
                                                    image: NetworkImage(category!.imageUrl!),
                                                    fit: BoxFit.cover,
                                                  )
                                                : null,
                                            gradient: (!isSavings && category?.imageUrl != null)
                                                ? null
                                                : LinearGradient(
                                                    colors: isSavings
                                                        ? [
                                                            const Color(0xFF6366F1).withOpacity(0.3),
                                                            const Color(0xFF6366F1).withOpacity(0.85),
                                                          ]
                                                        : (category != null
                                                            ? [
                                                                Color(category.colorValue).withOpacity(0.3),
                                                                Color(category.colorValue).withOpacity(0.85),
                                                              ]
                                                            : [
                                                                Colors.grey.withOpacity(0.3),
                                                                Colors.grey.withOpacity(0.85),
                                                              ]),
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                  ),
                                          ),
                                          child: (!isSavings && category?.imageUrl != null)
                                              ? null
                                              : Icon(
                                                  isSavings
                                                      ? Icons.savings
                                                      : (category != null
                                                          ? IconData(category.iconCode, fontFamily: 'MaterialIcons')
                                                          : Icons.help_outline),
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
                                            child: const Icon(Icons.push_pin,
                                                size: 12, color: Colors.white),
                                          ),
                                        ),
                                    ],
                                  ),
                                  title: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          displayTitle,
                                          style: TextStyle(
                                              color: textColor,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                      if (tx.isPinned)
                                        const Icon(Icons.push_pin,
                                            size: 16, color: Colors.orange),
                                    ],
                                  ),
                                  subtitle: displaySubtitle.isNotEmpty
                                      ? Text(
                                          displaySubtitle,
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: subTextColor.withOpacity(0.8)),
                                        )
                                      : null,
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '${tx.type == TransactionType.income ? '+' : '-'}${DebtUtils.formatAmount(tx.amount, tx.currency)}',
                                        style: TextStyle(
                                          color: amountColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.more_vert,
                                            color: Colors.grey),
                                        onPressed: () =>
                                            _showTransactionMenu(context, tx),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      );
                    },
                  ),
        ],
      ),
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
          heroTag: 'dashboard_fab',
          onPressed: () => Navigator.pushNamed(context, AppRoutes.addTransaction),
          backgroundColor: Colors.transparent,
          elevation: 0,
          highlightElevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    );

    final List<Widget> pages = [
      dashboardHome,
      const BudgetsScreen(),
      const DebtsScreen(),
      const AnalyticsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF0F172A), const Color(0xFF1E293B)]
                : [const Color(0xFFEEF2F6), const Color(0xFFE2E8F0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: IndexedStack(
            index: _currentIndex,
            children: pages,
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
            selectedItemColor: const Color(0xFF6366F1),
            unselectedItemColor: isDark ? Colors.white.withOpacity(0.4) : Colors.black.withOpacity(0.4),
            showSelectedLabels: true,
            showUnselectedLabels: true,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            unselectedLabelStyle: const TextStyle(fontSize: 11),
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.home_outlined),
                activeIcon: const Icon(Icons.home),
                label: l10n.dashboard,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.track_changes_outlined),
                activeIcon: const Icon(Icons.track_changes),
                label: l10n.budgets,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.account_balance_wallet_outlined),
                activeIcon: const Icon(Icons.account_balance_wallet),
                label: l10n.sharedWallet,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.bar_chart_outlined),
                activeIcon: const Icon(Icons.bar_chart_rounded),
                label: 'Аналитика',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.person_outline),
                activeIcon: const Icon(Icons.person),
                label: l10n.profile,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _today(AppLocalizations l10n) {
    // Use localized "Today" if available, fallback to common strings
    final code = Localizations.localeOf(context).languageCode;
    if (code == 'ru') return 'Сегодня';
    if (code == 'kk') return 'Бүгін';
    return 'Today';
  }

  String _yesterday(AppLocalizations l10n) {
    final code = Localizations.localeOf(context).languageCode;
    if (code == 'ru') return 'Вчера';
    if (code == 'kk') return 'Кеше';
    return 'Yesterday';
  }
}

// ---- Monthly stat card ----
class _StatCard extends StatelessWidget {
  final String label;
  final String amount;
  final IconData icon;
  final Color color;
  final bool isVisible;

  const _StatCard({
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
    required this.isVisible,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: isDark ? Colors.white.withOpacity(0.5) : Colors.black.withOpacity(0.55),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isVisible ? amount : '••••',
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Mini Analytics Banner ────────────────────────────────────────────────────
class _MiniAnalyticsBanner extends StatelessWidget {
  final List<TransactionModel> transactions;
  final List<CategoryModel> categories;
  final String currencyCode;
  final Color textColor;
  final Color subTextColor;
  final Color cardBgColor;
  final Color cardBorderColor;
  final bool isDark;
  final VoidCallback onTap;

  const _MiniAnalyticsBanner({
    required this.transactions,
    required this.categories,
    required this.currencyCode,
    required this.textColor,
    required this.subTextColor,
    required this.cardBgColor,
    required this.cardBorderColor,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final Map<String, double> catMap = {};

    for (final tx in transactions) {
      if (tx.type == TransactionType.expense &&
          tx.date.year == now.year &&
          tx.date.month == now.month) {
        catMap[tx.categoryId] = (catMap[tx.categoryId] ?? 0) + tx.amount;
      }
    }

    if (catMap.isEmpty) return const SizedBox.shrink();

    final sorted = catMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top3 = sorted.take(3).toList();
    final total = catMap.values.fold<double>(0, (s, v) => s + v);

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        child: Container(
          decoration: BoxDecoration(
            color: cardBgColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: cardBorderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.25 : 0.05),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.bar_chart_rounded,
                          color: Color(0xFF6366F1),
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Ай бойынша шығыстар',
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        'Толық',
                        style: const TextStyle(
                          color: Color(0xFF6366F1),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: Color(0xFF6366F1),
                        size: 16,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...top3.map((entry) {
                final cat = categories.firstWhere(
                  (c) => c.id == entry.key,
                  orElse: () => CategoryModel(
                    id: entry.key,
                    name: entry.key,
                    colorValue: 0xFF9E9E9E,
                    iconCode: 58826,
                  ),
                );
                final catColor = Color(cat.colorValue);
                final pct = total > 0 ? entry.value / total : 0.0;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: cat.imageUrl != null ? null : catColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                          image: cat.imageUrl != null
                              ? DecorationImage(
                                  image: NetworkImage(cat.imageUrl!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: cat.imageUrl != null
                            ? null
                            : Icon(
                                IconData(cat.iconCode,
                                    fontFamily: 'MaterialIcons'),
                                color: catColor,
                                size: 16,
                              ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  cat.getLocalizedName(context),
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  DebtUtils.formatAmount(
                                      entry.value, currencyCode),
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(3),
                              child: LinearProgressIndicator(
                                value: pct,
                                minHeight: 4,
                                backgroundColor:
                                    catColor.withOpacity(0.10),
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(catColor),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
