import 'package:flutter/material.dart';

class EcoColors {
  // --- NEW STITCH PALETTE ---
  // Base Surfaces
  static const bgLowest = Color(0xFF0B0E1A);
  static const bgSurface = Color(0xFF10131F);
  static const bgLow = Color(0xFF181B27);
  static const bgContainer = Color(0xFF1C1F2C);
  static const bgHigh = Color(0xFF272936);
  static const bgHighest = Color(0xFF313442);

  // Primary (Blue)
  static const primary = Color(0xFFA4CCFF);
  static const primaryContainer = Color(0xFF6FB1FC);
  static const onPrimary = Color(0xFF003259);

  // Secondary (Purple)
  static const secondary = Color(0xFFD1BCFF);
  static const secondaryContainer = Color(0xFF5728AF);
  static const onSecondary = Color(0xFF3D0090);

  // Tertiary (Green)
  static const tertiary = Color(0xFF51E0A5);
  static const tertiaryContainer = Color(0xFF29C48B);
  static const onTertiary = Color(0xFF003824);

  // Text & Lines
  static const onSurface = Color(0xFFE0E1F3);
  static const onSurfaceVariant = Color(0xFFC1C7D2);
  static const outline = Color(0xFF8B919C);

  // Gradients
  static const gradientPrimary = LinearGradient(
    colors: [primaryContainer, primary],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const gradientGlow = LinearGradient(
    colors: [tertiary, primaryContainer, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // --- BACKWARDS COMPATIBILITY (ALIASES) ---
  // These map the old names to the new colors so the rest of the app compiles.
  static const bg1 = bgLowest;
  static const bg2 = bgContainer;
  static const bg3 = bgSurface;
  static const bg4 = bgHighest;

  static const accentCool1 = primaryContainer;
  static const accentCool2 = primary;
  static const accentWarm1 = secondary;
  static const accentWarm2 = Color(0xFFE14E75); // Old warm color
  static const success1 = tertiary;
  static const success2 = tertiaryContainer;

  static const glassBg = Color(0x0FFFFFFF);
  static const glassBorder = Color(0x1FFFFFFF);

  static const textPrimary = onSurface;
  static const textSecondary = onSurfaceVariant;
  static const textMuted = outline;

  static const bgGradient = [bg1, bg2, bg3, bg4];
  static const coolGradient = [accentCool1, accentCool2];
  static const warmGradient = [accentWarm1, accentWarm2];
  static const successGradient = [success1, success2];
}