import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onFinished;
  const SplashScreen({super.key, required this.onFinished});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Drop falls from top → bottom
  late AnimationController _dropController;

  // Ripple expands + fades after drop lands
  late AnimationController _rippleController;

  // Wordmark fades in after ripple
  late AnimationController _wordmarkController;

  // Subtle background breathing
  late AnimationController _bgController;

  @override
  void initState() {
    super.initState();

    _dropController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    _wordmarkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _runSequence();
  }

  Future<void> _runSequence() async {
    // Drop falls
    await _dropController.forward();
    // Ripple expands
    _rippleController.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    // Wordmark fades in
    await _wordmarkController.forward();
    await Future.delayed(const Duration(milliseconds: 500));
    widget.onFinished();
  }

  @override
  void dispose() {
    _dropController.dispose();
    _rippleController.dispose();
    _wordmarkController.dispose();
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final centerY = size.height * 0.55;

    return Scaffold(
      backgroundColor: EcoColors.bg1,
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _dropController,
          _rippleController,
          _wordmarkController,
          _bgController,
        ]),
        builder: (context, _) {
          // ---------- Drop position & opacity ----------
          final dropT = _dropController.value;
          final dropEased = Curves.easeInQuad.transform(dropT);

          // Drop starts above the screen and lands at `centerY`
          final dropStartY = -80.0;
          final dropEndY = centerY - 40; // droplet's tip meets the ripple line
          final dropY = dropStartY + (dropEndY - dropStartY) * dropEased;

          // Drop squashes slightly on impact
          final dropSquash = dropT > 0.9
              ? 1.0 - ((dropT - 0.9) / 0.1) * 0.35
              : 1.0;
          final dropStretch = dropT > 0.9
              ? 1.0 + ((dropT - 0.9) / 0.1) * 0.35
              : 1.0;

          // Drop opacity: fades in briefly at the start
          final dropOpacity =
          Curves.easeOut.transform(math.min(1.0, dropT * 3.5));

          // ---------- Ripple ----------
          final rippleT = _rippleController.value;
          final rippleRadius = 20 + 220 * Curves.easeOutCubic.transform(rippleT);
          final rippleOpacity = (1 - rippleT).clamp(0.0, 1.0) * 0.7;

          // ---------- Wordmark ----------
          final wordT = _wordmarkController.value;
          final wordOpacity = Curves.easeOut.transform(wordT);
          final wordOffset = (1 - wordT) * 14;

          return Stack(
            children: [
              // ---------- Breathing radial background ----------
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(
                        0,
                        -0.2 + _bgController.value * 0.15,
                      ),
                      radius: 1.2,
                      colors: [
                        EcoColors.accentCool1.withOpacity(0.20),
                        EcoColors.bg1,
                      ],
                    ),
                  ),
                ),
              ),

              // ---------- Ripple ring ----------
              if (_rippleController.value > 0)
                Positioned(
                  left: size.width / 2 - rippleRadius,
                  top: centerY - rippleRadius,
                  child: IgnorePointer(
                    child: Container(
                      width: rippleRadius * 2,
                      height: rippleRadius * 2,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: EcoColors.accentCool1
                              .withOpacity(rippleOpacity),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: EcoColors.accentCool1
                                .withOpacity(rippleOpacity * 0.4),
                            blurRadius: 24,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // ---------- Second ripple (delayed, thinner) ----------
              if (_rippleController.value > 0.25)
                Positioned(
                  left: size.width / 2 -
                      (20 + 220 * Curves.easeOutCubic.transform(
                          (_rippleController.value - 0.25) / 0.75)) *
                          0.7,
                  top: centerY -
                      (20 + 220 * Curves.easeOutCubic.transform(
                          (_rippleController.value - 0.25) / 0.75)) *
                          0.7,
                  child: IgnorePointer(
                    child: Container(
                      width: (20 +
                          220 *
                              Curves.easeOutCubic.transform(
                                  (_rippleController.value - 0.25) /
                                      0.75)) *
                          1.4,
                      height: (20 +
                          220 *
                              Curves.easeOutCubic.transform(
                                  (_rippleController.value - 0.25) /
                                      0.75)) *
                          1.4,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: EcoColors.accentCool1.withOpacity(
                            (1 - (_rippleController.value - 0.25) / 0.75)
                                .clamp(0.0, 1.0) *
                                0.35,
                          ),
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                ),

              // ---------- Falling droplet ----------
              if (dropT < 1.0 || _rippleController.value < 0.3)
                Positioned(
                  left: size.width / 2 - 18,
                  top: dropY,
                  child: Opacity(
                    opacity: dropOpacity,
                    child: Transform.scale(
                      scaleX: dropStretch,
                      scaleY: dropSquash,
                      child: _droplet(),
                    ),
                  ),
                ),

              // ---------- Wordmark ----------
              Positioned(
                top: centerY + 70,
                left: 0,
                right: 0,
                child: Opacity(
                  opacity: wordOpacity,
                  child: Transform.translate(
                    offset: Offset(0, wordOffset),
                    child: Column(
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) =>
                              const LinearGradient(
                                colors: EcoColors.coolGradient,
                              ).createShader(bounds),
                          child: Text(
                            'EcoTrax',
                            style: GoogleFonts.outfit(
                              fontSize: 42,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -1.2,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'DRIVE SMART · TRACK EVERY DROP',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            letterSpacing: 3,
                            color: EcoColors.textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// The glowing droplet shape.
  Widget _droplet() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF8CC5FF),
            Color(0xFF4A90E2),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: EcoColors.accentCool1.withOpacity(0.7),
            blurRadius: 28,
            spreadRadius: 4,
          ),
          BoxShadow(
            color: EcoColors.accentCool1.withOpacity(0.35),
            blurRadius: 60,
            spreadRadius: 12,
          ),
        ],
      ),
      // Highlight
      child: Align(
        alignment: const Alignment(-0.35, -0.35),
        child: Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.55),
          ),
        ),
      ),
    );
  }
}