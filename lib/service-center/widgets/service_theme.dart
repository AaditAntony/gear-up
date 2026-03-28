import 'package:flutter/material.dart';

class ServiceTheme {
  /// COLORS
  static const Color primary = Color(0xFF1E293B); // Deep Navy
  static const Color accent = Color(0xFF6366F1); // Modern Indigo
  static const Color background = Color(0xFFF8FAFC); // Slate 50
  static const Color surface = Colors.white;

  static const Color success = Color(0xFF10B981); // Emerald
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color error = Color(0xFFF43F5E); // Rose
  static const Color info = Color(0xFF3B82F6); // Blue

  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF64748B); // Slate 500
  static const Color border = Color(0xFFE2E8F0); // Slate 200

  /// SHADOWS
  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: const Color(0xFF1E293B).withOpacity(0.04),
      blurRadius: 20,
      offset: const Offset(0, 10),
    ),
  ];

  /// TEXT STYLES
  static const TextStyle heading1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    letterSpacing: -0.5,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  static const TextStyle body = TextStyle(fontSize: 14, color: textSecondary);

  static const TextStyle label = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: textSecondary,
    textBaseline: TextBaseline.alphabetic,
  );

  /// DECORATIONS
  static BoxDecoration cardDecoration = BoxDecoration(
    color: surface,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: border, width: 1),
    boxShadow: softShadow,
  );

  static BoxDecoration accentButtonDecoration = BoxDecoration(
    color: accent,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: accent.withOpacity(0.3),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ],
  );
}
