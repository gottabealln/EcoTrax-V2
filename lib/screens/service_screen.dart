import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../state/app_state.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import '../widgets/animated_gradient_bg.dart';
import '../widgets/glass_card.dart';
import '../models/service_record.dart';
import 'car_setup_screen.dart';

class ServiceScreen extends StatelessWidget {
  const ServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final car = state.activeCar;
    final size = MediaQuery.of(context).size;
    final hp = size.width * 0.05;

    if (car == null) {
      return const CarSetupScreen(isFirstTime: true);
    }

    final services = [...state.activeServices]
      ..sort((a, b) => b.date.compareTo(a.date));

    return AnimatedGradientBg(
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(hp, 16, hp, 100),
              children: [
                ShaderMask(
                  shaderCallback: (b) => const LinearGradient(
                    colors: EcoColors.coolGradient,
                  ).createShader(b),
                  child: Text('Service Log', style: EcoText.logo),
                ),
                const SizedBox(height: 4),
                Text('${car.name} · ${car.model}',
                    style: EcoText.body.copyWith(fontSize: 13)),
                const SizedBox(height: 24),

                // ---- Total spent card ----
                GlassCard(
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFFFB347),
                              Color(0xFFFF7B54),
                            ],
                          ),
                        ),
                        child: const Icon(Icons.build_rounded,
                            color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('TOTAL SERVICE SPEND',
                                style: EcoText.label),
                            const SizedBox(height: 6),
                            Text(
                              '₹ ${state.totalServiceSpend.toStringAsFixed(0)}',
                              style: EcoText.bodyStrong.copyWith(
                                  fontSize: 18),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${services.length} record${services.length == 1 ? '' : 's'}',
                              style: EcoText.body.copyWith(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                Text('RECORDS', style: EcoText.label),
                const SizedBox(height: 12),

                if (services.isEmpty)
                  GlassCard(
                    child: Column(
                      children: [
                        const Icon(Icons.build_outlined,
                            color: Colors.white24, size: 40),
                        const SizedBox(height: 10),
                        Text('No service records yet',
                            style: EcoText.bodyStrong
                                .copyWith(color: Colors.white70)),
                        const SizedBox(height: 4),
                        Text(
                          'Tap the + button to log your first service',
                          style: EcoText.body.copyWith(fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                else
                  ...services.map((s) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _ServiceTile(record: s),
                  )),
              ],
            ),

            // ---- Floating action button ----
            Positioned(
              bottom: 24,
              right: hp,
              child: GestureDetector(
                onTap: () => _openAddService(context),
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: EcoColors.coolGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: EcoColors.accentCool1.withOpacity(0.45),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.add_rounded,
                      color: Colors.white, size: 30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openAddService(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddServiceSheet(),
    );
  }
}

// ---------------------------------------------------------------------------

class _ServiceTile extends StatelessWidget {
  final ServiceRecord record;
  const _ServiceTile({required this.record});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openDetail(context),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFFFB347),
                    Color(0xFFFF7B54),
                  ],
                ),
              ),
              child: const Icon(Icons.build_rounded,
                  color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(record.serviceType,
                      style: EcoText.bodyStrong.copyWith(fontSize: 15)),
                  const SizedBox(height: 3),
                  Text(
                    '${record.odometerKm.toStringAsFixed(0)} km · ${DateFormat('MMM d, yyyy').format(record.date)}',
                    style: EcoText.body.copyWith(fontSize: 11),
                  ),
                  if (record.billPhotoPath != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.image_rounded,
                            size: 12, color: Colors.white.withOpacity(0.5)),
                        const SizedBox(width: 4),
                        Text('Bill attached',
                            style: EcoText.body.copyWith(fontSize: 10)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('₹ ${record.cost.toStringAsFixed(0)}',
                    style: EcoText.bodyStrong.copyWith(
                        fontSize: 14, color: EcoColors.accentCool1)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _openDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ServiceDetailSheet(record: record),
    );
  }
}

// ---------------------------------------------------------------------------

class _ServiceDetailSheet extends StatelessWidget {
  final ServiceRecord record;
  const _ServiceDetailSheet({required this.record});

  @override
  Widget build(BuildContext context) {
    final state = context.read<AppState>();

    return Material(
      color: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        decoration: const BoxDecoration(
          color: EcoColors.bg2,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.all(24),
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
              ShaderMask(
                shaderCallback: (b) => const LinearGradient(
                  colors: EcoColors.coolGradient,
                ).createShader(b),
                child: Text(record.serviceType,
                    style: EcoText.h1.copyWith(fontSize: 22)),
              ),
              const SizedBox(height: 6),
              Text(
                DateFormat('EEEE, MMM d, yyyy').format(record.date),
                style: EcoText.body.copyWith(fontSize: 12),
              ),
              const SizedBox(height: 20),

              _detailRow('Odometer', '${record.odometerKm.toStringAsFixed(0)} km'),
              _detailRow('Cost', '₹ ${record.cost.toStringAsFixed(2)}'),
              if (record.notes.isNotEmpty) _detailRow('Notes', record.notes),

              if (record.billPhotoPath != null) ...[
                const SizedBox(height: 16),
                Text('BILL PHOTO', style: EcoText.label),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(
                    File(record.billPhotoPath!),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 200,
                      color: Colors.white.withOpacity(0.05),
                      child: Center(
                        child: Text('Photo not found',
                            style: EcoText.body.copyWith(fontSize: 12)),
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 24),
              GestureDetector(
                onTap: () {
                  state.deleteService(record.id);
                  Navigator.pop(context);
                },
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
                      Text('Delete Record',
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
          Expanded(flex: 2, child: Text(label, style: EcoText.label)),
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

// ---------------------------------------------------------------------------

class AddServiceSheet extends StatefulWidget {
  const AddServiceSheet({super.key});

  @override
  State<AddServiceSheet> createState() => _AddServiceSheetState();
}

class _AddServiceSheetState extends State<AddServiceSheet> {
  final _typeCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _odoCtrl = TextEditingController();
  final _costCtrl = TextEditingController();

  DateTime _date = DateTime.now();
  String? _billPhotoPath;
  bool _saving = false;

  @override
  void dispose() {
    _typeCtrl.dispose();
    _notesCtrl.dispose();
    _odoCtrl.dispose();
    _costCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        imageQuality: 75,
        maxWidth: 1600,
      );
      if (picked == null) return;

      // Copy to app documents so it persists
      final dir = await getApplicationDocumentsDirectory();
      final fileName = 'bill_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedFile = File('${dir.path}/$fileName');
      await File(picked.path).copy(savedFile.path);

      setState(() => _billPhotoPath = savedFile.path);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not pick image: $e')),
        );
      }
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2015),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: EcoColors.accentCool1,
            surface: EcoColors.bg2,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save(AppState state) async {
    final type = _typeCtrl.text.trim();
    if (type.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a service type')),
      );
      return;
    }

    final odo = double.tryParse(_odoCtrl.text) ?? 0;
    final cost = double.tryParse(_costCtrl.text) ?? 0;

    setState(() => _saving = true);

    await state.addService(
      serviceType: type,
      notes: _notesCtrl.text.trim(),
      odometerKm: odo,
      cost: cost,
      date: _date,
      billPhotoPath: _billPhotoPath,
    );

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.read<AppState>();
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Material(
      color: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.92,
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

              ShaderMask(
                shaderCallback: (b) => const LinearGradient(
                  colors: EcoColors.coolGradient,
                ).createShader(b),
                child: Text('New Service Record',
                    style: EcoText.h1.copyWith(fontSize: 22)),
              ),
              const SizedBox(height: 8),
              Text('Log what was done, when, and how much.',
                  style: EcoText.body.copyWith(fontSize: 13)),
              const SizedBox(height: 22),

              _input('SERVICE TYPE', _typeCtrl,
                  hint: 'e.g. Oil Change, Tyre Rotation'),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: _input('ODOMETER (KM)', _odoCtrl, hint: 'e.g. 42000'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _input('COST (₹)', _costCtrl, hint: 'e.g. 3200'),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              Text('DATE', style: EcoText.label),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.12)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded,
                          color: Colors.white70, size: 18),
                      const SizedBox(width: 10),
                      Text(
                        DateFormat('EEEE, MMM d, yyyy').format(_date),
                        style: EcoText.bodyStrong.copyWith(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              _input('NOTES (OPTIONAL)', _notesCtrl,
                  hint: 'Anything to remember', maxLines: 2),
              const SizedBox(height: 14),

              Text('BILL PHOTO', style: EcoText.label),
              const SizedBox(height: 8),
              if (_billPhotoPath != null)
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.file(
                        File(_billPhotoPath!),
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () => setState(() => _billPhotoPath = null),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withOpacity(0.6),
                          ),
                          child: const Icon(Icons.close,
                              color: Colors.white, size: 16),
                        ),
                      ),
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: _photoButton(
                        icon: Icons.photo_camera_rounded,
                        label: 'Camera',
                        onTap: () => _pickImage(ImageSource.camera),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _photoButton(
                        icon: Icons.photo_library_rounded,
                        label: 'Gallery',
                        onTap: () => _pickImage(ImageSource.gallery),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
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
                      onTap: _saving ? null : () => _save(state),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: EcoColors.coolGradient),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: EcoColors.accentCool1
                                  .withOpacity(0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Center(
                          child: _saving
                              ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                              : Text('Save Record',
                              style: EcoText.bodyStrong.copyWith(
                                  fontSize: 15,
                                  letterSpacing: 0.4)),
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
    );
  }

  Widget _photoButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white70, size: 18),
            const SizedBox(width: 8),
            Text(label,
                style: EcoText.bodyStrong.copyWith(
                    fontSize: 13, color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  Widget _input(
      String label,
      TextEditingController controller, {
        String? hint,
        int maxLines = 1,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: EcoText.label),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: EcoText.bodyStrong.copyWith(fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: EcoText.body.copyWith(color: Colors.white30),
            filled: true,
            fillColor: Colors.white.withOpacity(0.06),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.12)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                  color: EcoColors.accentCool1, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}