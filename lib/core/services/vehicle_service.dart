import '../models/vehicle_model.dart';
import 'mongodb_service.dart';
import 'package:flutter/foundation.dart';
import 'package:mongo_dart/mongo_dart.dart';

class VehicleService {
  static const String _collection = 'vehicles';

  /// Get all vehicles for a distributor
  static Future<List<Vehicle>> getDistributorVehicles(
    String distributorId,
  ) async {
    try {
      debugPrint('🚛 Getting vehicles for distributor $distributorId...');

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
        debugPrint('🚛 Invalid ObjectId format: $distributorId');
        return [];
      }

      final result = await MongoDBService.findDocuments(
        collectionName: _collection,
        filter: {'distributor_id': objectId},
        sortBy: {'created_at': -1},
      );

      if (result['success']) {
        final vehiclesData = result['data'] as List;
        return vehiclesData.map((data) => Vehicle.fromJson(data)).toList();
      } else {
        debugPrint('🚛 Failed to get vehicles: ${result['message']}');
        return [];
      }
    } catch (e) {
      debugPrint('🚛 Error getting vehicles: $e');
      return [];
    }
  }

  /// Add a new vehicle
  static Future<bool> addVehicle(Vehicle vehicle) async {
    try {
      debugPrint('🚛 Adding new vehicle: ${vehicle.vehicleNumber}');

      // Convert distributorId to ObjectId for database storage
      ObjectId? distributorObjectId;
      if (vehicle.distributorId.startsWith('ObjectId("') &&
          vehicle.distributorId.endsWith('")')) {
        final idString = vehicle.distributorId.substring(
          10,
          vehicle.distributorId.length - 2,
        );
        distributorObjectId = ObjectId.tryParse(idString);
      } else {
        distributorObjectId = ObjectId.tryParse(vehicle.distributorId);
      }

      if (distributorObjectId == null) {
        debugPrint('🚛 Invalid ObjectId format: ${vehicle.distributorId}');
        return false;
      }

      // Prepare data with ObjectId
      final vehicleData = vehicle.toJson();
      vehicleData['distributor_id'] = distributorObjectId;

      final result = await MongoDBService.insertDocument(
        collectionName: _collection,
        data: vehicleData,
      );

      if (result['success']) {
        debugPrint('🚛 Vehicle added successfully');
        return true;
      } else {
        debugPrint('🚛 Failed to add vehicle: ${result['message']}');
        return false;
      }
    } catch (e) {
      debugPrint('🚛 Error adding vehicle: $e');
      return false;
    }
  }

  /// Update vehicle status
  static Future<bool> updateVehicleStatus(
    String vehicleId,
    String newStatus, {
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      debugPrint('🚛 Updating vehicle $vehicleId status to $newStatus');

      Map<String, dynamic> updateData = {
        'status': newStatus,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (additionalData != null) {
        updateData.addAll(additionalData);
      }

      final result = await MongoDBService.updateDocument(
        collectionName: _collection,
        filter: {'_id': vehicleId},
        updateData: updateData,
      );

      if (result['success']) {
        debugPrint('🚛 Vehicle status updated successfully');
        return true;
      } else {
        debugPrint('🚛 Failed to update vehicle status: ${result['message']}');
        return false;
      }
    } catch (e) {
      debugPrint('🚛 Error updating vehicle status: $e');
      return false;
    }
  }

  /// Create mock vehicles for testing
  static Future<void> createMockVehicles(String distributorId) async {
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
        debugPrint(
          '🚛 Invalid ObjectId format for mock vehicles: $distributorId',
        );
        return;
      }

      final mockVehicles = [
        {
          'distributor_id': objectId,
          'vehicle_number': 'MH12AB1234',
          'vehicle_type': 'Small Truck',
          'capacity': 2000.0,
          'fuel_type': 'Diesel',
          'status': 'available',
          'current_location': 'Pune, MH',
          'driver_name': 'Ramesh Patil',
          'driver_phone': '+91 9876543210',
          'insurance_expiry': DateTime.now()
              .add(Duration(days: 180))
              .toIso8601String(),
          'maintenance_due': DateTime.now()
              .add(Duration(days: 30))
              .toIso8601String(),
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        },
        {
          'distributor_id': objectId,
          'vehicle_number': 'MH14CD5678',
          'vehicle_type': 'Large Truck',
          'capacity': 5000.0,
          'fuel_type': 'Diesel',
          'status': 'in_transit',
          'current_location': 'Mumbai-Pune Highway',
          'driver_name': 'Suresh Kumar',
          'driver_phone': '+91 9876543211',
          'insurance_expiry': DateTime.now()
              .add(Duration(days: 200))
              .toIso8601String(),
          'maintenance_due': DateTime.now()
              .add(Duration(days: 15))
              .toIso8601String(),
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        },
        {
          'distributor_id': objectId,
          'vehicle_number': 'MH16EF9012',
          'vehicle_type': 'Mini Van',
          'capacity': 1000.0,
          'fuel_type': 'Petrol',
          'status': 'maintenance',
          'current_location': 'Service Center, Nashik',
          'driver_name': 'Prakash Sharma',
          'driver_phone': '+91 9876543212',
          'insurance_expiry': DateTime.now()
              .add(Duration(days: 150))
              .toIso8601String(),
          'maintenance_due': DateTime.now()
              .subtract(Duration(days: 5))
              .toIso8601String(),
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        },
      ];

      for (final vehicle in mockVehicles) {
        await MongoDBService.insertDocument(
          collectionName: _collection,
          data: vehicle,
        );
      }

      debugPrint('🚛 Mock vehicles created successfully');
    } catch (e) {
      debugPrint('🚛 Error creating mock vehicles: $e');
    }
  }

  /// Update an existing vehicle
  static Future<bool> updateVehicle(Vehicle vehicle) async {
    try {
      debugPrint('🚛 Updating vehicle: ${vehicle.vehicleNumber}');

      // Parse ObjectId from string that might contain ObjectId("...")
      String idString = vehicle.id;
      if (idString.startsWith('ObjectId("') && idString.endsWith('")')) {
        idString = idString.substring(10, idString.length - 2);
      }
      final objectId = ObjectId.fromHexString(idString);
      final vehicleData = vehicle.toJson();
      vehicleData['updated_at'] = DateTime.now().toIso8601String();

      // Convert distributorId to ObjectId if it's a string
      if (vehicleData['distributor_id'] is String) {
        final distributorIdStr = vehicleData['distributor_id'] as String;
        if (distributorIdStr.startsWith('ObjectId("') &&
            distributorIdStr.endsWith('")')) {
          final idPart = distributorIdStr.substring(
            10,
            distributorIdStr.length - 2,
          );
          vehicleData['distributor_id'] = ObjectId.fromHexString(idPart);
        } else {
          vehicleData['distributor_id'] = ObjectId.fromHexString(
            distributorIdStr,
          );
        }
      }

      final result = await MongoDBService.updateDocument(
        collectionName: _collection,
        filter: {'_id': objectId},
        updateData: vehicleData,
      );

      if (result['success'] == true) {
        debugPrint('🚛 Vehicle updated successfully');
        return true;
      } else {
        debugPrint('🚛 Failed to update vehicle: ${result['message']}');
        return false;
      }
    } catch (e) {
      debugPrint('🚛 Error updating vehicle: $e');
      return false;
    }
  }

  /// Delete a vehicle
  static Future<bool> deleteVehicle(String vehicleId) async {
    try {
      debugPrint('🚛 Deleting vehicle: $vehicleId');

      // Parse ObjectId from string that might contain ObjectId("...")
      String idString = vehicleId;
      if (idString.startsWith('ObjectId("') && idString.endsWith('")')) {
        idString = idString.substring(10, idString.length - 2);
      }
      final objectId = ObjectId.fromHexString(idString);

      final result = await MongoDBService.deleteDocument(
        collectionName: _collection,
        filter: {'_id': objectId},
      );

      if (result['success'] == true) {
        debugPrint('🚛 Vehicle deleted successfully');
        return true;
      } else {
        debugPrint('🚛 Failed to delete vehicle: ${result['message']}');
        return false;
      }
    } catch (e) {
      debugPrint('🚛 Error deleting vehicle: $e');
      return false;
    }
  }

  /// Calculate vehicle efficiency
  static double calculateEfficiency(Vehicle vehicle) {
    // Calculate efficiency based on fuel consumption and trips
    final baseEfficiency = 100.0;

    // Reduce efficiency for older vehicles
    final daysSinceCreated = DateTime.now()
        .difference(vehicle.createdAt)
        .inDays;
    final ageMultiplier = daysSinceCreated > 365 ? 0.9 : 1.0;

    // Reduce efficiency if maintenance is due
    final isMaintenanceDue =
        vehicle.maintenanceDue?.isBefore(DateTime.now()) ?? false;
    final maintenanceMultiplier = isMaintenanceDue ? 0.8 : 1.0;

    return baseEfficiency * ageMultiplier * maintenanceMultiplier;
  }
}
