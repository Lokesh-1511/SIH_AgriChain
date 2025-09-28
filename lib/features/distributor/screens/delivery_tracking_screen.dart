import 'package:flutter/material.dart';
import 'dart:async';
import '../../../core/theme/app_colors.dart';

class DeliveryTrackingScreen extends StatefulWidget {
  const DeliveryTrackingScreen({super.key});

  @override
  State<DeliveryTrackingScreen> createState() => _DeliveryTrackingScreenState();
}

class _DeliveryTrackingScreenState extends State<DeliveryTrackingScreen> {
  String _selectedFilter = 'All';
  Timer? _locationTimer;

  @override
  void initState() {
    super.initState();
    _startLocationUpdates();
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    super.dispose();
  }

  void _startLocationUpdates() {
    _locationTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      // Simulate real-time location updates
      setState(() {
        // Update delivery locations (in real app, this would come from GPS/API)
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Delivery Tracking'),
        backgroundColor: AppColors.distributorPrimary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => _showMapView(context),
            icon: const Icon(Icons.map),
          ),
        ],
      ),
      body: Column(
        children: [
          // Status Overview
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.distributorPrimary,
                  AppColors.distributorPrimary.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.distributorPrimary.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatusItem('Active', '8', Icons.local_shipping),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.white.withOpacity(0.3),
                ),
                Expanded(
                  child: _buildStatusItem(
                    'Delivered',
                    '24',
                    Icons.check_circle,
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.white.withOpacity(0.3),
                ),
                Expanded(
                  child: _buildStatusItem('Pending', '3', Icons.schedule),
                ),
              ],
            ),
          ),

          // Filter Tabs
          Container(
            height: 40,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilterChip('All'),
                _buildFilterChip('In Transit'),
                _buildFilterChip('Delivered'),
                _buildFilterChip('Pending'),
                _buildFilterChip('Delayed'),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Delivery List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _getFilteredDeliveries().length,
              itemBuilder: (context, index) {
                final delivery = _getFilteredDeliveries()[index];
                return _buildDeliveryCard(context, delivery);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createNewDelivery(context),
        backgroundColor: AppColors.distributorPrimary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildStatusItem(String label, String count, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 8),
        Text(
          count,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String filter) {
    bool isSelected = _selectedFilter == filter;
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(filter),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedFilter = filter;
          });
        },
        selectedColor: AppColors.distributorPrimary.withOpacity(0.2),
        checkmarkColor: AppColors.distributorPrimary,
        labelStyle: TextStyle(
          color: isSelected
              ? AppColors.distributorPrimary
              : AppColors.textSecondary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildDeliveryCard(
    BuildContext context,
    Map<String, dynamic> delivery,
  ) {
    Color statusColor = _getStatusColor(delivery['status']);
    double progress = _getDeliveryProgress(delivery['status']);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getStatusIcon(delivery['status']),
                  color: statusColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Order #${delivery['orderId']}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            delivery['status'],
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      delivery['customerName'],
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '${delivery['vehicle']} • ${delivery['driver']}',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'ETA: ${delivery['eta']}',
                    style: TextStyle(
                      color: AppColors.distributorPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${delivery['distance']} km',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Progress Bar
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progress',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.textSecondary.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Location & Route Info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.location_on, color: AppColors.success, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'From: ${delivery['origin']}',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.flag, color: AppColors.error, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'To: ${delivery['destination']}',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                if (delivery['currentLocation'] != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.my_location, color: AppColors.info, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Current: ${delivery['currentLocation']}',
                          style: TextStyle(
                            color: AppColors.info,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Text(
                        'Updated: ${delivery['lastUpdate']}',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _viewDeliveryDetails(context, delivery),
                  icon: const Icon(Icons.info_outline, size: 16),
                  label: const Text('Details'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _trackLive(context, delivery),
                  icon: const Icon(Icons.gps_fixed, size: 16),
                  label: const Text('Track Live'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.distributorPrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return AppColors.success;
      case 'in transit':
        return AppColors.info;
      case 'pending':
        return AppColors.warning;
      case 'delayed':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return Icons.check_circle;
      case 'in transit':
        return Icons.local_shipping;
      case 'pending':
        return Icons.schedule;
      case 'delayed':
        return Icons.warning;
      default:
        return Icons.help;
    }
  }

  double _getDeliveryProgress(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return 1.0;
      case 'in transit':
        return 0.65;
      case 'pending':
        return 0.1;
      case 'delayed':
        return 0.3;
      default:
        return 0.0;
    }
  }

  List<Map<String, dynamic>> _getFilteredDeliveries() {
    if (_selectedFilter == 'All') {
      return _deliveries;
    }
    return _deliveries
        .where((delivery) => delivery['status'] == _selectedFilter)
        .toList();
  }

  void _showMapView(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Map View'),
        content: Container(
          height: 300,
          width: 300,
          decoration: BoxDecoration(
            color: AppColors.info.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.map, size: 64),
                SizedBox(height: 16),
                Text('Interactive map with real-time'),
                Text('vehicle tracking will be'),
                Text('available soon!'),
              ],
            ),
          ),
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

  void _viewDeliveryDetails(
    BuildContext context,
    Map<String, dynamic> delivery,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delivery #${delivery['orderId']}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Customer: ${delivery['customerName']}'),
              Text('Vehicle: ${delivery['vehicle']}'),
              Text('Driver: ${delivery['driver']}'),
              Text('Status: ${delivery['status']}'),
              Text('Distance: ${delivery['distance']} km'),
              Text('ETA: ${delivery['eta']}'),
              const SizedBox(height: 8),
              const Text(
                'Route:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('From: ${delivery['origin']}'),
              Text('To: ${delivery['destination']}'),
              if (delivery['currentLocation'] != null)
                Text('Current: ${delivery['currentLocation']}'),
              const SizedBox(height: 8),
              const Text(
                'Items:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...delivery['items']
                  .map<Widget>((item) => Text('• $item'))
                  .toList(),
            ],
          ),
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

  void _trackLive(BuildContext context, Map<String, dynamic> delivery) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Live Tracking - ${delivery['orderId']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.gps_fixed, size: 48),
                    SizedBox(height: 16),
                    Text('Real-time GPS tracking'),
                    Text('with live location updates'),
                    Text('coming soon!'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Current Location: ${delivery['currentLocation'] ?? 'Unknown'}',
            ),
            Text('Last Update: ${delivery['lastUpdate']}'),
            Text('Speed: 45 km/h'),
            Text('Next Checkpoint: 2.5 km'),
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

  void _createNewDelivery(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Delivery'),
        content: const Text(
          'New delivery creation feature will be available soon!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  static final List<Map<String, dynamic>> _deliveries = [
    {
      'orderId': 'D001',
      'customerName': 'Green Valley Mart',
      'vehicle': 'MH-12-AB-1234',
      'driver': 'Rajesh Kumar',
      'status': 'In Transit',
      'origin': 'Pune Distribution Center',
      'destination': 'Green Valley Mart, Nashik',
      'currentLocation': 'Alephata Toll Plaza',
      'distance': 45,
      'eta': '2:30 PM',
      'lastUpdate': '5 mins ago',
      'items': ['Alphonso Mango 50kg', 'Basmati Rice 100kg', 'Red Onion 25kg'],
    },
    {
      'orderId': 'D002',
      'customerName': 'Fresh Foods Store',
      'vehicle': 'MH-14-CD-5678',
      'driver': 'Suresh Patil',
      'status': 'Delivered',
      'origin': 'Pune Distribution Center',
      'destination': 'Fresh Foods Store, Satara',
      'distance': 0,
      'eta': 'Delivered',
      'lastUpdate': '1 hour ago',
      'items': ['Fresh Milk 80L', 'Green Peas 30kg'],
    },
    {
      'orderId': 'D003',
      'customerName': 'Organic Bazaar',
      'vehicle': 'MH-15-EF-9012',
      'driver': 'Amit Sharma',
      'status': 'Pending',
      'origin': 'Pune Distribution Center',
      'destination': 'Organic Bazaar, Kolhapur',
      'distance': 120,
      'eta': '5:00 PM',
      'lastUpdate': 'Not started',
      'items': ['Turmeric Powder 25kg', 'Organic Vegetables 40kg'],
    },
    {
      'orderId': 'D004',
      'customerName': 'City Fresh Market',
      'vehicle': 'MH-16-GH-3456',
      'driver': 'Mohan Singh',
      'status': 'In Transit',
      'origin': 'Pune Distribution Center',
      'destination': 'City Fresh Market, Aurangabad',
      'currentLocation': 'Ahmednagar',
      'distance': 85,
      'eta': '4:15 PM',
      'lastUpdate': '10 mins ago',
      'items': ['Mixed Vegetables 60kg', 'Dairy Products 40kg'],
    },
    {
      'orderId': 'D005',
      'customerName': 'Premium Grocers',
      'vehicle': 'MH-17-IJ-7890',
      'driver': 'Deepak Joshi',
      'status': 'Delayed',
      'origin': 'Pune Distribution Center',
      'destination': 'Premium Grocers, Solapur',
      'currentLocation': 'Baramati (Vehicle Issue)',
      'distance': 95,
      'eta': '6:30 PM (Delayed)',
      'lastUpdate': '20 mins ago',
      'items': ['Premium Rice 80kg', 'Spices 15kg'],
    },
  ];
}
