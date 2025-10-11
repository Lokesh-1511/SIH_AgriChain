import 'mongodb_service.dart';
import 'package:mongo_dart/mongo_dart.dart';

class UserService {
  static Future<Map<String, dynamic>?> getUserById(String userId) async {
    try {
      // Handle ObjectId conversion
      ObjectId? objectId;
      if (userId.startsWith('ObjectId("') && userId.endsWith('")')) {
        final idString = userId.substring(10, userId.length - 2);
        objectId = ObjectId.tryParse(idString);
      } else {
        objectId = ObjectId.tryParse(userId);
      }

      if (objectId == null) {
        print('Invalid ObjectId format: $userId');
        return null;
      }

      final result = await MongoDBService.findDocuments(
        collectionName: 'distributors', // Try distributors collection first
        filter: {'_id': objectId},
      );

      if (result['success'] == true && result['data'] is List) {
        final List<dynamic> users = result['data'];
        if (users.isNotEmpty) {
          return users.first as Map<String, dynamic>;
        }
      }

      // If not found in distributors, try users collection
      final userResult = await MongoDBService.findDocuments(
        collectionName: 'users',
        filter: {'_id': objectId},
      );

      if (userResult['success'] == true && userResult['data'] is List) {
        final List<dynamic> users = userResult['data'];
        return users.isNotEmpty ? users.first as Map<String, dynamic> : null;
      }

      return null;
    } catch (e) {
      print('Error fetching user: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    try {
      // Try distributors collection first
      final result = await MongoDBService.findDocuments(
        collectionName: 'distributors',
        filter: {'email': email},
      );

      if (result['success'] == true && result['data'] is List) {
        final List<dynamic> users = result['data'];
        if (users.isNotEmpty) {
          return users.first as Map<String, dynamic>;
        }
      }

      // If not found in distributors, try users collection
      final userResult = await MongoDBService.findDocuments(
        collectionName: 'users',
        filter: {'email': email},
      );

      if (userResult['success'] == true && userResult['data'] is List) {
        final List<dynamic> users = userResult['data'];
        return users.isNotEmpty ? users.first as Map<String, dynamic> : null;
      }

      return null;
    } catch (e) {
      print('Error fetching user by email: $e');
      return null;
    }
  }

  static Future<int> getUserVehicleCount(String distributorId) async {
    try {
      // Handle ObjectId conversion
      ObjectId? objectId;
      if (distributorId.startsWith('ObjectId("') &&
          distributorId.endsWith('")')) {
        final idString = distributorId.substring(10, distributorId.length - 2);
        objectId = ObjectId.tryParse(idString);
      } else {
        objectId = ObjectId.tryParse(distributorId);
      }

      if (objectId == null) {
        print('Invalid ObjectId format for vehicle count: $distributorId');
        return 0;
      }

      final result = await MongoDBService.findDocuments(
        collectionName: 'vehicles',
        filter: {'distributor_id': objectId},
      );

      if (result['success'] == true && result['data'] is List) {
        final List<dynamic> vehicles = result['data'];
        return vehicles.length;
      }
      return 0;
    } catch (e) {
      print('Error fetching vehicle count: $e');
      return 0;
    }
  }

  static Future<double> getUserRating(String userId) async {
    try {
      // For now, return placeholder rating
      // In future, this would calculate from actual ratings
      return 0.0; // "Yet to be calculated"
    } catch (e) {
      print('Error fetching user rating: $e');
      return 0.0;
    }
  }
}
