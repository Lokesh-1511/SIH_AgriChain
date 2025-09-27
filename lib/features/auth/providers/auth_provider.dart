import 'package:flutter/foundation.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService.instance;
  
  User? _currentUser;
  bool _isLoading = false;
  String? _error;
  bool _isLoggedIn = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _isLoggedIn;

  AuthProvider() {
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    _setLoading(true);
    try {
      _isLoggedIn = await _authService.isLoggedIn();
      if (_isLoggedIn) {
        _currentUser = await _authService.getCurrentUser();
      }
    } catch (e) {
      _setError('Failed to check login status: $e');
    }
    _setLoading(false);
  }

  Future<bool> login(String email, String password, String role) async {
    _setLoading(true);
    _setError(null);
    
    try {
      final user = await _authService.login(email, password, role);
      if (user != null) {
        _currentUser = user;
        _isLoggedIn = true;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _setError('Login failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register(Map<String, dynamic> userData) async {
    _setLoading(true);
    _setError(null);
    
    try {
      final user = await _authService.register(userData);
      if (user != null) {
        _currentUser = user;
        _isLoggedIn = true;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _setError('Registration failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      await _authService.logout();
      _currentUser = null;
      _isLoggedIn = false;
      notifyListeners();
    } catch (e) {
      _setError('Logout failed: $e');
    }
    _setLoading(false);
  }

  Future<bool> verifyAadhaar(String aadhaarNumber) async {
    _setLoading(true);
    _setError(null);
    
    try {
      final isValid = await _authService.verifyAadhaar(aadhaarNumber);
      return isValid;
    } catch (e) {
      _setError('Aadhaar verification failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<String?> sendOTP(String phone) async {
    _setLoading(true);
    _setError(null);
    
    try {
      final otp = await _authService.sendOTP(phone);
      return otp;
    } catch (e) {
      _setError('Failed to send OTP: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> verifyOTP(String phone, String otp) async {
    _setLoading(true);
    _setError(null);
    
    try {
      final isValid = await _authService.verifyOTP(phone, otp);
      return isValid;
    } catch (e) {
      _setError('OTP verification failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}