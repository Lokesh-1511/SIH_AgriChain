import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class MyBatchesScreen extends StatelessWidget {
  const MyBatchesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats Row
            Row(
              children: [
                Expanded(child: _buildStatCard('Active', '5', AppColors.info)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard('In Transit', '3', AppColors.warning)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard('Delivered', '12', AppColors.success)),
              ],
            ),

            const SizedBox(height: 24),

            Text(
              'My Batches',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 16),

            // Batch List
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _mockBatches.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final batch = _mockBatches[index];
                return _buildBatchCard(context, batch);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String count, Color color) {
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
            count,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBatchCard(BuildContext context, Map<String, dynamic> batch) {
    Color statusColor = _getStatusColor(batch['status']);
    
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                batch['product'],
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  batch['status'],
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildInfoChip('ID', batch['id']),
              const SizedBox(width: 12),
              _buildInfoChip('Qty', batch['quantity']),
              const SizedBox(width: 12),
              _buildInfoChip('Price', '₹${batch['price']}'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Posted: ${batch['date']}',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              TextButton(
                onPressed: () => _showBatchDetails(context, batch),
                child: const Text('View Details'),
              ),
            ],
          ),
          if (batch['status'] == 'Pending') ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _editBatch(context, batch),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.farmerPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                child: const Text('Edit Batch', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.farmerPrimary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          color: AppColors.farmerPrimary,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return AppColors.warning;
      case 'In Transit':
        return AppColors.info;
      case 'Delivered':
        return AppColors.success;
      default:
        return AppColors.textSecondary;
    }
  }

  void _showBatchDetails(BuildContext context, Map<String, dynamic> batch) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(batch['product']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Batch ID: ${batch['id']}'),
            Text('Quantity: ${batch['quantity']}'),
            Text('Price: ₹${batch['price']}'),
            Text('Status: ${batch['status']}'),
            Text('Posted: ${batch['date']}'),
            if (batch['distributor'] != null)
              Text('Distributor: ${batch['distributor']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _editBatch(BuildContext context, Map<String, dynamic> batch) {
    // Navigate to edit batch screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit batch functionality coming soon!')),
    );
  }

  static final List<Map<String, dynamic>> _mockBatches = [
    {
      'id': 'BTH001',
      'product': 'Fresh Tomatoes',
      'quantity': '500 kg',
      'price': '45',
      'status': 'In Transit',
      'date': '2025-09-25',
      'distributor': 'Green Transport Co.',
    },
    {
      'id': 'BTH002',
      'product': 'Organic Onions',
      'quantity': '800 kg',
      'price': '35',
      'status': 'Pending',
      'date': '2025-09-26',
    },
    {
      'id': 'BTH003',
      'product': 'Fresh Carrots',
      'quantity': '300 kg',
      'price': '40',
      'status': 'Delivered',
      'date': '2025-09-20',
      'distributor': 'City Logistics',
    },
    {
      'id': 'BTH004',
      'product': 'Green Cabbage',
      'quantity': '600 kg',
      'price': '20',
      'status': 'In Transit',
      'date': '2025-09-24',
      'distributor': 'Fresh Delivery',
    },
    {
      'id': 'BTH005',
      'product': 'Sweet Potatoes',
      'quantity': '400 kg',
      'price': '50',
      'status': 'Pending',
      'date': '2025-09-27',
    },
  ];
}