import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class WalletAssignmentService {
  static const String _assignmentsFile = 'wallet_assignments.json';
  static Map<String, dynamic> _assignmentCache = {};
  static bool _cacheLoaded = false;

  /// Load existing wallet assignments from file
  static Future<void> _loadAssignments() async {
    if (_cacheLoaded) return;

    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_assignmentsFile');
      if (await file.exists()) {
        final content = await file.readAsString();
        if (content.isNotEmpty) {
          _assignmentCache = json.decode(content);
          debugPrint('📂 Loaded ${_assignmentCache.length} wallet assignments');
        }
      }
    } catch (e) {
      debugPrint('⚠️ Failed to load wallet assignments: $e');
      _assignmentCache = {};
    }
    _cacheLoaded = true;
  }

  /// Save wallet assignments to file
  static Future<void> _saveAssignments() async {
    try {
      final jsonString = const JsonEncoder.withIndent(
        '  ',
      ).convert(_assignmentCache);

      // Save to app documents directory
      final directory = await getApplicationDocumentsDirectory();
      final mobileFile = File('${directory.path}/$_assignmentsFile');
      await mobileFile.writeAsString(jsonString);
      debugPrint('💾 Saved wallet assignments to ${mobileFile.path}');

      // Also save to web-accessible location for HTML explorer
      try {
        final webFile = File(_assignmentsFile);
        await webFile.writeAsString(jsonString);
        debugPrint('💾 Saved wallet assignments to web directory');
      } catch (e) {
        debugPrint('⚠️ Could not save web assignments file: $e');
      }
    } catch (e) {
      debugPrint('❌ Failed to save wallet assignments: $e');
    }
  }

  /// Get or create wallet assignment for a user
  static Future<String> getOrAssignWallet(String userId, String role) async {
    await _loadAssignments();

    // Check if user already has an assignment
    if (_assignmentCache.containsKey(userId)) {
      final existingAssignment = _assignmentCache[userId];
      debugPrint(
        '♻️ Found existing wallet for $userId: ${existingAssignment['wallet']}',
      );
      return existingAssignment['wallet'];
    }

    // Available wallets for each role (Hardhat accounts 0-19)
    final roleWallets = {
      'farmer': [
        '0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266', // Account #0
        '0x70997970C51812dc3A010C7d01b50e0d17dc79C8', // Account #1
        '0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC', // Account #2
        '0x90F79bf6EB2c4f870365E785982E1f101E93b906', // Account #3
        '0x15d34AAf54267DB7D7c367839AAf71A00a2C6A65', // Account #4
      ],
      'distributor': [
        '0x9965507D1a55bcC2695C58ba16FB37d819B0A4dc', // Account #5
        '0x976EA74026E726554dB657fA54763abd0C3a0aa9', // Account #6
        '0x14dC79964da2C08b23698B3D3cc7Ca32193d9955', // Account #7
        '0x23618e81E3f5cdF7f54C3d65f7FBc0aBf5B21E8f', // Account #8
        '0xa0Ee7A142d267C1f36714E4a8F75612F20a79720', // Account #9
      ],
      'retailer': [
        '0xBcd4042DE499D14e55001CcbB24a551F3b954096', // Account #10
        '0x71bE63f3384f5fb98995898A86B02Fb2426c5788', // Account #11
        '0xFABB0ac9d68B0B445fB7357272Ff202C5651694a', // Account #12
        '0x1CBd3b2770909D4e10f157cABC84C7264073C9Ec', // Account #13
        '0xdF3e18d64BC6A983f673Ab319CCaE4f1a57C7097', // Account #14
      ],
      'consumer': [
        '0x2546BcD3c84621e976D8185a91A922aE77ECEc30', // Account #16
        '0xbDA5747bFD65F08deb54cb465eB87D40e51B197E', // Account #17
        '0xdD2FD4581271e230360230F9337D5c0430Bf44C0', // Account #18
        '0x8626f6940E2eb28930eFb4CeF49B2d1F2C9C1199', // Account #19
        '0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266', // Account #0 (fallback)
      ],
    };

    final normalizedRole = role.toLowerCase().trim();
    final availableWallets = roleWallets[normalizedRole];

    if (availableWallets == null) {
      throw Exception('No wallets available for role: $role');
    }

    // Find an unassigned wallet for this role
    final assignedWallets = _assignmentCache.values
        .where((assignment) => assignment['role'] == normalizedRole)
        .map((assignment) => assignment['wallet'] as String)
        .toSet();

    final unassignedWallets = availableWallets
        .where((wallet) => !assignedWallets.contains(wallet.toLowerCase()))
        .toList();

    if (unassignedWallets.isEmpty) {
      // If all wallets are assigned, use a deterministic assignment
      final walletIndex = userId.hashCode.abs() % availableWallets.length;
      final assignedWallet = availableWallets[walletIndex];
      debugPrint('🔄 All wallets assigned, reusing: $assignedWallet');
      return assignedWallet;
    }

    // Assign the first available unassigned wallet
    final newWallet = unassignedWallets.first;

    // Save the assignment
    _assignmentCache[userId] = {
      'wallet': newWallet,
      'role': normalizedRole,
      'assignedAt': DateTime.now().toIso8601String(),
    };

    await _saveAssignments();

    debugPrint(
      '🆕 Assigned new wallet to $userId ($normalizedRole): $newWallet',
    );
    return newWallet;
  }

  /// Get all current assignments grouped by role
  static Future<Map<String, Map<String, dynamic>>> getAllAssignments() async {
    await _loadAssignments();

    final groupedAssignments = <String, Map<String, dynamic>>{};

    for (final entry in _assignmentCache.entries) {
      final userId = entry.key;
      final assignment = entry.value;
      final role = assignment['role'] as String;

      if (!groupedAssignments.containsKey(role)) {
        groupedAssignments[role] = {};
      }

      groupedAssignments[role]![assignment['wallet']] = {
        'userId': userId,
        'assignedAt': assignment['assignedAt'],
        'role': role,
      };
    }

    return groupedAssignments;
  }

  /// Get assignment for a specific user
  static Future<Map<String, dynamic>?> getUserAssignment(String userId) async {
    await _loadAssignments();
    return _assignmentCache[userId];
  }

  /// Clear all assignments (for testing)
  static Future<void> clearAllAssignments() async {
    _assignmentCache.clear();
    _cacheLoaded = true;
    await _saveAssignments();
    debugPrint('🗑️ Cleared all wallet assignments');
  }
}
