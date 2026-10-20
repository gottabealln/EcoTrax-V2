import 'package:flutter/material.dart';

enum FuelStation {
  indianOil('IndianOil', Color(0xFF1E63C6)),
  nayara('Nayara', Color(0xFFE63946)),
  hp('HP', Color(0xFF0072BC)),
  jioBp('JioBP', Color(0xFF00A651));

  final String label;
  final Color color;
  const FuelStation(this.label, this.color);
}