import 'package:mongo_dart/mongo_dart.dart';
import 'package:flutter/foundation.dart';

/// MongoDB Service for storing user data
class MongoDBService {
  static Db? _database;
  static bool _isConnected = false;

  // MongoDB connection string - replace with your actual MongoDB URI
  static const String _connectionString =
      'mongodb+srv://karthikrajaanand12:aaaaaaaa@cluster-akr.pqejowl.mongodb.net/agrichain_db?retryWrites=true&w=majority&appName=Cluster-AKR';

  // Collection names
  static const String _farmersCollection = 'farmers';
  static const String _distributorsCollection = 'distributors';
  static const String _retailersCollection = 'retailers';
  static const String _consumersCollection = 'consumers';

  /// Initialize MongoDB connection
  static Future<bool> connect() async {
    try {
<<<<<<< HEAD
      if (_isConnected && _database != null) {
=======
      if (_isConnected && _database != null && _database!.state == State.open) {
>>>>>>> 5b3ae447a7a6f15554647b4ed5c427121e8f156b
        return true;
      }

      debugPrint('🍃 MongoDB: Connecting to database...');

<<<<<<< HEAD
=======
      // Close existing connection if any
      if (_database != null) {
        try {
          await _database!.close();
        } catch (e) {
          debugPrint('🍃 MongoDB: Error closing existing connection: $e');
        }
      }

>>>>>>> 5b3ae447a7a6f15554647b4ed5c427121e8f156b
      _database = await Db.create(_connectionString);
      await _database!.open();

      _isConnected = true;
      debugPrint('🍃 MongoDB: Connected successfully');

      return true;
    } catch (e) {
      debugPrint('🍃 MongoDB Connection Error: $e');
      _isConnected = false;

<<<<<<< HEAD
      // Try to reconnect after a delay
      await Future.delayed(const Duration(seconds: 2));
      try {
        if (_database == null) {
          _database = await Db.create(_connectionString);
          await _database!.open();
          _isConnected = true;
          debugPrint('🍃 MongoDB: Reconnected successfully');
          return true;
        }
      } catch (retryError) {
        debugPrint('🍃 MongoDB Retry failed: $retryError');
      }

=======
>>>>>>> 5b3ae447a7a6f15554647b4ed5c427121e8f156b
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
<<<<<<< HEAD
  static bool get isConnected => _isConnected && _database != null;
=======
  static bool get isConnected =>
      _isConnected && _database != null && _database!.state == State.open;
>>>>>>> 5b3ae447a7a6f15554647b4ed5c427121e8f156b

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
        return {'success': false, 'message': 'Failed to connect to database'};
      }

      final collection = _getCollectionByRole(role);
      if (collection == null) {
        return {'success': false, 'message': 'Invalid user role: $role'};
      }

      // Check if user already exists
      final existingUser = await collection.findOne(
        where.eq('firebaseUid', firebaseUid),
      );
      if (existingUser != null) {
        return {'success': false, 'message': 'User already exists in database'};
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
      final userId = result.id.toString();

      debugPrint('🍃 MongoDB: User created - Role: $role, ID: $userId');

      return {
        'success': true,
        'userId': userId,
        'message': 'User created successfully',
      };
    } catch (e) {
      debugPrint('🍃 MongoDB Create User Error: $e');
      return {'success': false, 'message': 'Failed to create user: $e'};
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

      final user = await collection.findOne(
        where.eq('firebaseUid', firebaseUid),
      );

      if (user != null) {
        debugPrint('🍃 MongoDB: User found - Role: $role');
      } else {
        debugPrint(
          '🍃 MongoDB: User not found - Role: $role, UID: $firebaseUid',
        );
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
        modify.set('updatedAt', updateData['updatedAt']),
      );

      debugPrint(
        '🍃 MongoDB: User updated - Role: $role, Modified: ${result.nModified}',
      );
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

      final result = await collection.deleteOne(
        where.eq('firebaseUid', firebaseUid),
      );

      debugPrint(
        '🍃 MongoDB: User deleted - Role: $role, Deleted: ${result.nRemoved}',
      );
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
          .find(
            where.sortBy('createdAt', descending: true).limit(limit).skip(skip),
          )
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
          .find(where.match('name', regex.pattern).limit(limit))
          .toList();

      debugPrint(
        '🍃 MongoDB: Found ${users.length} users matching "$searchTerm"',
      );
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

      final farmerCount = await _database!
          .collection(_farmersCollection)
          .count();
      final distributorCount = await _database!
          .collection(_distributorsCollection)
          .count();
      final retailerCount = await _database!
          .collection(_retailersCollection)
          .count();
      final consumerCount = await _database!
          .collection(_consumersCollection)
          .count();

      stats['farmers'] = farmerCount;
      stats['distributors'] = distributorCount;
      stats['retailers'] = retailerCount;
      stats['consumers'] = consumerCount;
      stats['total'] =
          farmerCount + distributorCount + retailerCount + consumerCount;

      debugPrint('🍃 MongoDB: User statistics retrieved');
      return stats;
    } catch (e) {
      debugPrint('🍃 MongoDB Statistics Error: $e');
      return {};
    }
  }
<<<<<<< HEAD
=======

  /// Generic method to find documents in any collection
  static Future<Map<String, dynamic>> findDocuments({
    required String collectionName,
    Map<String, dynamic>? filter,
    Map<String, dynamic>? sortBy,
    int? limit,
  }) async {
    try {
      // Ensure connection
      if (!isConnected) {
        bool connected = await connect();
        if (!connected) {
          return {
            'success': false,
            'message': 'Failed to connect to database',
            'data': [],
          };
        }
      }

      final collection = _database!.collection(collectionName);

      // Build the aggregation pipeline or use simple find
      List<Map<String, dynamic>> documents;

      if (sortBy != null || limit != null) {
        // Use aggregation pipeline for sorting and limiting
        final pipeline = <Map<String, Object>>[];

        // Add match stage if filter exists
        if (filter != null && filter.isNotEmpty) {
          pipeline.add({'\$match': filter});
        }

        // Add sort stage if sortBy exists
        if (sortBy != null) {
          pipeline.add({'\$sort': sortBy});
        }

        // Add limit stage if limit exists
        if (limit != null) {
          pipeline.add({'\$limit': limit});
        }

        final aggregationResult = collection.aggregateToStream(pipeline);
        documents = await aggregationResult.toList();
      } else {
        // Use simple find for basic queries
        final cursor = collection.find(filter ?? {});
        documents = await cursor.toList();
      }

      return {
        'success': true,
        'message': 'Documents found successfully',
        'data': documents,
      };
    } catch (e) {
      debugPrint('🍃 MongoDB Find Error: $e');

      // Try to reconnect and retry once
      if (e.toString().contains('connection') ||
          e.toString().contains('master')) {
        debugPrint('🍃 MongoDB: Connection lost, attempting to reconnect...');
        _isConnected = false;
        bool reconnected = await connect();
        if (reconnected) {
          try {
            final collection = _database!.collection(collectionName);
            final cursor = collection.find(filter ?? {});
            final documents = await cursor.toList();
            return {
              'success': true,
              'message': 'Documents found successfully after reconnection',
              'data': documents,
            };
          } catch (retryError) {
            debugPrint('🍃 MongoDB: Retry failed: $retryError');
          }
        }
      }

      return {
        'success': false,
        'message': 'Error finding documents: $e',
        'data': [],
      };
    }
  }

  /// Generic method to insert a document into any collection
  static Future<Map<String, dynamic>> insertDocument({
    required String collectionName,
    required Map<String, dynamic> data,
  }) async {
    try {
      // Ensure connection
      if (!isConnected) {
        bool connected = await connect();
        if (!connected) {
          return {'success': false, 'message': 'Failed to connect to database'};
        }
      }

      final collection = _database!.collection(collectionName);
      final result = await collection.insertOne(data);

      return {
        'success': true,
        'message': 'Document inserted successfully',
        'insertedId': result.id,
      };
    } catch (e) {
      debugPrint('🍃 MongoDB Insert Error: $e');

      // Try to reconnect and retry once
      if (e.toString().contains('connection') ||
          e.toString().contains('master')) {
        debugPrint(
          '🍃 MongoDB: Connection lost during insert, attempting to reconnect...',
        );
        _isConnected = false;
        bool reconnected = await connect();
        if (reconnected) {
          try {
            final collection = _database!.collection(collectionName);
            final result = await collection.insertOne(data);
            return {
              'success': true,
              'message': 'Document inserted successfully after reconnection',
              'insertedId': result.id,
            };
          } catch (retryError) {
            debugPrint('🍃 MongoDB: Insert retry failed: $retryError');
          }
        }
      }

      return {'success': false, 'message': 'Error inserting document: $e'};
    }
  }

  /// Generic method to update a document in any collection
  static Future<Map<String, dynamic>> updateDocument({
    required String collectionName,
    required Map<String, dynamic> filter,
    required Map<String, dynamic> updateData,
  }) async {
    try {
      if (!_isConnected || _database == null) {
        await connect();
      }

      if (!_isConnected || _database == null) {
        return {'success': false, 'message': 'Database not connected'};
      }

      final collection = _database!.collection(collectionName);
      final result = await collection.updateOne(filter, {'\$set': updateData});

      return {
        'success': result.isSuccess,
        'message': result.isSuccess
            ? 'Document updated successfully'
            : 'Failed to update document',
        'modifiedCount': result.nModified,
      };
    } catch (e) {
      debugPrint('🍃 MongoDB Update Error: $e');
      return {'success': false, 'message': 'Error updating document: $e'};
    }
  }

  /// Generic method to delete a document from any collection
  static Future<Map<String, dynamic>> deleteDocument({
    required String collectionName,
    required Map<String, dynamic> filter,
  }) async {
    try {
      if (!_isConnected || _database == null) {
        await connect();
      }

      if (!_isConnected || _database == null) {
        return {'success': false, 'message': 'Database not connected'};
      }

      final collection = _database!.collection(collectionName);
      final result = await collection.deleteOne(filter);

      return {
        'success': result.isSuccess,
        'message': result.isSuccess
            ? 'Document deleted successfully'
            : 'Failed to delete document',
        'deletedCount': result.nRemoved,
      };
    } catch (e) {
      debugPrint('🍃 MongoDB Delete Error: $e');
      return {'success': false, 'message': 'Error deleting document: $e'};
    }
  }
>>>>>>> 5b3ae447a7a6f15554647b4ed5c427121e8f156b
}
