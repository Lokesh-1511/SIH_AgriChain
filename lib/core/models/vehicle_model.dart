class Vehicle {
  final String id;
  final String distributorId;
  final String vehicleNumber;
  final String vehicleType;
  final double capacity;
  final String fuelType;
  final String status;
  final String currentLocation;
  final String driverName;
  final String driverPhone;
  final DateTime? insuranceExpiry;
  final DateTime? maintenanceDue;
  final DateTime createdAt;
  final DateTime updatedAt;

  Vehicle({
    required this.id,
    required this.distributorId,
    required this.vehicleNumber,
    required this.vehicleType,
    required this.capacity,
    required this.fuelType,
    required this.status,
    required this.currentLocation,
    required this.driverName,
    required this.driverPhone,
    this.insuranceExpiry,
    this.maintenanceDue,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    // Handle ObjectId conversion properly
    String getId(dynamic idValue) {
      if (idValue == null) return '';
      if (idValue is String) return idValue;
      // Handle ObjectId - extract the hex string
      String idString = idValue.toString();
      if (idString.startsWith('ObjectId("') && idString.endsWith('")')) {
        return idString.substring(10, idString.length - 2);
      }
      return idString;
    }

    String getDistributorId(dynamic idValue) {
      if (idValue == null) return '';
      if (idValue is String) return idValue;
      // Handle ObjectId - keep the full format for distributor ID
      String idString = idValue.toString();
      return idString;
    }

    return Vehicle(
      id: getId(json['_id'] ?? json['id']),
      distributorId: getDistributorId(json['distributor_id']),
      vehicleNumber: json['vehicle_number'] ?? '',
      vehicleType: json['vehicle_type'],
      capacity: json['capacity']?.toDouble() ?? 0.0,
      fuelType: json['fuel_type'],
      status: json['status'],
      currentLocation: json['current_location'],
      driverName: json['driver_name'],
      driverPhone: json['driver_phone'],
      insuranceExpiry: json['insurance_expiry'] != null
          ? DateTime.parse(json['insurance_expiry'])
          : null,
      maintenanceDue: json['maintenance_due'] != null
          ? DateTime.parse(json['maintenance_due'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'distributor_id': distributorId,
      'vehicle_number': vehicleNumber,
      'vehicle_type': vehicleType,
      'capacity': capacity,
      'fuel_type': fuelType,
      'status': status,
      'current_location': currentLocation,
      'driver_name': driverName,
      'driver_phone': driverPhone,
      'insurance_expiry': insuranceExpiry?.toIso8601String(),
      'maintenance_due': maintenanceDue?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Vehicle copyWith({
    String? id,
    String? distributorId,
    String? vehicleNumber,
    String? vehicleType,
    double? capacity,
    String? fuelType,
    String? status,
    String? currentLocation,
    String? driverName,
    String? driverPhone,
    DateTime? insuranceExpiry,
    DateTime? maintenanceDue,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Vehicle(
      id: id ?? this.id,
      distributorId: distributorId ?? this.distributorId,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      vehicleType: vehicleType ?? this.vehicleType,
      capacity: capacity ?? this.capacity,
      fuelType: fuelType ?? this.fuelType,
      status: status ?? this.status,
      currentLocation: currentLocation ?? this.currentLocation,
      driverName: driverName ?? this.driverName,
      driverPhone: driverPhone ?? this.driverPhone,
      insuranceExpiry: insuranceExpiry ?? this.insuranceExpiry,
      maintenanceDue: maintenanceDue ?? this.maintenanceDue,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get status color based on vehicle status
  String get statusColor {
    switch (status.toLowerCase()) {
      case 'available':
        return 'green';
      case 'in_transit':
        return 'blue';
      case 'maintenance':
        return 'orange';
      case 'unavailable':
        return 'red';
      default:
        return 'grey';
    }
  }

  /// Check if maintenance is overdue
  bool get isMaintenanceOverdue {
    if (maintenanceDue == null) return false;
    return DateTime.now().isAfter(maintenanceDue!);
  }

  /// Check if insurance is expiring soon (within 30 days)
  bool get isInsuranceExpiringSoon {
    if (insuranceExpiry == null) return false;
    final thirtyDaysFromNow = DateTime.now().add(const Duration(days: 30));
    return insuranceExpiry!.isBefore(thirtyDaysFromNow);
  }

  /// Get capacity in a formatted string
  String get formattedCapacity {
    if (capacity >= 1000) {
      return '${(capacity / 1000).toStringAsFixed(1)}T';
    }
    return '${capacity.toInt()}kg';
  }
}
