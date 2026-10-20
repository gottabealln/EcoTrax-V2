import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EcoText {
  static TextStyle logo = GoogleFonts.outfit(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.8,
    color: Colors.white,
    decoration: TextDecoration.none,
  );

  static TextStyle h1 = GoogleFonts.outfit(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.4,
    color: Colors.white,
    decoration: TextDecoration.none,
  );

  static TextStyle h2 = GoogleFonts.outfit(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    decoration: TextDecoration.none,
  );

  static TextStyle label = GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.2,
    color: Color(0x80FFFFFF),
    decoration: TextDecoration.none,
  );

  static TextStyle body = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Color(0xB3FFFFFF),
    decoration: TextDecoration.none,
  );

  static TextStyle bodyStrong = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    decoration: TextDecoration.none,
  );

  static TextStyle bigNumber = GoogleFonts.outfit(
    fontSize: 44,
    fontWeight: FontWeight.w700,
    letterSpacing: -1,
    color: Colors.white,
    decoration: TextDecoration.none,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  static TextStyle mediumNumber = GoogleFonts.outfit(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    color: Colors.white,
    decoration: TextDecoration.none,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  static TextStyle smallNumber = GoogleFonts.outfit(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    decoration: TextDecoration.none,
    fontFeatures: const [FontFeature.tabularFigures()],
  );
}