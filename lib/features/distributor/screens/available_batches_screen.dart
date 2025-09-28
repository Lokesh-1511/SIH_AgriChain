import 'package:flutter/material.dart';
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Available Batches'),
        backgroundColor: AppColors.distributorPrimary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _showFilterDialog,
            icon: const Icon(Icons.filter_list),
          ),
          IconButton(
            onPressed: _showSortDialog,
            icon: const Icon(Icons.sort),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Nearby'),
                  const SizedBox(width: 8),
                  _buildFilterChip('High Quality'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Organic'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Urgent'),
                ],
              ),
            ),
          ),

          // Stats Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard('Total Batches', '48', AppColors.distributorPrimary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard('Avg Quality', '87%', AppColors.success),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard('Total Value', '₹12.5L', AppColors.info),
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
        color: isSelected ? AppColors.distributorPrimary : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? AppColors.distributorPrimary : AppColors.textSecondary.withOpacity(0.3),
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
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
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
            const Text('Tomorrow 9:00 AM', style: TextStyle(fontWeight: FontWeight.bold)),
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
                SnackBar(content: Text('${batch['product']} batch accepted! Pickup scheduled.')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.distributorPrimary),
            child: const Text('Confirm Accept', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _rejectBatch(Map<String, dynamic> batch) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${batch['product']} batch rejected.')),
    );
  }

  static final List<Map<String, dynamic>> _availableBatches = [
    {
      'product': 'Fresh Tomatoes',
      'productEmoji': '🍅',
      'farmer': 'Ramesh Farm',
      'location': 'Nashik, MH',
      'quantity': '500 kg',
      'price': '45',
      'totalValue': '22,500',
      'harvestDate': 'Today',
      'distance': '25 km',
      'qualityScore': 92,
      'shelfLife': 5,
    },
    {
      'product': 'Organic Onions',
      'productEmoji': '🧅',
      'farmer': 'Green Valley Co-op',
      'location': 'Pune, MH',
      'quantity': '800 kg',
      'price': '35',
      'totalValue': '28,000',
      'harvestDate': 'Tomorrow',
      'distance': '45 km',
      'qualityScore': 88,
      'shelfLife': 14,
    },
    {
      'product': 'Fresh Carrots',
      'productEmoji': '🥕',
      'farmer': 'Sunrise Organics',
      'location': 'Satara, MH',
      'quantity': '300 kg',
      'price': '40',
      'totalValue': '12,000',
      'harvestDate': 'Today',
      'distance': '35 km',
      'qualityScore': 95,
      'shelfLife': 7,
    },
    {
      'product': 'Green Cabbage',
      'productEmoji': '🥬',
      'farmer': 'Nature\'s Best Farm',
      'location': 'Kolhapur, MH',
      'quantity': '600 kg',
      'price': '20',
      'totalValue': '12,000',
      'harvestDate': 'Today',
      'distance': '60 km',
      'qualityScore': 85,
      'shelfLife': 10,
    },
    {
      'product': 'Sweet Potatoes',
      'productEmoji': '🍠',
      'farmer': 'Golden Harvest',
      'location': 'Sangli, MH',
      'quantity': '400 kg',
      'price': '50',
      'totalValue': '20,000',
      'harvestDate': 'Yesterday',
      'distance': '55 km',
      'qualityScore': 90,
      'shelfLife': 21,
    },
  ];
}