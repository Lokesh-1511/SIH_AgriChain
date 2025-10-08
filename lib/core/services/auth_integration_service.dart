import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/agrichain_user.dart';
import 'firebase_auth_service.dart';
import 'auth_firebase_service.dart';
import 'mongodb_service.dart';
import 'local_storage_service.dart';

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

      // Step 1: Register with Firebase Auth (SSL-tolerant)
      Map<String, dynamic> userData = {
        'email': email,
        'name': name,
        'phone': phone,
        'address': address,
        'role': role.name,
        'kycDetails': kycDetails,
        'additionalInfo': additionalInfo,
      };

      final user = await AuthFirebaseService.registerWithFirebase(
        email: email,
        password: password,
        userData: userData,
      );

      if (user == null) {
        return {
          'success': false,
          'message': 'Registration failed',
          'step': 'firebase_auth',
        };
      }

      debugPrint('🔐 Firebase registration successful: ${user.firebaseUid}');

      // Step 2: User data already stored in MongoDB via AuthFirebaseService
      // Create the result format expected by the calling code
      final mongoResult = {'success': true, 'userId': user.id};

      if (mongoResult['success'] != true) {
        // Don't rollback Firebase user, use local storage fallback instead
        debugPrint('🔐 MongoDB insertion failed, using local storage fallback');

        // Create AgriChainUser object for local storage
        final agriChainUser = AgriChainUser(
          firebaseUid: user.firebaseUid,
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

        // Save locally
        await LocalStorageService.saveUser(agriChainUser);
        // Add to pending sync for later
        await LocalStorageService.addToPendingSync(agriChainUser);

        debugPrint(
          '🔐 User saved locally, will sync to MongoDB when connection is available',
        );

        return {
          'success': true,
          'message': 'Registration successful (saved locally)',
          'userData': agriChainUser.toJson(),
          'isOnline': false,
        };
      }

      debugPrint('🔐 User registration completed successfully');

      // Create AgriChainUser object
      final agriChainUser = AgriChainUser(
        id: mongoResult['userId']?.toString(),
        firebaseUid: user.firebaseUid,
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
        'userData': agriChainUser.toJson(),
        'isOnline': true,
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

      // Step 1: Sign in with Firebase Auth (SSL-tolerant with fallback)
      final authUser = await AuthFirebaseService.loginWithFirebase(
        email: email,
        password: password,
        role: role.name,
      );

      if (authUser == null) {
        return {
          'success': false,
          'message': 'Login failed - invalid credentials or connection issue',
          'step': 'firebase_auth',
        };
      }

      debugPrint('🔐 Firebase sign in successful: ${authUser.firebaseUid}');

      // Step 2: Retrieve user data from MongoDB
      final userData = await MongoDBService.getUserByFirebaseUid(
        role: role.name,
        firebaseUid: authUser.firebaseUid,
      );

      AgriChainUser agriChainUser;

      if (userData == null) {
        debugPrint('🔐 MongoDB data not found, checking local storage...');

        // Try to get user from local storage
        final localUser = await LocalStorageService.getUser();

        if (localUser != null && localUser.firebaseUid == authUser.firebaseUid) {
          debugPrint('🔐 User found in local storage');
          agriChainUser = localUser;
        } else {
          debugPrint('🔐 Creating user from AuthService user data');
          // Create user from AuthService user data if neither MongoDB nor local storage has the user
          agriChainUser = AgriChainUser(
            firebaseUid: authUser.firebaseUid,
            name: authUser.name,
            email: authUser.email,
            phone: authUser.phone,
            role: role,
            address: authUser.address,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            kycDetails: {},
            isVerified: true, // AuthService user is considered verified
          );

          // Save to local storage for future logins
          await LocalStorageService.saveUser(agriChainUser);
        }
      } else {
        debugPrint('🔐 User data retrieved from MongoDB successfully');
        agriChainUser = AgriChainUser.fromJson(userData);

        // Update local storage with latest data from MongoDB
        await LocalStorageService.saveUser(agriChainUser);
      }

      // Step 3: Validate if user's role matches the selected role
      if (agriChainUser.role != role) {
        debugPrint(
          '🔐 Role mismatch: User role is ${agriChainUser.role.name}, but trying to login as ${role.name}',
        );

        // Sign out from Firebase since role doesn't match
        await FirebaseAuthService.signOut();

        return {
          'success': false,
          'message':
              'This account is registered as ${agriChainUser.role.name.toUpperCase()}. Please use the ${agriChainUser.role.name.toUpperCase()} login instead.',
          'step': 'role_validation',
          'userActualRole': agriChainUser.role.name,
          'attemptedRole': role.name,
        };
      }

      return {
        'success': true,
        'message': 'Sign in successful',
        'userData': agriChainUser.toJson(),
        'authUser': authUser,
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
        return {'success': true, 'message': 'Profile updated successfully'};
      } else {
        return {'success': false, 'message': 'Failed to update profile'};
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
        return {'success': true, 'message': 'Account deleted successfully'};
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
      final firebaseResult = await FirebaseAuthService.updateEmail(
        newEmail: newEmail,
      );

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
        return {'success': true, 'message': 'Email updated successfully'};
      } else {
        return {
          'success': false,
          'message':
              'Email updated in Firebase but failed to update in database',
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

  /// Get user from MongoDB by Firebase UID
  static Future<Map<String, dynamic>> getUserFromMongoDB({
    required String role,
    required String firebaseUid,
  }) async {
    try {
      final userData = await MongoDBService.getUserByFirebaseUid(
        role: role,
        firebaseUid: firebaseUid,
      );

      if (userData != null) {
        return {
          'success': true,
          'userData': userData,
          'message': 'User found successfully',
        };
      } else {
        return {'success': false, 'message': 'User not found in database'};
      }
    } catch (e) {
      debugPrint('🔍 Get user from MongoDB error: $e');
      return {
        'success': false,
        'message': 'Failed to retrieve user from database',
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
