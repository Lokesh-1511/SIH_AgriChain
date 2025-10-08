import '../models/batch_model.dart';
import 'mongodb_service.dart';
import 'package:flutter/foundation.dart';

class BatchService {
  static const String _collection = 'batches';

  /// Get all available batches for distributors
  static Future<List<Batch>> getAvailableBatches({
    String? location,
    String? category,
    int? maxDistance,
    bool? isOrganic,
    int? minQualityScore,
    int limit = 20,
  }) async {
    try {
      debugPrint('🚛 Getting available batches for distributor...');

      // Query filters
      Map<String, dynamic> filters = {
        'status': 'available',
        'distributor_id': null, // Not yet assigned to any distributor
      };

      if (location != null) {
        filters['location'] = RegExp(location, caseSensitive: false);
      }

      if (category != null) {
        filters['category'] = category;
      }

      if (isOrganic != null) {
        filters['is_organic'] = isOrganic;
      }

      if (minQualityScore != null) {
        filters['quality_metrics.score'] = {'\$gte': minQualityScore};
      }

      final result = await MongoDBService.findDocuments(
        collectionName: _collection,
        filter: filters,
        limit: limit,
        sortBy: {'created_at': -1}, // Most recent first
      );

      if (result['success']) {
        final batchesData = result['data'] as List;
        return batchesData.map((data) => Batch.fromJson(data)).toList();
      } else {
        debugPrint('🚛 Failed to get available batches: ${result['message']}');
        return [];
      }
    } catch (e) {
      debugPrint('🚛 Error getting available batches: $e');
      return [];
    }
  }

  /// Accept a batch by distributor
  static Future<bool> acceptBatch(String batchId, String distributorId) async {
    try {
      debugPrint('🚛 Accepting batch $batchId by distributor $distributorId');

      final result = await MongoDBService.updateDocument(
        collectionName: _collection,
        filter: {'_id': batchId, 'status': 'available'},
        updateData: {
          'status': 'accepted',
          'distributor_id': distributorId,
          'accepted_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        },
      );

      if (result['success']) {
        debugPrint('🚛 Batch accepted successfully');
        return true;
      } else {
        debugPrint('🚛 Failed to accept batch: ${result['message']}');
        return false;
      }
    } catch (e) {
      debugPrint('🚛 Error accepting batch: $e');
      return false;
    }
  }

  /// Get batches assigned to a specific distributor
  static Future<List<Batch>> getDistributorBatches(String distributorId) async {
    try {
      debugPrint('🚛 Getting batches for distributor $distributorId');

      final result = await MongoDBService.findDocuments(
        collectionName: _collection,
        filter: {'distributor_id': distributorId},
        sortBy: {'accepted_at': -1},
      );

      if (result['success']) {
        final batchesData = result['data'] as List;
        return batchesData.map((data) => Batch.fromJson(data)).toList();
      } else {
        debugPrint(
          '🚛 Failed to get distributor batches: ${result['message']}',
        );
        return [];
      }
    } catch (e) {
      debugPrint('🚛 Error getting distributor batches: $e');
      return [];
    }
  }

  /// Update batch status (e.g., in_transit, delivered)
  static Future<bool> updateBatchStatus(
    String batchId,
    String newStatus, {
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      debugPrint('🚛 Updating batch $batchId status to $newStatus');

      Map<String, dynamic> updateData = {
        'status': newStatus,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (additionalData != null) {
        updateData.addAll(additionalData);
      }

      // Add specific timestamp based on status
      switch (newStatus) {
        case 'in_transit':
          updateData['pickup_at'] = DateTime.now().toIso8601String();
          break;
        case 'delivered':
          updateData['delivered_at'] = DateTime.now().toIso8601String();
          break;
      }

      final result = await MongoDBService.updateDocument(
        collectionName: _collection,
        filter: {'_id': batchId},
        updateData: updateData,
      );

      if (result['success']) {
        debugPrint('🚛 Batch status updated successfully');
        return true;
      } else {
        debugPrint('🚛 Failed to update batch status: ${result['message']}');
        return false;
      }
    } catch (e) {
      debugPrint('🚛 Error updating batch status: $e');
      return false;
    }
  }

  /// Create mock batches for testing (remove in production)
  static Future<void> createMockBatches() async {
    final mockBatches = [
      {
        'farmer_id': 'farmer123',
        'farmer_name': 'Ramesh Farm',
        'product_name': 'Tomatoes',
        'category': 'vegetables',
        'quantity': 500.0,
        'unit': 'kg',
        'base_price': 45.0,
        'current_price': 45.0,
        'location': 'Nashik, MH',
        'status': 'available',
        'is_organic': true,
        'quality_metrics': {
          'score': 92,
          'color': 'excellent',
          'firmness': 'good',
          'size': 'medium',
        },
        'harvested_at': DateTime.now()
            .subtract(Duration(hours: 6))
            .toIso8601String(),
        'expiry_date': DateTime.now().add(Duration(days: 5)).toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      {
        'farmer_id': 'farmer456',
        'farmer_name': 'Green Valley Co-op',
        'product_name': 'Onions',
        'category': 'vegetables',
        'quantity': 800.0,
        'unit': 'kg',
        'base_price': 35.0,
        'current_price': 35.0,
        'location': 'Pune, MH',
        'status': 'available',
        'is_organic': false,
        'quality_metrics': {
          'score': 88,
          'color': 'good',
          'firmness': 'excellent',
          'size': 'large',
        },
        'harvested_at': DateTime.now()
            .subtract(Duration(hours: 12))
            .toIso8601String(),
        'expiry_date': DateTime.now().add(Duration(days: 14)).toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      {
        'farmer_id': 'farmer789',
        'farmer_name': 'Sunrise Organics',
        'product_name': 'Carrots',
        'category': 'vegetables',
        'quantity': 300.0,
        'unit': 'kg',
        'base_price': 40.0,
        'current_price': 40.0,
        'location': 'Satara, MH',
        'status': 'available',
        'is_organic': true,
        'quality_metrics': {
          'score': 95,
          'color': 'excellent',
          'firmness': 'excellent',
          'size': 'medium',
        },
        'harvested_at': DateTime.now()
            .subtract(Duration(hours: 3))
            .toIso8601String(),
        'expiry_date': DateTime.now().add(Duration(days: 7)).toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
    ];

    for (final batch in mockBatches) {
      await MongoDBService.insertDocument(
        collectionName: _collection,
        data: batch,
      );
    }

    debugPrint('🚛 Mock batches created successfully');
  }

  /// Calculate estimated delivery cost
  static double calculateDeliveryCost({
    required double distance,
    required double quantity,
    String vehicleType = 'small_truck',
  }) {
    // Base cost per km
    double costPerKm = 8.0;

    // Vehicle type multiplier
    switch (vehicleType) {
      case 'bike':
        costPerKm = 3.0;
        break;
      case 'small_truck':
        costPerKm = 8.0;
        break;
      case 'large_truck':
        costPerKm = 15.0;
        break;
    }

    // Quantity factor (more quantity = lower per kg cost)
    double quantityFactor = quantity > 500
        ? 0.8
        : quantity > 100
        ? 0.9
        : 1.0;

    return (distance * costPerKm * quantityFactor).roundToDouble();
  }
}
