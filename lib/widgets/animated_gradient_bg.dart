import 'package:flutter/material.dart';
import '../theme/colors.dart';

class AnimatedGradientBg extends StatefulWidget {
  final Widget child;
  const AnimatedGradientBg({super.key, required this.child});

  @override
  State<AnimatedGradientBg> createState() => _AnimatedGradientBgState();
}

class _AnimatedGradientBgState extends State<AnimatedGradientBg>
    with TickerProviderStateMixin {
  late AnimationController _bgCtrl;
  late AnimationController _orbCtrl;

  @override
  void initState() {
    super.initState();
    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat(reverse: true);

    _orbCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    _orbCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnimatedBuilder(
      animation: Listenable.merge([_bgCtrl, _orbCtrl]),
      builder: (context, _) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: EcoColors.bgGradient,
              stops: [
                0.0,
                0.3 + _bgCtrl.value * 0.15,
                0.6 + _bgCtrl.value * 0.1,
                1.0,
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -size.height * 0.15 + _orbCtrl.value * 120,
                left: -size.width * 0.25 + _orbCtrl.value * 80,
                child: _orb(size.width * 0.8, EcoColors.accentCool1, 0.18),
              ),
              Positioned(
                bottom: -size.height * 0.1 - _orbCtrl.value * 80,
                right: -size.width * 0.3 - _orbCtrl.value * 60,
                child: _orb(size.width * 0.9, EcoColors.accentWarm1, 0.14),
              ),
              Positioned(
                top: size.height * 0.4 + _bgCtrl.value * 60,
                right: -size.width * 0.2,
                child: _orb(size.width * 0.6, EcoColors.success1, 0.08),
              ),
              widget.child,
            ],
          ),
        );
      },
    );
  }

  Widget _orb(double size, Color color, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withOpacity(opacity),
            color.withOpacity(0),
          ],
        ),
      ),
    );
  }
}