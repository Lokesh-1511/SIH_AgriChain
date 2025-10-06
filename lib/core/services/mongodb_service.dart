import 'package:mongo_dart/mongo_dart.dart';
import 'package:flutter/foundation.dart';

/// MongoDB Service for storing user data
class MongoDBService {
  static Db? _database;
  static bool _isConnected = false;
  
  // MongoDB connection string - replace with your actual MongoDB URI
  static const String _connectionString = 'mongodb+srv://<username>:<password>@<cluster>.mongodb.net/<database>?retryWrites=true&w=majority';
  static const String _databaseName = 'agrichain_db';
  
  // Collection names
  static const String _farmersCollection = 'farmers';
  static const String _distributorsCollection = 'distributors';
  static const String _retailersCollection = 'retailers';
  static const String _consumersCollection = 'consumers';

  /// Initialize MongoDB connection
  static Future<bool> connect() async {
    try {
      if (_isConnected && _database != null) {
        return true;
      }

      debugPrint('🍃 MongoDB: Connecting to database...');
      
      _database = await Db.create(_connectionString);
      await _database!.open();
      
      _isConnected = true;
      debugPrint('🍃 MongoDB: Connected successfully');
      
      return true;
    } catch (e) {
      debugPrint('🍃 MongoDB Connection Error: $e');
      _isConnected = false;
      return false;
    }
  }

  /// Close MongoDB connection
  static Future<void> disconnect() async {
    try {
      if (_database != null) {
        await _database!.close();
        _database = null;
        _isConnected = false;
        debugPrint('🍃 MongoDB: Disconnected');
      }
    } catch (e) {
      debugPrint('🍃 MongoDB Disconnect Error: $e');
    }
  }

  /// Check if connected
  static bool get isConnected => _isConnected && _database != null;

  /// Get collection by role
  static DbCollection? _getCollectionByRole(String role) {
    if (!isConnected) return null;
    
    switch (role.toLowerCase()) {
      case 'farmer':
        return _database!.collection(_farmersCollection);
      case 'distributor':
        return _database!.collection(_distributorsCollection);
      case 'retailer':
        return _database!.collection(_retailersCollection);
      case 'consumer':
        return _database!.collection(_consumersCollection);
      default:
        return null;
    }
  }

  /// Create user in MongoDB
  static Future<Map<String, dynamic>> createUser({
    required String role,
    required String firebaseUid,
    required String email,
    required String name,
    required String phone,
    required Map<String, dynamic> kycDetails,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      if (!await connect()) {
        return {
          'success': false,
          'message': 'Failed to connect to database',
        };
      }

      final collection = _getCollectionByRole(role);
      if (collection == null) {
        return {
          'success': false,
          'message': 'Invalid user role: $role',
        };
      }

      // Check if user already exists
      final existingUser = await collection.findOne(where.eq('firebaseUid', firebaseUid));
      if (existingUser != null) {
        return {
          'success': false,
          'message': 'User already exists in database',
        };
      }

      // Create user document
      final userDocument = {
        'firebaseUid': firebaseUid,
        'email': email,
        'name': name,
        'phone': phone,
        'role': role.toLowerCase(),
        'kycDetails': kycDetails,
        'isActive': true,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        ...?additionalData,
      };

      // Insert user
      final result = await collection.insertOne(userDocument);
      
      debugPrint('🍃 MongoDB: User created - Role: $role, ID: ${result.insertedId}');

      return {
        'success': true,
        'userId': result.insertedId.toString(),
        'message': 'User created successfully',
      };
    } catch (e) {
      debugPrint('🍃 MongoDB Create User Error: $e');
      return {
        'success': false,
        'message': 'Failed to create user: $e',
      };
    }
  }

  /// Get user by Firebase UID
  static Future<Map<String, dynamic>?> getUserByFirebaseUid({
    required String role,
    required String firebaseUid,
  }) async {
    try {
      if (!await connect()) {
        debugPrint('🍃 MongoDB: Failed to connect');
        return null;
      }

      final collection = _getCollectionByRole(role);
      if (collection == null) {
        debugPrint('🍃 MongoDB: Invalid role - $role');
        return null;
      }

      final user = await collection.findOne(where.eq('firebaseUid', firebaseUid));
      
      if (user != null) {
        debugPrint('🍃 MongoDB: User found - Role: $role');
      } else {
        debugPrint('🍃 MongoDB: User not found - Role: $role, UID: $firebaseUid');
      }

      return user;
    } catch (e) {
      debugPrint('🍃 MongoDB Get User Error: $e');
      return null;
    }
  }

  /// Update user data
  static Future<bool> updateUser({
    required String role,
    required String firebaseUid,
    required Map<String, dynamic> updateData,
  }) async {
    try {
      if (!await connect()) {
        return false;
      }

      final collection = _getCollectionByRole(role);
      if (collection == null) {
        return false;
      }

      // Add updated timestamp
      updateData['updatedAt'] = DateTime.now().toIso8601String();

      final result = await collection.updateOne(
        where.eq('firebaseUid', firebaseUid),
        modify.set('updatedAt', updateData['updatedAt']).setAll(updateData),
      );

      debugPrint('🍃 MongoDB: User updated - Role: $role, Modified: ${result.nModified}');
      return result.nModified > 0;
    } catch (e) {
      debugPrint('🍃 MongoDB Update User Error: $e');
      return false;
    }
  }

  /// Delete user
  static Future<bool> deleteUser({
    required String role,
    required String firebaseUid,
  }) async {
    try {
      if (!await connect()) {
        return false;
      }

      final collection = _getCollectionByRole(role);
      if (collection == null) {
        return false;
      }

      final result = await collection.deleteOne(where.eq('firebaseUid', firebaseUid));
      
      debugPrint('🍃 MongoDB: User deleted - Role: $role, Deleted: ${result.nRemoved}');
      return result.nRemoved > 0;
    } catch (e) {
      debugPrint('🍃 MongoDB Delete User Error: $e');
      return false;
    }
  }

  /// Get all users by role (for admin purposes)
  static Future<List<Map<String, dynamic>>> getUsersByRole({
    required String role,
    int limit = 100,
    int skip = 0,
  }) async {
    try {
      if (!await connect()) {
        return [];
      }

      final collection = _getCollectionByRole(role);
      if (collection == null) {
        return [];
      }

      final users = await collection
          .find(where.sortBy('createdAt', descending: true).limit(limit).skip(skip))
          .toList();

      debugPrint('🍃 MongoDB: Retrieved ${users.length} users for role: $role');
      return users;
    } catch (e) {
      debugPrint('🍃 MongoDB Get Users Error: $e');
      return [];
    }
  }

  /// Search users by name or email
  static Future<List<Map<String, dynamic>>> searchUsers({
    required String role,
    required String searchTerm,
    int limit = 50,
  }) async {
    try {
      if (!await connect()) {
        return [];
      }

      final collection = _getCollectionByRole(role);
      if (collection == null) {
        return [];
      }

      final regex = RegExp(searchTerm, caseSensitive: false);
      final users = await collection
          .find(where
              .or([
                where.match('name', regex.pattern),
                where.match('email', regex.pattern),
              ])
              .limit(limit))
          .toList();

      debugPrint('🍃 MongoDB: Found ${users.length} users matching "$searchTerm"');
      return users;
    } catch (e) {
      debugPrint('🍃 MongoDB Search Users Error: $e');
      return [];
    }
  }

  /// Get user statistics
  static Future<Map<String, int>> getUserStatistics() async {
    try {
      if (!await connect()) {
        return {};
      }

      final stats = <String, int>{};
      
      final farmerCount = await _database!.collection(_farmersCollection).count();
      final distributorCount = await _database!.collection(_distributorsCollection).count();
      final retailerCount = await _database!.collection(_retailersCollection).count();
      final consumerCount = await _database!.collection(_consumersCollection).count();

      stats['farmers'] = farmerCount;
      stats['distributors'] = distributorCount;
      stats['retailers'] = retailerCount;
      stats['consumers'] = consumerCount;
      stats['total'] = farmerCount + distributorCount + retailerCount + consumerCount;

      debugPrint('🍃 MongoDB: User statistics retrieved');
      return stats;
    } catch (e) {
      debugPrint('🍃 MongoDB Statistics Error: $e');
      return {};
    }
  }
}