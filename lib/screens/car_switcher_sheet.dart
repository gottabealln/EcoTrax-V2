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
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          border: Border(
            top: BorderSide(color: EcoColors.glassBorder, width: 1),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
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
                    color: EcoColors.outline.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text('Your Cars', style: EcoText.h1.copyWith(fontSize: 24)),
              const SizedBox(height: 6),
              Text('Tap to switch · long-press to edit',
                  style: EcoText.body.copyWith(fontSize: 13)),
              const SizedBox(height: 24),

              ...state.cars.map((car) {
                final isActive = car.id == state.activeCarId;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
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
                            ? EcoColors.primaryContainer
                            : EcoColors.bgLow,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isActive
                              ? EcoColors.primary
                              : Colors.transparent,
                          width: isActive ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: isActive ? EcoColors.primary : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.directions_car_rounded,
                              color: isActive
                                  ? Colors.white
                                  : EcoColors.onSurfaceVariant,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 16),
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
                                color: EcoColors.primary, size: 24),
                        ],
                      ),
                    ),
                  ),
                );
              }),

              const SizedBox(height: 8),

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
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: EcoColors.glassBorder),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_rounded,
                          color: EcoColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Text('Add New Car',
                          style: EcoText.bodyStrong
                              .copyWith(color: EcoColors.primary)),
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
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_rounded,
                  color: EcoColors.primary),
              title: Text('Edit "${car.name}"', style: EcoText.bodyStrong),
              onTap: () {
                Navigator.pop(ctx);
                _editCar(context, state, car);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded,
                  color: Color(0xFFDC2626)),
              title: Text('Delete "${car.name}"',
                  style: EcoText.bodyStrong
                      .copyWith(color: const Color(0xFFDC2626))),
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
      backgroundColor: Colors.white,
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
                Text('Edit Car',
                    style: EcoText.h1.copyWith(fontSize: 22)),
                const SizedBox(height: 20),

                Text('CAR NAME', style: EcoText.label.copyWith(fontSize: 10)),
                const SizedBox(height: 8),
                TextField(
                  controller: nameCtrl,
                  style: EcoText.bodyStrong.copyWith(fontSize: 15, color: EcoColors.onSurface),
                  decoration: _deco('Car name'),
                ),
                const SizedBox(height: 14),

                Text('MODEL', style: EcoText.label.copyWith(fontSize: 10)),
                const SizedBox(height: 8),
                TextField(
                  controller: modelCtrl,
                  style: EcoText.bodyStrong.copyWith(fontSize: 15, color: EcoColors.onSurface),
                  decoration: _deco('Model'),
                ),
                const SizedBox(height: 14),

                Text('FUEL TYPE', style: EcoText.label.copyWith(fontSize: 10)),
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
                          color: sel ? EcoColors.primaryContainer : EcoColors.bgLow,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: sel ? EcoColors.primary : Colors.transparent,
                            width: sel ? 1.5 : 1,
                          ),
                        ),
                        child: Text(
                          f.label,
                          style: EcoText.bodyStrong.copyWith(
                            fontSize: 12,
                            color: sel ? EcoColors.primary : EcoColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),

                Text('TANK SIZE (L)', style: EcoText.label.copyWith(fontSize: 10)),
                const SizedBox(height: 8),
                TextField(
                  controller: tankCtrl,
                  keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
                  style: EcoText.bodyStrong.copyWith(fontSize: 15, color: EcoColors.onSurface),
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
                            color: EcoColors.bgLow,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Text('Cancel',
                                style: EcoText.bodyStrong
                                    .copyWith(color: EcoColors.onSurfaceVariant)),
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
                            color: EcoColors.primary,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Text('Save',
                                style: EcoText.bodyStrong.copyWith(
                                    color: Colors.white, fontSize: 15)),
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
        backgroundColor: Colors.white,
        title: Text('Delete "${car.name}"?',
            style: EcoText.h2.copyWith(fontSize: 18)),
        content: Text(
          'This will remove all refills and service records for this car. This cannot be undone.',
          style: EcoText.body.copyWith(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: EcoColors.onSurfaceVariant)),
          ),
          TextButton(
            onPressed: () {
              state.deleteCar(car.id);
              Navigator.pop(ctx);
            },
            child: const Text('Delete',
                style: TextStyle(color: Color(0xFFDC2626))),
          ),
        ],
      ),
    );
  }

  // ---------------- Helpers ----------------

  InputDecoration _deco(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: EcoText.body.copyWith(color: EcoColors.outline.withOpacity(0.5)),
      filled: true,
      fillColor: EcoColors.bgLow,
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
        const BorderSide(color: EcoColors.primary, width: 1.5),
      ),
    );
  }
}