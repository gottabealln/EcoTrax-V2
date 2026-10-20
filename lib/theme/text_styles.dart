import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class EcoText {
  static TextStyle logo = GoogleFonts.plusJakartaSans(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.8,
    color: EcoColors.primary,
    decoration: TextDecoration.none,
  );

  static TextStyle h1 = GoogleFonts.plusJakartaSans(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
    color: EcoColors.onSurface,
    decoration: TextDecoration.none,
  );

  static TextStyle h2 = GoogleFonts.plusJakartaSans(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: EcoColors.onSurface,
    decoration: TextDecoration.none,
  );

  static TextStyle label = GoogleFonts.plusJakartaSans(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.0,
    color: EcoColors.onSurfaceVariant,
    decoration: TextDecoration.none,
  );

  static TextStyle body = GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: EcoColors.onSurfaceVariant,
    decoration: TextDecoration.none,
  );

  static TextStyle bodyStrong = GoogleFonts.plusJakartaSans(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: EcoColors.onSurface,
    decoration: TextDecoration.none,
  );

  static TextStyle mediumNumber = GoogleFonts.jetBrainsMono(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -1,
    color: EcoColors.onSurface,
    decoration: TextDecoration.none,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  static TextStyle smallNumber = GoogleFonts.jetBrainsMono(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: EcoColors.onSurface,
    decoration: TextDecoration.none,
    fontFeatures: const [FontFeature.tabularFigures()],
  );
}