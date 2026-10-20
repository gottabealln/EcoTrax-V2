import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

class ForgotResetSheet extends StatefulWidget {
  const ForgotResetSheet({super.key});

  @override
  State<ForgotResetSheet> createState() => _ForgotResetSheetState();
}

class _ForgotResetSheetState extends State<ForgotResetSheet> {
  final _tripCtrl = TextEditingController();

  @override
  void dispose() {
    _tripCtrl.dispose();
    super.dispose();
  }

  void _submit(AppState state) {
    final trip = double.tryParse(_tripCtrl.text);
    if (trip == null || trip <= 0) return;
    state.skipLastRefill(tripMeter: trip);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.read<AppState>();
    final lastTrip = state.lastTripMeter;
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Material(
      color: Colors.transparent,
      child: Container(
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
                  colors: [Color(0xFFFFB347), Color(0xFFFF7B54)],
                ).createShader(b),
                child: Text('Forgot to Log?',
                    style: EcoText.h1.copyWith(fontSize: 22)),
              ),
              const SizedBox(height: 8),
              Text(
                "No problem. Enter your current trip meter reading, and EcoTrax will start fresh from here.",
                style: EcoText.body.copyWith(fontSize: 13),
              ),
              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb_outline_rounded,
                        color: Color(0xFF6FB1FC), size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'This will not affect your average economy. The skipped refill is only used to anchor the trip meter.',
                        style: EcoText.body.copyWith(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Text('CURRENT TRIP METER READING (KM)', style: EcoText.label),
              const SizedBox(height: 8),
              TextField(
                controller: _tripCtrl,
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
                style: EcoText.bodyStrong.copyWith(fontSize: 16),
                decoration: InputDecoration(
                  hintText: lastTrip > 0
                      ? 'Last: ${lastTrip.toStringAsFixed(0)}'
                      : 'e.g. 500',
                  hintStyle: EcoText.body.copyWith(color: Colors.white30),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.06),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 16),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide:
                    BorderSide(color: Colors.white.withOpacity(0.12)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                        color: Color(0xFFFFB347), width: 1.5),
                  ),
                ),
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
                      onTap: () => _submit(state),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFB347), Color(0xFFFF7B54)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF7B54)
                                  .withOpacity(0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text('Reset Counter',
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
    );
  }
}