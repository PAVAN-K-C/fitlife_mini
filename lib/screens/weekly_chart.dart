import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../services/database_service.dart';

class WeeklyChart extends StatefulWidget {
  const WeeklyChart({Key? key}) : super(key: key);

  @override
  State<WeeklyChart> createState() => _WeeklyChartState();
}

class _WeeklyChartState extends State<WeeklyChart> {
  final DatabaseService _databaseService = DatabaseService();
  Map<int, int> _weeklyData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWeeklyData();
  }

  Future<void> _loadWeeklyData() async {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));

    Map<int, int> data = {};

    for (int i = 0; i < 7; i++) {
      final day = weekStart.add(Duration(days: i));
      final workouts = await _databaseService.getWorkoutsByDate(day);
      final totalCalories = workouts.fold<int>(
        0,
            (sum, workout) => sum + workout.caloriesBurned,
      );
      data[i] = totalCalories;
    }

    setState(() {
      _weeklyData = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final maxCalories = _weeklyData.values.isEmpty
        ? 1
        : _weeklyData.values.reduce((a, b) => a > b ? a : b);

    if (maxCalories == 0) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        child: const Text('No activity recorded'),
      );
    }

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    final currentWeekday = now.weekday - 1;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxCalories.toDouble() * 1.2,
        minY: 0,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${rod.toY.round()} kcal',
                TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                final index = value.toInt();
                if (index >= 0 && index < labels.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      labels[index],
                      style: TextStyle(
                        color: isDarkMode ? Colors.white70 : Colors.black87,
                        fontWeight: index == currentWeekday
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: 12,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: TextStyle(
                    color: isDarkMode ? Colors.white70 : Colors.black87,
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxCalories / 5,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: isDarkMode ? Colors.white10 : Colors.black12,
              strokeWidth: 1,
            );
          },
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(7, (index) {
          final calories = _weeklyData[index] ?? 0;
          final isToday = index == currentWeekday;

          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: calories.toDouble(),
                color: isToday
                    ? Colors.blue.shade700
                    : (isDarkMode ? Colors.blue.shade300 : Colors.blue.shade400),
                width: 16,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
