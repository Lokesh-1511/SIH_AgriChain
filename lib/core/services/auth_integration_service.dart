import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/agrichain_user.dart';
import 'firebase_auth_service.dart';
import 'mongodb_service.dart';

/// Integration service that combines Firebase Auth with MongoDB user storage
class AuthIntegrationService {
  /// Register a new user with email/password and store in MongoDB
  static Future<Map<String, dynamic>> registerUser({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String address,
    required UserRole role,
    required Map<String, dynamic> kycDetails,
    Map<String, dynamic>? additionalInfo,
  }) async {
    try {
      debugPrint('🔐 Starting user registration process...');

      // Step 1: Register with Firebase Auth
      final firebaseResult = await FirebaseAuthService.registerWithEmailPassword(
        email: email,
        password: password,
        displayName: name,
      );

      if (!firebaseResult['success']) {
        return {
          'success': false,
          'message': firebaseResult['message'],
          'step': 'firebase_auth',
        };
      }

      final User firebaseUser = firebaseResult['user'];
      debugPrint('🔐 Firebase registration successful: ${firebaseUser.uid}');

      // Step 2: Store user data in MongoDB
      final mongoResult = await MongoDBService.createUser(
        role: role.name,
        firebaseUid: firebaseUser.uid,
        email: email,
        name: name,
        phone: phone,
        kycDetails: kycDetails,
        additionalData: {
          'address': address,
          'isVerified': true, // Since Aadhaar is verified
          ...?additionalInfo,
        },
      );

      if (!mongoResult['success']) {
        // Rollback: Delete Firebase user if MongoDB insertion fails
        debugPrint('🔐 MongoDB insertion failed, rolling back Firebase user...');
        try {
          await firebaseUser.delete();
        } catch (rollbackError) {
          debugPrint('🔐 Rollback failed: $rollbackError');
        }

        return {
          'success': false,
          'message': mongoResult['message'],
          'step': 'mongodb_storage',
        };
      }

      debugPrint('🔐 User registration completed successfully');

      // Create AgriChainUser object
      final agriChainUser = AgriChainUser(
        id: mongoResult['userId'],
        firebaseUid: firebaseUser.uid,
        name: name,
        email: email,
        phone: phone,
        role: role,
        address: address,
        isVerified: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        kycDetails: kycDetails,
        additionalInfo: additionalInfo,
      );

      return {
        'success': true,
        'message': 'Registration successful',
        'user': agriChainUser,
        'firebaseUser': firebaseUser,
      };

    } catch (e) {
      debugPrint('🔐 Registration error: $e');
      return {
        'success': false,
        'message': 'An unexpected error occurred during registration',
        'step': 'unexpected_error',
      };
    }
  }

  /// Sign in user with email/password and retrieve from MongoDB
  static Future<Map<String, dynamic>> signInUser({
    required String email,
    required String password,
    required UserRole role,
  }) async {
    try {
      debugPrint('🔐 Starting user sign in process...');

      // Step 1: Sign in with Firebase Auth
      final firebaseResult = await FirebaseAuthService.signInWithEmailPassword(
        email: email,
        password: password,
      );

      if (!firebaseResult['success']) {
        return {
          'success': false,
          'message': firebaseResult['message'],
          'step': 'firebase_auth',
        };
      }

      final User firebaseUser = firebaseResult['user'];
      debugPrint('🔐 Firebase sign in successful: ${firebaseUser.uid}');

      // Step 2: Retrieve user data from MongoDB
      final userData = await MongoDBService.getUserByFirebaseUid(
        role: role.name,
        firebaseUid: firebaseUser.uid,
      );

      if (userData == null) {
        return {
          'success': false,
          'message': 'User data not found in database. Please contact support.',
          'step': 'mongodb_retrieval',
        };
      }

      debugPrint('🔐 User data retrieved successfully');

      // Create AgriChainUser object
      final agriChainUser = AgriChainUser.fromJson(userData);

      return {
        'success': true,
        'message': 'Sign in successful',
        'user': agriChainUser,
        'firebaseUser': firebaseUser,
      };

    } catch (e) {
      debugPrint('🔐 Sign in error: $e');
      return {
        'success': false,
        'message': 'An unexpected error occurred during sign in',
        'step': 'unexpected_error',
      };
    }
  }

  /// Update user profile
  static Future<Map<String, dynamic>> updateUserProfile({
    required UserRole role,
    required String firebaseUid,
    required Map<String, dynamic> updateData,
  }) async {
    try {
      debugPrint('🔐 Updating user profile...');

      // Update in MongoDB
      final success = await MongoDBService.updateUser(
        role: role.name,
        firebaseUid: firebaseUid,
        updateData: updateData,
      );

      if (success) {
        debugPrint('🔐 Profile updated successfully');
        return {
          'success': true,
          'message': 'Profile updated successfully',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to update profile',
        };
      }

    } catch (e) {
      debugPrint('🔐 Update profile error: $e');
      return {
        'success': false,
        'message': 'An unexpected error occurred during profile update',
      };
    }
  }

  /// Delete user account completely (Firebase + MongoDB)
  static Future<Map<String, dynamic>> deleteUserAccount({
    required UserRole role,
    required String firebaseUid,
  }) async {
    try {
      debugPrint('🔐 Deleting user account...');

      // Step 1: Delete from MongoDB
      final mongoSuccess = await MongoDBService.deleteUser(
        role: role.name,
        firebaseUid: firebaseUid,
      );

      // Step 2: Delete from Firebase Auth
      final firebaseResult = await FirebaseAuthService.deleteAccount();

      if (mongoSuccess && firebaseResult['success']) {
        debugPrint('🔐 Account deleted successfully');
        return {
          'success': true,
          'message': 'Account deleted successfully',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to delete account completely',
        };
      }

    } catch (e) {
      debugPrint('🔐 Delete account error: $e');
      return {
        'success': false,
        'message': 'An unexpected error occurred during account deletion',
      };
    }
  }

  /// Sign out user
  static Future<void> signOut() async {
    try {
      await FirebaseAuthService.signOut();
      // MongoDB doesn't need explicit sign out
      debugPrint('🔐 User signed out successfully');
    } catch (e) {
      debugPrint('🔐 Sign out error: $e');
      rethrow;
    }
  }

  /// Get current user data from MongoDB
  static Future<AgriChainUser?> getCurrentUserData({
    required UserRole role,
  }) async {
    try {
      final firebaseUser = FirebaseAuthService.currentUser;
      if (firebaseUser == null) {
        debugPrint('🔐 No Firebase user found');
        return null;
      }

      final userData = await MongoDBService.getUserByFirebaseUid(
        role: role.name,
        firebaseUid: firebaseUser.uid,
      );

      if (userData != null) {
        return AgriChainUser.fromJson(userData);
      }

      return null;

    } catch (e) {
      debugPrint('🔐 Get current user error: $e');
      return null;
    }
  }

  /// Check if user is authenticated
  static bool get isAuthenticated => FirebaseAuthService.isLoggedIn;

  /// Get Firebase auth state stream
  static Stream<User?> get authStateChanges => FirebaseAuthService.userStream;

  /// Send password reset email
  static Future<Map<String, dynamic>> sendPasswordResetEmail({
    required String email,
  }) async {
    return await FirebaseAuthService.sendPasswordResetEmail(email: email);
  }

  /// Update email
  static Future<Map<String, dynamic>> updateEmail({
    required String newEmail,
    required UserRole role,
    required String firebaseUid,
  }) async {
    try {
      // Update in Firebase Auth
      final firebaseResult = await FirebaseAuthService.updateEmail(newEmail: newEmail);
      
      if (!firebaseResult['success']) {
        return firebaseResult;
      }

      // Update in MongoDB
      final mongoSuccess = await MongoDBService.updateUser(
        role: role.name,
        firebaseUid: firebaseUid,
        updateData: {'email': newEmail},
      );

      if (mongoSuccess) {
        return {
          'success': true,
          'message': 'Email updated successfully',
        };
      } else {
        return {
          'success': false,
          'message': 'Email updated in Firebase but failed to update in database',
        };
      }

    } catch (e) {
      debugPrint('🔐 Update email error: $e');
      return {
        'success': false,
        'message': 'An unexpected error occurred during email update',
      };
    }
  }

  /// Update password
  static Future<Map<String, dynamic>> updatePassword({
    required String newPassword,
  }) async {
    return await FirebaseAuthService.updatePassword(newPassword: newPassword);
  }
}