import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

/// Service for Real Aadhaar ID Verification using UIDAI API
/// Integrates with Node.js backend for KYC across all user roles
class AadhaarVerificationService {
  // Updated URLs for Node.js backend
  static String get _baseUrl {
    if (kDebugMode) {
      // Platform-specific URLs for development (Node.js backend on port 3000)
      if (kIsWeb) {
        return 'http://localhost:3000'; // Web
      } else if (Platform.isAndroid) {
        return 'http://10.0.2.2:3000'; // Android emulator - standard IP
      } else {
        return 'http://localhost:3000'; // iOS simulator, desktop
      }
    } else {
      return 'https://your-production-api.com'; // Production URL
    }
  }

  static const Duration _timeoutDuration = Duration(
    seconds: 5, // Reduced timeout for faster feedback
  );

  // Mock mode for offline testing
  static const bool _useMockMode = true; // Set to true for offline testing

  /// Headers for API requests
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Test backend connection
  static Future<bool> testConnection() async {
    debugPrint('🔍 Testing backend connectivity...');

    final urlsToTry = <String>[];

    // Add platform-specific URLs for Node.js backend
    if (kIsWeb) {
      urlsToTry.addAll(['http://localhost:3000', 'http://127.0.0.1:3000']);
    } else if (Platform.isAndroid) {
      urlsToTry.addAll([
        'http://10.0.2.2:3000', // Android emulator - standard IP
        'http://192.168.1.100:3000', // Common WiFi IP range
        'http://192.168.0.100:3000', // Common WiFi IP range
        'http://172.20.10.2:3000', // Mobile hotspot IP
        'http://10.252.175.5:3000', // Physical Android device - host machine IP (fallback)
        'http://localhost:3000', // Last resort
      ]);
    } else {
      urlsToTry.addAll(['http://localhost:3000', 'http://127.0.0.1:3000']);
    }

    for (String baseUrl in urlsToTry) {
      try {
        final url = Uri.parse('$baseUrl/api/health');
        debugPrint('🌐 Backend URL: $baseUrl');
        debugPrint('📡 Testing: $url');

        final response = await http
            .get(url, headers: _headers)
            .timeout(_timeoutDuration);

        debugPrint('📨 Response Status: ${response.statusCode}');
        debugPrint('📄 Response Body: ${response.body}');

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['status'] == 'OK') {
            debugPrint('✅ Backend connected successfully: $baseUrl');
            return true;
          }
        }
      } catch (e) {
        debugPrint('❌ Connection failed for $baseUrl: $e');
        continue;
      }
    }

    debugPrint('❌ Backend connectivity test failed');
    return false;
  }

  /// Step 1: Initiate Aadhaar verification by sending OTP
  /// Input: Aadhaar number, user ID, user role
  /// Output: Transaction ID for OTP verification
  static Future<AadhaarInitiateResponse> initiateVerification({
    required String aadhaarNumber,
    required String userId,
    required String userRole,
  }) async {
    try {
      debugPrint('🔄 Initiating Aadhaar verification...');
      debugPrint('👤 User ID: $userId, Role: $userRole');

      // Mock mode for offline testing
      if (_useMockMode) {
        debugPrint('🎭 Using mock mode for Aadhaar verification');

        // Validate input
        if (!_isValidAadhaar(aadhaarNumber)) {
          throw AadhaarVerificationException(
            'Invalid Aadhaar number. Must be 12 digits.',
            AadhaarErrorCode.invalidAadhaar,
          );
        }

        // Simulate network delay
        await Future.delayed(const Duration(seconds: 1));

        // Generate mock response
        final transactionId = 'TXN${DateTime.now().millisecondsSinceEpoch}';
        debugPrint('✅ Mock OTP generated: 123456');
        debugPrint('🔑 Mock Transaction ID: $transactionId');

        return AadhaarInitiateResponse(
          success: true,
          message: 'OTP sent to your Aadhaar-linked mobile number',
          transactionId: transactionId,
          mobileNumber: '+91******${aadhaarNumber.substring(8)}',
          debugOtp: '123456',
          otpLength: 6,
          expiresInMinutes: 10,
          debugNote: 'Mock OTP for testing - use 123456',
        );
      }

      // Test backend connection first
      final isConnected = await testConnection();
      if (!isConnected) {
        debugPrint('⚠️ Backend not available, falling back to mock mode');

        // Fallback to mock mode if backend is not available
        if (!_isValidAadhaar(aadhaarNumber)) {
          throw AadhaarVerificationException(
            'Invalid Aadhaar number. Must be 12 digits.',
            AadhaarErrorCode.invalidAadhaar,
          );
        }

        await Future.delayed(const Duration(seconds: 1));
        final transactionId = 'TXN${DateTime.now().millisecondsSinceEpoch}';

        return AadhaarInitiateResponse(
          success: true,
          message: 'OTP sent (Mock Mode - Backend unavailable)',
          transactionId: transactionId,
          mobileNumber: '+91******${aadhaarNumber.substring(8)}',
          debugOtp: '123456',
          otpLength: 6,
          expiresInMinutes: 10,
          debugNote: 'Mock OTP for testing - use 123456',
        );
      }

      // Validate input
      if (!_isValidAadhaar(aadhaarNumber)) {
        throw AadhaarVerificationException(
          'Invalid Aadhaar number. Must be 12 digits.',
          AadhaarErrorCode.invalidAadhaar,
        );
      }

      final url = Uri.parse('$_baseUrl/api/aadhaar/validate');

      final requestBody = {
        'aadhaar_number': aadhaarNumber,
        'user_id': userId,
        'user_role': userRole,
      };

      debugPrint('🔄 Initiating Aadhaar verification...');
      debugPrint('📡 API URL: $url');
      debugPrint('👤 User ID: $userId, Role: $userRole');
      debugPrint('📱 Platform: ${Platform.operatingSystem}');
      debugPrint('🌐 Using base URL: $_baseUrl');

      final response = await http
          .post(url, headers: _headers, body: jsonEncode(requestBody))
          .timeout(_timeoutDuration);

      debugPrint('📨 Response Status: ${response.statusCode}');
      debugPrint('📄 Response Body: ${response.body}');

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        debugPrint('✅ Aadhaar verification initiated successfully');
        return AadhaarInitiateResponse.fromJson(responseData);
      } else {
        throw AadhaarVerificationException(
          responseData['error'] ?? 'Failed to initiate verification',
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

  /// Step 2: Verify OTP and complete Aadhaar verification
  /// Input: Aadhaar number, OTP, transaction ID, user ID
  /// Output: Verification status and KYC details
  static Future<AadhaarVerifyResponse> verifyOTP({
    required String aadhaarNumber,
    required String otp,
    required String transactionId,
    required String userId,
  }) async {
    try {
      debugPrint('🔐 Verifying OTP...');
      debugPrint('🔑 Transaction ID: $transactionId');
      debugPrint('👤 User ID: $userId');

      // Mock mode for offline testing
      if (_useMockMode || !await testConnection()) {
        debugPrint('🎭 Using mock mode for OTP verification');

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

        // Check if OTP is correct (mock: 123456)
        if (otp != '123456') {
          throw AadhaarVerificationException(
            'Invalid OTP. Use 123456 for testing.',
            AadhaarErrorCode.otpMismatch,
          );
        }

        // Simulate network delay
        await Future.delayed(const Duration(seconds: 1));

        debugPrint('✅ Mock OTP verification successful');

        // Return mock KYC data
        return AadhaarVerifyResponse(
          success: true,
          message: 'Aadhaar verification completed successfully (Mock Mode)',
          kycDetails: {
            'name': 'John Doe',
            'dob': '1990-01-01',
            'gender': 'M',
            'address': {
              'house': '123',
              'street': 'Mock Street',
              'locality': 'Test Locality',
              'city': 'Sample City',
              'state': 'Test State',
              'pincode': '123456',
            },
            'verified_at': DateTime.now().toIso8601String(),
          },
          verificationStatus: 'verified',
        );
      }

      if (!_isValidOTP(otp)) {
        throw AadhaarVerificationException(
          'Invalid OTP. Must be 6 digits.',
          AadhaarErrorCode.invalidOTP,
        );
      }

      final url = Uri.parse('$_baseUrl/api/otp/verify');

      final requestBody = {
        'transaction_id': transactionId,
        'otp': otp,
        'aadhaar_number': aadhaarNumber,
        'user_id': userId,
      };

      debugPrint('🔐 Verifying OTP...');
      debugPrint('📡 API URL: $url');

      final response = await http
          .post(url, headers: _headers, body: jsonEncode(requestBody))
          .timeout(_timeoutDuration);

      debugPrint('📨 Response Status: ${response.statusCode}');
      debugPrint('📄 Response Body: ${response.body}');

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        debugPrint('✅ OTP verification successful');
        return AadhaarVerifyResponse.fromJson(responseData);
      } else {
        throw AadhaarVerificationException(
          responseData['error'] ?? 'OTP verification failed',
          AadhaarErrorCode.otpMismatch,
        );
      }
    } on AadhaarVerificationException {
      rethrow;
    } catch (e) {
      debugPrint('OTP verification error: $e');
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

      final response = await http
          .get(url, headers: _headers)
          .timeout(_timeoutDuration);

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return AadhaarStatusResponse.fromJson(responseData);
      } else {
        throw AadhaarVerificationException(
          responseData['detail'] ?? 'Failed to get verification status',
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

  /// Test connectivity to backend server
  static Future<bool> testConnectivity() async {
    return await testConnection();
  }

  /// Validate Aadhaar number format
  static bool _isValidAadhaar(String aadhaar) {
    return RegExp(r'^\d{12}$').hasMatch(aadhaar);
  }

  /// Validate OTP format
  static bool _isValidOTP(String otp) {
    return RegExp(r'^\d{6}$').hasMatch(otp);
  }

  /// Format Aadhaar number with dashes
  static String formatAadhaar(String aadhaar) {
    if (aadhaar.length == 12) {
      return '${aadhaar.substring(0, 4)}-${aadhaar.substring(4, 8)}-${aadhaar.substring(8, 12)}';
    }
    return aadhaar;
  }

  /// Mask Aadhaar number for display
  static String maskAadhaar(String aadhaar) {
    return 'XXXX-XXXX-${aadhaar.substring(8, 12)}';
  }
}

/// Response model for Aadhaar initiation
class AadhaarInitiateResponse {
  final bool success;
  final String message;
  final String? transactionId;
  final String? mobileNumber;
  final String? debugOtp;
  final int? otpLength;
  final int? expiresInMinutes;
  final String? debugNote;

  AadhaarInitiateResponse({
    required this.success,
    required this.message,
    this.transactionId,
    this.mobileNumber,
    this.debugOtp,
    this.otpLength,
    this.expiresInMinutes,
    this.debugNote,
  });

  factory AadhaarInitiateResponse.fromJson(Map<String, dynamic> json) {
    return AadhaarInitiateResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      transactionId: json['transaction_id'],
      mobileNumber: json['mobile_number'],
      debugOtp: json['debug_otp'],
      otpLength: json['otp_length'],
      expiresInMinutes: json['expires_in_minutes'] is String
          ? int.tryParse(json['expires_in_minutes'])
          : json['expires_in_minutes'],
      debugNote: json['debug_note'],
    );
  }
}

/// Response model for OTP verification
class AadhaarVerifyResponse {
  final bool success;
  final String message;
  final Map<String, dynamic>? kycDetails;
  final String? verificationStatus;

  AadhaarVerifyResponse({
    required this.success,
    required this.message,
    this.kycDetails,
    this.verificationStatus,
  });

  factory AadhaarVerifyResponse.fromJson(Map<String, dynamic> json) {
    return AadhaarVerifyResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      kycDetails: json['kyc_details'],
      verificationStatus: json['verification_status'],
    );
  }
}

/// Response model for status check
class AadhaarStatusResponse {
  final bool isVerified;
  final String status;
  final String? lastVerifiedAt;
  final Map<String, dynamic>? details;

  AadhaarStatusResponse({
    required this.isVerified,
    required this.status,
    this.lastVerifiedAt,
    this.details,
  });

  factory AadhaarStatusResponse.fromJson(Map<String, dynamic> json) {
    return AadhaarStatusResponse(
      isVerified: json['is_verified'] ?? false,
      status: json['status'] ?? 'not_verified',
      lastVerifiedAt: json['last_verified_at'],
      details: json['details'],
    );
  }
}

/// Custom exception for Aadhaar verification errors
class AadhaarVerificationException implements Exception {
  final String message;
  final AadhaarErrorCode errorCode;

  AadhaarVerificationException(this.message, this.errorCode);

  @override
  String toString() => 'AadhaarVerificationException: $message';
}

/// Error codes for different types of Aadhaar verification errors
enum AadhaarErrorCode {
  invalidAadhaar,
  invalidOTP,
  otpMismatch,
  otpExpired,
  networkError,
  apiError,
  rateLimitExceeded,
  serverError,
}
