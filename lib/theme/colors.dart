import 'package:flutter/material.dart';

class EcoColors {
  // Base Surfaces
  static const bgLowest = Color(0xFFF8F9FA); // porcelain
  static const bgSurface = Color(0xFFF8F9FA);
  static const bgLow = Color(0xFFF0F2F5); // titanium
  static const bgContainer = Color(0xFFF0F2F5);
  static const bgHigh = Color(0xFFE2E8F0); // titanium-border
  static const bgHighest = Color(0xFFE2E8F0);

  // Primary (Cerulean)
  static const primary = Color(0xFF0284C7);
  static const primaryContainer = Color(0xFFE0F2FE); // cerulean-light
  static const onPrimary = Color(0xFFFFFFFF);

  // Secondary (Mint/Emerald)
  static const secondary = Color(0xFF059669); // mint
  static const secondaryContainer = Color(0xFFD1FAE5); // mint-light
  static const onSecondary = Color(0xFFFFFFFF);

  // Tertiary
  static const tertiary = Color(0xFF0F172A);
  static const tertiaryContainer = Color(0xFF64748B);

  // Text & Lines
  static const onSurface = Color(0xFF0F172A); // ink
  static const onSurfaceVariant = Color(0xFF64748B); // ink-muted
  static const outline = Color(0xFF94A3B8);

  // Gradients
  static const gradientPrimary = LinearGradient(
    colors: [primary, Color(0xFF0369A1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradientGlow = LinearGradient(
    colors: [secondary, primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // --- BACKWARDS COMPATIBILITY (ALIASES) ---
  static const bg1 = bgLowest;
  static const bg2 = bgLowest;
  static const bg3 = bgSurface;
  static const bg4 = bgHigh;

  static const accentCool1 = primary;
  static const accentCool2 = primary;
  static const accentWarm1 = secondary;
  static const accentWarm2 = secondary;
  static const success1 = secondary;
  static const success2 = secondary;

  static const glassBg = Colors.white;
  static const glassBorder = Color(0xFFE2E8F0); // titanium-border

  static const textPrimary = onSurface;
  static const textSecondary = onSurfaceVariant;
  static const textMuted = outline;

  static const bgGradient = [bg1, bg2, bg3, bg4];
  static const coolGradient = [primary, Color(0xFF0369A1)];
  static const warmGradient = [secondary, Color(0xFF047857)];
  static const successGradient = [secondary, Color(0xFF047857)];
}