import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import '../widgets/animated_gradient_bg.dart';
import '../widgets/glass_card.dart';
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
    final hp = size.width * 0.06;

    return Material(
      color: Colors.transparent,
      child: AnimatedGradientBg(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: hp),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ShaderMask(
                    shaderCallback: (b) => const LinearGradient(
                      colors: EcoColors.coolGradient,
                    ).createShader(b),
                    child: Text('EcoTrax', style: EcoText.logo),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.isFirstTime
                        ? 'Add your first car to get started'
                        : 'Add a new car',
                    style: EcoText.body,
                  ),
                  const SizedBox(height: 30),
                  GlassCard(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('CAR DETAILS', style: EcoText.label),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _nameCtrl,
                          style: EcoText.bodyStrong.copyWith(fontSize: 16),
                          decoration: _deco('Car name (e.g. Swift)'),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _modelCtrl,
                          style: EcoText.bodyStrong.copyWith(fontSize: 16),
                          decoration: _deco('Model (e.g. VXi 2019)'),
                        ),
                        const SizedBox(height: 18),

                        Text('FUEL TYPE', style: EcoText.label),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: FuelType.values.map((f) {
                            final selected = f == _fuelType;
                            return GestureDetector(
                              onTap: () =>
                                  setState(() => _fuelType = f),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? EcoColors.accentCool1
                                      .withOpacity(0.2)
                                      : Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: selected
                                        ? EcoColors.accentCool1
                                        : Colors.white.withOpacity(0.12),
                                    width: selected ? 1.5 : 1,
                                  ),
                                ),
                                child: Text(
                                  f.label,
                                  style: EcoText.bodyStrong.copyWith(
                                    fontSize: 12,
                                    color: selected
                                        ? Colors.white
                                        : Colors.white70,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),

                        TextField(
                          controller: _tankCtrl,
                          keyboardType:
                          const TextInputType.numberWithOptions(
                              decimal: true),
                          style: EcoText.bodyStrong.copyWith(fontSize: 16),
                          decoration: _deco('Tank size in L (optional)'),
                        ),
                        const SizedBox(height: 22),

                        GestureDetector(
                          onTap: () => _save(state),
                          child: Container(
                            padding:
                            const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                  colors: EcoColors.coolGradient),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                  EcoColors.accentCool1.withOpacity(0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                widget.isFirstTime
                                    ? 'Get Started'
                                    : 'Add Car',
                                style: EcoText.bodyStrong.copyWith(
                                    fontSize: 15, letterSpacing: 0.4),
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
      ),
    );
  }

  InputDecoration _deco(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: EcoText.body.copyWith(color: Colors.white30),
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.12)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide:
        const BorderSide(color: EcoColors.accentCool1, width: 1.5),
      ),
    );
  }
}