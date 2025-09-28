import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class VehicleManagementScreen extends StatelessWidget {
  const VehicleManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Vehicle Management'),
        backgroundColor: AppColors.distributorPrimary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => _addVehicle(context),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fleet Overview
            Row(
              children: [
                Expanded(
                  child: _buildFleetStatCard(
                    'Total Vehicles',
                    '8',
                    AppColors.distributorPrimary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildFleetStatCard('Active', '6', AppColors.success),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildFleetStatCard(
                    'Maintenance',
                    '2',
                    AppColors.warning,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            Text(
              'Vehicle Fleet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 16),

            // Vehicle List
            ..._vehicles.map((vehicle) => _buildVehicleCard(context, vehicle)),
          ],
        ),
      ),
    );
  }

  Widget _buildFleetStatCard(String title, String count, Color color) {
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
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleCard(BuildContext context, Map<String, dynamic> vehicle) {
    Color statusColor = _getStatusColor(vehicle['status']);

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
                  color: AppColors.distributorPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.local_shipping,
                  color: AppColors.distributorPrimary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicle['model'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      vehicle['plateNumber'],
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      'Driver: ${vehicle['driver']}',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  vehicle['status'],
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildVehicleInfoChip('Capacity', '${vehicle['capacity']} kg'),
              const SizedBox(width: 8),
              _buildVehicleInfoChip('Mileage', '${vehicle['mileage']} km/l'),
              const SizedBox(width: 8),
              _buildVehicleInfoChip('Age', '${vehicle['age']} years'),
            ],
          ),
          if (vehicle['currentLocation'] != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.location_on, color: AppColors.info, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Current Location: ${vehicle['currentLocation']}',
                      style: TextStyle(
                        color: AppColors.info,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (vehicle['status'] == 'Active') ...[
                    TextButton(
                      onPressed: () => _trackVehicle(context, vehicle),
                      child: const Text(
                        'Track',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _viewVehicleDetails(context, vehicle),
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
                  onPressed: () => _manageVehicle(context, vehicle),
                  icon: const Icon(Icons.settings, size: 16),
                  label: const Text('Manage'),
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

  Widget _buildVehicleInfoChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.distributorPrimary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          color: AppColors.distributorPrimary,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Active':
        return AppColors.success;
      case 'Maintenance':
        return AppColors.warning;
      case 'Idle':
        return AppColors.info;
      case 'Out of Service':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  void _addVehicle(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Vehicle'),
        content: const Text(
          'Vehicle registration feature will be available soon!',
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

  void _trackVehicle(BuildContext context, Map<String, dynamic> vehicle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Track ${vehicle['plateNumber']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Current Location: ${vehicle['currentLocation']}'),
            const SizedBox(height: 8),
            Text('Last Updated: ${DateTime.now().toString().split('.').first}'),
            const SizedBox(height: 16),
            const Text('Real-time GPS tracking will be available soon!'),
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

  void _viewVehicleDetails(BuildContext context, Map<String, dynamic> vehicle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(vehicle['model']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Plate Number: ${vehicle['plateNumber']}'),
            Text('Driver: ${vehicle['driver']}'),
            Text('Capacity: ${vehicle['capacity']} kg'),
            Text('Mileage: ${vehicle['mileage']} km/l'),
            Text('Age: ${vehicle['age']} years'),
            Text('Status: ${vehicle['status']}'),
            if (vehicle['nextMaintenance'] != null)
              Text('Next Maintenance: ${vehicle['nextMaintenance']}'),
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

  void _manageVehicle(BuildContext context, Map<String, dynamic> vehicle) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Manage ${vehicle['plateNumber']}',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.build),
              title: const Text('Schedule Maintenance'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Maintenance scheduling coming soon!'),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Change Driver'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Driver assignment coming soon!'),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.assessment),
              title: const Text('View Reports'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Vehicle reports coming soon!')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  static final List<Map<String, dynamic>> _vehicles = [
    {
      'model': 'Tata Ace Gold',
      'plateNumber': 'MH-12-AB-1234',
      'driver': 'Rajesh Kumar',
      'capacity': 750,
      'mileage': 16,
      'age': 2,
      'status': 'Active',
      'currentLocation': 'Pune Market',
      'nextMaintenance': '15 Oct 2024',
    },
    {
      'model': 'Mahindra Bolero Pickup',
      'plateNumber': 'MH-14-CD-5678',
      'driver': 'Suresh Patil',
      'capacity': 1000,
      'mileage': 14,
      'age': 3,
      'status': 'Active',
      'currentLocation': 'Nashik Highway',
    },
    {
      'model': 'Ashok Leyland Dost',
      'plateNumber': 'MH-15-EF-9012',
      'driver': 'Amit Sharma',
      'capacity': 1200,
      'mileage': 12,
      'age': 1,
      'status': 'Maintenance',
      'nextMaintenance': '2 Oct 2024',
    },
    {
      'model': 'Force Traveller',
      'plateNumber': 'MH-16-GH-3456',
      'driver': 'Mohan Singh',
      'capacity': 1500,
      'mileage': 10,
      'age': 4,
      'status': 'Active',
      'currentLocation': 'Satara Market',
    },
    {
      'model': 'Eicher Pro 1049',
      'plateNumber': 'MH-17-IJ-7890',
      'driver': 'Deepak Joshi',
      'capacity': 2500,
      'mileage': 8,
      'age': 2,
      'status': 'Idle',
    },
  ];
}
