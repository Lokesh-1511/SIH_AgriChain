import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../models/user_model.dart';
import 'dart:convert';

class AuthService {
  static AuthService? _instance;
  static AuthService get instance {
    _instance ??= AuthService._internal();
    return _instance!;
  }
  
  AuthService._internal();

  SharedPreferences? _prefs;

  Future<void> _initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Mock authentication
  Future<User?> login(String email, String password, String role) async {
    await _initPrefs();
    
    // Mock login logic - in real app, this would call an API
    if (email.isNotEmpty && password.isNotEmpty) {
      final mockUser = _createMockUser(email, role);
      await _saveUserSession(mockUser);
      return mockUser;
    }
    
    throw Exception('Invalid credentials');
  }

  Future<User?> register(Map<String, dynamic> userData) async {
    await _initPrefs();
    
    // Mock registration logic
    final user = _createUserFromData(userData);
    await _saveUserSession(user);
    return user;
  }

  Future<void> logout() async {
    await _initPrefs();
    await _prefs!.clear();
  }

  Future<bool> isLoggedIn() async {
    await _initPrefs();
    return _prefs!.getBool(AppConstants.keyIsLoggedIn) ?? false;
  }

  Future<User?> getCurrentUser() async {
    await _initPrefs();
    final userJson = _prefs!.getString(AppConstants.keyUserId);
    if (userJson != null) {
      return User.fromJson(json.decode(userJson));
    }
    return null;
  }

  Future<String?> getCurrentUserRole() async {
    await _initPrefs();
    return _prefs!.getString(AppConstants.keyUserRole);
  }

  Future<void> _saveUserSession(User user) async {
    await _prefs!.setBool(AppConstants.keyIsLoggedIn, true);
    await _prefs!.setString(AppConstants.keyUserId, json.encode(user.toJson()));
    await _prefs!.setString(AppConstants.keyUserRole, user.role);
    await _prefs!.setString(AppConstants.keyUserToken, 'mock_token_${user.id}');
  }

  User _createMockUser(String email, String role) {
    final now = DateTime.now();
    final id = 'user_${DateTime.now().millisecondsSinceEpoch}';
    
    switch (role) {
      case AppConstants.roleFarmer:
        return Farmer(
          id: id,
          name: 'Mock Farmer',
          email: email,
          phone: '+91 9876543210',
          address: 'Village, District, State',
          createdAt: now,
          farmerId: 'FRM_$id',
          landOwnership: 'owned',
          landSize: 5.0,
          agriScore: 85.0,
        );
      
      case AppConstants.roleDistributor:
        return Distributor(
          id: id,
          name: 'Mock Distributor',
          email: email,
          phone: '+91 9876543210',
          address: 'City, State',
          createdAt: now,
          distributorId: 'DST_$id',
          vehicleDetails: 'Truck - TN 01 AB 1234',
          licenseNumber: 'DL_123456789',
          rating: 4.2,
        );
      
      case AppConstants.roleRetailer:
        return Retailer(
          id: id,
          name: 'Mock Retailer',
          email: email,
          phone: '+91 9876543210',
          address: 'Shop Address',
          createdAt: now,
          retailerId: 'RTL_$id',
          shopName: 'Green Grocery Store',
          location: 'Market Street, City',
          rating: 4.5,
        );
      
      case AppConstants.roleConsumer:
        return Consumer(
          id: id,
          name: 'Mock Consumer',
          email: email,
          phone: '+91 9876543210',
          address: 'Home Address',
          createdAt: now,
          consumerId: 'CSM_$id',
          preferences: ['organic', 'local'],
        );
      
      default:
        throw Exception('Invalid role');
    }
  }

  User _createUserFromData(Map<String, dynamic> data) {
    final now = DateTime.now();
    final id = 'user_${DateTime.now().millisecondsSinceEpoch}';
    final role = data['role'] as String;
    
    switch (role) {
      case AppConstants.roleFarmer:
        return Farmer(
          id: id,
          name: data['name'],
          email: data['email'],
          phone: data['phone'],
          address: data['address'],
          createdAt: now,
          farmerId: 'FRM_$id',
          landOwnership: data['landOwnership'] ?? 'owned',
          landSize: double.tryParse(data['landSize'] ?? '0') ?? 0.0,
        );
      
      case AppConstants.roleDistributor:
        return Distributor(
          id: id,
          name: data['name'],
          email: data['email'],
          phone: data['phone'],
          address: data['address'],
          createdAt: now,
          distributorId: 'DST_$id',
          vehicleDetails: data['vehicleDetails'] ?? '',
          licenseNumber: data['licenseNumber'] ?? '',
        );
      
      case AppConstants.roleRetailer:
        return Retailer(
          id: id,
          name: data['name'],
          email: data['email'],
          phone: data['phone'],
          address: data['address'],
          createdAt: now,
          retailerId: 'RTL_$id',
          shopName: data['shopName'] ?? '',
          location: data['location'] ?? '',
        );
      
      case AppConstants.roleConsumer:
        return Consumer(
          id: id,
          name: data['name'],
          email: data['email'],
          phone: data['phone'],
          address: data['address'],
          createdAt: now,
          consumerId: 'CSM_$id',
        );
      
      default:
        throw Exception('Invalid role');
    }
  }

  // Mock Aadhaar verification
  Future<bool> verifyAadhaar(String aadhaarNumber) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 2));
    
    // Mock verification - in real app, this would call Aadhaar API
    return aadhaarNumber.length == 12 && aadhaarNumber.contains(RegExp(r'^[0-9]+$'));
  }

  Future<String> sendOTP(String phone) async {
    await Future.delayed(const Duration(seconds: 1));
    return '123456'; // Mock OTP
  }

  Future<bool> verifyOTP(String phone, String otp) async {
    await Future.delayed(const Duration(seconds: 1));
    return otp == '123456'; // Mock verification
  }
}