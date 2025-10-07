import 'package:flutter/foundation.dart';
import '../../../core/services/auth_integration_service.dart';
import '../../../core/services/firebase_auth_service.dart';
import '../../../core/services/local_storage_service.dart';
import '../../../core/models/agrichain_user.dart';

class AuthProvider extends ChangeNotifier {
  AgriChainUser? _currentUser;
  bool _isLoading = false;
  String? _error;
  bool _isLoggedIn = false;
  
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _isLoggedIn;
  AgriChainUser? get currentUser => _currentUser;

  AuthProvider() {
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    _setLoading(true);
    try {
      _isLoggedIn = FirebaseAuthService.isLoggedIn;
      if (_isLoggedIn) {
        // Try to load user data from local storage first, then MongoDB
        final firebaseUser = FirebaseAuthService.currentUser;
        if (firebaseUser != null) {
          // First try to get user from local storage
          final localUser = await LocalStorageService.getUserByFirebaseUid(firebaseUser.uid);
          if (localUser != null) {
            _currentUser = localUser;
          } else {
            // If not in local storage, try MongoDB for all roles
            for (final role in UserRole.values) {
              try {
                final authResult = await AuthIntegrationService.getUserFromMongoDB(
                  role: role.name,
                  firebaseUid: firebaseUser.uid,
                );
                if (authResult['success'] == true) {
                  _currentUser = AgriChainUser.fromJson(authResult['userData']);
                  // Save to local storage for future use
                  await LocalStorageService.saveUser(_currentUser!);
                  break;
                }
              } catch (e) {
                // Continue to next role if this one fails
                continue;
              }
            }
          }
        }
      }
    } catch (e) {
      _setError('Failed to check login status: $e');
    }
    _setLoading(false);
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }
  
  Future<bool> login(String email, String password, String role) async {
    _setLoading(true);
    _setError(null);
    
    try {
      // Convert string role to UserRole enum
      UserRole userRole;
      switch (role.toLowerCase()) {
        case 'farmer':
          userRole = UserRole.farmer;
          break;
        case 'distributor':
          userRole = UserRole.distributor;
          break;
        case 'retailer':
          userRole = UserRole.retailer;
          break;
        case 'consumer':
          userRole = UserRole.consumer;
          break;
        default:
          throw Exception('Invalid role: $role');
      }
      
      final result = await AuthIntegrationService.signInUser(
        email: email,
        password: password,
        role: userRole,
      );
      
      if (result['success']) {
        // Convert the returned user data to AgriChainUser
        _currentUser = AgriChainUser.fromJson(result['userData']);
        _isLoggedIn = true;
        _setLoading(false);
        return true;
      } else {
        _setError(result['message']);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Login failed: $e');
      _setLoading(false);
      return false;
    }
  }
  
  Future<bool> register(Map<String, dynamic> userData) async {
    _setLoading(true);
    _setError(null);
    
    try {
      // Extract required fields from userData map
      final email = userData['email'] as String;
      final password = userData['password'] as String;
      final name = userData['name'] as String;
      final phone = userData['phone'] as String;
      final address = userData['address'] as String;
      final roleString = userData['role'] as String;
      final kycDetails = userData['kycDetails'] as Map<String, dynamic>;
      
      // Convert string role to UserRole enum
      final role = UserRole.fromString(roleString);
      
      final result = await AuthIntegrationService.registerUser(
        email: email,
        password: password,
        name: name,
        phone: phone,
        address: address,
        role: role,
        kycDetails: kycDetails,
        additionalInfo: userData['additionalInfo'],
      );
      
      if (result['success']) {
        // Convert the returned user data to AgriChainUser
        _currentUser = AgriChainUser.fromJson(result['userData']);
        _isLoggedIn = true;
        _setLoading(false);
        return true;
      } else {
        _setError(result['message']);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Registration failed: $e');
      _setLoading(false);
      return false;
    }
  }
  
  Future<void> logout() async {
    _setLoading(true);
    try {
      await FirebaseAuthService.signOut();
      _currentUser = null;
      _isLoggedIn = false;
    } catch (e) {
      _setError('Logout failed: $e');
    }
    _setLoading(false);
  }

  Future<bool> sendPasswordResetOTP(String email) async {
    _setLoading(true);
    _setError(null);
    
    try {
      await FirebaseAuthService.sendPasswordResetEmail(email: email);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Password reset failed: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<void> verifyPasswordResetOTP(String email, String otp) async {
    // Firebase Auth uses email link verification, not OTP
    // This method is kept for compatibility but delegates to email reset
    await sendPasswordResetOTP(email);
  }

  Future<bool> resetPassword(String email, String newPassword) async {
    // Firebase Auth handles password reset via email link
    // This method sends the reset email
    return await sendPasswordResetOTP(email);
  }
}