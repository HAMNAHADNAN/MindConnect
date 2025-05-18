import 'package:flutter/material.dart';

class AppColor {
  static const Color primary = Color(0xFF487495);      // Primary accent
  static const Color dark =Color(0xFF244C98);         // AppBar / header
  static const Color background = Color(0xFFD8E0E9);   // Screen background
  static const Color contentBg = Color(0xFFF8F8F8);
  // Card / input background

  // Optional: translucent white for blur effect overlays
  static const Color glass = Color.fromRGBO(255, 255, 255, 0.2);
  static const List<Color> darkGradient = [
    Color(0xFF7584D8),
    Color(0xFF85C1FA),

  ];

  static const LinearGradient linearDarkGradient = LinearGradient(
    colors: darkGradient,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient buttonGradient = LinearGradient(
    colors: [Color(0xFF75ACE6), Color(0xFF6C7DDD)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}