import 'package:flutter/material.dart';
import '../models/fuel_station.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

class StationBarChart extends StatelessWidget {
  final Map<FuelStation, double> averages;

  const StationBarChart({super.key, required this.averages});

  @override
  Widget build(BuildContext context) {
    if (averages.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.bar_chart_rounded,
                  color: Colors.white.withOpacity(0.2), size: 40),
              const SizedBox(height: 10),
              Text(
                'No station data yet',
                style: EcoText.body.copyWith(fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    final maxAvg = averages.values.reduce((a, b) => a > b ? a : b);
    final sorted = averages.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: sorted.map((e) {
        final ratio = maxAvg == 0 ? 0.0 : e.value / maxAvg;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              SizedBox(
                width: 70,
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: e.key.color,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        e.key.label,
                        style: EcoText.bodyStrong.copyWith(fontSize: 11),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
                      children: [
                        Container(
                          height: 22,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.04),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeOutCubic,
                          width: constraints.maxWidth * ratio,
                          height: 22,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                e.key.color.withOpacity(0.9),
                                e.key.color.withOpacity(0.5),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 50,
                child: Text(
                  e.value.toStringAsFixed(2),
                  style: EcoText.bodyStrong.copyWith(fontSize: 12),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}