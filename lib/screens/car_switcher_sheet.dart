import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import '../models/car.dart';
import 'car_setup_screen.dart';

class CarSwitcherSheet extends StatelessWidget {
  const CarSwitcherSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Material(
      color: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        decoration: const BoxDecoration(
          color: EcoColors.bg2,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          border: Border(
            top: BorderSide(color: EcoColors.glassBorder, width: 1),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
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
              ShaderMask(
                shaderCallback: (b) => const LinearGradient(
                  colors: EcoColors.coolGradient,
                ).createShader(b),
                child: Text('Your Cars',
                    style: EcoText.h1.copyWith(fontSize: 22)),
              ),
              const SizedBox(height: 6),
              Text('Tap to switch · long-press to edit',
                  style: EcoText.body.copyWith(fontSize: 13)),
              const SizedBox(height: 18),

              ...state.cars.map((car) {
                final isActive = car.id == state.activeCarId;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: GestureDetector(
                    onTap: () async {
                      await state.setActiveCar(car.id);
                      if (context.mounted) Navigator.pop(context);
                    },
                    onLongPress: () => _showOptions(context, state, car),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isActive
                            ? EcoColors.accentCool1.withOpacity(0.15)
                            : Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isActive
                              ? EcoColors.accentCool1
                              : Colors.white.withOpacity(0.1),
                          width: isActive ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              gradient: isActive
                                  ? const LinearGradient(
                                  colors: EcoColors.coolGradient)
                                  : null,
                              color: isActive
                                  ? null
                                  : Colors.white.withOpacity(0.06),
                            ),
                            child: Icon(
                              Icons.directions_car_rounded,
                              color:
                              isActive ? Colors.white : Colors.white60,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(car.name,
                                    style: EcoText.bodyStrong
                                        .copyWith(fontSize: 16)),
                                const SizedBox(height: 2),
                                Text(
                                  '${car.model} · ${car.fuelType.label}',
                                  style: EcoText.body.copyWith(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          if (isActive)
                            const Icon(Icons.check_circle_rounded,
                                color: EcoColors.accentCool1, size: 22),
                        ],
                      ),
                    ),
                  ),
                );
              }),

              const SizedBox(height: 6),

              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                      const CarSetupScreen(isFirstTime: false),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.15),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_rounded,
                          color: Colors.white70, size: 20),
                      const SizedBox(width: 8),
                      Text('Add New Car',
                          style: EcoText.bodyStrong
                              .copyWith(color: Colors.white70)),
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

  // ---------------- Options (edit / delete) ----------------

  void _showOptions(BuildContext context, AppState state, Car car) {
    showModalBottomSheet(
      context: context,
      backgroundColor: EcoColors.bg2,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_rounded,
                  color: EcoColors.accentCool1),
              title: Text('Edit "${car.name}"', style: EcoText.bodyStrong),
              onTap: () {
                Navigator.pop(ctx);
                _editCar(context, state, car);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded,
                  color: Color(0xFFF5576C)),
              title: Text('Delete "${car.name}"',
                  style: EcoText.bodyStrong
                      .copyWith(color: const Color(0xFFF5576C))),
              onTap: () {
                Navigator.pop(ctx);
                _confirmDelete(context, state, car);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- Edit car ----------------

  void _editCar(BuildContext context, AppState state, Car car) {
    final nameCtrl = TextEditingController(text: car.name);
    final modelCtrl = TextEditingController(text: car.model);
    final tankCtrl =
    TextEditingController(text: car.tankSize.toString());
    FuelType selectedFuel = car.fuelType;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: EcoColors.bg2,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShaderMask(
                  shaderCallback: (b) => const LinearGradient(
                    colors: EcoColors.coolGradient,
                  ).createShader(b),
                  child: Text('Edit Car',
                      style: EcoText.h1.copyWith(fontSize: 20)),
                ),
                const SizedBox(height: 20),

                Text('CAR NAME', style: EcoText.label),
                const SizedBox(height: 8),
                TextField(
                  controller: nameCtrl,
                  style: EcoText.bodyStrong.copyWith(fontSize: 15),
                  decoration: _deco('Car name'),
                ),
                const SizedBox(height: 14),

                Text('MODEL', style: EcoText.label),
                const SizedBox(height: 8),
                TextField(
                  controller: modelCtrl,
                  style: EcoText.bodyStrong.copyWith(fontSize: 15),
                  decoration: _deco('Model'),
                ),
                const SizedBox(height: 14),

                Text('FUEL TYPE', style: EcoText.label),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: FuelType.values.map((f) {
                    final sel = f == selectedFuel;
                    return GestureDetector(
                      onTap: () => setLocal(() => selectedFuel = f),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: sel
                              ? EcoColors.accentCool1.withOpacity(0.2)
                              : Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: sel
                                ? EcoColors.accentCool1
                                : Colors.white.withOpacity(0.12),
                            width: sel ? 1.5 : 1,
                          ),
                        ),
                        child: Text(
                          f.label,
                          style: EcoText.bodyStrong.copyWith(
                            fontSize: 12,
                            color: sel ? Colors.white : Colors.white70,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),

                Text('TANK SIZE (L)', style: EcoText.label),
                const SizedBox(height: 8),
                TextField(
                  controller: tankCtrl,
                  keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
                  style: EcoText.bodyStrong.copyWith(fontSize: 15),
                  decoration: _deco('Tank size (optional)'),
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(ctx),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.12)),
                          ),
                          child: Center(
                            child: Text('Cancel',
                                style: EcoText.bodyStrong
                                    .copyWith(color: Colors.white70)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: GestureDetector(
                        onTap: () {
                          final name = nameCtrl.text.trim();
                          final model = modelCtrl.text.trim();
                          if (name.isEmpty || model.isEmpty) return;
                          final tank =
                              double.tryParse(tankCtrl.text) ?? 0;

                          final updated = Car(
                            id: car.id,
                            name: name,
                            model: model,
                            fuelType: selectedFuel,
                            tankSize: tank,
                            createdAt: car.createdAt,
                          );
                          state.updateCar(car.id, updated);
                          Navigator.pop(ctx);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                                colors: EcoColors.coolGradient),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text('Save',
                                style: EcoText.bodyStrong.copyWith(
                                    fontSize: 15, letterSpacing: 0.4)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- Delete car ----------------

  void _confirmDelete(BuildContext context, AppState state, Car car) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: EcoColors.bg2,
        title: Text('Delete "${car.name}"?',
            style: EcoText.bodyStrong.copyWith(fontSize: 18)),
        content: Text(
          'This will remove all refills and service records for this car. This cannot be undone.',
          style: EcoText.body.copyWith(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () {
              state.deleteCar(car.id);
              Navigator.pop(ctx);
            },
            child: const Text('Delete',
                style: TextStyle(color: Color(0xFFF5576C))),
          ),
        ],
      ),
    );
  }

  // ---------------- Helpers ----------------

  InputDecoration _deco(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: EcoText.body.copyWith(color: Colors.white30),
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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