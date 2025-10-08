import 'package:agrichain/core/models/user_model.dart';
import 'package:agrichain/core/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'dart:math';

class AuthFirebaseService {
  static final firebase_auth.FirebaseAuth _auth =
      firebase_auth.FirebaseAuth.instance;

  /// Register user with Firebase Auth (with fallback for SSL issues)
  static Future<User?> registerWithFirebase({
    required String email,
    required String password,
    required Map<String, dynamic> userData,
  }) async {
    try {
      print('🔥 Attempting Firebase registration for: $email');

      // Try Firebase authentication
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        print('✅ Firebase registration successful');

        // Add Firebase UID to user data
        userData['firebaseUid'] = credential.user!.uid;

        // Use existing AuthService for session management
        return await AuthService.instance.register(userData);
      }
    } catch (e) {
      print('❌ Firebase registration failed: $e');

      // Check if it's SSL certificate error
      if (e.toString().contains('CertPathValidatorException') ||
          e.toString().contains('Trust anchor')) {
        print('🔄 SSL certificate issue detected, using fallback registration');
        return await _fallbackRegistration(email, password, userData);
      }

      throw e;
    }

    return null;
  }

  /// Fallback registration when Firebase fails due to SSL issues
  static Future<User?> _fallbackRegistration(
    String email,
    String password,
    Map<String, dynamic> userData,
  ) async {
    try {
      // Generate a mock Firebase UID for development
      final mockFirebaseUid =
          'dev_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';
      userData['firebaseUid'] = mockFirebaseUid;

      print('🔧 Using mock Firebase UID: $mockFirebaseUid');
      print('⚠️ Development mode: Bypassing Firebase authentication');

      // Use existing AuthService for session management
      return await AuthService.instance.register(userData);
    } catch (e) {
      print('❌ Fallback registration failed: $e');
      rethrow;
    }
  }

  /// Login with Firebase Auth (with fallback for SSL issues)
  static Future<User?> loginWithFirebase({
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      print('🔥 Attempting Firebase login for: $email');

      // Try Firebase authentication
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        print('✅ Firebase login successful');

        // Use existing AuthService for session management
        return await AuthService.instance.login(email, password, role);
      }
    } catch (e) {
      print('❌ Firebase login failed: $e');

      // Enhanced SSL certificate error detection
      final errorString = e.toString().toLowerCase();
      final isSSLError = errorString.contains('certpathvalidatorexception') ||
          errorString.contains('trust anchor') ||
          errorString.contains('certificate') ||
          errorString.contains('ssl') ||
          errorString.contains('tls') ||
          errorString.contains('handshake') ||
          errorString.contains('network error') ||
          errorString.contains('internal error');

      if (isSSLError) {
        print('🔄 SSL/Certificate issue detected, using fallback authentication');
        print('📱 Attempting local authentication bypass...');
        
        try {
          // Use local authentication fallback
          final fallbackUser = await AuthService.instance.login(email, password, role);
          if (fallbackUser != null) {
            print('✅ Fallback authentication successful');
            return fallbackUser;
          }
        } catch (fallbackError) {
          print('❌ Fallback authentication also failed: $fallbackError');
        }
      }

      // If not SSL error or fallback failed, rethrow original error
      rethrow;
    }

    return null;
  }

  /// Sign out from Firebase
  static Future<void> signOut() async {
    try {
      await _auth.signOut();
      await AuthService.instance.logout();
    } catch (e) {
      print('❌ Firebase signout failed: $e');
      // Continue with local logout even if Firebase fails
      await AuthService.instance.logout();
    }
  }
}
