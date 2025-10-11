import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../models/agrichain_user.dart';

/// Local storage service for offline data persistence
class LocalStorageService {
  static const String _userKey = 'agrichain_user';
  static const String _pendingSyncKey = 'pending_sync_users';

  /// Save user data locally
  static Future<bool> saveUser(AgriChainUser user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = jsonEncode(user.toJson());
      await prefs.setString(_userKey, userJson);
      debugPrint('💾 User saved locally');
      return true;
    } catch (e) {
      debugPrint('💾 Local save error: $e');
      return false;
    }
  }

  /// Get user data from local storage
  static Future<AgriChainUser?> getUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);
      if (userJson != null) {
        final userData = jsonDecode(userJson);
        return AgriChainUser.fromJson(userData);
      }
      return null;
    } catch (e) {
      debugPrint('💾 Local get error: $e');
      return null;
    }
  }

  /// Get user by Firebase UID from local storage
  static Future<AgriChainUser?> getUserByFirebaseUid(String firebaseUid) async {
    try {
      final user = await getUser();
      if (user != null && user.firebaseUid == firebaseUid) {
        return user;
      }
      return null;
    } catch (e) {
      debugPrint('💾 Local get by UID error: $e');
      return null;
    }
  }

  /// Clear user data from local storage
  static Future<bool> clearUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
      debugPrint('💾 User cleared from local storage');
      return true;
    } catch (e) {
      debugPrint('💾 Local clear error: $e');
      return false;
    }
  }

  /// Add user to pending sync queue (for MongoDB sync when connection is restored)
  static Future<bool> addToPendingSync(AgriChainUser user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pendingJson = prefs.getString(_pendingSyncKey) ?? '[]';
      final List<dynamic> pendingList = jsonDecode(pendingJson);

      // Check if user already exists in pending sync
      final existingIndex = pendingList.indexWhere(
        (item) => item['firebaseUid'] == user.firebaseUid,
      );

      if (existingIndex != -1) {
        // Update existing entry
        pendingList[existingIndex] = user.toJson();
      } else {
        // Add new entry
        pendingList.add(user.toJson());
      }

      await prefs.setString(_pendingSyncKey, jsonEncode(pendingList));
      debugPrint('💾 User added to pending sync queue');
      return true;
    } catch (e) {
      debugPrint('💾 Pending sync error: $e');
      return false;
    }
  }

  /// Get pending sync users
  static Future<List<AgriChainUser>> getPendingSyncUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pendingJson = prefs.getString(_pendingSyncKey) ?? '[]';
      final List<dynamic> pendingList = jsonDecode(pendingJson);

      return pendingList.map((item) => AgriChainUser.fromJson(item)).toList();
    } catch (e) {
      debugPrint('💾 Get pending sync error: $e');
      return [];
    }
  }

  /// Remove user from pending sync queue
  static Future<bool> removeFromPendingSync(String firebaseUid) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pendingJson = prefs.getString(_pendingSyncKey) ?? '[]';
      final List<dynamic> pendingList = jsonDecode(pendingJson);

      pendingList.removeWhere((item) => item['firebaseUid'] == firebaseUid);

      await prefs.setString(_pendingSyncKey, jsonEncode(pendingList));
      debugPrint('💾 User removed from pending sync queue');
      return true;
    } catch (e) {
      debugPrint('💾 Remove pending sync error: $e');
      return false;
    }
  }

  /// Check if user is logged in locally
  static Future<bool> isLoggedIn() async {
    final user = await getUser();
    return user != null;
  }
}
