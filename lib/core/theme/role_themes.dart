import 'package:flutter/material.dart';

/// Role-specific theme colors for the AgriChain app
class RoleThemes {
  // Farmer theme - Green
  static const Color farmerPrimary = Color(0xFF4CAF50);
  static const Color farmerSecondary = Color(0xFF8BC34A);
  static const Color farmerAccent = Color(0xFF2E7D32);

  // Consumer theme - Orange
  static const Color consumerPrimary = Color(0xFFFF9800);
  static const Color consumerSecondary = Color(0xFFFFB74D);
  static const Color consumerAccent = Color(0xFFE65100);

  // Retailer theme - Purple
  static const Color retailerPrimary = Color(0xFF9C27B0);
  static const Color retailerSecondary = Color(0xFFBA68C8);
  static const Color retailerAccent = Color(0xFF6A1B9A);

  // Distributor theme - Blue
  static const Color distributorPrimary = Color(0xFF2196F3);
  static const Color distributorSecondary = Color(0xFF64B5F6);
  static const Color distributorAccent = Color(0xFF1565C0);

  /// Get primary color based on role
  static Color getPrimaryColor(String role) {
    switch (role.toLowerCase()) {
      case 'farmer':
        return farmerPrimary;
      case 'consumer':
        return consumerPrimary;
      case 'retailer':
        return retailerPrimary;
      case 'distributor':
        return distributorPrimary;
      default:
        return farmerPrimary; // Default to farmer green
    }
  }

  /// Get secondary color based on role
  static Color getSecondaryColor(String role) {
    switch (role.toLowerCase()) {
      case 'farmer':
        return farmerSecondary;
      case 'consumer':
        return consumerSecondary;
      case 'retailer':
        return retailerSecondary;
      case 'distributor':
        return distributorSecondary;
      default:
        return farmerSecondary;
    }
  }

  /// Get accent color based on role
  static Color getAccentColor(String role) {
    switch (role.toLowerCase()) {
      case 'farmer':
        return farmerAccent;
      case 'consumer':
        return consumerAccent;
      case 'retailer':
        return retailerAccent;
      case 'distributor':
        return distributorAccent;
      default:
        return farmerAccent;
    }
  }
}
