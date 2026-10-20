import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../state/app_state.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
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

    return Scaffold(
      backgroundColor: EcoColors.bgLowest,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          physics: const BouncingScrollPhysics(),
          children: [
            // --- Header ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: EcoColors.onSurface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.eco, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("EcoTrax", style: EcoText.h2.copyWith(fontSize: 18)),
                        Row(
                          children: [
                            const Icon(Icons.circle, size: 6, color: EcoColors.secondary),
                            const SizedBox(width: 4),
                            Text("LIVE TELEMETRY", style: EcoText.label.copyWith(fontSize: 9)),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => showModalBottomSheet(
                      context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (_) => const CarSwitcherSheet()),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: EcoColors.glassBorder),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.directions_car, color: EcoColors.primary, size: 16),
                        const SizedBox(width: 6),
                        Text("${car.name} · ${car.model}", style: EcoText.label.copyWith(color: EcoColors.onSurface, fontSize: 12)),
                        const SizedBox(width: 4),
                        const Icon(Icons.unfold_more, size: 14, color: EcoColors.outline),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // --- Badge Strip ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6), border: Border.all(color: EcoColors.glassBorder)),
                      child: Text("2024 Petrol", style: EcoText.label.copyWith(fontSize: 10, color: EcoColors.onSurface)),
                    ),
                    const SizedBox(width: 8),
                    Text("•", style: EcoText.label.copyWith(color: EcoColors.outline)),
                    const SizedBox(width: 8),
                    Text("${state.lastTripMeter.toStringAsFixed(0)} KM", style: EcoText.label.copyWith(fontSize: 11, color: EcoColors.onSurface)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: EcoColors.secondaryContainer, borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      const Icon(Icons.circle, size: 6, color: EcoColors.secondary),
                      const SizedBox(width: 6),
                      Text("OPTIMAL TUNE", style: EcoText.label.copyWith(fontSize: 9, color: EcoColors.secondary)),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 20),

            // --- Hero Economy Card ---
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: EcoColors.glassBorder),
                boxShadow: [BoxShadow(color: EcoColors.onSurface.withOpacity(0.04), blurRadius: 24, offset: const Offset(0, 8))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text("LIFETIME EFFICIENCY", style: EcoText.label.copyWith(fontSize: 10, color: EcoColors.onSurfaceVariant)),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: EcoColors.primaryContainer, borderRadius: BorderRadius.circular(4)),
                                child: Text("VALIDATED", style: EcoText.label.copyWith(fontSize: 8, color: EcoColors.primary)),
                              )
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(state.overallAverage == 0 ? "0.00" : state.overallAverage.toStringAsFixed(2), style: EcoText.mediumNumber.copyWith(fontSize: 44, fontWeight: FontWeight.w800)),
                              const SizedBox(width: 6),
                              Text("km/L", style: EcoText.bodyStrong.copyWith(color: EcoColors.onSurfaceVariant)),
                            ],
                          )
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text("LAST REFILL", style: EcoText.label.copyWith(fontSize: 10, color: EcoColors.onSurfaceVariant)),
                          const SizedBox(height: 4),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(state.lastEconomy == 0 ? "0.00" : state.lastEconomy.toStringAsFixed(2), style: EcoText.mediumNumber.copyWith(fontSize: 24, color: EcoColors.secondary)),
                              const SizedBox(width: 4),
                              Text("km/L", style: EcoText.label.copyWith(fontSize: 10)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.trending_up, size: 14, color: EcoColors.secondary),
                              const SizedBox(width: 2),
                              Text("+9.1%", style: EcoText.label.copyWith(fontSize: 10, color: EcoColors.secondary)),
                            ],
                          )
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 20),
                  Divider(color: EcoColors.glassBorder, height: 1),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: EcoColors.secondaryContainer, borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          children: [
                            const Icon(Icons.north_east, size: 12, color: EcoColors.secondary),
                            const SizedBox(width: 4),
                            Text("+1.2 vs last month", style: EcoText.label.copyWith(fontSize: 10, color: EcoColors.secondary)),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Text("Range: ", style: EcoText.label.copyWith(fontSize: 11)),
                          Text("598 km", style: EcoText.label.copyWith(fontSize: 12, color: EcoColors.onSurface, fontWeight: FontWeight.bold)),
                        ],
                      )
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 16),

            // --- Dual CTA Actions ---
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: GestureDetector(
                    onTap: () => _openRefill(context),
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(color: EcoColors.onSurface, borderRadius: BorderRadius.circular(14)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.local_gas_station, color: EcoColors.primaryContainer, size: 20),
                          const SizedBox(width: 8),
                          Text("Log Refill", style: EcoText.bodyStrong.copyWith(color: Colors.white, fontSize: 14)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: GestureDetector(
                    onTap: () => showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (_) => const ForgotResetSheet()),
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: EcoColors.glassBorder)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.history_toggle_off, color: EcoColors.outline, size: 18),
                          const SizedBox(width: 6),
                          Text("Forgot to log", style: EcoText.bodyStrong.copyWith(color: EcoColors.onSurface, fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // --- Diagnostics Grid ---
            Text("PRECISION DIAGNOSTICS", style: EcoText.label.copyWith(fontSize: 10)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _DiagCard(title: "COST / KM", value: "₹${state.costPerKm.toStringAsFixed(2)}", sub: "₹4,200 this cycle", icon: Icons.currency_rupee, iconColor: EcoColors.onSurface, iconBg: EcoColors.bgLow, trend: "-₹0.32", isMint: true)),
                const SizedBox(width: 12),
                Expanded(child: _DiagCard(
                    title: "TOP STATION",
                    value: state.bestStation?.station.label ?? "N/A",
                    sub: "${state.bestStation?.avg.toStringAsFixed(1) ?? '0'} km/L avg",
                    icon: Icons.verified, iconColor: EcoColors.primary, iconBg: EcoColors.primaryContainer,
                    isTextValue: true
                )),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _DiagCard(title: "DENSITY", value: state.bestDensity?.density.toStringAsFixed(3) ?? "0.745", sub: "kg/L (Euro VI)", icon: Icons.science, iconColor: EcoColors.secondary, iconBg: EcoColors.secondaryContainer)),
                const SizedBox(width: 12),
                Expanded(child: _DiagCard(title: "TANK RANGE", value: "598", sub: "approx 32.5 L left", icon: Icons.navigation, iconColor: EcoColors.onSurface, iconBg: EcoColors.bgLow, suffix: "km")),
              ],
            ),
            const SizedBox(height: 28),

            // --- Editorial List ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("REFILL LOG", style: EcoText.label.copyWith(fontSize: 10)),
                Row(
                  children: [
                    const Icon(Icons.file_download, size: 14, color: EcoColors.primary),
                    const SizedBox(width: 4),
                    Text("Export CSV", style: EcoText.label.copyWith(color: EcoColors.primary, fontSize: 11)),
                  ],
                )
              ],
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: EcoColors.glassBorder)),
              child: Column(
                children: state.recentEntries.take(3).map((e) => Column(
                  children: [
                    ListTile(
                      onTap: () => showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (_) => EntryDetailSheet(entryId: e.id)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(color: e.station.color.withOpacity(0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: e.station.color.withOpacity(0.2))),
                        alignment: Alignment.center,
                        child: Text(e.station.label.substring(0, 2).toUpperCase(), style: EcoText.label.copyWith(color: e.station.color, fontSize: 10)),
                      ),
                      title: Text(e.station.label, style: EcoText.bodyStrong.copyWith(fontSize: 14)),
                      subtitle: Text("${DateFormat('dd MMM').format(e.date)} · ${e.litres} L · ₹${e.pricePerLitre}/L", style: EcoText.label.copyWith(fontSize: 11, color: EcoColors.onSurfaceVariant)),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text("${e.economy.toStringAsFixed(2)}", style: EcoText.mediumNumber.copyWith(fontSize: 16, color: EcoColors.onSurface)),
                          Text("km/L", style: EcoText.label.copyWith(fontSize: 9)),
                        ],
                      ),
                    ),
                    if (e != state.recentEntries.take(3).last) Divider(height: 1, color: EcoColors.glassBorder),
                  ],
                )).toList(),
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  void _openRefill(BuildContext context) {
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (_) => const RefillSheet());
  }
}

// --- Helper Widgets ---

class _DiagCard extends StatelessWidget {
  final String title, value, sub;
  final IconData icon;
  final Color iconColor, iconBg;
  final String? trend, suffix;
  final bool isMint, isTextValue;

  const _DiagCard({
    required this.title, required this.value, required this.sub,
    required this.icon, required this.iconColor, required this.iconBg,
    this.trend, this.suffix, this.isMint = false, this.isTextValue = false
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: EcoColors.glassBorder)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: EcoText.label.copyWith(fontSize: 9, color: EcoColors.onSurfaceVariant)),
              Container(
                width: 24, height: 24,
                decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(6)),
                child: Icon(icon, size: 14, color: iconColor),
              )
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(
                  value,
                  style: isTextValue
                      ? EcoText.bodyStrong.copyWith(fontSize: 16)
                      : EcoText.mediumNumber.copyWith(fontSize: 20),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (suffix != null) ...[
                const SizedBox(width: 4),
                Text(suffix!, style: EcoText.label.copyWith(fontSize: 10)),
              ]
            ],
          ),
          const SizedBox(height: 4),
          Text(sub, style: EcoText.label.copyWith(fontSize: 10, color: isMint ? EcoColors.secondary : EcoColors.outline)),
          if (trend != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.arrow_downward, size: 12, color: EcoColors.secondary),
                const SizedBox(width: 4),
                Text(trend!, style: EcoText.label.copyWith(fontSize: 10, color: EcoColors.secondary)),
              ],
            )
          ]
        ],
      ),
    );
  }
}