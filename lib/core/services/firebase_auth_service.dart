import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Firebase Authentication Service
class FirebaseAuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get current user
  static User? get currentUser => _auth.currentUser;

  /// Get user stream for listening to auth changes
  static Stream<User?> get userStream => _auth.authStateChanges();

  /// Check if user is logged in
  static bool get isLoggedIn => _auth.currentUser != null;

  /// Register with email and password
  static Future<Map<String, dynamic>> registerWithEmailPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      // Create user with email and password
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Update display name
      await userCredential.user?.updateDisplayName(displayName);
      await userCredential.user?.reload();

      debugPrint('🔥 Firebase Auth: User registered successfully');

      return {
        'success': true,
        'user': userCredential.user,
        'message': 'Registration successful',
      };
    } on FirebaseAuthException catch (e) {
      debugPrint('🔥 Firebase Auth Error: ${e.code} - ${e.message}');

      String errorMessage;
      switch (e.code) {
        case 'weak-password':
          errorMessage = 'The password provided is too weak.';
          break;
        case 'email-already-in-use':
          errorMessage = 'An account already exists for this email.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is not valid.';
          break;
        default:
          errorMessage = e.message ?? 'Registration failed. Please try again.';
      }

      return {'success': false, 'message': errorMessage};
    } catch (e) {
      debugPrint('🔥 Firebase Auth Unexpected Error: $e');
      return {
        'success': false,
        'message': 'An unexpected error occurred. Please try again.',
      };
    }
  }

  /// Sign in with email and password
  static Future<Map<String, dynamic>> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);

      debugPrint('🔥 Firebase Auth: User signed in successfully');

      return {
        'success': true,
        'user': userCredential.user,
        'message': 'Sign in successful',
      };
    } on FirebaseAuthException catch (e) {
      debugPrint('🔥 Firebase Auth Error: ${e.code} - ${e.message}');

      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found for this email.';
          break;
        case 'wrong-password':
          errorMessage = 'Wrong password provided.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is not valid.';
          break;
        case 'user-disabled':
          errorMessage = 'This user account has been disabled.';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many failed attempts. Try again later.';
          break;
        default:
          errorMessage = e.message ?? 'Sign in failed. Please try again.';
      }

      return {'success': false, 'message': errorMessage};
    } catch (e) {
      debugPrint('🔥 Firebase Auth Unexpected Error: $e');
      return {
        'success': false,
        'message': 'An unexpected error occurred. Please try again.',
      };
    }
  }

  /// Send password reset email
  static Future<Map<String, dynamic>> sendPasswordResetEmail({
    required String email,
  }) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);

      debugPrint('🔥 Firebase Auth: Password reset email sent');

      return {
        'success': true,
        'message': 'Password reset email sent successfully',
      };
    } on FirebaseAuthException catch (e) {
      debugPrint('🔥 Firebase Auth Error: ${e.code} - ${e.message}');

      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found for this email.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is not valid.';
          break;
        default:
          errorMessage = e.message ?? 'Failed to send reset email.';
      }

      return {'success': false, 'message': errorMessage};
    } catch (e) {
      debugPrint('🔥 Firebase Auth Unexpected Error: $e');
      return {
        'success': false,
        'message': 'An unexpected error occurred. Please try again.',
      };
    }
  }

  /// Sign out
  static Future<void> signOut() async {
    try {
      await _auth.signOut();
      debugPrint('🔥 Firebase Auth: User signed out');
    } catch (e) {
      debugPrint('🔥 Firebase Auth Sign Out Error: $e');
      rethrow;
    }
  }

  /// Delete user account
  static Future<Map<String, dynamic>> deleteAccount() async {
    try {
      await _auth.currentUser?.delete();
      debugPrint('🔥 Firebase Auth: User account deleted');

      return {'success': true, 'message': 'Account deleted successfully'};
    } on FirebaseAuthException catch (e) {
      debugPrint('🔥 Firebase Auth Delete Error: ${e.code} - ${e.message}');

      String errorMessage;
      switch (e.code) {
        case 'requires-recent-login':
          errorMessage = 'Please sign in again to delete your account.';
          break;
        default:
          errorMessage = e.message ?? 'Failed to delete account.';
      }

      return {'success': false, 'message': errorMessage};
    } catch (e) {
      debugPrint('🔥 Firebase Auth Unexpected Error: $e');
      return {
        'success': false,
        'message': 'An unexpected error occurred. Please try again.',
      };
    }
  }

  /// Update user email
  static Future<Map<String, dynamic>> updateEmail({
    required String newEmail,
  }) async {
    try {
      await _auth.currentUser?.updateEmail(newEmail);
      debugPrint('🔥 Firebase Auth: Email updated successfully');

      return {'success': true, 'message': 'Email updated successfully'};
    } on FirebaseAuthException catch (e) {
      debugPrint(
        '🔥 Firebase Auth Update Email Error: ${e.code} - ${e.message}',
      );

      String errorMessage;
      switch (e.code) {
        case 'invalid-email':
          errorMessage = 'The email address is not valid.';
          break;
        case 'email-already-in-use':
          errorMessage = 'This email is already in use by another account.';
          break;
        case 'requires-recent-login':
          errorMessage = 'Please sign in again to update your email.';
          break;
        default:
          errorMessage = e.message ?? 'Failed to update email.';
      }

      return {'success': false, 'message': errorMessage};
    } catch (e) {
      debugPrint('🔥 Firebase Auth Unexpected Error: $e');
      return {
        'success': false,
        'message': 'An unexpected error occurred. Please try again.',
      };
    }
  }

  /// Update user password
  static Future<Map<String, dynamic>> updatePassword({
    required String newPassword,
  }) async {
    try {
      await _auth.currentUser?.updatePassword(newPassword);
      debugPrint('🔥 Firebase Auth: Password updated successfully');

      return {'success': true, 'message': 'Password updated successfully'};
    } on FirebaseAuthException catch (e) {
      debugPrint(
        '🔥 Firebase Auth Update Password Error: ${e.code} - ${e.message}',
      );

      String errorMessage;
      switch (e.code) {
        case 'weak-password':
          errorMessage = 'The password provided is too weak.';
          break;
        case 'requires-recent-login':
          errorMessage = 'Please sign in again to update your password.';
          break;
        default:
          errorMessage = e.message ?? 'Failed to update password.';
      }

      return {'success': false, 'message': errorMessage};
    } catch (e) {
      debugPrint('🔥 Firebase Auth Unexpected Error: $e');
      return {
        'success': false,
        'message': 'An unexpected error occurred. Please try again.',
      };
    }
  }
}
