import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/vehicle_model.dart';
import '../../../core/services/vehicle_service.dart';
import '../../auth/providers/auth_provider.dart';

class VehicleManagementScreen extends StatefulWidget {
  const VehicleManagementScreen({super.key});

  @override
  State<VehicleManagementScreen> createState() => _VehicleManagementScreenState();
}

class _VehicleManagementScreenState extends State<VehicleManagementScreen> {
  List<Vehicle> _vehicles = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final distributorId = authProvider.currentUser?.id;

      if (distributorId != null) {
        final vehicles = await VehicleService.getDistributorVehicles(distributorId);
        setState(() {
          _vehicles = vehicles;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load vehicles: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Vehicle Management',
          style: TextStyle(
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
            onPressed: _showAddVehicleDialog,
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Add Vehicle',
          ),
          IconButton(
            onPressed: _loadVehicles,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.distributorPrimary),
          strokeWidth: 3,
        ),
      );
    }

    if (_error != null) {
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
              _error!,
              style: TextStyle(
                color: Colors.red[700],
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadVehicles,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.distributorPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Retry',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_vehicles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_shipping_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No vehicles found',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first vehicle to get started',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _showAddVehicleDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.distributorPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.add),
              label: const Text(
                'Add Vehicle',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadVehicles,
      color: AppColors.distributorPrimary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFleetOverview(),
            const SizedBox(height: 24),
            _buildVehiclesList(),
          ],
        ),
      ),
    );
  }

  Widget _buildFleetOverview() {
    final availableCount = _vehicles.where((v) => v.status == 'available').length;
    final inTransitCount = _vehicles.where((v) => v.status == 'in_transit').length;
    final maintenanceCount = _vehicles.where((v) => v.status == 'maintenance').length;
    final totalCapacity = _vehicles.fold<double>(0, (sum, vehicle) => sum + vehicle.capacity);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.dashboard_outlined,
                  color: AppColors.distributorPrimary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Fleet Overview',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total',
                    _vehicles.length.toString(),
                    AppColors.distributorPrimary,
                    Icons.local_shipping,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Available',
                    availableCount.toString(),
                    AppColors.success,
                    Icons.check_circle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'In Transit',
                    inTransitCount.toString(),
                    AppColors.info,
                    Icons.local_shipping,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Maintenance',
                    maintenanceCount.toString(),
                    AppColors.warning,
                    Icons.build,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.distributorPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.distributorPrimary.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.inventory,
                    color: AppColors.distributorPrimary,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Total Capacity',
                    style: TextStyle(
                      color: AppColors.distributorPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(totalCapacity / 1000).toStringAsFixed(1)} Tonnes',
                    style: TextStyle(
                      color: AppColors.distributorPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
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
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildVehiclesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.local_shipping_outlined,
              color: AppColors.distributorPrimary,
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text(
              'Vehicles',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _vehicles.length,
          itemBuilder: (context, index) {
            final vehicle = _vehicles[index];
            return _buildVehicleCard(vehicle);
          },
        ),
      ],
    );
  }

  Widget _buildVehicleCard(Vehicle vehicle) {
    Color statusColor = AppColors.success;
    IconData statusIcon = Icons.check_circle;
    
    switch (vehicle.status.toLowerCase()) {
      case 'available':
        statusColor = AppColors.success;
        statusIcon = Icons.check_circle;
        break;
      case 'in_transit':
        statusColor = AppColors.info;
        statusIcon = Icons.local_shipping;
        break;
      case 'maintenance':
        statusColor = AppColors.warning;
        statusIcon = Icons.build;
        break;
      default:
        statusColor = AppColors.error;
        statusIcon = Icons.cancel;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              AppColors.distributorPrimary.withOpacity(0.05),
            ],
          ),
          border: Border.all(
            color: AppColors.distributorPrimary.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.distributorPrimary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.local_shipping,
                      color: AppColors.distributorPrimary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vehicle.vehicleNumber,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          vehicle.vehicleType,
                          style: TextStyle(
                            color: AppColors.distributorPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, color: statusColor, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          vehicle.status.toUpperCase(),
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildVehicleInfoItem(
                      Icons.inventory,
                      vehicle.formattedCapacity,
                      'Capacity',
                    ),
                  ),
                  Expanded(
                    child: _buildVehicleInfoItem(
                      Icons.local_gas_station,
                      vehicle.fuelType,
                      'Fuel Type',
                    ),
                  ),
                  Expanded(
                    child: _buildVehicleInfoItem(
                      Icons.location_on,
                      vehicle.currentLocation,
                      'Location',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildVehicleInfoItem(
                      Icons.person,
                      vehicle.driverName,
                      'Driver',
                    ),
                  ),
                  Expanded(
                    child: _buildVehicleInfoItem(
                      Icons.phone,
                      vehicle.driverPhone,
                      'Phone',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _showVehicleDetails(vehicle),
                    icon: const Icon(Icons.info_outline, size: 16),
                    label: const Text('Details'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.distributorPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _showEditVehicleDialog(vehicle),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Edit'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.distributorPrimary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _showDeleteConfirmationDialog(vehicle),
                    icon: const Icon(Icons.delete, size: 16),
                    label: const Text('Delete'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleInfoItem(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.distributorPrimary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.distributorPrimary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: AppColors.distributorPrimary),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _showVehicleDetails(Vehicle vehicle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(vehicle.vehicleNumber),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Type: ${vehicle.vehicleType}'),
              const SizedBox(height: 8),
              Text('Capacity: ${vehicle.formattedCapacity}'),
              const SizedBox(height: 8),
              Text('Fuel: ${vehicle.fuelType}'),
              const SizedBox(height: 8),
              Text('Status: ${vehicle.status}'),
              const SizedBox(height: 8),
              Text('Driver: ${vehicle.driverName}'),
              const SizedBox(height: 8),
              Text('Phone: ${vehicle.driverPhone}'),
              const SizedBox(height: 8),
              Text('Location: ${vehicle.currentLocation}'),
              if (vehicle.insuranceExpiry != null) ...[
                const SizedBox(height: 8),
                Text('Insurance Expiry: ${vehicle.insuranceExpiry!.toString().split(' ')[0]}'),
              ],
              if (vehicle.maintenanceDue != null) ...[
                const SizedBox(height: 8),
                Text('Maintenance Due: ${vehicle.maintenanceDue!.toString().split(' ')[0]}'),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.distributorPrimary,
            ),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAddVehicleDialog() {
    final formKey = GlobalKey<FormState>();
    final vehicleNumberController = TextEditingController();
    final driverNameController = TextEditingController();
    final driverPhoneController = TextEditingController();
    final currentLocationController = TextEditingController();
    final capacityController = TextEditingController();
    
    String selectedVehicleType = 'Truck';
    String selectedFuelType = 'Diesel';
    String selectedStatus = 'available';
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text(
            'Add New Vehicle',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.distributorPrimary,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: vehicleNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Vehicle Number',
                        hintText: 'e.g., MH12AB1234',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter vehicle number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedVehicleType,
                      decoration: const InputDecoration(
                        labelText: 'Vehicle Type',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Truck', child: Text('Truck')),
                        DropdownMenuItem(value: 'Van', child: Text('Van')),
                        DropdownMenuItem(value: 'Pickup', child: Text('Pickup')),
                        DropdownMenuItem(value: 'Mini Truck', child: Text('Mini Truck')),
                      ],
                      onChanged: (value) => setState(() => selectedVehicleType = value!),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: capacityController,
                      decoration: const InputDecoration(
                        labelText: 'Capacity (tonnes)',
                        hintText: 'e.g., 5.0',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter capacity';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedFuelType,
                      decoration: const InputDecoration(
                        labelText: 'Fuel Type',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Diesel', child: Text('Diesel')),
                        DropdownMenuItem(value: 'Petrol', child: Text('Petrol')),
                        DropdownMenuItem(value: 'CNG', child: Text('CNG')),
                        DropdownMenuItem(value: 'Electric', child: Text('Electric')),
                      ],
                      onChanged: (value) => setState(() => selectedFuelType = value!),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedStatus,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'available', child: Text('Available')),
                        DropdownMenuItem(value: 'in_transit', child: Text('In Transit')),
                        DropdownMenuItem(value: 'maintenance', child: Text('Maintenance')),
                        DropdownMenuItem(value: 'out_of_service', child: Text('Out of Service')),
                      ],
                      onChanged: (value) => setState(() => selectedStatus = value!),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: driverNameController,
                      decoration: const InputDecoration(
                        labelText: 'Driver Name',
                        hintText: 'e.g., Rajesh Kumar',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter driver name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: driverPhoneController,
                      decoration: const InputDecoration(
                        labelText: 'Driver Phone',
                        hintText: 'e.g., +91 9876543210',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter driver phone';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: currentLocationController,
                      decoration: const InputDecoration(
                        labelText: 'Current Location',
                        hintText: 'e.g., Mumbai, Maharashtra',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter current location';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => _addVehicle(
                formKey,
                vehicleNumberController.text,
                selectedVehicleType,
                double.tryParse(capacityController.text) ?? 0.0,
                selectedFuelType,
                selectedStatus,
                driverNameController.text,
                driverPhoneController.text,
                currentLocationController.text,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.distributorPrimary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Add Vehicle'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addVehicle(
    GlobalKey<FormState> formKey,
    String vehicleNumber,
    String vehicleType,
    double capacity,
    String fuelType,
    String status,
    String driverName,
    String driverPhone,
    String currentLocation,
  ) async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    try {
      final authProvider = context.read<AuthProvider>();
      final distributorId = authProvider.currentUser?.id;

      if (distributorId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: User not authenticated')),
        );
        return;
      }

      final newVehicle = Vehicle(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        distributorId: distributorId,
        vehicleNumber: vehicleNumber.trim(),
        vehicleType: vehicleType,
        capacity: capacity,
        fuelType: fuelType,
        status: status,
        currentLocation: currentLocation.trim(),
        driverName: driverName.trim(),
        driverPhone: driverPhone.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final success = await VehicleService.addVehicle(newVehicle);

      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vehicle added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        _loadVehicles(); // Refresh the vehicle list
        
        // Trigger a global refresh for vehicle count in profile
        _refreshGlobalVehicleCount();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to add vehicle. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding vehicle: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Trigger a global refresh for vehicle count
  void _refreshGlobalVehicleCount() {
    // This can be used to notify other parts of the app about vehicle count changes
    // For now, we'll just print a debug message, but this could be enhanced with
    // state management solutions like Provider, Riverpod, or BLoC
    debugPrint('🚛 Vehicle count updated - triggering global refresh');
  }

  /// Show edit vehicle dialog
  void _showEditVehicleDialog(Vehicle vehicle) {
    final vehicleNumberController = TextEditingController(text: vehicle.vehicleNumber);
    final vehicleTypeController = TextEditingController(text: vehicle.vehicleType);
    final capacityController = TextEditingController(text: vehicle.capacity.toString());
    final fuelTypeController = TextEditingController(text: vehicle.fuelType);
    
    // Normalize status to database format
    String normalizedStatus = vehicle.status.toLowerCase().replaceAll(' ', '_');
    final statusController = TextEditingController(text: normalizedStatus);
    
    final locationController = TextEditingController(text: vehicle.currentLocation);
    final driverNameController = TextEditingController(text: vehicle.driverName);
    final driverPhoneController = TextEditingController(text: vehicle.driverPhone);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.edit, color: AppColors.distributorPrimary),
            const SizedBox(width: 8),
            const Text('Edit Vehicle'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: vehicleNumberController,
                decoration: const InputDecoration(
                  labelText: 'Vehicle Number',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: vehicleTypeController,
                decoration: const InputDecoration(
                  labelText: 'Vehicle Type',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: capacityController,
                decoration: const InputDecoration(
                  labelText: 'Capacity (kg)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: fuelTypeController,
                decoration: const InputDecoration(
                  labelText: 'Fuel Type',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: statusController.text,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: ['available', 'in_transit', 'maintenance', 'out_of_service'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value.replaceAll('_', ' ').toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) {
                  statusController.text = value ?? 'available';
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(
                  labelText: 'Current Location',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: driverNameController,
                decoration: const InputDecoration(
                  labelText: 'Driver Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: driverPhoneController,
                decoration: const InputDecoration(
                  labelText: 'Driver Phone',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _updateVehicle(
              vehicle,
              vehicleNumberController,
              vehicleTypeController,
              capacityController,
              fuelTypeController,
              statusController,
              locationController,
              driverNameController,
              driverPhoneController,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.distributorPrimary,
            ),
            child: const Text('Update', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /// Update vehicle method
  void _updateVehicle(
    Vehicle vehicle,
    TextEditingController vehicleNumberController,
    TextEditingController vehicleTypeController,
    TextEditingController capacityController,
    TextEditingController fuelTypeController,
    TextEditingController statusController,
    TextEditingController locationController,
    TextEditingController driverNameController,
    TextEditingController driverPhoneController,
  ) async {
    try {
      final updatedVehicle = Vehicle(
        id: vehicle.id,
        distributorId: vehicle.distributorId,
        vehicleNumber: vehicleNumberController.text.trim(),
        vehicleType: vehicleTypeController.text.trim(),
        capacity: double.tryParse(capacityController.text) ?? vehicle.capacity,
        fuelType: fuelTypeController.text.trim(),
        status: statusController.text.trim(),
        currentLocation: locationController.text.trim(),
        driverName: driverNameController.text.trim(),
        driverPhone: driverPhoneController.text.trim(),
        insuranceExpiry: vehicle.insuranceExpiry,
        maintenanceDue: vehicle.maintenanceDue,
        createdAt: vehicle.createdAt,
        updatedAt: DateTime.now(),
      );

      final success = await VehicleService.updateVehicle(updatedVehicle);

      Navigator.pop(context);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vehicle updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        await _loadVehicles();
        _refreshGlobalVehicleCount();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update vehicle. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating vehicle: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Show delete confirmation dialog
  void _showDeleteConfirmationDialog(Vehicle vehicle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: AppColors.error),
            const SizedBox(width: 8),
            const Text('Delete Vehicle'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to delete this vehicle?'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vehicle.vehicleNumber,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('Type: ${vehicle.vehicleType}'),
                  Text('Driver: ${vehicle.driverName}'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'This action cannot be undone.',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _deleteVehicle(vehicle),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /// Delete vehicle method
  void _deleteVehicle(Vehicle vehicle) async {
    try {
      final success = await VehicleService.deleteVehicle(vehicle.id);

      Navigator.pop(context);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vehicle deleted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        await _loadVehicles();
        _refreshGlobalVehicleCount();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete vehicle. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting vehicle: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}