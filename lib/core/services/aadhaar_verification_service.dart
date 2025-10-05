import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

/// Service for Real Aadhaar ID Verification using UIDAI API
/// Integrates with Python FastAPI backend for KYC across all user roles
class AadhaarVerificationService {
  static const String _baseUrl = kDebugMode
      ? 'http://10.0.2.2:8000' // Android emulator - maps to host localhost:8000
      : 'https://your-production-api.com'; // Production URL

  static const String _apiVersion = '/api/v1';
  static const Duration _timeoutDuration = Duration(seconds: 30);

  /// Headers for API requests
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Step 1: Initiate Aadhaar verification by sending OTP
  /// Input: Aadhaar number, user ID, user role
  /// Output: Transaction ID for OTP verification
  static Future<AadhaarInitiateResponse> initiateVerification({
    required String aadhaarNumber,
    required String userId,
    required String userRole,
  }) async {
    try {
      // Validate input
      if (!_isValidAadhaar(aadhaarNumber)) {
        throw AadhaarVerificationException(
          'Invalid Aadhaar number. Must be 12 digits.',
          AadhaarErrorCode.invalidAadhaar,
        );
      }

      final url = Uri.parse('$_baseUrl/aadhaar/initiate');

      final requestBody = {
        'aadhaar_number': aadhaarNumber,
        'user_id': userId,
        'user_role': userRole,
      };

      debugPrint('Initiating Aadhaar verification for user: $userId');

      final response = await http
          .post(url, headers: _headers, body: jsonEncode(requestBody))
          .timeout(_timeoutDuration);

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        debugPrint('OTP sent successfully');
        return AadhaarInitiateResponse.fromJson(responseData);
      } else if (response.statusCode == 429) {
        throw AadhaarVerificationException(
          'Too many OTP requests. Please try again later.',
          AadhaarErrorCode.rateLimitExceeded,
        );
      } else {
        throw AadhaarVerificationException(
          responseData['detail'] ?? 'Failed to send OTP',
          AadhaarErrorCode.apiError,
        );
      }
    } on AadhaarVerificationException {
      rethrow;
    } catch (e) {
      debugPrint('Aadhaar initiation error: $e');
      throw AadhaarVerificationException(
        'Network error. Please check your connection and try again.',
        AadhaarErrorCode.networkError,
      );
    }
  }

  /// Step 2: Verify OTP and complete KYC
  /// Input: Aadhaar number, OTP, transaction ID, user ID
  /// Output: Verification status and KYC details
  static Future<AadhaarVerifyResponse> verifyOTP({
    required String aadhaarNumber,
    required String otp,
    required String transactionId,
    required String userId,
  }) async {
    try {
      // Validate input
      if (!_isValidAadhaar(aadhaarNumber)) {
        throw AadhaarVerificationException(
          'Invalid Aadhaar number',
          AadhaarErrorCode.invalidAadhaar,
        );
      }

      if (!_isValidOTP(otp)) {
        throw AadhaarVerificationException(
          'Invalid OTP. Must be 6 digits.',
          AadhaarErrorCode.invalidOTP,
        );
      }

      final url = Uri.parse('$_baseUrl/aadhaar/verify');

      final requestBody = {
        'aadhaar_number': aadhaarNumber,
        'otp': otp,
        'transaction_id': transactionId,
        'user_id': userId,
      };

      debugPrint('Verifying OTP for transaction: $transactionId');

      final response = await http
          .post(url, headers: _headers, body: jsonEncode(requestBody))
          .timeout(_timeoutDuration);

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        debugPrint('Aadhaar verified successfully');
        return AadhaarVerifyResponse.fromJson(responseData);
      } else if (response.statusCode == 400) {
        throw AadhaarVerificationException(
          responseData['detail'] ?? 'Invalid OTP',
          AadhaarErrorCode.invalidOTP,
        );
      } else if (response.statusCode == 404) {
        throw AadhaarVerificationException(
          'Transaction not found or expired',
          AadhaarErrorCode.transactionExpired,
        );
      } else {
        throw AadhaarVerificationException(
          responseData['detail'] ?? 'Verification failed',
          AadhaarErrorCode.apiError,
        );
      }
    } on AadhaarVerificationException {
      rethrow;
    } catch (e) {
      debugPrint('Aadhaar verification error: $e');
      throw AadhaarVerificationException(
        'Network error. Please check your connection and try again.',
        AadhaarErrorCode.networkError,
      );
    }
  }

  /// Get Aadhaar verification status for a user
  static Future<AadhaarStatusResponse> getVerificationStatus({
    required String userId,
    required String userRole,
  }) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/aadhaar/status/$userId?user_role=$userRole',
      );

      debugPrint('Checking Aadhaar status for user: $userId');

      final response = await http
          .get(url, headers: _headers)
          .timeout(_timeoutDuration);

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return AadhaarStatusResponse.fromJson(responseData);
      } else {
        throw AadhaarVerificationException(
          responseData['detail'] ?? 'Failed to get status',
          AadhaarErrorCode.apiError,
        );
      }
    } catch (e) {
      debugPrint('Status check error: $e');
      throw AadhaarVerificationException(
        'Failed to check verification status',
        AadhaarErrorCode.networkError,
      );
    }
  }

  /// Validate Aadhaar number format
  static bool _isValidAadhaar(String aadhaar) {
    return RegExp(r'^\d{12}$').hasMatch(aadhaar);
  }

  /// Validate OTP format
  static bool _isValidOTP(String otp) {
    return RegExp(r'^\d{6}$').hasMatch(otp);
  }

  /// Format Aadhaar number with dashes (XXXX-XXXX-XXXX)
  static String formatAadhaar(String aadhaar) {
    if (aadhaar.length != 12) return aadhaar;
    return '${aadhaar.substring(0, 4)}-${aadhaar.substring(4, 8)}-${aadhaar.substring(8, 12)}';
  }

  /// Mask Aadhaar number for display (XXXX-XXXX-1234)
  static String maskAadhaar(String aadhaar) {
    if (aadhaar.length != 12) return aadhaar;
    return 'XXXX-XXXX-${aadhaar.substring(8, 12)}';
  }
}

/// Response model for Aadhaar initiation
class AadhaarInitiateResponse {
  final bool success;
  final String message;
  final String? transactionId;

  AadhaarInitiateResponse({
    required this.success,
    required this.message,
    this.transactionId,
  });

  factory AadhaarInitiateResponse.fromJson(Map<String, dynamic> json) {
    return AadhaarInitiateResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      transactionId: json['transaction_id'],
    );
  }
}

/// Response model for Aadhaar verification
class AadhaarVerifyResponse {
  final bool success;
  final String message;
  final KYCDetails? kycDetails;

  AadhaarVerifyResponse({
    required this.success,
    required this.message,
    this.kycDetails,
  });

  factory AadhaarVerifyResponse.fromJson(Map<String, dynamic> json) {
    return AadhaarVerifyResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      kycDetails: json['data']?['kyc_details'] != null
          ? KYCDetails.fromJson(json['data']['kyc_details'])
          : null,
    );
  }
}

/// Response model for Aadhaar status check
class AadhaarStatusResponse {
  final String userId;
  final bool aadhaarVerified;
  final String? aadhaarLast4;
  final DateTime? kycVerifiedAt;
  final String verificationStatus;

  AadhaarStatusResponse({
    required this.userId,
    required this.aadhaarVerified,
    this.aadhaarLast4,
    this.kycVerifiedAt,
    required this.verificationStatus,
  });

  factory AadhaarStatusResponse.fromJson(Map<String, dynamic> json) {
    return AadhaarStatusResponse(
      userId: json['user_id'] ?? '',
      aadhaarVerified: json['aadhaar_verified'] ?? false,
      aadhaarLast4: json['aadhaar_last4'],
      kycVerifiedAt: json['kyc_verified_at'] != null
          ? DateTime.parse(json['kyc_verified_at'])
          : null,
      verificationStatus: json['verification_status'] ?? 'PENDING',
    );
  }
}

/// KYC Details model
class KYCDetails {
  final String name;
  final String maskedAadhaar;
  final String verificationStatus;

  KYCDetails({
    required this.name,
    required this.maskedAadhaar,
    required this.verificationStatus,
  });

  factory KYCDetails.fromJson(Map<String, dynamic> json) {
    return KYCDetails(
      name: json['name'] ?? '',
      maskedAadhaar: json['masked_aadhaar'] ?? '',
      verificationStatus: json['verification_status'] ?? 'PENDING',
    );
  }
}

/// Aadhaar verification exception
class AadhaarVerificationException implements Exception {
  final String message;
  final AadhaarErrorCode errorCode;

  AadhaarVerificationException(this.message, this.errorCode);

  @override
  String toString() => 'AadhaarVerificationException: $message';
}

/// Error codes for Aadhaar verification
enum AadhaarErrorCode {
  invalidAadhaar,
  invalidOTP,
  rateLimitExceeded,
  transactionExpired,
  networkError,
  apiError,
  serverError,
}

/// Extension to get user-friendly error messages
extension AadhaarErrorCodeExtension on AadhaarErrorCode {
  String get message {
    switch (this) {
      case AadhaarErrorCode.invalidAadhaar:
        return 'Please enter a valid 12-digit Aadhaar number';
      case AadhaarErrorCode.invalidOTP:
        return 'Please enter a valid 6-digit OTP';
      case AadhaarErrorCode.rateLimitExceeded:
        return 'Too many requests. Please try again later';
      case AadhaarErrorCode.transactionExpired:
        return 'OTP expired. Please request a new one';
      case AadhaarErrorCode.networkError:
        return 'Network error. Please check your connection';
      case AadhaarErrorCode.apiError:
        return 'Verification failed. Please try again';
      case AadhaarErrorCode.serverError:
        return 'Server error. Please try again later';
    }
  }
}
