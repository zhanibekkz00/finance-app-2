import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart';
import '../providers/settings_provider.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';
import '../utils/debt_utils.dart';
import 'package:finance_app/l10n/generated/app_localizations.dart';
import 'category_stats_screen.dart';

// ─── Period filter enum ───────────────────────────────────────────────────────
enum AnalyticsPeriod { week, month, threeMonths, year }

// ─── Provider for selected period ────────────────────────────────────────────
final analyticsPeriodProvider =
    StateProvider<AnalyticsPeriod>((ref) => AnalyticsPeriod.month);

// ─── Provider for selected transaction type ───────────────────────────────────
final analyticsTypeProvider =
    StateProvider<TransactionType>((ref) => TransactionType.expense);

// ─── Analytics data class ─────────────────────────────────────────────────────
class CategoryAnalytics {
  final String categoryId;
  final String categoryName;
  final int colorValue;
  final int iconCode;
  final String? imageUrl;
  final double amount;
  final int count;
  final double percentage;

  const CategoryAnalytics({
    required this.categoryId,
    required this.categoryName,
    required this.colorValue,
    required this.iconCode,
    this.imageUrl,
    required this.amount,
    required this.count,
    required this.percentage,
  });
}

// ─── Main Analytics Screen ────────────────────────────────────────────────────
class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  int _touchedIndex = -1;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // ─── Compute category analytics ────────────────────────────────────────────
  List<CategoryAnalytics> _computeAnalytics(
    List<TransactionModel> transactions,
    List<CategoryModel> categories,
    AnalyticsPeriod period,
    TransactionType type,
    BuildContext context,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    DateTime startDate;
    switch (period) {
      case AnalyticsPeriod.week:
        startDate = now.subtract(const Duration(days: 7));
        break;
      case AnalyticsPeriod.month:
        startDate = DateTime(now.year, now.month, 1);
        break;
      case AnalyticsPeriod.threeMonths:
        startDate = DateTime(now.year, now.month - 2, 1);
        break;
      case AnalyticsPeriod.year:
        startDate = DateTime(now.year, 1, 1);
        break;
    }

    final filtered = transactions.where((tx) {
      return tx.type == type &&
          (tx.date.isAfter(startDate) ||
              tx.date.isAtSameMomentAs(startDate));
    }).toList();

    double total = filtered.fold(0, (s, tx) => s + tx.amount);

    final Map<String, double> amountMap = {};
    final Map<String, int> countMap = {};
    final Map<String, CategoryModel> categoryObjectsMap = {};
    for (final tx in filtered) {
      String key = tx.categoryId;
      if (tx.category != null) {
        categoryObjectsMap[key] = tx.category!;
      }
      if (key.isEmpty) {
        final isSavings = tx.note.startsWith('Накопление:');
        final isDebt = DebtUtils.parseDebtTransaction(l10n, tx) != null;
        if (isSavings) {
          key = 'SYSTEM_SAVINGS';
        } else if (isDebt) {
          key = 'SYSTEM_DEBTS';
        } else {
          key = 'SYSTEM_UNKNOWN';
        }
      }
      amountMap[key] = (amountMap[key] ?? 0) + tx.amount;
      countMap[key] = (countMap[key] ?? 0) + 1;
    }

    final result = <CategoryAnalytics>[];
    for (final entry in amountMap.entries) {
      String name;
      int colorValue;
      int iconCode;
      String? imageUrl;

      if (entry.key == 'SYSTEM_SAVINGS') {
        name = l10n.savingsGoals;
        colorValue = 0xFF6366F1;
        iconCode = Icons.savings.codePoint;
      } else if (entry.key == 'SYSTEM_DEBTS') {
        name = l10n.debts;
        colorValue = 0xFFFFB300;
        iconCode = Icons.account_balance_wallet.codePoint;
      } else if (entry.key == 'SYSTEM_UNKNOWN') {
        name = l10n.unknown;
        colorValue = 0xFF9E9E9E;
        iconCode = 58826;
      } else {
        final cat = categoryObjectsMap[entry.key] ?? categories.firstWhere(
          (c) => c.id == entry.key,
          orElse: () => CategoryModel(
            id: entry.key,
            name: entry.key,
            colorValue: 0xFF9E9E9E,
            iconCode: 58826,
          ),
        );
        name = cat.getLocalizedName(context);
        colorValue = cat.colorValue;
        iconCode = cat.iconCode;
        imageUrl = cat.imageUrl;
      }

      result.add(CategoryAnalytics(
        categoryId: entry.key,
        categoryName: name,
        colorValue: colorValue,
        iconCode: iconCode,
        imageUrl: imageUrl,
        amount: entry.value,
        count: countMap[entry.key] ?? 0,
        percentage: total > 0 ? (entry.value / total * 100) : 0,
      ));
    }

    result.sort((a, b) => b.amount.compareTo(a.amount));
    return result;
  }

  // ─── Compute monthly/weekly trend data ─────────────────────────────────────
  List<Map<String, dynamic>> _computeTrend(
    List<TransactionModel> transactions,
    AnalyticsPeriod period,
    TransactionType type,
  ) {
    final now = DateTime.now();
    final Map<String, double> trendMap = {};

    if (period == AnalyticsPeriod.week) {
      for (int i = 6; i >= 0; i--) {
        final day = now.subtract(Duration(days: i));
        final key = DateFormat('EEE').format(day);
        trendMap[key] = 0;
      }
      for (final tx in transactions) {
        if (tx.type != type) continue;
        final diff = now.difference(tx.date).inDays;
        if (diff <= 6) {
          final key = DateFormat('EEE').format(tx.date);
          trendMap[key] = (trendMap[key] ?? 0) + tx.amount;
        }
      }
    } else if (period == AnalyticsPeriod.month) {
      for (int i = 0; i < DateTime(now.year, now.month + 1, 0).day; i++) {
        final key = '${i + 1}';
        trendMap[key] = 0;
      }
      for (final tx in transactions) {
        if (tx.type != type) continue;
        if (tx.date.year == now.year && tx.date.month == now.month) {
          final key = '${tx.date.day}';
          trendMap[key] = (trendMap[key] ?? 0) + tx.amount;
        }
      }
    } else if (period == AnalyticsPeriod.threeMonths ||
        period == AnalyticsPeriod.year) {
      final months = period == AnalyticsPeriod.year ? 12 : 3;
      for (int i = months - 1; i >= 0; i--) {
        final month = DateTime(now.year, now.month - i, 1);
        final key = DateFormat('MMM').format(month);
        trendMap[key] = 0;
      }
      for (final tx in transactions) {
        if (tx.type != type) continue;
        final diff = now.month -
            tx.date.month +
            12 * (now.year - tx.date.year);
        if (diff < months) {
          final key = DateFormat('MMM').format(tx.date);
          trendMap[key] = (trendMap[key] ?? 0) + tx.amount;
        }
      }
    }

    return trendMap.entries
        .map((e) => {'label': e.key, 'value': e.value})
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final txState = ref.watch(transactionProvider);
    final categories = ref.watch(categoryProvider);
    final period = ref.watch(analyticsPeriodProvider);
    final txType = ref.watch(analyticsTypeProvider);
    final currencyCode = ref.watch(settingsProvider).currencyCode;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subColor = isDark
        ? Colors.white.withOpacity(0.55)
        : Colors.black.withOpacity(0.55);
    final cardColor = isDark
        ? Colors.white.withOpacity(0.04)
        : Colors.white.withOpacity(0.9);
    final borderColor = isDark
        ? Colors.white.withOpacity(0.10)
        : Colors.black.withOpacity(0.07);

    final analytics = _computeAnalytics(
      txState.transactions,
      categories,
      period,
      txType,
      context,
    );

    final totalAmount =
        analytics.fold<double>(0, (s, a) => s + a.amount);

    final trendData = _computeTrend(
      txState.transactions,
      period,
      txType,
    );

    final maxTrend =
        trendData.isEmpty ? 1.0 : trendData.map((e) => e['value'] as double).reduce((a, b) => a > b ? a : b);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          _periodTitle(period),
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _PeriodSelector(
              selected: period,
              onChanged: (p) {
                ref.read(analyticsPeriodProvider.notifier).state = p;
                setState(() => _touchedIndex = -1);
                _animController.forward(from: 0);
              },
              textColor: textColor,
              isDark: isDark,
            ),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: txState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : analytics.isEmpty
                ? _buildEmpty(textColor, subColor)
                : CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ── Type toggle ─────────────────────────────
                              _TypeToggle(
                                selected: txType,
                                onChanged: (t) {
                                  ref
                                      .read(analyticsTypeProvider.notifier)
                                      .state = t;
                                  setState(() => _touchedIndex = -1);
                                  _animController.forward(from: 0);
                                },
                                isDark: isDark,
                              ),
                              const SizedBox(height: 16),

                              // ── Donut Chart Card ─────────────────────────
                              _buildDonutCard(
                                analytics,
                                totalAmount,
                                currencyCode,
                                textColor,
                                subColor,
                                cardColor,
                                borderColor,
                                isDark,
                              ),
                              const SizedBox(height: 16),

                              // ── Trend Bar Chart Card ─────────────────────
                              _buildTrendCard(
                                trendData,
                                maxTrend,
                                currencyCode,
                                textColor,
                                subColor,
                                cardColor,
                                borderColor,
                                txType,
                                isDark,
                              ),
                              const SizedBox(height: 16),

                              // ── Category List heading ────────────────────
                              Text(
                                txType == TransactionType.expense
                                    ? 'Шығындар бойынша'
                                    : 'Кіріс бойынша',
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                            ],
                          ),
                        ),
                      ),

                      // ── Category rows ────────────────────────────────────
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (ctx, i) => _CategoryRow(
                              item: analytics[i],
                              currencyCode: currencyCode,
                              textColor: textColor,
                              subColor: subColor,
                              cardColor: cardColor,
                              borderColor: borderColor,
                              isDark: isDark,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CategoryStatsScreen(
                                    categoryId: analytics[i].categoryId,
                                  ),
                                ),
                              ),
                            ),
                            childCount: analytics.length,
                          ),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  // ─── Donut card ─────────────────────────────────────────────────────────────
  Widget _buildDonutCard(
    List<CategoryAnalytics> analytics,
    double total,
    String currencyCode,
    Color textColor,
    Color subColor,
    Color cardColor,
    Color borderColor,
    bool isDark,
  ) {
    final sections = analytics.asMap().entries.map((entry) {
      final i = entry.key;
      final a = entry.value;
      final isTouched = i == _touchedIndex;
      return PieChartSectionData(
        value: a.amount,
        color: Color(a.colorValue),
        radius: isTouched ? 64 : 54,
        showTitle: false,
        borderSide: isTouched
            ? BorderSide(
                color: Color(a.colorValue).withOpacity(0.6), width: 3)
            : const BorderSide(color: Colors.transparent),
      );
    }).toList();

    final touched = _touchedIndex >= 0 && _touchedIndex < analytics.length
        ? analytics[_touchedIndex]
        : null;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          SizedBox(
            height: 220,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sections: sections,
                    centerSpaceRadius: 68,
                    sectionsSpace: 2,
                    startDegreeOffset: -90,
                    pieTouchData: PieTouchData(
                      touchCallback: (event, response) {
                        if (!event.isInterestedForInteractions ||
                            response?.touchedSection == null) {
                          setState(() => _touchedIndex = -1);
                          return;
                        }
                        setState(() => _touchedIndex =
                            response!.touchedSection!.touchedSectionIndex);
                      },
                    ),
                  ),
                ),
                // Center label
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (touched != null) ...[
                      Container(
                        padding: touched.imageUrl != null ? EdgeInsets.zero : const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: touched.imageUrl != null ? null : Color(touched.colorValue).withOpacity(0.15),
                          shape: BoxShape.circle,
                          image: touched.imageUrl != null
                              ? DecorationImage(
                                  image: NetworkImage(touched.imageUrl!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        width: touched.imageUrl != null ? 38 : null,
                        height: touched.imageUrl != null ? 38 : null,
                        child: touched.imageUrl != null
                            ? null
                            : Icon(
                                IconData(touched.iconCode,
                                    fontFamily: 'MaterialIcons'),
                                color: Color(touched.colorValue),
                                size: 22,
                              ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        touched.categoryName,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${touched.percentage.toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: Color(touched.colorValue),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ] else ...[
                      Text(
                        'Барлығы',
                        style: TextStyle(
                          color: subColor,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      FittedBox(
                        child: Text(
                          DebtUtils.formatAmount(total, currencyCode),
                          style: TextStyle(
                            color: textColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          // Legend
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: analytics.take(6).map((a) {
              return _LegendChip(
                color: Color(a.colorValue),
                label: a.categoryName,
                percentage: a.percentage,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ─── Trend bar chart card ────────────────────────────────────────────────────
  Widget _buildTrendCard(
    List<Map<String, dynamic>> trendData,
    double maxTrend,
    String currencyCode,
    Color textColor,
    Color subColor,
    Color cardColor,
    Color borderColor,
    TransactionType txType,
    bool isDark,
  ) {
    final barColor = txType == TransactionType.expense
        ? const Color(0xFF6366F1)
        : const Color(0xFF22C55E);

    final barGroups = trendData.asMap().entries.map((entry) {
      final i = entry.key;
      final val = (entry.value['value'] as double);
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: val,
            gradient: LinearGradient(
              colors: [barColor.withOpacity(0.5), barColor],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            width: trendData.length > 20 ? 6 : 14,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(6),
            ),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: maxTrend * 1.2,
              color: isDark
                  ? Colors.white.withOpacity(0.03)
                  : Colors.black.withOpacity(0.03),
            ),
          ),
        ],
      );
    }).toList();

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            txType == TransactionType.expense
                ? 'Шығындар динамикасы'
                : 'Кіріс динамикасы',
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: trendData.isEmpty || maxTrend == 0
                ? Center(
                    child: Text(
                      'Деректер жоқ',
                      style: TextStyle(color: subColor),
                    ),
                  )
                : BarChart(
                    BarChartData(
                      maxY: maxTrend * 1.2,
                      barGroups: barGroups,
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (_) => FlLine(
                          color: isDark
                              ? Colors.white.withOpacity(0.05)
                              : Colors.black.withOpacity(0.05),
                          strokeWidth: 1,
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 24,
                            getTitlesWidget: (value, meta) {
                              final idx = value.toInt();
                              if (idx < 0 || idx >= trendData.length) {
                                return const SizedBox.shrink();
                              }
                              // Show every Nth label depending on data count
                              final step = trendData.length > 20 ? 5 : 1;
                              if (idx % step != 0) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  trendData[idx]['label'] as String,
                                  style: TextStyle(
                                    color: subColor,
                                    fontSize: 9,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          tooltipBgColor: isDark
                              ? const Color(0xFF1E293B)
                              : Colors.white,
                          tooltipRoundedRadius: 10,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            return BarTooltipItem(
                              DebtUtils.formatAmount(
                                  rod.toY, currencyCode),
                              TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // ─── Empty state ─────────────────────────────────────────────────────────────
  Widget _buildEmpty(Color textColor, Color subColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart_rounded,
              size: 72, color: subColor.withOpacity(0.4)),
          const SizedBox(height: 16),
          Text(
            'Деректер жоқ',
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Транзакциялар қосыңыз',
            style: TextStyle(color: subColor, fontSize: 14),
          ),
        ],
      ),
    );
  }

  String _periodTitle(AnalyticsPeriod period) {
    switch (period) {
      case AnalyticsPeriod.week:
        return 'Апта';
      case AnalyticsPeriod.month:
        return 'Ай';
      case AnalyticsPeriod.threeMonths:
        return '3 ай';
      case AnalyticsPeriod.year:
        return 'Жыл';
    }
  }
}

// ─── Period Selector Widget ───────────────────────────────────────────────────
class _PeriodSelector extends StatelessWidget {
  final AnalyticsPeriod selected;
  final ValueChanged<AnalyticsPeriod> onChanged;
  final Color textColor;
  final bool isDark;

  const _PeriodSelector({
    required this.selected,
    required this.onChanged,
    required this.textColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    const periods = [
      (AnalyticsPeriod.week, 'Апта'),
      (AnalyticsPeriod.month, 'Ай'),
      (AnalyticsPeriod.threeMonths, '3 ай'),
      (AnalyticsPeriod.year, 'Жыл'),
    ];

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.06)
            : Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: periods.map((p) {
          final isSelected = selected == p.$1;
          return GestureDetector(
            onTap: () => onChanged(p.$1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF6366F1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                p.$2,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : textColor.withOpacity(0.6),
                  fontSize: 11,
                  fontWeight: isSelected
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Type Toggle Widget ───────────────────────────────────────────────────────
class _TypeToggle extends StatelessWidget {
  final TransactionType selected;
  final ValueChanged<TransactionType> onChanged;
  final bool isDark;

  const _TypeToggle({
    required this.selected,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.06)
            : Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ToggleButton(
              label: 'Шығыс',
              icon: Icons.arrow_upward_rounded,
              isSelected: selected == TransactionType.expense,
              selectedColor: const Color(0xFFEF4444),
              isDark: isDark,
              onTap: () => onChanged(TransactionType.expense),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _ToggleButton(
              label: 'Кіріс',
              icon: Icons.arrow_downward_rounded,
              isSelected: selected == TransactionType.income,
              selectedColor: const Color(0xFF22C55E),
              isDark: isDark,
              onTap: () => onChanged(TransactionType.income),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color selectedColor;
  final bool isDark;
  final VoidCallback onTap;

  const _ToggleButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.selectedColor,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: selectedColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected
                  ? Colors.white
                  : (isDark
                      ? Colors.white.withOpacity(0.5)
                      : Colors.black.withOpacity(0.45)),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : (isDark
                        ? Colors.white.withOpacity(0.5)
                        : Colors.black.withOpacity(0.45)),
                fontWeight:
                    isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Legend Chip ─────────────────────────────────────────────────────────────
class _LegendChip extends StatelessWidget {
  final Color color;
  final String label;
  final double percentage;

  const _LegendChip({
    required this.color,
    required this.label,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '$label ${percentage.toStringAsFixed(0)}%',
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withOpacity(0.7)
                : Colors.black.withOpacity(0.6),
          ),
        ),
      ],
    );
  }
}

// ─── Category Row Widget ──────────────────────────────────────────────────────
class _CategoryRow extends StatelessWidget {
  final CategoryAnalytics item;
  final String currencyCode;
  final Color textColor;
  final Color subColor;
  final Color cardColor;
  final Color borderColor;
  final bool isDark;
  final VoidCallback onTap;

  const _CategoryRow({
    required this.item,
    required this.currencyCode,
    required this.textColor,
    required this.subColor,
    required this.cardColor,
    required this.borderColor,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final catColor = Color(item.colorValue);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: item.imageUrl != null ? null : catColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                image: item.imageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(item.imageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: item.imageUrl != null
                  ? null
                  : Icon(
                      IconData(item.iconCode, fontFamily: 'MaterialIcons'),
                      color: catColor,
                      size: 22,
                    ),
            ),
            const SizedBox(width: 12),
            // Category name + progress bar
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          item.categoryName,
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        DebtUtils.formatAmount(item.amount, currencyCode),
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: item.percentage / 100,
                            minHeight: 5,
                            backgroundColor: catColor.withOpacity(0.12),
                            valueColor:
                                AlwaysStoppedAnimation<Color>(catColor),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${item.percentage.toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: catColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${item.count} операция',
                    style: TextStyle(
                      color: subColor,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              color: subColor.withOpacity(0.5),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
