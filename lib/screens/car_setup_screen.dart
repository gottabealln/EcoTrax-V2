import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import '../models/car.dart';

class CarSetupScreen extends StatefulWidget {
  final bool isFirstTime;
  const CarSetupScreen({super.key, this.isFirstTime = false});

  @override
  State<CarSetupScreen> createState() => _CarSetupScreenState();
}

class _CarSetupScreenState extends State<CarSetupScreen> {
  final _nameCtrl = TextEditingController();
  final _modelCtrl = TextEditingController();
  final _tankCtrl = TextEditingController();
  FuelType _fuelType = FuelType.petrol;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _modelCtrl.dispose();
    _tankCtrl.dispose();
    super.dispose();
  }

  void _save(AppState state) async {
    final name = _nameCtrl.text.trim();
    final model = _modelCtrl.text.trim();
    if (name.isEmpty || model.isEmpty) return;

    final tank = double.tryParse(_tankCtrl.text) ?? 0;

    await state.addCar(
      name,
      model,
      fuelType: _fuelType,
      tankSize: tank,
    );

    if (mounted) {
      Navigator.of(context).popUntil((r) => r.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.read<AppState>();
    final size = MediaQuery.of(context).size;
    final hp = size.width * 0.08;

    return Scaffold(
      backgroundColor: EcoColors.bgLowest,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: hp, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('EcoTrax', style: EcoText.h1.copyWith(color: EcoColors.primary, fontSize: 32)),
                const SizedBox(height: 8),
                Text(
                  widget.isFirstTime
                      ? 'Add your first car to get started'
                      : 'Add a new car',
                  style: EcoText.body.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 32),

                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: EcoColors.glassBorder),
                    boxShadow: [
                      BoxShadow(
                        color: EcoColors.onSurface.withOpacity(0.04),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('CAR DETAILS', style: EcoText.label.copyWith(fontSize: 10)),
                      const SizedBox(height: 16),

                      _inputField('Car Name', _nameCtrl, 'e.g. Swift'),
                      const SizedBox(height: 16),

                      _inputField('Model', _modelCtrl, 'e.g. VXi 2019'),
                      const SizedBox(height: 20),

                      Text('FUEL TYPE', style: EcoText.label.copyWith(fontSize: 10)),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: FuelType.values.map((f) {
                          final selected = f == _fuelType;
                          return GestureDetector(
                            onTap: () => setState(() => _fuelType = f),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: selected ? EcoColors.primaryContainer : EcoColors.bgLow,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: selected ? EcoColors.primary : Colors.transparent,
                                  width: 1.5,
                                ),
                              ),
                              child: Text(
                                f.label,
                                style: EcoText.bodyStrong.copyWith(
                                  fontSize: 13,
                                  color: selected ? EcoColors.primary : EcoColors.onSurfaceVariant,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),

                      _inputField('Tank Size (optional)', _tankCtrl, 'e.g. 42'),
                      const SizedBox(height: 32),

                      GestureDetector(
                        onTap: () => _save(state),
                        child: Container(
                          height: 52,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: EcoColors.primary,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Text(
                              widget.isFirstTime ? 'Get Started' : 'Add Car',
                              style: EcoText.bodyStrong.copyWith(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputField(String label, TextEditingController controller, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: EcoText.label.copyWith(fontSize: 10)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: EcoText.bodyStrong.copyWith(
            fontSize: 16,
            color: EcoColors.onSurface, // 👈 Forces dark text
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: EcoText.body.copyWith(color: EcoColors.outline.withOpacity(0.5)),
            filled: true,
            fillColor: EcoColors.bgLow,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: EcoColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}