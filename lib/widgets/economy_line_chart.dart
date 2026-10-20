import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

class EconomyLineChart extends StatelessWidget {
  final List<({DateTime date, double economy})> series;

  const EconomyLineChart({super.key, required this.series});

  @override
  Widget build(BuildContext context) {
    if (series.length < 2) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.show_chart_rounded,
                  color: Colors.white.withOpacity(0.2), size: 40),
              const SizedBox(height: 10),
              Text(
                'Add at least 2 refills to see the trend',
                style: EcoText.body.copyWith(fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final economies = series.map((e) => e.economy).toList();
    final minY = ((economies.reduce((a, b) => a < b ? a : b) * 0.85)
        .clamp(0.0, double.infinity))
        .toDouble();
    final maxY = (economies.reduce((a, b) => a > b ? a : b) * 1.15).toDouble();

    return SizedBox(
      height: 220,
      child: LineChart(
        LineChartData(
          minY: minY,
          maxY: maxY,
          minX: 0,
          maxX: (series.length - 1).toDouble(),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: ((maxY - minY) / 4).clamp(0.1, double.infinity),
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.white.withOpacity(0.06),
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 34,
                interval: ((maxY - minY) / 4).clamp(0.1, double.infinity),
                getTitlesWidget: (value, meta) => Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Text(
                    value.toStringAsFixed(1),
                    style: EcoText.label.copyWith(fontSize: 9),
                    textAlign: TextAlign.right,
                  ),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 26,
                interval: (series.length <= 5)
                    ? 1
                    : (series.length / 4).ceilToDouble(),
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= series.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      DateFormat('d MMM').format(series[idx].date),
                      style: EcoText.label.copyWith(fontSize: 9),
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => EcoColors.bg2,
              tooltipRoundedRadius: 12,
              getTooltipItems: (spots) => spots.map((s) {
                final idx = s.x.toInt();
                return LineTooltipItem(
                  '${DateFormat('d MMM').format(series[idx].date)}\n',
                  EcoText.label.copyWith(fontSize: 10),
                  children: [
                    TextSpan(
                      text: '${s.y.toStringAsFixed(2)} km/L',
                      style: EcoText.bodyStrong.copyWith(fontSize: 13),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(series.length, (i) {
                return FlSpot(i.toDouble(), series[i].economy);
              }),
              isCurved: true,
              curveSmoothness: 0.3,
              gradient: const LinearGradient(
                colors: EcoColors.coolGradient,
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                  radius: 3.5,
                  color: Colors.white,
                  strokeWidth: 2,
                  strokeColor: EcoColors.accentCool1,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    EcoColors.accentCool1.withOpacity(0.25),
                    EcoColors.accentCool1.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}