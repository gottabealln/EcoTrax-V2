import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../state/app_state.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import '../models/fuel_entry.dart';
import '../models/fuel_station.dart';

class EntryDetailSheet extends StatefulWidget {
  final String entryId;
  const EntryDetailSheet({super.key, required this.entryId});

  @override
  State<EntryDetailSheet> createState() => _EntryDetailSheetState();
}

class _EntryDetailSheetState extends State<EntryDetailSheet> {
  bool _editing = false;

  late TextEditingController _tripCtrl;
  late TextEditingController _litresCtrl;
  late TextEditingController _densityCtrl;
  late TextEditingController _priceCtrl;
  late TextEditingController _notesCtrl;
  late FuelStation _station;
  late TripType _tripType;

  FuelEntry? _entry;

  @override
  void initState() {
    super.initState();
    final state = context.read<AppState>();
    _entry = state.entries.where((e) => e.id == widget.entryId).firstOrNull;
    if (_entry != null) {
      _tripCtrl = TextEditingController(text: _entry!.tripMeter.toString());
      _litresCtrl = TextEditingController(text: _entry!.litres.toString());
      _densityCtrl = TextEditingController(text: _entry!.density.toString());
      _priceCtrl =
          TextEditingController(text: _entry!.pricePerLitre.toString());
      _notesCtrl = TextEditingController(text: _entry!.notes);
      _station = _entry!.station;
      _tripType = _entry!.tripType;
    } else {
      _tripCtrl = TextEditingController();
      _litresCtrl = TextEditingController();
      _densityCtrl = TextEditingController();
      _priceCtrl = TextEditingController();
      _notesCtrl = TextEditingController();
      _station = FuelStation.indianOil;
      _tripType = TripType.mixed;
    }
  }

  @override
  void dispose() {
    _tripCtrl.dispose();
    _litresCtrl.dispose();
    _densityCtrl.dispose();
    _priceCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _save(AppState state) {
    final trip = double.tryParse(_tripCtrl.text);
    final litres = double.tryParse(_litresCtrl.text);
    final density = double.tryParse(_densityCtrl.text) ?? 0.745;
    final price = double.tryParse(_priceCtrl.text) ?? 0;

    if (trip == null || litres == null) return;
    if (trip <= 0 || litres <= 0) return;

    final updated = FuelEntry(
      id: _entry!.id,
      carId: _entry!.carId,
      tripMeter: trip,
      litres: litres,
      density: density,
      pricePerLitre: price,
      station: _station,
      tripType: _tripType,
      notes: _notesCtrl.text.trim(),
      date: _entry!.date,
      distance: _entry!.distance,
      isSkipped: _entry!.isSkipped,
    );

    state.updateRefill(updated);
    Navigator.pop(context);
  }

  void _delete(AppState state) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: EcoColors.bg2,
        title: const Text('Delete Entry',
            style: TextStyle(color: Colors.white)),
        content: const Text('This cannot be undone.',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () {
              state.deleteRefill(_entry!.id);
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Delete',
                style: TextStyle(color: Color(0xFFF5576C))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.read<AppState>();

    if (_entry == null) {
      return const Material(
        color: Colors.transparent,
        child: SizedBox.shrink(),
      );
    }

    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Material(
      color: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        decoration: const BoxDecoration(
          color: EcoColors.bg2,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          border: Border(
            top: BorderSide(color: EcoColors.glassBorder, width: 1),
          ),
        ),
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 12,
          bottom: bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: ShaderMask(
                      shaderCallback: (b) => const LinearGradient(
                        colors: EcoColors.coolGradient,
                      ).createShader(b),
                      child: Text(
                        _editing ? 'Edit Entry' : 'Entry Detail',
                        style: EcoText.h1.copyWith(fontSize: 22),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _editing = !_editing),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.12)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _editing ? Icons.close : Icons.edit,
                            size: 14,
                            color: Colors.white70,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _editing ? 'Cancel' : 'Edit',
                            style: EcoText.label.copyWith(
                                color: Colors.white70, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                DateFormat('EEEE, MMM d, yyyy · h:mm a').format(_entry!.date),
                style: EcoText.body.copyWith(fontSize: 12),
              ),
              const SizedBox(height: 20),

              if (_entry!.isSkipped) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: Colors.orange.withOpacity(0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded,
                          color: Colors.orange, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'This entry was created via "I forgot to log last refill". It anchors the trip meter but is excluded from economy averages.',
                          style: EcoText.body.copyWith(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              if (!_editing) ...[
                _detailRow('Trip Meter',
                    '${_entry!.tripMeter.toStringAsFixed(0)} km'),
                _detailRow('Fuel Amount',
                    '${_entry!.litres.toStringAsFixed(2)} L'),
                _detailRow('Density',
                    '${_entry!.density.toStringAsFixed(3)} kg/L'),
                _detailRow('Price',
                    '₹ ${_entry!.pricePerLitre.toStringAsFixed(2)} / L'),
                _detailRow('Total Cost',
                    '₹ ${_entry!.cost.toStringAsFixed(2)}'),
                _detailRow('Distance',
                    '${_entry!.distance.toStringAsFixed(1)} km'),
                _detailRow(
                  'Economy',
                  _entry!.isSkipped
                      ? '—'
                      : '${_entry!.economy.toStringAsFixed(2)} km/L',
                ),
                _detailRow('Cost / km',
                    _entry!.costPerKm == 0
                        ? '—'
                        : '₹ ${_entry!.costPerKm.toStringAsFixed(2)}'),
                _detailRow('Station', _entry!.station.label),
                _detailRow('Trip Type', _entry!.tripType.label),
                if (_entry!.notes.isNotEmpty)
                  _detailRow('Notes', _entry!.notes),
              ] else ...[
                _InputField(
                    label: 'TRIP METER (KM)', controller: _tripCtrl),
                const SizedBox(height: 12),
                _InputField(
                    label: 'FUEL AMOUNT (LITRES)', controller: _litresCtrl),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _InputField(
                          label: 'DENSITY', controller: _densityCtrl),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _InputField(
                          label: 'PRICE (₹/L)', controller: _priceCtrl),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text('STATION', style: EcoText.label),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: FuelStation.values.map((s) {
                    final selected = s == _station;
                    return GestureDetector(
                      onTap: () => setState(() => _station = s),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: selected
                              ? s.color.withOpacity(0.25)
                              : Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selected
                                ? s.color
                                : Colors.white.withOpacity(0.12),
                          ),
                        ),
                        child: Text(
                          s.label,
                          style: EcoText.bodyStrong.copyWith(
                              fontSize: 12,
                              color:
                              selected ? Colors.white : Colors.white70),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                Text('TRIP TYPE', style: EcoText.label),
                const SizedBox(height: 8),
                Row(
                  children: TripType.values.map((t) {
                    final selected = t == _tripType;
                    return Expanded(
                      child: Padding(
                        padding:
                        EdgeInsets.only(right: t == TripType.mixed ? 0 : 8),
                        child: GestureDetector(
                          onTap: () => setState(() => _tripType = t),
                          child: Container(
                            padding:
                            const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: selected
                                  ? EcoColors.accentCool1.withOpacity(0.2)
                                  : Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: selected
                                    ? EcoColors.accentCool1
                                    : Colors.white.withOpacity(0.12),
                              ),
                            ),
                            child: Center(
                              child: Text(t.label,
                                  style: EcoText.bodyStrong.copyWith(
                                      fontSize: 12)),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                _InputField(label: 'NOTES', controller: _notesCtrl),
              ],

              const SizedBox(height: 24),

              if (_editing)
                GestureDetector(
                  onTap: () => _save(state),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: EcoColors.coolGradient),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text('Save Changes',
                          style: EcoText.bodyStrong
                              .copyWith(fontSize: 15)),
                    ),
                  ),
                )
              else
                GestureDetector(
                  onTap: () => _delete(state),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5576C).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: const Color(0xFFF5576C).withOpacity(0.4)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.delete_outline_rounded,
                            color: Color(0xFFF5576C), size: 18),
                        const SizedBox(width: 8),
                        Text('Delete Entry',
                            style: EcoText.bodyStrong.copyWith(
                                fontSize: 14,
                                color: const Color(0xFFF5576C))),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: EcoText.label),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: EcoText.bodyStrong.copyWith(fontSize: 14),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  const _InputField({required this.label, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: EcoText.label),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: EcoText.bodyStrong.copyWith(fontSize: 14),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withOpacity(0.06),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.12)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                  color: EcoColors.accentCool1, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}