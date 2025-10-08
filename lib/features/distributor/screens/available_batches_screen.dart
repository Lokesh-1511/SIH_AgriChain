import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/batch_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/models/batch_model.dart';
import '../../../core/services/batch_service.dart';

class AvailableBatchesScreen extends StatefulWidget {
  const AvailableBatchesScreen({super.key});

  @override
  State<AvailableBatchesScreen> createState() => _AvailableBatchesScreenState();
}

class _AvailableBatchesScreenState extends State<AvailableBatchesScreen> {
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BatchProvider>().loadAvailableBatches();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'available_batches.title'.tr(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.distributorPrimary,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: Icon(
              _showFilters ? Icons.filter_list_off : Icons.filter_list,
            ),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<BatchProvider>().loadAvailableBatches();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_showFilters) _buildFiltersPanel(),
          Expanded(
            child: Consumer<BatchProvider>(
              builder: (context, batchProvider, child) {
                if (batchProvider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.distributorPrimary,
                      ),
                      strokeWidth: 3,
                    ),
                  );
                }

                if (batchProvider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          batchProvider.error!,
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            batchProvider.clearError();
                            batchProvider.loadAvailableBatches();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.distributorPrimary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'retry'.tr(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (batchProvider.availableBatches.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'no_batches_available'.tr(),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'try_adjusting_filters'.tr(),
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => batchProvider.loadAvailableBatches(),
                  color: AppColors.primary,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: batchProvider.availableBatches.length,
                    itemBuilder: (context, index) {
                      final batch = batchProvider.availableBatches[index];
                      return _buildBatchCard(batch);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersPanel() {
    return Consumer<BatchProvider>(
      builder: (context, batchProvider, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'filters'.tr(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (batchProvider.hasActiveFilters)
                    TextButton(
                      onPressed: () {
                        batchProvider.clearFilters();
                        batchProvider.loadAvailableBatches();
                      },
                      child: Text('clear_all'.tr()),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  _buildLocationFilter(batchProvider),
                  _buildCategoryFilter(batchProvider),
                  _buildOrganicFilter(batchProvider),
                  _buildQualityFilter(batchProvider),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => batchProvider.loadAvailableBatches(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: Text('apply_filters'.tr()),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLocationFilter(BatchProvider batchProvider) {
    return DropdownButtonFormField<String>(
      value: batchProvider.selectedLocation,
      decoration: InputDecoration(
        labelText: 'location'.tr(),
        isDense: true,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: [
        DropdownMenuItem<String>(
          value: null,
          child: Text('all_locations'.tr()),
        ),
        ...batchProvider.locations.map((location) {
          return DropdownMenuItem<String>(
            value: location,
            child: Text(location),
          );
        }),
      ],
      onChanged: (value) => batchProvider.setLocationFilter(value),
    );
  }

  Widget _buildCategoryFilter(BatchProvider batchProvider) {
    return DropdownButtonFormField<String>(
      value: batchProvider.selectedCategory,
      decoration: InputDecoration(
        labelText: 'category'.tr(),
        isDense: true,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: [
        DropdownMenuItem<String>(
          value: null,
          child: Text('all_categories'.tr()),
        ),
        ...batchProvider.categories.map((category) {
          return DropdownMenuItem<String>(
            value: category,
            child: Text(category.tr()),
          );
        }),
      ],
      onChanged: (value) => batchProvider.setCategoryFilter(value),
    );
  }

  Widget _buildOrganicFilter(BatchProvider batchProvider) {
    return DropdownButtonFormField<bool>(
      value: batchProvider.isOrganicFilter,
      decoration: InputDecoration(
        labelText: 'organic'.tr(),
        isDense: true,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: [
        DropdownMenuItem<bool>(value: null, child: Text('all'.tr())),
        DropdownMenuItem<bool>(value: true, child: Text('organic_only'.tr())),
        DropdownMenuItem<bool>(value: false, child: Text('conventional'.tr())),
      ],
      onChanged: (value) => batchProvider.setOrganicFilter(value),
    );
  }

  Widget _buildQualityFilter(BatchProvider batchProvider) {
    return DropdownButtonFormField<int>(
      value: batchProvider.minQualityScore,
      decoration: InputDecoration(
        labelText: 'min_quality'.tr(),
        isDense: true,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: [
        DropdownMenuItem<int>(value: null, child: Text('any_quality'.tr())),
        DropdownMenuItem<int>(value: 90, child: Text('excellent_90+'.tr())),
        DropdownMenuItem<int>(value: 80, child: Text('good_80+'.tr())),
        DropdownMenuItem<int>(value: 70, child: Text('average_70+'.tr())),
      ],
      onChanged: (value) => batchProvider.setQualityFilter(value),
    );
  }

  Widget _buildBatchCard(Batch batch) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        batch.productName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        batch.farmerName,
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    if (batch.isOrganic)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'organic'.tr(),
                          style: TextStyle(
                            color: Colors.green[700],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
                    _buildQualityBadge(batch.qualityMetrics?['score'] ?? 0),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    Icons.scale,
                    '${batch.quantity} ${batch.unit}',
                    'quantity'.tr(),
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    Icons.currency_rupee,
                    '₹${batch.currentPrice}/${batch.unit}',
                    'price'.tr(),
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    Icons.location_on,
                    batch.location,
                    'location'.tr(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    Icons.schedule,
                    batch.harvestedAt != null
                        ? _formatDate(batch.harvestedAt!)
                        : 'N/A',
                    'harvested'.tr(),
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    Icons.event,
                    batch.expiryDate != null
                        ? _formatDate(batch.expiryDate!)
                        : 'N/A',
                    'expires'.tr(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Total Value: ₹${(batch.quantity * (batch.currentPrice ?? batch.basePrice)).toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _showAcceptDialog(batch),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: Text('accept_batch'.tr()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildQualityBadge(int score) {
    Color color;
    String text;

    if (score >= 90) {
      color = Colors.green;
      text = 'excellent'.tr();
    } else if (score >= 80) {
      color = Colors.blue;
      text = 'good'.tr();
    } else if (score >= 70) {
      color = Colors.orange;
      text = 'average'.tr();
    } else {
      color = Colors.red;
      text = 'poor'.tr();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$score% $text',
        style: TextStyle(
          color: color.withOpacity(0.8),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;

    if (difference == 0) {
      return 'today'.tr();
    } else if (difference == 1) {
      return 'tomorrow'.tr();
    } else if (difference == -1) {
      return 'yesterday'.tr();
    } else if (difference > 0) {
      return 'in_days'.tr(args: [difference.toString()]);
    } else {
      return 'days_ago'.tr(args: [(-difference).toString()]);
    }
  }

  void _showAcceptDialog(Batch batch) {
    final authProvider = context.read<AuthProvider>();
    final distributorId = authProvider.currentUser?.id;

    if (distributorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('error_user_not_found'.tr()),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final estimatedCost = BatchService.calculateDeliveryCost(
      distance: 50.0, // This should be calculated based on actual distance
      quantity: batch.quantity,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('accept_batch_title'.tr()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('batch_details'.tr()),
            const SizedBox(height: 8),
            Text('Product: ${batch.productName}'),
            Text('Quantity: ${batch.quantity} ${batch.unit}'),
            Text(
              'Price: ₹${batch.currentPrice ?? batch.basePrice}/${batch.unit}',
            ),
            Text(
              'Total: ₹${(batch.quantity * (batch.currentPrice ?? batch.basePrice)).toStringAsFixed(0)}',
            ),
            const SizedBox(height: 8),
            Text(
              'Estimated delivery cost: ₹${estimatedCost.toStringAsFixed(0)}',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cancel'.tr()),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              final batchProvider = context.read<BatchProvider>();
              final success = await batchProvider.acceptBatch(
                batch.id,
                distributorId,
              );

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('batch_accepted_successfully'.tr()),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('failed_to_accept_batch'.tr()),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: Text('accept'.tr()),
          ),
        ],
      ),
    );
  }
}
