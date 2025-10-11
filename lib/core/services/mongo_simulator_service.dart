import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

/// Service to simulate MongoDB wallet assignments for testing
class MongoSimulatorService {
  static const String _mongoSimFile = 'mongo_wallet_assignments.json';

  /// Save wallet assignment to simulate MongoDB storage
  static Future<void> saveWalletAssignment({
    required String userId,
    required String walletAddress,
    required String role,
    required String name,
    required String email,
  }) async {
    try {
      final file = File(_mongoSimFile);
      Map<String, dynamic> assignments = {};

      // Load existing assignments
      if (await file.exists()) {
        final content = await file.readAsString();
        if (content.isNotEmpty) {
          assignments = json.decode(content);
        }
      }

      // Add new assignment
      assignments[userId] = {
        'userId': userId,
        'walletAddress': walletAddress,
        'role': role,
        'name': name,
        'email': email,
        'assignedAt': DateTime.now().toIso8601String(),
        'createdAt': DateTime.now().toIso8601String(),
      };

      // Save back to file
      await file.writeAsString(
        const JsonEncoder.withIndent('  ').convert(assignments),
      );

      debugPrint(
        '💾 Saved wallet assignment to MongoDB simulator: $walletAddress -> $name ($role)',
      );
    } catch (e) {
      debugPrint('❌ Failed to save wallet assignment to MongoDB simulator: $e');
    }
  }

  /// Get all wallet assignments (simulates MongoDB query)
  static Future<Map<String, dynamic>> getAllWalletAssignments() async {
    try {
      final file = File(_mongoSimFile);
      if (await file.exists()) {
        final content = await file.readAsString();
        if (content.isNotEmpty) {
          final assignments = json.decode(content) as Map<String, dynamic>;

          // Group by role like the API expects
          final grouped = <String, Map<String, dynamic>>{};
          for (final assignment in assignments.values) {
            final role = assignment['role'] as String;
            final wallet = assignment['walletAddress'] as String;

            if (!grouped.containsKey(role)) {
              grouped[role] = {};
            }

            grouped[role]![wallet] = assignment;
          }

          debugPrint(
            '📊 Retrieved ${assignments.length} wallet assignments from MongoDB simulator',
          );
          return grouped;
        }
      }
    } catch (e) {
      debugPrint(
        '❌ Failed to read wallet assignments from MongoDB simulator: $e',
      );
    }

    return {};
  }

  /// Check if a wallet is already assigned
  static Future<Map<String, dynamic>?> checkWalletAssignment(
    String walletAddress,
  ) async {
    try {
      final file = File(_mongoSimFile);
      if (await file.exists()) {
        final content = await file.readAsString();
        if (content.isNotEmpty) {
          final assignments = json.decode(content) as Map<String, dynamic>;

          for (final assignment in assignments.values) {
            if ((assignment['walletAddress'] as String).toLowerCase() ==
                walletAddress.toLowerCase()) {
              return assignment as Map<String, dynamic>;
            }
          }
        }
      }
    } catch (e) {
      debugPrint('❌ Failed to check wallet assignment: $e');
    }

    return null;
  }

  /// Clear all assignments (for testing)
  static Future<void> clearAllAssignments() async {
    try {
      final file = File(_mongoSimFile);
      if (await file.exists()) {
        await file.delete();
        debugPrint('🗑️ Cleared all MongoDB simulator assignments');
      }
    } catch (e) {
      debugPrint('❌ Failed to clear assignments: $e');
    }
  }
}
