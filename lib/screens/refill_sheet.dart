import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import '../models/fuel_station.dart';
import '../models/fuel_entry.dart';

class RefillSheet extends StatefulWidget {
  const RefillSheet({super.key});
  @override
  State<RefillSheet> createState() => _RefillSheetState();
}

class _RefillSheetState extends State<RefillSheet> {
  final _tripCtrl = TextEditingController();
  final _litresCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _densityCtrl = TextEditingController(text: '0.745');
  final _notesCtrl = TextEditingController();

  FuelStation _station = FuelStation.indianOil;
  TripType _tripType = TripType.mixed;
  double _estTotal = 0;
  double _estEcon = 0;

  @override
  void initState() {
    super.initState();
    _litresCtrl.addListener(_calculate);
    _priceCtrl.addListener(_calculate);
    _tripCtrl.addListener(_calculate);
  }

  void _calculate() {
    final litres = double.tryParse(_litresCtrl.text) ?? 0;
    final price = double.tryParse(_priceCtrl.text) ?? 0;
    final trip = double.tryParse(_tripCtrl.text) ?? 0;

    setState(() {
      _estTotal = litres * price;
      _estEcon = litres > 0 ? (trip / litres) : 0;
    });
  }

  @override
  void dispose() {
    _tripCtrl.dispose(); _litresCtrl.dispose(); _priceCtrl.dispose();
    _densityCtrl.dispose(); _notesCtrl.dispose();
    super.dispose();
  }

  void _submit(AppState state) {
    final trip = double.tryParse(_tripCtrl.text);
    final litres = double.tryParse(_litresCtrl.text);
    if (trip == null || litres == null) return;

    state.addRefill(
      tripMeter: trip, litres: litres,
      density: double.tryParse(_densityCtrl.text) ?? 0.745,
      pricePerLitre: double.tryParse(_priceCtrl.text) ?? 0,
      station: _station, tripType: _tripType, notes: _notesCtrl.text.trim(),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.read<AppState>();

    return Material(
      color: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.95),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 16),
                    width: 48, height: 6,
                    decoration: BoxDecoration(color: EcoColors.outline.withOpacity(0.3), borderRadius: BorderRadius.circular(3)),
                  ),
                ),

                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(color: EcoColors.primaryContainer, shape: BoxShape.circle),
                            child: const Icon(Icons.local_gas_station, color: EcoColors.primary, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Text("Log New Refill", style: EcoText.h1.copyWith(fontSize: 22)),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(color: EcoColors.bgLow, shape: BoxShape.circle),
                          child: const Icon(Icons.close, size: 18, color: EcoColors.onSurface),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Live Calculation Banner
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: EcoColors.bgLow,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("ESTIMATED CYCLE", style: EcoText.label.copyWith(fontSize: 9, color: EcoColors.outline)),
                          const SizedBox(height: 4),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text("₹ ${_estTotal.toStringAsFixed(2)}", style: EcoText.mediumNumber.copyWith(fontSize: 18)),
                              const SizedBox(width: 6),
                              Text("·", style: EcoText.label.copyWith(color: EcoColors.outline)),
                              const SizedBox(width: 6),
                              Text("${_estEcon.toStringAsFixed(2)} km/L", style: EcoText.label.copyWith(color: EcoColors.secondary, fontSize: 13)),
                            ],
                          )
                        ],
                      ),
                      const Icon(Icons.trending_up, size: 24, color: EcoColors.secondary),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 2x2 Grid Inputs
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: _InputBox(label: "TRIP METER", hint: "482.5", suffix: "km", controller: _tripCtrl)),
                          const SizedBox(width: 12),
                          Expanded(child: _InputBox(label: "FUEL FILLED", hint: "26.15", suffix: "L", controller: _litresCtrl)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _InputBox(label: "PRICE RATE", hint: "96.50", suffix: "₹/L", controller: _priceCtrl)),
                          const SizedBox(width: 12),
                          Expanded(child: _InputBox(label: "DENSITY", hint: "0.742", suffix: "kg/L", controller: _densityCtrl)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Station Selector
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text("SELECT FUEL BRAND", style: EcoText.label.copyWith(fontSize: 10, color: EcoColors.outline)),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Wrap(
                    spacing: 12, runSpacing: 12,
                    children: FuelStation.values.map((s) {
                      final isSelected = s == _station;
                      return GestureDetector(
                        onTap: () => setState(() => _station = s),
                        child: Container(
                          width: (MediaQuery.of(context).size.width - 60) / 2,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected ? EcoColors.primaryContainer : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isSelected ? EcoColors.primary : EcoColors.glassBorder),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 20, height: 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected ? EcoColors.primary : EcoColors.bgLow,
                                ),
                                child: Icon(isSelected ? Icons.check : Icons.local_gas_station, size: 12, color: isSelected ? Colors.white : EcoColors.outline),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(s.label, style: EcoText.label.copyWith(color: isSelected ? EcoColors.primary : EcoColors.onSurface, fontSize: 12)),
                              )
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24),

                // Trip Type Selector
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text("TRIP CONDITION", style: EcoText.label.copyWith(fontSize: 10, color: EcoColors.outline)),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: TripType.values.map((t) {
                      final isSelected = t == _tripType;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _tripType = t),
                          child: Container(
                            margin: EdgeInsets.only(right: t == TripType.mixed ? 0 : 8),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected ? EcoColors.secondaryContainer : EcoColors.bgLow,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Icon(_getTripIcon(t), size: 18, color: isSelected ? EcoColors.secondary : EcoColors.outline),
                                const SizedBox(height: 4),
                                Text(t.label, style: EcoText.label.copyWith(color: isSelected ? EcoColors.secondary : EcoColors.onSurfaceVariant, fontSize: 12)),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 32),

                // Save Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: GestureDetector(
                    onTap: () => _submit(state),
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: EcoColors.onSurface,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle, color: EcoColors.primaryContainer, size: 20),
                          const SizedBox(width: 8),
                          Text("Save Refill Entry", style: EcoText.bodyStrong.copyWith(color: Colors.white, fontSize: 15)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getTripIcon(TripType t) {
    switch(t) {
      case TripType.city: return Icons.location_city;
      case TripType.highway: return Icons.route;
      case TripType.mixed: return Icons.tune;
    }
  }
}

class _InputBox extends StatelessWidget {
  final String label, hint, suffix;
  final TextEditingController controller;

  const _InputBox({required this.label, required this.hint, required this.suffix, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: EcoText.label.copyWith(fontSize: 10, color: EcoColors.outline)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(color: EcoColors.bgLow, borderRadius: BorderRadius.circular(12)),
          child: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: EcoText.mediumNumber.copyWith(
              fontSize: 16,
              color: EcoColors.onSurface, // 👈 Explicit dark text
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: EcoText.body.copyWith(color: EcoColors.outline.withOpacity(0.4)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              suffixIcon: Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: EcoColors.bgHighest, borderRadius: BorderRadius.circular(4)),
                child: Text(suffix, style: EcoText.label.copyWith(fontSize: 10, color: EcoColors.onSurfaceVariant)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}