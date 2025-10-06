import 'dart:math';
import 'package:flutter/foundation.dart';

/// Simple Local Aadhaar Verification Service
/// Generates OTP locally and shows in-app notification
class LocalAadhaarService {
  static String? _currentOtp;
  static String? _currentAadhaarNumber;
  static DateTime? _otpGeneratedAt;
  static const int _otpValidityMinutes = 5;

  /// Generate 6-digit OTP for Aadhaar number
  static String generateOtp(String aadhaarNumber) {
    // Validate Aadhaar number format
    if (aadhaarNumber.length != 12 || !_isValidAadhaarNumber(aadhaarNumber)) {
      throw Exception('Invalid Aadhaar number format');
    }

    // Generate random 6-digit OTP
    final random = Random();
    final otp = (100000 + random.nextInt(900000)).toString();

    // Store OTP details
    _currentOtp = otp;
    _currentAadhaarNumber = aadhaarNumber;
    _otpGeneratedAt = DateTime.now();

    debugPrint('🔐 Generated OTP: $otp for Aadhaar: $aadhaarNumber');
    return otp;
  }

  /// Verify OTP
  static Map<String, dynamic> verifyOtp(String enteredOtp) {
    // Check if OTP exists
    if (_currentOtp == null ||
        _currentAadhaarNumber == null ||
        _otpGeneratedAt == null) {
      return {
        'success': false,
        'message': 'No OTP generated. Please request OTP first.',
      };
    }

    // Check if OTP is expired
    final now = DateTime.now();
    final otpAge = now.difference(_otpGeneratedAt!);
    if (otpAge.inMinutes > _otpValidityMinutes) {
      _clearOtpData();
      return {
        'success': false,
        'message': 'OTP has expired. Please request a new OTP.',
      };
    }

    // Verify OTP
    if (enteredOtp == _currentOtp) {
      final kycData = _generateMockKycData(_currentAadhaarNumber!);
      _clearOtpData();

      debugPrint('✅ OTP verification successful');
      return {
        'success': true,
        'message': 'Aadhaar verification successful',
        'kycData': kycData,
      };
    } else {
      return {'success': false, 'message': 'Invalid OTP. Please try again.'};
    }
  }

  /// Get current OTP (for testing/debugging)
  static String? getCurrentOtp() => _currentOtp;

  /// Check if OTP is still valid
  static bool isOtpValid() {
    if (_currentOtp == null || _otpGeneratedAt == null) return false;

    final now = DateTime.now();
    final otpAge = now.difference(_otpGeneratedAt!);
    return otpAge.inMinutes <= _otpValidityMinutes;
  }

  /// Get remaining OTP validity time in seconds
  static int getRemainingOtpTime() {
    if (_otpGeneratedAt == null) return 0;

    final now = DateTime.now();
    final otpAge = now.difference(_otpGeneratedAt!);
    final remainingSeconds = (_otpValidityMinutes * 60) - otpAge.inSeconds;

    return remainingSeconds > 0 ? remainingSeconds : 0;
  }

  /// Clear OTP data
  static void _clearOtpData() {
    _currentOtp = null;
    _currentAadhaarNumber = null;
    _otpGeneratedAt = null;
  }

  /// Validate Aadhaar number format
  static bool _isValidAadhaarNumber(String aadhaarNumber) {
    // Basic validation: 12 digits, not all same digits
    if (aadhaarNumber.length != 12) return false;
    if (!RegExp(r'^\d{12}$').hasMatch(aadhaarNumber)) return false;

    // Check if all digits are same (invalid)
    final firstDigit = aadhaarNumber[0];
    if (aadhaarNumber.split('').every((digit) => digit == firstDigit)) {
      return false;
    }

    return true;
  }

  /// Generate mock KYC data for successful verification
  static Map<String, dynamic> _generateMockKycData(String aadhaarNumber) {
    final names = [
      'Raj Kumar',
      'Priya Sharma',
      'Amit Singh',
      'Sunita Devi',
      'Rohit Gupta',
    ];
    final cities = ['Delhi', 'Mumbai', 'Bangalore', 'Chennai', 'Kolkata'];
    final states = [
      'Delhi',
      'Maharashtra',
      'Karnataka',
      'Tamil Nadu',
      'West Bengal',
    ];

    final random = Random();
    final nameIndex = random.nextInt(names.length);
    final cityIndex = random.nextInt(cities.length);

    return {
      'aadhaarNumber': aadhaarNumber,
      'name': names[nameIndex],
      'fatherName': 'Father of ${names[nameIndex]}',
      'dateOfBirth':
          '1990-0${random.nextInt(9) + 1}-${(random.nextInt(28) + 1).toString().padLeft(2, '0')}',
      'gender': random.nextBool() ? 'Male' : 'Female',
      'address': {
        'street': '${random.nextInt(999) + 1} Main Street',
        'city': cities[cityIndex],
        'state': states[cityIndex],
        'pincode': '${random.nextInt(899999) + 100000}',
      },
      'phoneNumber': '+91${random.nextInt(900000000) + 1000000000}',
      'verifiedAt': DateTime.now().toIso8601String(),
    };
  }

  /// Reset service (for testing)
  static void reset() {
    _clearOtpData();
    debugPrint('🔄 LocalAadhaarService reset');
  }
}
