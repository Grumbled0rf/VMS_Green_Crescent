import 'package:flutter/material.dart';

// ============================================
// VMS Platform Colors
// UAE Green Theme - Professional & Modern
// ============================================
class AppColors {
  // Prevent instantiation
  AppColors._();

  // ==========================================
  // PRIMARY - Green (Brand Color)
  // UAE eco-friendly / sustainability theme
  // ==========================================
  static const Color primary = Color(0xFF10B981);       // Emerald green
  static const Color primaryLight = Color(0xFFD1FAE5);  // Light mint
  static const Color primaryDark = Color(0xFF059669);   // Dark emerald
  static const Color primarySurface = Color(0xFFECFDF5); // Very light green bg

  // ==========================================
  // SECONDARY - Blue (Accent)
  // Trust, reliability, technology
  // ==========================================
  static const Color secondary = Color(0xFF0EA5E9);     // Sky blue
  static const Color secondaryLight = Color(0xFFE0F2FE); // Light sky
  static const Color secondaryDark = Color(0xFF0284C7);  // Dark sky

  // ==========================================
  // ACCENT - Gold (UAE Premium feel)
  // ==========================================
  static const Color accent = Color(0xFFF59E0B);        // Amber gold
  static const Color accentLight = Color(0xFFFEF3C7);   // Light gold
  static const Color accentDark = Color(0xFFD97706);    // Dark gold

  // ==========================================
  // NEUTRALS - Grays
  // ==========================================
  static const Color dark = Color(0xFF111827);          // Almost black
  static const Color darkGray = Color(0xFF374151);      // Dark gray (headings)
  static const Color gray = Color(0xFF6B7280);          // Medium gray (body)
  static const Color lightGray = Color(0xFF9CA3AF);     // Light gray (hints)
  static const Color silver = Color(0xFFD1D5DB);        // Silver (disabled)
  static const Color border = Color(0xFFE5E7EB);        // Border color
  static const Color divider = Color(0xFFF3F4F6);       // Divider color
  static const Color background = Color(0xFFF9FAFB);    // Page background
  static const Color surface = Color(0xFFFFFFFF);       // Card/surface
  static const Color white = Color(0xFFFFFFFF);         // Pure white

  // ==========================================
  // STATUS COLORS
  // ==========================================
  // Success - Green
  static const Color success = Color(0xFF22C55E);
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color successDark = Color(0xFF16A34A);

  // Warning - Amber
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color warningDark = Color(0xFFD97706);

  // Error - Red
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color errorDark = Color(0xFFDC2626);

  // Info - Blue
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);
  static const Color infoDark = Color(0xFF2563EB);

  // ==========================================
  // VEHICLE STATUS COLORS
  // ==========================================
  static const Color compliant = Color(0xFF22C55E);     // Green - passed
  static const Color expiringSoon = Color(0xFFF59E0B);  // Amber - warning
  static const Color expired = Color(0xFFEF4444);       // Red - overdue
  static const Color noTest = Color(0xFF6B7280);        // Gray - no record

  // ==========================================
  // GRADIENT COLORS
  // ==========================================
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, secondaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, accentDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Dark overlay gradient (for images)
  static LinearGradient overlayGradient = LinearGradient(
    colors: [
      Colors.transparent,
      dark.withOpacity(0.7),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ==========================================
  // SHADOW COLORS
  // ==========================================
  static Color shadowLight = dark.withOpacity(0.04);
  static Color shadowMedium = dark.withOpacity(0.08);
  static Color shadowDark = dark.withOpacity(0.12);

  // ==========================================
  // HELPER METHODS
  // ==========================================
  
  // Get color with opacity
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }

  // Get vehicle status color
  static Color getVehicleStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'compliant':
        return compliant;
      case 'expiring':
      case 'expiring_soon':
        return expiringSoon;
      case 'expired':
      case 'overdue':
        return expired;
      default:
        return noTest;
    }
  }

  // Get booking status color
  static Color getBookingStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return success;
      case 'pending':
        return warning;
      case 'completed':
        return primary;
      case 'cancelled':
        return error;
      default:
        return gray;
    }
  }
}