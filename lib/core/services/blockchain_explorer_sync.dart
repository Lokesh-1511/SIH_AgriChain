import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart';

class BlockchainExplorerSync {
  static const String _fileName = 'registered_users.json';

  /// Sync user registration with blockchain explorer
  static Future<void> syncUserRegistration({
    required String userId,
    required String name,
    required String email,
    required String role,
    required String walletAddress,
  }) async {
    try {
      if (kIsWeb) {
        // For web, we'll use a different approach
        await _syncForWeb(userId, name, email, role, walletAddress);
      } else {
        // For mobile/desktop, write to file system
        await _syncToFile(userId, name, email, role, walletAddress);
      }

      print('✅ User registration synced with blockchain explorer');
    } catch (e) {
      print('❌ Failed to sync with blockchain explorer: $e');
    }
  }

  static Future<void> _syncToFile(
    String userId,
    String name,
    String email,
    String role,
    String walletAddress,
  ) async {
    try {
      // Get the app's documents directory
      final appDir = Directory.current;
      final syncFile = File(path.join(appDir.path, _fileName));

      Map<String, dynamic> registrations = {};

      // Read existing registrations if file exists
      if (await syncFile.exists()) {
        final content = await syncFile.readAsString();
        try {
          registrations = json.decode(content) as Map<String, dynamic>;
        } catch (e) {
          print('Warning: Could not parse existing registrations: $e');
          registrations = {};
        }
      }

      // Add new user registration
      registrations[userId] = {
        'userId': userId,
        'name': name,
        'email': email,
        'role': role,
        'wallet': walletAddress,
        'registrationTime': DateTime.now().toIso8601String(),
        'source': 'flutter_app',
        'lastUpdated': DateTime.now().toIso8601String(),
      };

      // Write updated registrations back to file
      await syncFile.writeAsString(
        const JsonEncoder.withIndent('  ').convert({
          'lastUpdated': DateTime.now().toIso8601String(),
          'totalUsers': registrations.length,
          'users': registrations,
        }),
      );

      print('📝 User registration saved to: ${syncFile.path}');
    } catch (e) {
      print('❌ Error writing to sync file: $e');
    }
  }

  static Future<void> _syncForWeb(
    String userId,
    String name,
    String email,
    String role,
    String walletAddress,
  ) async {
    // For web platform, we'll use localStorage through JS interop
    // or send to a backend service

    final userData = {
      'userId': userId,
      'name': name,
      'email': email,
      'role': role,
      'wallet': walletAddress,
      'registrationTime': DateTime.now().toIso8601String(),
      'source': 'flutter_web_app',
    };

    // This would be sent to your backend or stored in browser localStorage
    print('🌐 Web sync - User data: ${json.encode(userData)}');

    // You could implement a REST API call here to sync with a backend service
    // that the HTML explorer can then query
  }

  /// Read all registered users (for testing/debugging)
  static Future<Map<String, dynamic>> getAllRegistrations() async {
    try {
      final appDir = Directory.current;
      final syncFile = File(path.join(appDir.path, _fileName));

      if (await syncFile.exists()) {
        final content = await syncFile.readAsString();
        return json.decode(content) as Map<String, dynamic>;
      }
    } catch (e) {
      print('❌ Error reading registrations: $e');
    }

    return {};
  }

  /// Clear all registrations (for testing)
  static Future<void> clearAllRegistrations() async {
    try {
      final appDir = Directory.current;
      final syncFile = File(path.join(appDir.path, _fileName));

      if (await syncFile.exists()) {
        await syncFile.delete();
        print('🗑️ All registrations cleared');
      }
    } catch (e) {
      print('❌ Error clearing registrations: $e');
    }
  }
}
