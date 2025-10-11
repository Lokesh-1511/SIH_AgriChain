import 'package:flutter/foundation.dart';
import '../models/batch_model.dart';
import '../services/batch_service.dart';

class BatchProvider with ChangeNotifier {
  List<Batch> _availableBatches = [];
  List<Batch> _distributorBatches = [];
  bool _isLoading = false;
  String? _error;

  // Filters
  String? _selectedLocation;
  String? _selectedCategory;
  bool? _isOrganicFilter;
  int? _minQualityScore;

  // Getters
  List<Batch> get availableBatches => _availableBatches;
  List<Batch> get distributorBatches => _distributorBatches;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get selectedLocation => _selectedLocation;
  String? get selectedCategory => _selectedCategory;
  bool? get isOrganicFilter => _isOrganicFilter;
  int? get minQualityScore => _minQualityScore;

  // Available categories
  List<String> get categories => [
    'vegetables',
    'fruits',
    'grains',
    'dairy',
    'poultry',
    'organic',
  ];

  // Available locations (common Maharashtra locations)
  List<String> get locations => [
    'Mumbai, MH',
    'Pune, MH',
    'Nashik, MH',
    'Satara, MH',
    'Kolhapur, MH',
    'Aurangabad, MH',
    'Nagpur, MH',
    'Solapur, MH',
  ];

  /// Load available batches with filters
  Future<void> loadAvailableBatches() async {
    try {
      _setLoading(true);
      _error = null;

      _availableBatches = await BatchService.getAvailableBatches(
        location: _selectedLocation,
        category: _selectedCategory,
        isOrganic: _isOrganicFilter,
        minQualityScore: _minQualityScore,
      );

      debugPrint('📦 Loaded ${_availableBatches.length} available batches');
    } catch (e) {
      _error = 'Failed to load batches: $e';
      debugPrint('📦 Error loading available batches: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Load distributor's accepted batches
  Future<void> loadDistributorBatches(String distributorId) async {
    try {
      _setLoading(true);
      _error = null;

      _distributorBatches = await BatchService.getDistributorBatches(
        distributorId,
      );

      debugPrint('📦 Loaded ${_distributorBatches.length} distributor batches');
    } catch (e) {
      _error = 'Failed to load distributor batches: $e';
      debugPrint('📦 Error loading distributor batches: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Accept a batch
  Future<bool> acceptBatch(String batchId, String distributorId) async {
    try {
      _setLoading(true);
      _error = null;

      final success = await BatchService.acceptBatch(batchId, distributorId);

      if (success) {
        // Remove from available batches
        _availableBatches.removeWhere((batch) => batch.id == batchId);

        // Reload distributor batches to include the new one
        await loadDistributorBatches(distributorId);

        debugPrint('📦 Batch $batchId accepted successfully');
        notifyListeners();
        return true;
      } else {
        _error = 'Failed to accept batch';
        return false;
      }
    } catch (e) {
      _error = 'Error accepting batch: $e';
      debugPrint('📦 Error accepting batch: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update batch status
  Future<bool> updateBatchStatus(
    String batchId,
    String newStatus, {
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      _setLoading(true);
      _error = null;

      final success = await BatchService.updateBatchStatus(
        batchId,
        newStatus,
        additionalData: additionalData,
      );

      if (success) {
        // Update the batch in distributor batches list
        final batchIndex = _distributorBatches.indexWhere(
          (b) => b.id == batchId,
        );
        if (batchIndex != -1) {
          _distributorBatches[batchIndex] = _distributorBatches[batchIndex]
              .copyWith(status: newStatus);
        }

        debugPrint('📦 Batch $batchId status updated to $newStatus');
        notifyListeners();
        return true;
      } else {
        _error = 'Failed to update batch status';
        return false;
      }
    } catch (e) {
      _error = 'Error updating batch status: $e';
      debugPrint('📦 Error updating batch status: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Apply filters
  void setLocationFilter(String? location) {
    _selectedLocation = location;
    notifyListeners();
  }

  void setCategoryFilter(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setOrganicFilter(bool? isOrganic) {
    _isOrganicFilter = isOrganic;
    notifyListeners();
  }

  void setQualityFilter(int? minScore) {
    _minQualityScore = minScore;
    notifyListeners();
  }

  /// Clear all filters
  void clearFilters() {
    _selectedLocation = null;
    _selectedCategory = null;
    _isOrganicFilter = null;
    _minQualityScore = null;
    notifyListeners();
  }

  /// Check if any filters are active
  bool get hasActiveFilters =>
      _selectedLocation != null ||
      _selectedCategory != null ||
      _isOrganicFilter != null ||
      _minQualityScore != null;

  /// Get filtered batches count
  int get filteredBatchesCount => _availableBatches.length;

  /// Calculate estimated profit for a batch
  double calculateEstimatedProfit(Batch batch, double sellingPrice) {
    final costPrice = (batch.currentPrice ?? batch.basePrice) * batch.quantity;
    final revenue = sellingPrice * batch.quantity;
    return revenue - costPrice;
  }

  /// Get quality color based on score
  String getQualityColor(int score) {
    if (score >= 90) return 'excellent';
    if (score >= 80) return 'good';
    if (score >= 70) return 'average';
    return 'poor';
  }

  /// Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Refresh data
  Future<void> refresh() async {
    await loadAvailableBatches();
  }
}
