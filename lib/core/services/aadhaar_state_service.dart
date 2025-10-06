import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

/// Service for persisting Aadhaar verification state across sessions
class AadhaarStateService {
  static const String _keyPrefix = 'aadhaar_verification_';
  static const String _verifiedKey = 'verified';
  static const String _kycDetailsKey = 'kyc_details';
  static const String _timestampKey = 'timestamp';
  static const String _expiryHours =
      '24'; // Verification expires after 24 hours

  /// Save verification state to local storage
  static Future<void> saveVerificationState({
    required String userId,
    required String userRole,
    required bool isVerified,
    Map<String, dynamic>? kycDetails,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_keyPrefix${userId}_$userRole';

      final stateData = {
        _verifiedKey: isVerified,
        _timestampKey: DateTime.now().millisecondsSinceEpoch,
        if (kycDetails != null) _kycDetailsKey: kycDetails,
      };

      await prefs.setString(key, jsonEncode(stateData));
      debugPrint('✅ Aadhaar verification state saved for $userId ($userRole)');
    } catch (e) {
      debugPrint('❌ Failed to save Aadhaar verification state: $e');
    }
  }

  /// Load verification state from local storage
  static Future<AadhaarVerificationState?> loadVerificationState({
    required String userId,
    required String userRole,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_keyPrefix${userId}_$userRole';

      final stateJson = prefs.getString(key);
      if (stateJson == null) {
        debugPrint('📋 No saved verification state for $userId ($userRole)');
        return null;
      }

      final stateData = jsonDecode(stateJson) as Map<String, dynamic>;
      final timestamp = stateData[_timestampKey] as int;
      final savedAt = DateTime.fromMillisecondsSinceEpoch(timestamp);

      // Check if verification has expired (24 hours)
      final expiryDuration = Duration(hours: int.parse(_expiryHours));
      if (DateTime.now().difference(savedAt) > expiryDuration) {
        debugPrint(
          '⏰ Saved verification state expired for $userId ($userRole)',
        );
        await clearVerificationState(userId: userId, userRole: userRole);
        return null;
      }

      final isVerified = stateData[_verifiedKey] as bool;
      Map<String, dynamic>? kycDetails;

      if (stateData.containsKey(_kycDetailsKey)) {
        kycDetails = stateData[_kycDetailsKey] as Map<String, dynamic>;
      }

      debugPrint(
        '✅ Loaded verification state for $userId ($userRole): verified=$isVerified',
      );

      return AadhaarVerificationState(
        isVerified: isVerified,
        kycDetails: kycDetails,
        savedAt: savedAt,
      );
    } catch (e) {
      debugPrint('❌ Failed to load Aadhaar verification state: $e');
      return null;
    }
  }

  /// Clear verification state from local storage
  static Future<void> clearVerificationState({
    required String userId,
    required String userRole,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_keyPrefix${userId}_$userRole';
      await prefs.remove(key);
      debugPrint('🗑️ Cleared verification state for $userId ($userRole)');
    } catch (e) {
      debugPrint('❌ Failed to clear verification state: $e');
    }
  }

  /// Clear all verification states (useful for logout)
  static Future<void> clearAllVerificationStates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();

      for (final key in keys) {
        if (key.startsWith(_keyPrefix)) {
          await prefs.remove(key);
        }
      }

      debugPrint('🗑️ Cleared all verification states');
    } catch (e) {
      debugPrint('❌ Failed to clear all verification states: $e');
    }
  }
}

/// Model for stored verification state
class AadhaarVerificationState {
  final bool isVerified;
  final Map<String, dynamic>? kycDetails;
  final DateTime savedAt;

  const AadhaarVerificationState({
    required this.isVerified,
    this.kycDetails,
    required this.savedAt,
  });
}
