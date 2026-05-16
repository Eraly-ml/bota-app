import 'package:flutter/material.dart';

/// Design system matching the web app dark-premium aesthetic.
///
/// Dark burgundy background, glass-morphism cards, warm gold gradients,
/// and ember-glow accents.
class AppColors {
  // ── Backgrounds ───────────────────────────────────────────
  static const Color bgDark = Color(0xFF0D0404); // noir
  static const Color bgDarkMid = Color(0xFF180808); // surface
  static const Color bgDarkLight = Color(0xFF220D0D); // surface-2
  static const Color bgLight = Color(0xFFFFF8F0); // legacy fallback
  static const Color bgCard = Color(0xFFFFFFFF);  // legacy fallback

  // ── Web App Warm Dark Palette ─────────────────────────────
  static const Color bordeaux = Color(0xFF6B1A1A);
  static const Color crimson = Color(0xFF991B1B);
  static const Color scarlet = Color(0xFFDC2626);
  static const Color ember = Color(0xFFEA580C);
  static const Color goldLight = Color(0xFFFCD34D);
  static const Color cream = Color(0xFFFEF3C7);

  // ── Glass morphism ────────────────────────────────────────
  static const Color glassBg = Color(0x526B1A1A); // 32% opacity
  static const Color glassBorder = Color(0x2EEA580C); // 18% opacity
  static const Color glassBorderLight = Color(0x26FFFFFF); // 15% white

  // ── Primary gold / orange ─────────────────────────────────
  static const Color primary = Color(0xFFD97706);
  static const Color primaryLight = Color(0xFFF59E0B);
  static const Color primaryDark = Color(0xFFB45309);

  // ── Secondary blue ────────────────────────────────────────
  static const Color secondary = Color(0xFF0EA5E9);
  static const Color secondaryLight = Color(0xFF38BDF8);

  // ── Accents ───────────────────────────────────────────────
  static const Color accent = Color(0xFFEF4444);
  static const Color accentYellow = Color(0xFFFCD34D);
  static const Color accentPurple = Color(0xFF9B59B6);
  static const Color accentGreen = Color(0xFF27AE60);
  static const Color accentBlue = Color(0xFF3498DB);

  // ── Text ──────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF2C3E50);   // on light bg (legacy)
  static const Color textSecondary = Color(0xFF7F8C8D); // on light bg (legacy)
  static const Color textDark = Color(0xFF2C3E50);      // legacy
  static const Color textOnDark = Color(0xFFFFFFFF);
  static const Color textOnDarkSecondary = Color(0xFF9CA3AF);
  static const Color textMuted = Color(0xFF6B7280);

  // ── Status ────────────────────────────────────────────────
  static const Color botakoin = Color(0xFFFFD700);
  static const Color success = Color(0xFF27AE60);
  static const Color error = Color(0xFFEF4444);

  // ── Location pins ─────────────────────────────────────────
  static const Color almaty = Color(0xFF27AE60);
  static const Color astana = Color(0xFF3498DB);
  static const Color turkestan = Color(0xFFE67E22);
  static const Color charyn = Color(0xFFE74C3C);
  static const Color steppe = Color(0xFFF39C12);

  // ── Gradients ─────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryLight, primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient bgGradient = LinearGradient(
    colors: [bgDark, bgDarkMid, bgDarkLight],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient goldShimmer = LinearGradient(
    colors: [
      Colors.transparent,
      Color(0x4DD97706),
      Colors.transparent,
    ],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient sunsetGradient = LinearGradient(
    colors: [Color(0xFFFF8C00), Color(0xFFFF6B6B), Color(0xFF9B59B6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient desertGradient = LinearGradient(
    colors: [Color(0xFFFFF8F0), Color(0xFFFFE4B5), Color(0xFFFFD700)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ── Shadow / Glow presets ─────────────────────────────────
  static List<BoxShadow> get goldGlow => [
    BoxShadow(
      color: const Color(0x66D97706),
      blurRadius: 20,
      spreadRadius: 2,
    ),
  ];

  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: const Color(0x70000000),
      blurRadius: 32,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> get emberGlow => [
    BoxShadow(
      color: const Color(0x40EA580C),
      blurRadius: 16,
      spreadRadius: 2,
    ),
  ];
}
