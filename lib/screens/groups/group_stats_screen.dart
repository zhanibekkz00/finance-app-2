import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/chart_provider.dart';
import '../../providers/category_provider.dart';
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

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Shared Wallet',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                child: Text('Week', style: const TextStyle(color: Colors.white)),
              ),
              DropdownMenuItem(
                value: ChartFilter.month,
                child: Text('Month', style: const TextStyle(color: Colors.white)),
              ),
              DropdownMenuItem(
                value: ChartFilter.year,
                child: Text('Year', style: const TextStyle(color: Colors.white)),
              ),
              DropdownMenuItem(
                value: ChartFilter.all,
                child: Text('All Time', style: const TextStyle(color: Colors.white)),
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
            const Text(
              'Dashboard',
              style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white),
            ),
            const SizedBox(height: 20),
            if (data.totalSpend == 0)
              _buildEmptyState()
            else
              _buildChartSection(data),
            const SizedBox(height: 40),
            const Text(
              'Who owes whom',
              style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white),
            ),
            const SizedBox(height: 20),
            _buildDebtsSection(data.debts),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return GlassContainer(
      child: Container(
        height: 250,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart_rounded, size: 60, color: Colors.white.withOpacity(0.3)),
            const SizedBox(height: 16),
            const Text(
              'Нет данных за этот период',
              style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartSection(ChartData data) {
    final categories = data.categorySpend.entries.toList();
    // Sort by amount descending
    categories.sort((a, b) => b.value.compareTo(a.value));

    return NeoContainer(
      child: Column(
        children: [
          const Text(
            'Total Group Spend',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            '${data.totalSpend.toStringAsFixed(0)} ₸',
            style: const TextStyle(
                fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 30),
          SizedBox(
            height: 220,
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          pieTouchResponse == null ||
                          pieTouchResponse.touchedSection == null) {
                        _touchedIndex = -1;
                        return;
                      }
                      _touchedIndex =
                          pieTouchResponse.touchedSection!.touchedSectionIndex;
                    });
                    
                    // Show dialog with details on tap up
                    if (event is FlTapUpEvent && _touchedIndex != -1) {
                      final catEntry = categories[_touchedIndex];
                      final catName = ref.read(categoryProvider.notifier).getCategoryById(catEntry.key)?.getLocalizedName(context) ?? 'Unknown';
                      _showDetailsDialog(catName, catEntry.value);
                    }
                  },
                ),
                sectionsSpace: 2,
                centerSpaceRadius: 50,
                sections: categories.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final catEntry = entry.value;
                  final isTouched = idx == _touchedIndex;
                  final radius = isTouched ? 50.0 : 40.0;
                  final fontSize = isTouched ? 16.0 : 12.0;

                  return PieChartSectionData(
                    color: _chartColors[idx % _chartColors.length],
                    value: catEntry.value,
                    title: '${(catEntry.value / data.totalSpend * 100).toStringAsFixed(0)}%',
                    radius: radius,
                    titleStyle: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildLegend(categories),
        ],
      ),
    );
  }

  void _showDetailsDialog(String categoryName, double amount) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E2C),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(categoryName, style: const TextStyle(color: Colors.white)),
          content: Text(
            'Amount: ${amount.toStringAsFixed(2)}',
            style: const TextStyle(color: Colors.white70, fontSize: 18),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK', style: TextStyle(color: Color(0xFF5E5CE6))),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLegend(List<MapEntry<String, double>> categories) {
    return Wrap(
      spacing: 16,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: categories.asMap().entries.map((entry) {
        final idx = entry.key;
        final data = entry.value;
        final cat = ref.read(categoryProvider.notifier).getCategoryById(data.key);
        final catName = cat?.getLocalizedName(context) ?? 'Unknown';

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
            Text(catName, style: const TextStyle(color: Colors.white70)),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildDebtsSection(List<Debt> debts) {
    if (debts.isEmpty) {
      return const GlassContainer(
        child: Center(
          child: Text('All settled up!',
              style: TextStyle(color: Colors.white, fontSize: 16)),
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
                          '${debt.from} owes ${debt.to}',
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
