import 'package:flutter/material.dart';

/// App color palette converted from the original JS theme.
/// Use `AppColors` static constants throughout the app.
class AppColors {
  AppColors._();

  // Core accents
  static const Color primary = Color(0xFF2E7D32);
  static const Color secondary = Color(0xFFFFB300);
  // Dark backgrounds
  static const Color backgroundBase = Color(0xFF0F1115); // main app background
  static const Color backgroundSunken = Color(
    0xFF0B0D10,
  ); // deep surfaces, sidebars
  static const Color backgroundRaised = Color(
    0xFF141720,
  ); // cards / elevated sections
  static const Color backgroundOverlay = Color(
    0xFF1A1E2A,
  ); // dialogs, dropdowns

  // Text colors
  static const Color textPrimary = Color(0xFFF2F4F8); // high-contrast on dark
  static const Color textSecondary = Color(0xFFC5CBD6); // softer body text
  static const Color textMuted = Color(0xFF98A1AE); // placeholders, hints

  // Borders / separators
  static const Color borderSubtle = Color(0xFF1E2430);
  static const Color borderDefault = Color(0xFF2A3242);
  static const Color borderStrong = Color(0xFF3A455A);

  // Semantic states
  static const Color stateInfo = Color(0xFF89AEBF);
  static const Color stateSuccess = Color(0xFF6FB7A3);
  static const Color stateWarning = Color(0xFFF1B0A6);
  static const Color stateDanger = Color(0xFF903F67);

  // Utility overlays (use fromRGBO for alpha values)
  static const Color alphaHover = Color.fromRGBO(139, 138, 178, 0.12);
  static const Color alphaActive = Color.fromRGBO(137, 174, 191, 0.16);
  static const Color alphaOverlay = Color.fromRGBO(0, 0, 0, 0.55);

  // Primary & Secondary
  static const Color kPrimaryColor = Color(0xFF2563EB);
  static const Color kPrimaryLight = Color(0xFFDBEAFE);
  static const Color kSecondaryColor = Color(0xFF059669);
  static const Color kSecondaryLight = Color(0xFFD1FAE5);

  // Neutrals
  static const Color kBackgroundColor = Color(0xFFF8FAFC);
  static const Color kSurfaceColor = Color(0xFFFFFFFF);
  static const Color kTextPrimary = Color(0xFF0F172A);
  static const Color kTextSecondary = Color(0xFF475569);

  // Semantic
  static const Color kErrorColor = Color(0xFFDC2626);
  static const Color kSuccessColor = Color(0xFF16A34A);
  static const Color kWarningColor = Color(0xFFD97706);
}
