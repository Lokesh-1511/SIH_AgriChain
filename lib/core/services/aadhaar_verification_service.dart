import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

/// Service for Real Aadhaar ID Verification using UIDAI API
/// Integrates with Python FastAPI backend for KYC across all user roles
class AadhaarVerificationService {
  // Updated URLs for Node.js backend
  static String get _baseUrl {
    if (kDebugMode) {
      // Platform-specific URLs for development (Node.js backend on port 3000)
      if (kIsWeb) {
        return 'http://localhost:3000'; // Web
      } else if (Platform.isAndroid) {
        return 'http://10.252.175.5:3000'; // Physical Android device - use host machine IP
      } else {
        return 'http://localhost:3000'; // iOS simulator, desktop
      }
    } else {
      return 'https://your-production-api.com'; // Production URL
    }
  }

  static const Duration _timeoutDuration = Duration(
    seconds: 10,
  ); // Shorter timeout for faster feedback

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
        'http://10.252.175.5:3000', // Physical Android device - host machine IP
        'http://10.0.2.2:3000', // Fallback for emulator
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
            .timeout(const Duration(seconds: 8));

        debugPrint('📊 Response status: ${response.statusCode}');

        if (response.statusCode == 200) {
          debugPrint('✅ Backend connection successful!');
          final data = json.decode(response.body);
          debugPrint('� Backend: ${data['service']} v${data['version']}');
          debugPrint('🎯 Using base URL: $baseUrl');
          return true;
        } else {
          debugPrint('❌ HTTP ${response.statusCode}: ${response.body}');
        }
      } on SocketException catch (e) {
        debugPrint('🔌 Socket error for $baseUrl: $e');
      } on TimeoutException catch (e) {
        debugPrint('⏱️ Timeout connecting to $baseUrl: $e');
      } catch (e) {
        debugPrint('❌ Connection error for $baseUrl: $e');
      }
    }

    debugPrint('� ALL CONNECTION ATTEMPTS FAILED');
    debugPrint('💡 Troubleshooting:');
    debugPrint(
      '   1. Check if Node.js backend is running: cd backend && node server.js',
    );
    debugPrint('   2. Backend should be on port 3000');
    debugPrint('   3. For Android emulator, use: http://10.0.2.2:3000');
    debugPrint('   4. Tested URLs: ${urlsToTry.join(', ')}');
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
      // Test backend connection first
      final isConnected = await testConnection();
      if (!isConnected) {
        throw AadhaarVerificationException(
          'Cannot connect to verification server. Please check if backend is running.',
          AadhaarErrorCode.networkError,
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
      debugPrint('🔍 Parsed Response Data: $responseData');

      if (response.statusCode == 200) {
        debugPrint('✅ OTP sent successfully');
        debugPrint('🔑 Transaction ID: ${responseData['transaction_id']}');
        debugPrint('📱 Debug OTP: ${responseData['debug_otp']}');
        return AadhaarInitiateResponse.fromJson(responseData);
      } else if (response.statusCode == 429) {
        throw AadhaarVerificationException(
          'Too many OTP requests. Please try again later.',
          AadhaarErrorCode.rateLimitExceeded,
        );
      } else {
        // Handle different types of validation errors
        String errorMessage =
            responseData['detail'] ??
            responseData['message'] ??
            'Failed to send OTP';
        String? errorCode = responseData['error_code'];

        // Provide specific error messages for Aadhaar validation failures
        if (errorCode != null) {
          switch (errorCode) {
            case 'FAKE_PATTERN':
              errorMessage =
                  'Invalid Aadhaar Number!\n${responseData['message']}\nPlease enter a real Aadhaar number.';
              break;
            case 'INVALID_CHECKSUM':
              errorMessage =
                  'Fake Aadhaar Detected!\nThis number failed official validation.\nPlease enter your real Aadhaar number.';
              break;
            case 'TOO_REPETITIVE':
              errorMessage =
                  'Invalid Aadhaar Format!\n${responseData['message']}\nReal Aadhaar numbers have varied digits.';
              break;
            case 'INVALID_PREFIX':
              errorMessage =
                  'Invalid Aadhaar Number!\n${responseData['message']}\nReal Aadhaar numbers start with digits 2-9.';
              break;
            case 'INVALID_LENGTH':
              errorMessage =
                  'Incomplete Aadhaar Number!\nAadhaar must be exactly 12 digits.\nPlease check and enter again.';
              break;
            case 'INVALID_FORMAT':
              errorMessage =
                  'Invalid Characters!\nAadhaar numbers contain only digits (0-9).\nPlease remove any spaces or special characters.';
              break;
            default:
              errorMessage = responseData['message'] ?? errorMessage;
          }
        }

        throw AadhaarVerificationException(
          errorMessage,
          AadhaarErrorCode.invalidAadhaar,
        );
      }
    } on AadhaarVerificationException {
      rethrow;
    } on http.ClientException catch (e) {
      debugPrint('❌ Network Connection Error: $e');
      throw AadhaarVerificationException(
        'Cannot connect to server. Please check if backend is running on $_baseUrl',
        AadhaarErrorCode.networkError,
      );
    } catch (e) {
      debugPrint('❌ Aadhaar initiation error: $e');
      throw AadhaarVerificationException(
        'Network error: ${e.toString()}',
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

      final url = Uri.parse('$_baseUrl/api/otp/verify');

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

  /// Test backend connectivity and server health
  static Future<bool> testConnectivity() async {
    try {
      debugPrint('🔍 Testing backend connectivity...');
      debugPrint('🌐 Backend URL: $_baseUrl');

      final url = Uri.parse('$_baseUrl/api/health');
      final response = await http
          .get(url, headers: _headers)
          .timeout(Duration(seconds: 10));

      debugPrint('🏥 Health Check Status: ${response.statusCode}');
      debugPrint('📄 Health Check Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('✅ Backend is healthy: ${data['status']}');
        return true;
      } else {
        debugPrint('⚠️ Backend health check failed');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Backend connectivity test failed: $e');
      return false;
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
      name: json['name'] ?? 'Verified User',
      maskedAadhaar: json['masked_aadhaar'] ?? '',
      verificationStatus: 'VERIFIED',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'masked_aadhaar': maskedAadhaar,
      'verification_status': verificationStatus,
    };
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
