import 'package:flutter/material.dart';

/// Design System E-Santé SN
/// Couleurs, espacements et styles réutilisables
class AppTheme {
  AppTheme._();

  // ============ COULEURS ============
  
  // Couleurs principales
  static const Color primaryGreen = Color(0xFF0A7A33);
  static const Color secondaryGreen = Color(0xFF1AAA42);
  static const Color accentGreen = Color(0xFF23A036);
  static const Color lightGreen = Color(0xFFE8F5EC);
  
  // Couleurs de fond
  static const Color background = Color(0xFFF8FAFB);
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color surfaceGrey = Color(0xFFF1F3F5);
  
  // Couleurs de texte
  static const Color textDark = Color(0xFF1A1D1F);
  static const Color textGrey = Color(0xFF6F767E);
  static const Color textLight = Color(0xFF9A9FA5);
  
  // Couleurs d'accent
  static const Color accentBlue = Color(0xFF2D7FF9);
  static const Color accentOrange = Color(0xFFFF9F43);
  static const Color accentRed = Color(0xFFEF4444);
  static const Color accentPurple = Color(0xFF8B5CF6);
  static const Color accentPink = Color(0xFFEC4899);
  
  // Couleurs de statut
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // ============ GRADIENTS ============
  
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryGreen, secondaryGreen],
  );
  
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0A7A33), Color(0xFF1AAA42), Color(0xFF23A036)],
  );
  
  static LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [cardWhite, surfaceGrey.withOpacity(0.5)],
  );

  // ============ ESPACEMENTS ============
  
  static const double spacingXs = 4;
  static const double spacingSm = 8;
  static const double spacingMd = 16;
  static const double spacingLg = 24;
  static const double spacingXl = 32;
  static const double spacing2Xl = 48;
  
  // ============ BORDER RADIUS ============
  
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 20;
  static const double radius2Xl = 24;
  static const double radiusFull = 9999;

  // ============ SHADOWS ============
  
  static List<BoxShadow> shadowSm = [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];
  
  static List<BoxShadow> shadowMd = [
    BoxShadow(
      color: Colors.black.withOpacity(0.06),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> shadowLg = [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];
  
  static List<BoxShadow> shadowGreen = [
    BoxShadow(
      color: primaryGreen.withOpacity(0.25),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  // ============ DÉCORATIONS ============
  
  static BoxDecoration cardDecoration = BoxDecoration(
    color: cardWhite,
    borderRadius: BorderRadius.circular(radiusXl),
    boxShadow: shadowSm,
  );
  
  static BoxDecoration cardDecorationHover = BoxDecoration(
    color: cardWhite,
    borderRadius: BorderRadius.circular(radiusXl),
    boxShadow: shadowMd,
    border: Border.all(color: primaryGreen.withOpacity(0.1)),
  );
  
  static BoxDecoration heroDecoration = BoxDecoration(
    gradient: heroGradient,
    borderRadius: const BorderRadius.only(
      bottomLeft: Radius.circular(32),
      bottomRight: Radius.circular(32),
    ),
  );

  // ============ DURÉES D'ANIMATION ============
  
  static const Duration animFast = Duration(milliseconds: 150);
  static const Duration animNormal = Duration(milliseconds: 300);
  static const Duration animSlow = Duration(milliseconds: 500);
}

/// Extension pour faciliter l'accès au thème
extension AppThemeExtension on BuildContext {
  AppTheme get appTheme => AppTheme._();
  
  Color get primaryColor => AppTheme.primaryGreen;
  Color get secondaryColor => AppTheme.secondaryGreen;
}

