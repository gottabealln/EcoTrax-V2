import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../state/app_state.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import '../widgets/animated_gradient_bg.dart';
import '../models/fuel_entry.dart';
import 'car_setup_screen.dart';

class GraphsScreen extends StatelessWidget {
  const GraphsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final car = state.activeCar;
    if (car == null) return const CarSetupScreen(isFirstTime: true);

    final now = DateTime.now();
    final month = state.summaryForMonth(now.year, now.month);

    return AnimatedGradientBg(
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          physics: const BouncingScrollPhysics(),
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Analytics", style: EcoText.h1.copyWith(fontSize: 28)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.circle, size: 8, color: EcoColors.tertiary),
                        const SizedBox(width: 6),
                        Text("${car.name} · ${car.model}", style: EcoText.label.copyWith(color: EcoColors.onSurfaceVariant)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: EcoColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                          child: Text("PETROL", style: EcoText.label.copyWith(fontSize: 9, color: EcoColors.primary)),
                        )
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(color: EcoColors.bgHigh, borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    children: [
                      const Icon(Icons.directions_car, color: EcoColors.primary, size: 16),
                      const SizedBox(width: 6),
                      Text("Switch", style: EcoText.label.copyWith(fontSize: 11)),
                      const Icon(Icons.expand_more, size: 16, color: EcoColors.outline),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 24),

            // Time Tabs
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: EcoColors.bgLow, borderRadius: BorderRadius.circular(20)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: ["1M", "3M", "6M", "1Y", "All"].map((t) {
                  final isSel = t == "3M";
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSel ? EcoColors.primaryContainer : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(t, style: EcoText.label.copyWith(color: isSel ? EcoColors.onPrimary : EcoColors.onSurfaceVariant)),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // 2x2 Metric Grid
            Row(
              children: [
                Expanded(child: _StatBox(label: "Avg Economy", value: month.avgEconomy.toStringAsFixed(2), unit: "km/L", trend: "+4.2%")),
                const SizedBox(width: 12),
                Expanded(child: _StatBox(label: "Distance", value: month.totalDistance.toStringAsFixed(0), unit: "km", sub: "7 trips logged")),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _StatBox(label: "Fuel Bought", value: month.totalLitres.toStringAsFixed(1), unit: "L", sub: "Regular Petrol")),
                const SizedBox(width: 12),
                Expanded(child: _StatBox(label: "Total Spent", value: "₹${month.totalCost.toStringAsFixed(0)}", unit: "", sub: "₹5.22 / km", isHighlight: true)),
              ],
            ),
            const SizedBox(height: 24),

            // Line Chart Placeholder
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: EcoColors.bgLow, borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.circle, size: 8, color: EcoColors.primaryContainer),
                          const SizedBox(width: 8),
                          Text("Fuel Economy Over Time", style: EcoText.bodyStrong.copyWith(fontSize: 14)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: EcoColors.bgContainer, borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          children: [
                            const Icon(Icons.insights, size: 12, color: EcoColors.tertiary),
                            const SizedBox(width: 4),
                            Text("Peak 20.4", style: EcoText.label.copyWith(fontSize: 10)),
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 150,
                    child: Stack(
                      children: [
                        Positioned.fill(child: CustomPaint(painter: _LineChartPainter())),
                        Positioned(
                          left: MediaQuery.of(context).size.width * 0.45,
                          top: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: EcoColors.bgHighest, borderRadius: BorderRadius.circular(10)),
                            child: Row(
                              children: [
                                const Icon(Icons.circle, size: 6, color: EcoColors.tertiary),
                                const SizedBox(width: 4),
                                Text("20.4 km/L", style: EcoText.label.copyWith(fontSize: 10, color: EcoColors.tertiary)),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: ["Aug 15", "Sep 01", "Sep 15", "Oct 01", "Oct 15"].map((d) => Text(d, style: EcoText.label.copyWith(fontSize: 9, color: EcoColors.outline))).toList(),
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Station Efficiency Bar Chart
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: EcoColors.bgLow, borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.circle, size: 8, color: EcoColors.secondary),
                      const SizedBox(width: 8),
                      Text("Station Efficiency", style: EcoText.bodyStrong.copyWith(fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _BarRow(label: "Nayara Energy", val: 19.8, max: 22, color: const Color(0xFFEA580C), isBest: true),
                  const SizedBox(height: 16),
                  _BarRow(label: "IndianOil", val: 18.4, max: 22, color: const Color(0xFF2563EB)),
                  const SizedBox(height: 16),
                  _BarRow(label: "Jio-bp", val: 18.1, max: 22, color: const Color(0xFF16A34A)),
                  const SizedBox(height: 16),
                  _BarRow(label: "HP Lubricants", val: 17.5, max: 22, color: const Color(0xFF4F46E5)),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

// Helpers
class _StatBox extends StatelessWidget {
  final String label, value, unit;
  final String? sub;
  final String? trend;
  final bool isHighlight;

  const _StatBox({required this.label, required this.value, required this.unit, this.trend, this.sub, this.isHighlight = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: EcoColors.bgLow, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: EcoText.label.copyWith(fontSize: 10, color: EcoColors.onSurfaceVariant)),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: EcoText.mediumNumber.copyWith(fontSize: 22, color: isHighlight ? EcoColors.onSurface : EcoColors.primary)),
              const SizedBox(width: 4),
              Text(unit, style: EcoText.label.copyWith(fontSize: 10)),
            ],
          ),
          const SizedBox(height: 6),
          if (trend != null)
            Text(trend!, style: EcoText.label.copyWith(color: EcoColors.tertiary, fontSize: 10)),
          if (sub != null)
            Text(sub!, style: EcoText.label.copyWith(color: EcoColors.outline, fontSize: 10)),
        ],
      ),
    );
  }
}

class _BarRow extends StatelessWidget {
  final String label; final double val, max; final Color color; final bool isBest;
  const _BarRow({required this.label, required this.val, required this.max, required this.color, this.isBest = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(width: 10, height: 10, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
                const SizedBox(width: 8),
                Text(label, style: EcoText.bodyStrong.copyWith(fontSize: 13)),
                if (isBest) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
                    child: Text("Best", style: EcoText.label.copyWith(fontSize: 9, color: color)),
                  )
                ]
              ],
            ),
            Text("${val} km/L", style: EcoText.bodyStrong.copyWith(fontSize: 13)),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 8, width: double.infinity,
          decoration: BoxDecoration(color: EcoColors.bgLowest, borderRadius: BorderRadius.circular(4)),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: (val / max).clamp(0.0, 1.0),
            child: Container(decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
          ),
        )
      ],
    );
  }
}

class _LineChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.05)..strokeWidth = 1;
    for (int i = 0; i <= 4; i++) {
      canvas.drawLine(Offset(0, size.height * i / 4), Offset(size.width, size.height * i / 4), paint);
    }

    final path = Path()
      ..moveTo(0, size.height * 0.8)
      ..cubicTo(size.width * 0.2, size.height * 0.7, size.width * 0.3, size.height * 0.4, size.width * 0.45, size.height * 0.3)
      ..cubicTo(size.width * 0.6, size.height * 0.2, size.width * 0.7, size.height * 0.6, size.width * 0.8, size.height * 0.55)
      ..cubicTo(size.width * 0.9, size.height * 0.5, size.width * 0.95, size.height * 0.4, size.width, size.height * 0.4);

    final linePaint = Paint()
      ..shader = const LinearGradient(colors: [EcoColors.primaryContainer, EcoColors.tertiary]).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..strokeWidth = 3..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;

    canvas.drawPath(path, linePaint);

    final dotPaint = Paint()..color = EcoColors.bgLowest;
    final ringPaint = Paint()..color = EcoColors.primaryContainer..style = PaintingStyle.stroke..strokeWidth = 2;

    canvas.drawCircle(Offset(size.width * 0.45, size.height * 0.3), 4, dotPaint);
    canvas.drawCircle(Offset(size.width * 0.45, size.height * 0.3), 4, ringPaint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}