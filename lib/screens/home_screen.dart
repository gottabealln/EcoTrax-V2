import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../state/app_state.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import '../widgets/animated_gradient_bg.dart';
import 'car_setup_screen.dart';
import 'car_switcher_sheet.dart';
import 'refill_sheet.dart';
import 'entry_detail_sheet.dart';
import 'forgot_reset_sheet.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final car = state.activeCar;

    if (car == null) return const CarSetupScreen(isFirstTime: true);

    return AnimatedGradientBg(
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          physics: const BouncingScrollPhysics(),
          children: [
            // --- Vehicle Header ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text("${car.name} · ${car.model}", style: EcoText.h1.copyWith(color: EcoColors.primary)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: EcoColors.bgContainer, borderRadius: BorderRadius.circular(10)),
                          child: Text("2019", style: EcoText.label.copyWith(fontSize: 10)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.speed, size: 14, color: EcoColors.tertiary),
                        const SizedBox(width: 4),
                        Text("${state.lastTripMeter.toStringAsFixed(0)} km", style: EcoText.label.copyWith(color: EcoColors.onSurface)),
                        const SizedBox(width: 8),
                        Container(width: 3, height: 3, decoration: const BoxDecoration(shape: BoxShape.circle, color: EcoColors.outline)),
                        const SizedBox(width: 8),
                        const Icon(Icons.circle, size: 6, color: EcoColors.tertiary),
                        const SizedBox(width: 4),
                        Text("Active Profile", style: EcoText.label.copyWith(color: EcoColors.tertiary, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => const CarSwitcherSheet(),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: EcoColors.bgHigh,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.swap_horiz, color: EcoColors.primary, size: 16),
                        const SizedBox(width: 6),
                        Text("Change", style: EcoText.label.copyWith(color: EcoColors.onSurface)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // --- Action Buttons ---
            GestureDetector(
              onTap: () => _openRefill(context),
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: EcoColors.primaryContainer,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(color: EcoColors.primaryContainer.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8)),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.local_gas_station, color: EcoColors.onPrimary, size: 24),
                    const SizedBox(width: 8),
                    Text("Refill Now", style: EcoText.h2.copyWith(color: EcoColors.onPrimary)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => showModalBottomSheet(
                  context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (_) => const ForgotResetSheet()),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: EcoColors.bgLow.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.history, color: EcoColors.secondary, size: 18),
                    const SizedBox(width: 8),
                    Text("I forgot to log last refill", style: EcoText.label.copyWith(color: EcoColors.onSurfaceVariant)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // --- 2x2 Metric Grid ---
            Row(
              children: [
                Expanded(child: _MetricCard(
                  label: "Average",
                  value: state.overallAverage == 0 ? "0.00" : state.overallAverage.toStringAsFixed(2),
                  icon: Icons.auto_graph,
                  iconColor: EcoColors.primary,
                  trendText: "+0.8 vs last mo",
                  trendColor: EcoColors.tertiary,
                )),
                const SizedBox(width: 12),
                Expanded(child: _MetricCard(
                  label: "Last Refill",
                  value: state.lastEconomy == 0 ? "0.00" : state.lastEconomy.toStringAsFixed(2),
                  icon: Icons.eco,
                  iconColor: EcoColors.secondary,
                  trendText: "Efficient",
                  trendColor: EcoColors.secondary,
                )),
              ],
            ),
            const SizedBox(height: 24),

            // --- Insights ---
            Text("VEHICLE DIAGNOSTICS & COST", style: EcoText.label.copyWith(fontSize: 10, color: EcoColors.onSurfaceVariant)),
            const SizedBox(height: 12),

            _InsightRow(
              icon: Icons.currency_rupee,
              iconColor: EcoColors.secondary,
              iconBg: EcoColors.secondaryContainer.withOpacity(0.3),
              title: "Cost per KM",
              value: "₹ ${state.costPerKm.toStringAsFixed(2)} / km",
              subtitle: "Total spent: ₹ ${state.totalFuelSpend.toStringAsFixed(0)}",
            ),
            const SizedBox(height: 8),
            _InsightRow(
              icon: Icons.local_gas_station,
              iconColor: EcoColors.primary,
              iconBg: EcoColors.primaryContainer.withOpacity(0.2),
              title: "Best Fuel Station",
              value: state.bestStation != null ? "${state.bestStation!.station.label} · ${state.bestStation!.avg.toStringAsFixed(1)} km/L" : "Not enough data",
              subtitle: "Top Rank",
              isBadge: true,
            ),
            const SizedBox(height: 8),
            _InsightRow(
              icon: Icons.opacity,
              iconColor: EcoColors.tertiary,
              iconBg: EcoColors.tertiaryContainer.withOpacity(0.2),
              title: "Best Density",
              value: state.bestDensity != null ? "${state.bestDensity!.density.toStringAsFixed(3)} kg/L" : "Not enough data",
              subtitle: "Optimal combustion",
            ),
            const SizedBox(height: 24),

            // --- Recent Refills ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("RECENT REFILLS", style: EcoText.label.copyWith(fontSize: 10, color: EcoColors.onSurfaceVariant)),
                Row(
                  children: [
                    const Icon(Icons.download, size: 14, color: EcoColors.primary),
                    const SizedBox(width: 4),
                    Text("Export CSV", style: EcoText.label.copyWith(color: EcoColors.primary)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            ...state.recentEntries.take(3).map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: () => showModalBottomSheet(
                    context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (_) => EntryDetailSheet(entryId: e.id)),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: EcoColors.bgLow.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(color: e.station.color.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                        alignment: Alignment.center,
                        child: Text(e.station.label.substring(0, 2).toUpperCase(), style: EcoText.label.copyWith(color: e.station.color, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(e.station.label, style: EcoText.bodyStrong.copyWith(fontSize: 15)),
                            Text("${DateFormat('dd MMM yyyy').format(e.date)} · ${e.litres} L", style: EcoText.label.copyWith(fontSize: 11, color: EcoColors.onSurfaceVariant)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text("${e.economy.toStringAsFixed(2)}", style: EcoText.h2.copyWith(color: EcoColors.primary, fontSize: 18)),
                          Text("km/L", style: EcoText.label.copyWith(fontSize: 10)),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            )),

            const SizedBox(height: 100), // Padding for bottom nav
          ],
        ),
      ),
    );
  }

  void _openRefill(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const RefillSheet(),
    );
  }
}

// --- Helper Widgets ---

class _MetricCard extends StatelessWidget {
  final String label, value, trendText;
  final IconData icon;
  final Color iconColor, trendColor;

  const _MetricCard({
    required this.label, required this.value, required this.icon,
    required this.iconColor, required this.trendText, required this.trendColor
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: EcoColors.bgLow.withOpacity(0.8), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label.toUpperCase(), style: EcoText.label.copyWith(fontSize: 10, color: EcoColors.onSurfaceVariant)),
              Icon(icon, size: 18, color: iconColor),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: EcoText.mediumNumber.copyWith(color: iconColor)),
              const SizedBox(width: 4),
              Text("km/L", style: EcoText.label.copyWith(fontSize: 10)),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(color: trendColor.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.arrow_upward, size: 12, color: trendColor),
                const SizedBox(width: 4),
                Text(trendText, style: EcoText.label.copyWith(fontSize: 10, color: trendColor)),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _InsightRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor, iconBg;
  final String title, value, subtitle;
  final bool isBadge;

  const _InsightRow({
    required this.icon, required this.iconColor, required this.iconBg,
    required this.title, required this.value, required this.subtitle, this.isBadge = false
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: EcoColors.bgContainer.withOpacity(0.7), borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title.toUpperCase(), style: EcoText.label.copyWith(fontSize: 10, color: EcoColors.onSurfaceVariant)),
                const SizedBox(height: 2),
                Text(value, style: EcoText.bodyStrong.copyWith(fontSize: 15)),
                const SizedBox(height: 2),
                Text(subtitle, style: EcoText.label.copyWith(fontSize: 11, color: isBadge ? EcoColors.primary : EcoColors.outline)),
              ],
            ),
          ),
          if (isBadge)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: EcoColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Text("Top Rank", style: EcoText.label.copyWith(fontSize: 10, color: EcoColors.primary)),
            )
          else
            const Icon(Icons.chevron_right, color: EcoColors.outline, size: 20),
        ],
      ),
    );
  }
}