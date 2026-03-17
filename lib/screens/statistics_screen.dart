import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/translations.dart';
import '../theme/app_theme.dart';
import '../providers/app_state.dart';
import '../models/models.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final expenses = appState.expenses;

    if (expenses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bar_chart, size: 64, color: AppTheme.textSecondary),
            const SizedBox(height: 16),
            Text(context.tr('no_items_found'), style: const TextStyle(color: AppTheme.textSecondary, fontStyle: FontStyle.italic)),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 900) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildCategoryCard(context, expenses)),
                    const SizedBox(width: 24),
                    Expanded(child: _buildDaysSpendingCard(context, expenses)),
                  ],
                );
              } else {
                return Column(
                  children: [
                    _buildCategoryCard(context, expenses),
                    const SizedBox(height: 24),
                    _buildDaysSpendingCard(context, expenses),
                  ],
                );
              }
            },
          ),
          const SizedBox(height: 24),
          _buildSpendingByStoreCard(context, expenses),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, List<Expense> expenses) {
    Map<String, double> categorySums = {};
    for (var e in expenses) {
      categorySums[e.category] = (categorySums[e.category] ?? 0) + e.amount;
    }

    final colors = [AppTheme.indigo, AppTheme.emerald, AppTheme.rose, AppTheme.amber, AppTheme.skyBlue];
    int colorIndex = 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Spending by Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 32),
            SizedBox(
              height: 250,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 60,
                      sections: categorySums.entries.map((entry) {
                        final color = colors[colorIndex++ % colors.length];
                        return PieChartSectionData(
                          color: color,
                          value: entry.value,
                          title: '',
                          radius: 30,
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            ...categorySums.entries.map((entry) {
              final color = colors[categorySums.keys.toList().indexOf(entry.key) % colors.length];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Text('${entry.key}: \$${entry.value.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDaysSpendingCard(BuildContext context, List<Expense> expenses) {
    // Last 7 days
    Map<int, double> dailySums = {};
    DateTime now = DateTime.now();
    for (int i = 0; i < 7; i++) {
      DateTime day = now.subtract(Duration(days: 6 - i));
      dailySums[i] = expenses
          .where((e) => e.date.year == day.year && e.date.month == day.month && e.date.day == day.day)
          .fold(0.0, (sum, e) => sum + e.amount);
    }

    double maxY = dailySums.values.fold(100.0, (prev, curr) => curr > prev ? curr : prev) * 1.2;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Last 7 Days Spending', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 32),
            SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxY,
                  barTouchData: BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          DateTime day = now.subtract(Duration(days: 6 - value.toInt()));
                          return SideTitleWidget(meta: meta, child: Text(DateFormat('E').format(day), style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10)));
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (v, m) => SideTitleWidget(meta: m, child: Text(v.toInt().toString(), style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10))),
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: maxY / 4),
                  borderData: FlBorderData(show: false),
                  barGroups: dailySums.entries.map((entry) => BarChartGroupData(
                    x: entry.key,
                    barRods: [BarChartRodData(toY: entry.value, color: AppTheme.indigo, width: 20, borderRadius: BorderRadius.circular(4))],
                  )).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpendingByStoreCard(BuildContext context, List<Expense> expenses) {
    Map<String, double> storeSums = {};
    for (var e in expenses) {
      if (e.storeName != null) {
        storeSums[e.storeName!] = (storeSums[e.storeName!] ?? 0) + e.amount;
      }
    }

    if (storeSums.isEmpty) return const SizedBox.shrink();

    double maxVal = storeSums.values.fold(1.0, (p, c) => c > p ? c : p);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Spending by Store', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 32),
            ...storeSums.entries.map((entry) => _buildStoreBar(entry.key, entry.value / maxVal, entry.value)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreBar(String name, double factor, double amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12), textAlign: TextAlign.right),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Row(
                  children: [
                    Container(
                      height: 20,
                      width: (constraints.maxWidth - 60) * factor,
                      decoration: BoxDecoration(color: AppTheme.emerald, borderRadius: BorderRadius.circular(4)),
                    ),
                    const SizedBox(width: 8),
                    Text('\$${amount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

