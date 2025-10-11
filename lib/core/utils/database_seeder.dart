import '../services/batch_service.dart';
import 'package:flutter/foundation.dart';

class DatabaseSeeder {
  static bool _isSeeded = false;

  /// Seed the database with mock data for testing
  static Future<void> seedDatabase() async {
    if (_isSeeded) return;

    try {
      debugPrint('🌱 Seeding database with mock data...');

      // Create mock batches for testing
      await BatchService.createMockBatches();

      _isSeeded = true;
      debugPrint('🌱 Database seeded successfully!');
    } catch (e) {
      debugPrint('🌱 Error seeding database: $e');
    }
  }

  /// Reset seeding flag (for development only)
  static void resetSeedingFlag() {
    _isSeeded = false;
  }
}
