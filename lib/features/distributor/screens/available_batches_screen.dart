import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/batch_request_card.dart';

class AvailableBatchesScreen extends StatefulWidget {
  const AvailableBatchesScreen({super.key});

  @override
  State<AvailableBatchesScreen> createState() => _AvailableBatchesScreenState();
}

class _AvailableBatchesScreenState extends State<AvailableBatchesScreen> {
  String _selectedFilter = 'All';
  String _selectedSort = 'Distance';

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

          // Stats Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Batches',
                    '48',
                    AppColors.distributorPrimary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Avg Quality',
                    '87%',
                    AppColors.success,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Total Value',
                    '₹12.5L',
                    AppColors.info,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Batch List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _availableBatches.length,
              itemBuilder: (context, index) {
                return BatchRequestCard(
                  batch: _availableBatches[index],
                  onAccept: () => _acceptBatch(_availableBatches[index]),
                  onReject: () => _rejectBatch(_availableBatches[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    bool isSelected = _selectedFilter == label;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = selected ? label : 'All';
        });
      },
      backgroundColor: Colors.white,
      selectedColor: AppColors.distributorPrimary.withOpacity(0.2),
      labelStyle: TextStyle(
        color: isSelected
            ? AppColors.distributorPrimary
            : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected
            ? AppColors.distributorPrimary
            : AppColors.textSecondary.withOpacity(0.3),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Batches'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('All Batches'),
              leading: Radio(
                value: 'All',
                groupValue: _selectedFilter,
                onChanged: (value) {
                  setState(() => _selectedFilter = value.toString());
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('Nearby (< 50km)'),
              leading: Radio(
                value: 'Nearby',
                groupValue: _selectedFilter,
                onChanged: (value) {
                  setState(() => _selectedFilter = value.toString());
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('High Quality (> 90)'),
              leading: Radio(
                value: 'High Quality',
                groupValue: _selectedFilter,
                onChanged: (value) {
                  setState(() => _selectedFilter = value.toString());
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sort By'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Distance'),
              leading: Radio(
                value: 'Distance',
                groupValue: _selectedSort,
                onChanged: (value) {
                  setState(() => _selectedSort = value.toString());
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('Quality Score'),
              leading: Radio(
                value: 'Quality',
                groupValue: _selectedSort,
                onChanged: (value) {
                  setState(() => _selectedSort = value.toString());
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('Price'),
              leading: Radio(
                value: 'Price',
                groupValue: _selectedSort,
                onChanged: (value) {
                  setState(() => _selectedSort = value.toString());
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _acceptBatch(Map<String, dynamic> batch) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Accept ${batch['product']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Farmer: ${batch['farmer']}'),
            Text('Quantity: ${batch['quantity']}'),
            Text('Total Value: ₹${batch['totalValue']}'),
            const SizedBox(height: 16),
            const Text('Estimated pickup time:'),
            const Text(
              'Tomorrow 9:00 AM',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${batch['product']} batch accepted! Pickup scheduled.',
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.distributorPrimary,
            ),
            child: const Text(
              'Confirm Accept',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
