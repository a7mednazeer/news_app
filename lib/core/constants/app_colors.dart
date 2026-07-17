import 'package:flutter/material.dart';

/// Centralized color palette for the entire application.
///
/// Redesigned from the original green News App mockup into a more premium,
/// editorial "Midnight Ink" palette: a deep indigo primary with a warm coral
/// accent, designed to feel modern and trustworthy (à la NYT/Apple News)
/// rather than a generic bright-green template.
abstract class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFF2A2E6E); // deep indigo
  static const Color primaryLight = Color(0xFF4B4FA0);
  static const Color primaryDark = Color(0xFF161936);
  static const Color accent = Color(0xFFFF6B4A); // warm coral
  static const Color accentLight = Color(0xFFFF9478);

  // Category accent colors (used for chips / category icons)
  static const Color sports = Color(0xFFE0524B);
  static const Color politics = Color(0xFF2F5DAA);
  static const Color health = Color(0xFFD6467F);
  static const Color business = Color(0xFFC97A2E);
  static const Color environment = Color(0xFF2E9E6A);
  static const Color science = Color(0xFFE0B23C);
  static const Color technology = Color(0xFF3E8FB0);
  static const Color entertainment = Color(0xFF9757C2);

  static const List<Color> categoryPalette = [
    sports,
    politics,
    health,
    business,
    environment,
    science,
    technology,
    entertainment,
  ];

  // Light theme neutrals
  static const Color lightBackground = Color(0xFFF7F7FB);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFEFEFF5);
  static const Color lightBorder = Color(0xFFE4E4EE);
  static const Color lightTextPrimary = Color(0xFF16182B);
  static const Color lightTextSecondary = Color(0xFF6B6D80);
  static const Color lightTextTertiary = Color(0xFF9C9DAD);

  // Dark theme neutrals
  static const Color darkBackground = Color(0xFF0E0F1A);
  static const Color darkSurface = Color(0xFF171827);
  static const Color darkSurfaceVariant = Color(0xFF20223A);
  static const Color darkBorder = Color(0xFF2B2D45);
  static const Color darkTextPrimary = Color(0xFFF3F3F8);
  static const Color darkTextSecondary = Color(0xFFAEAFC2);
  static const Color darkTextTertiary = Color(0xFF7C7E93);

  // Semantic
  static const Color success = Color(0xFF35A772);
  static const Color error = Color(0xFFE0524B);
  static const Color warning = Color(0xFFE0A83C);
  static const Color info = Color(0xFF3E8FB0);

  static Color categoryColor(int index) =>
      categoryPalette[index % categoryPalette.length];

  static const LinearGradient heroGradientLight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );

  static const LinearGradient heroGradientDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryDark, primary],
  );

  static LinearGradient imageScrim({bool dark = false}) => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.black.withValues(alpha: 0.0),
          Colors.black.withValues(alpha: dark ? 0.75 : 0.65),
        ],
        stops: const [0.4, 1.0],
      );
}
