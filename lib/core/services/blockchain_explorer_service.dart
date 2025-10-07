import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'wallet_assignment_service.dart';

/// Service to sync user registrations with the HTML blockchain explorer
class BlockchainExplorerService {
  static const String _htmlServerUrl = 'http://localhost:8080';

  /// Notify the blockchain explorer when a new user registers
  static Future<void> notifyUserRegistration({
    required String walletAddress,
    required String name,
    required String email,
    required String role,
    required String userId,
  }) async {
    try {
      // For now, we'll use localStorage approach
      // In production, you could set up a simple Node.js server
      debugPrint('📊 Blockchain Explorer: New user registered');
      debugPrint('   👤 Name: $name');
      debugPrint('   📧 Email: $email');
      debugPrint('   🎭 Role: $role');
      debugPrint('   💰 Wallet: $walletAddress');
      debugPrint('   🆔 User ID: $userId');

      // Save to local file and try to post to HTML server
      final userData = {
        'walletAddress': walletAddress,
        'name': name,
        'email': email,
        'role': role,
        'userId': userId,
        'registeredAt': DateTime.now().toIso8601String(),
      };

      await _saveToLocalFile(userData);
      await _postToHTMLServer(userData);
    } catch (e) {
      debugPrint('❌ Failed to notify blockchain explorer: $e');
    }
  }

  /// Save registration data to a JSON file that HTML can read
  static Future<void> _saveToLocalFile(Map<String, dynamic> userData) async {
    try {
      // Create the web-accessible registrations file in project root
      final webFile = File('web_registrations.json');
      // Also save to app documents directory for mobile access
      final directory = await getApplicationDocumentsDirectory();
      final mobileFile = File('${directory.path}/web_registrations.json');
      Map<String, dynamic> allRegistrations = {
        'lastUpdated': DateTime.now().toIso8601String(),
        'totalUsers': 0,
        'users': <String, dynamic>{},
        'walletAssignments': <String, dynamic>{},
        'statistics': {
          'farmers': 0,
          'distributors': 0,
          'retailers': 0,
          'consumers': 0,
        },
      };

      // Read existing registrations if file exists (try web file first for HTML access)
      if (await webFile.exists()) {
        final content = await webFile.readAsString();
        if (content.isNotEmpty) {
          try {
            allRegistrations = Map<String, dynamic>.from(json.decode(content));
          } catch (e) {
            debugPrint(
              '⚠️ Could not parse existing registrations, creating new file',
            );
          }
        }
      }

      // Add new user to registrations
      final userId = userData['userId'];
      allRegistrations['users'][userId] = userData;

      // Update statistics
      final users = Map<String, dynamic>.from(allRegistrations['users']);
      final stats = <String, int>{
        'farmers': 0,
        'distributors': 0,
        'retailers': 0,
        'consumers': 0,
      };

      for (final user in users.values) {
        final role = user['role'] as String;
        if (stats.containsKey(role + 's')) {
          stats[role + 's'] = stats[role + 's']! + 1;
        }
      }

      allRegistrations['statistics'] = stats;
      allRegistrations['totalUsers'] = users.length;
      allRegistrations['lastUpdated'] = DateTime.now().toIso8601String();

      // Add wallet assignments for HTML explorer
      final walletAssignments =
          await WalletAssignmentService.getAllAssignments();
      allRegistrations['walletAssignments'] = walletAssignments;

      // Write updated data to both files
      final jsonString = const JsonEncoder.withIndent(
        '  ',
      ).convert(allRegistrations);

      // Save to mobile documents directory (primary save)
      try {
        await mobileFile.writeAsString(jsonString);
        debugPrint('✅ Registration saved to documents directory (mobile)');
      } catch (e) {
        debugPrint('⚠️ Could not save mobile file: $e');
      }

      // Try to save to web-accessible location for HTML explorer (best effort)
      try {
        await webFile.writeAsString(jsonString);
        debugPrint('✅ Registration saved to web_registrations.json (web)');
      } catch (e) {
        debugPrint('! Could not save web file: $e');
        // This is expected on mobile devices - not an error
      }
      debugPrint('📊 Total users: ${users.length}');
      debugPrint('📈 Statistics: $stats');
    } catch (e) {
      debugPrint('❌ Failed to save registration file: $e');
    }
  }

  /// Generate JavaScript code to inject into HTML localStorage
  static String generateJavaScriptUpdate(Map<String, dynamic> userData) {
    return '''
      // Auto-generated registration update
      (function() {
        const walletAddress = "${userData['walletAddress']}";
        const userData = ${json.encode(userData)};
        
        let registrations = {};
        try {
          const stored = localStorage.getItem('agrichain_user_registrations');
          registrations = stored ? JSON.parse(stored) : {};
        } catch (e) {
          console.error('Failed to parse registrations:', e);
        }
        
        registrations[walletAddress] = userData;
        localStorage.setItem('agrichain_user_registrations', JSON.stringify(registrations));
        
        console.log('✅ Registration updated for wallet:', walletAddress);
        console.log('👤 User:', userData.name, '(', userData.email, ')');
      })();
    ''';
  }

  /// Create a simple HTML snippet showing current registrations
  static String generateRegistrationsSummary(
    List<Map<String, dynamic>> registrations,
  ) {
    final buffer = StringBuffer();
    buffer.writeln('<h3>📊 Recent Registrations</h3>');

    if (registrations.isEmpty) {
      buffer.writeln('<p>No registrations yet.</p>');
      return buffer.toString();
    }

    for (final reg in registrations.take(10)) {
      // Show last 10
      buffer.writeln('''
        <div style="border: 1px solid #ddd; padding: 10px; margin: 10px 0; border-radius: 5px;">
          <strong>👤 ${reg['name']}</strong> (${reg['email']})<br>
          <strong>🎭 Role:</strong> ${reg['role']}<br>
          <strong>💰 Wallet:</strong> <code>${reg['walletAddress']}</code><br>
          <strong>📅 Registered:</strong> ${reg['registeredAt']}<br>
        </div>
      ''');
    }

    return buffer.toString();
  }

  /// Post registration data to HTML server
  static Future<void> _postToHTMLServer(Map<String, dynamic> userData) async {
    try {
      final response = await http.post(
        Uri.parse('$_htmlServerUrl/api/registrations'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(userData),
      );

      if (response.statusCode == 200) {
        debugPrint('✅ Posted registration to HTML server');
      } else {
        debugPrint(
          '⚠️ HTML server responded with status: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('! Could not post to HTML server: $e');
      // This is expected if server is not running - not an error
    }
  }
}
