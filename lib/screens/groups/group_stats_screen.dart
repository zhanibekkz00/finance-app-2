import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/chart_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/group_provider.dart';
import '../../models/category_model.dart';
import '../../widgets/neo_container.dart';
import '../../widgets/glass_container.dart';
import 'package:finance_app/l10n/generated/app_localizations.dart';

class GroupStatsScreen extends ConsumerStatefulWidget {
  const GroupStatsScreen({super.key});

  @override
  ConsumerState<GroupStatsScreen> createState() => _GroupStatsScreenState();
}

class _GroupStatsScreenState extends ConsumerState<GroupStatsScreen> {
  int _touchedIndex = -1;

  final List<Color> _chartColors = [
    const Color(0xFF5E5CE6), // Indigo
    const Color(0xFF32D74B), // Mint
    const Color(0xFFFF9F0A), // Orange
    const Color(0xFFFF375F), // Pink
    const Color(0xFF64D2FF), // Cyan
    const Color(0xFFFFD60A), // Yellow
    const Color(0xFFBF5AF2), // Purple
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final chartState = ref.watch(chartProvider);
    final data = chartState.data;

    final groupState = ref.watch(groupProvider);
    final groupInfo = groupState.value;

    String getUserName(String userId) {
      if (groupInfo != null) {
        for (var member in groupInfo.users) {
          if (member.id == userId) {
            return member.displayName ?? member.email;
          }
        }
      }
      return userId;
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.sharedWallet,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Filter Dropdown
          DropdownButton<ChartFilter>(
            value: chartState.filter,
            dropdownColor: const Color(0xFF1E1E2C),
            icon: const Icon(Icons.filter_list, color: Colors.white),
            underline: const SizedBox(),
            items: [
              DropdownMenuItem(
                value: ChartFilter.week,
                child: Text(l10n.week, style: const TextStyle(color: Colors.white)),
              ),
              DropdownMenuItem(
                value: ChartFilter.month,
                child: Text(l10n.month, style: const TextStyle(color: Colors.white)),
              ),
              DropdownMenuItem(
                value: ChartFilter.year,
                child: Text(l10n.year, style: const TextStyle(color: Colors.white)),
              ),
              DropdownMenuItem(
                value: ChartFilter.all,
                child: Text(l10n.allTime, style: const TextStyle(color: Colors.white)),
              ),
            ],
            onChanged: (val) {
              if (val != null) {
                ref.read(chartFilterProvider.notifier).state = val;
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.dashboard,
              style: const TextStyle(
                  fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white),
            ),
            const SizedBox(height: 20),

            // 1. Expenses Chart
            _buildUserPieChart(
              title: l10n.totalGroupSpend,
              totalAmount: data.totalSpend,
              userAmountMap: data.userSpend,
              getUserName: getUserName,
              l10n: l10n,
              isExpense: true,
            ),

            const SizedBox(height: 20),

            // 2. Incomes Chart
            _buildUserPieChart(
              title: l10n.income,
              totalAmount: data.totalIncome,
              userAmountMap: data.userIncome,
              getUserName: getUserName,
              l10n: l10n,
              isExpense: false,
            ),

            const SizedBox(height: 40),
            Text(
              l10n.whoOwesWhom,
              style: const TextStyle(
                  fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white),
            ),
            const SizedBox(height: 20),
            _buildDebtsSection(data.debts, getUserName, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildUserPieChart({
    required String title,
    required double totalAmount,
    required Map<String, double> userAmountMap,
    required String Function(String) getUserName,
    required AppLocalizations l10n,
    required bool isExpense,
  }) {
    if (totalAmount == 0 || userAmountMap.isEmpty) {
      return NeoContainer(
        child: Container(
          height: 180,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              Icon(Icons.pie_chart_outline, size: 48, color: Colors.white.withOpacity(0.3)),
              const SizedBox(height: 8),
              Text(
                l10n.noDataForPeriod,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    final entries = userAmountMap.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));

    return NeoContainer(
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            '${totalAmount.toStringAsFixed(0)} ₸',
            style: const TextStyle(
                fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 30),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 45,
                sections: entries.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final userEntry = entry.value;
                  final percent = (userEntry.value / totalAmount * 100).toStringAsFixed(0);

                  return PieChartSectionData(
                    color: _chartColors[idx % _chartColors.length],
                    value: userEntry.value,
                    title: '$percent%',
                    radius: 40.0,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Legend
          Wrap(
            spacing: 16,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: entries.asMap().entries.map((entry) {
              final idx = entry.key;
              final userEntry = entry.value;
              final userName = getUserName(userEntry.key);

              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _chartColors[idx % _chartColors.length],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$userName (${userEntry.value.toStringAsFixed(0)} ₸)',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDebtsSection(List<Debt> debts, String Function(String) getUserName, AppLocalizations l10n) {
    if (debts.isEmpty) {
      return GlassContainer(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(l10n.allSettledUp,
                style: const TextStyle(color: Colors.white, fontSize: 16)),
          ),
        ),
      );
    }

    return Column(
      children: debts.map((debt) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: GlassContainer(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF375F).withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_upward, color: Color(0xFFFF375F)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${getUserName(debt.from)} ${l10n.owes} ${getUserName(debt.to)}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${debt.amount.toStringAsFixed(0)} ₸',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                ],
              ),
            ),
          )).toList(),
    );
  }
}
