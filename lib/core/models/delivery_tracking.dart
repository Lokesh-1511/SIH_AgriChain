/// Delivery tracking model for products in transit
class DeliveryTracking {
  final String deliveryId;
  final String productId;
  final String distributorId;
  final String distributorName;
  final String distributorWallet;
  final String farmerName;
  final String farmerWallet;
  final String status; // 'in_transit', 'delivered', 'cancelled'
  final DateTime pickupTime;
  final DateTime? deliveryTime;
  final String? vehicleNumber;
  final String? driverName;
  final String? driverContact;
  final List<TrackingUpdate> trackingUpdates;
  final String? currentLocation;
  final double? estimatedDistance;
  final DateTime? estimatedDelivery;

  DeliveryTracking({
    required this.deliveryId,
    required this.productId,
    required this.distributorId,
    required this.distributorName,
    required this.distributorWallet,
    required this.farmerName,
    required this.farmerWallet,
    this.status = 'in_transit',
    required this.pickupTime,
    this.deliveryTime,
    this.vehicleNumber,
    this.driverName,
    this.driverContact,
    this.trackingUpdates = const [],
    this.currentLocation,
    this.estimatedDistance,
    this.estimatedDelivery,
  });

  /// Create a copy with updated fields
  DeliveryTracking copyWith({
    String? deliveryId,
    String? productId,
    String? distributorId,
    String? distributorName,
    String? distributorWallet,
    String? farmerName,
    String? farmerWallet,
    String? status,
    DateTime? pickupTime,
    DateTime? deliveryTime,
    String? vehicleNumber,
    String? driverName,
    String? driverContact,
    List<TrackingUpdate>? trackingUpdates,
    String? currentLocation,
    double? estimatedDistance,
    DateTime? estimatedDelivery,
  }) {
    return DeliveryTracking(
      deliveryId: deliveryId ?? this.deliveryId,
      productId: productId ?? this.productId,
      distributorId: distributorId ?? this.distributorId,
      distributorName: distributorName ?? this.distributorName,
      distributorWallet: distributorWallet ?? this.distributorWallet,
      farmerName: farmerName ?? this.farmerName,
      farmerWallet: farmerWallet ?? this.farmerWallet,
      status: status ?? this.status,
      pickupTime: pickupTime ?? this.pickupTime,
      deliveryTime: deliveryTime ?? this.deliveryTime,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      driverName: driverName ?? this.driverName,
      driverContact: driverContact ?? this.driverContact,
      trackingUpdates: trackingUpdates ?? this.trackingUpdates,
      currentLocation: currentLocation ?? this.currentLocation,
      estimatedDistance: estimatedDistance ?? this.estimatedDistance,
      estimatedDelivery: estimatedDelivery ?? this.estimatedDelivery,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'deliveryId': deliveryId,
      'productId': productId,
      'distributorId': distributorId,
      'distributorName': distributorName,
      'distributorWallet': distributorWallet,
      'farmerName': farmerName,
      'farmerWallet': farmerWallet,
      'status': status,
      'pickupTime': pickupTime.toIso8601String(),
      'deliveryTime': deliveryTime?.toIso8601String(),
      'vehicleNumber': vehicleNumber,
      'driverName': driverName,
      'driverContact': driverContact,
      'trackingUpdates': trackingUpdates.map((update) => update.toJson()).toList(),
      'currentLocation': currentLocation,
      'estimatedDistance': estimatedDistance,
      'estimatedDelivery': estimatedDelivery?.toIso8601String(),
    };
  }

  /// Create from JSON
  factory DeliveryTracking.fromJson(Map<String, dynamic> json) {
    return DeliveryTracking(
      deliveryId: json['deliveryId'],
      productId: json['productId'],
      distributorId: json['distributorId'],
      distributorName: json['distributorName'],
      distributorWallet: json['distributorWallet'],
      farmerName: json['farmerName'],
      farmerWallet: json['farmerWallet'],
      status: json['status'] ?? 'in_transit',
      pickupTime: DateTime.parse(json['pickupTime']),
      deliveryTime: json['deliveryTime'] != null
          ? DateTime.parse(json['deliveryTime'])
          : null,
      vehicleNumber: json['vehicleNumber'],
      driverName: json['driverName'],
      driverContact: json['driverContact'],
      trackingUpdates: (json['trackingUpdates'] as List<dynamic>? ?? [])
          .map((update) => TrackingUpdate.fromJson(update))
          .toList(),
      currentLocation: json['currentLocation'],
      estimatedDistance: json['estimatedDistance']?.toDouble(),
      estimatedDelivery: json['estimatedDelivery'] != null
          ? DateTime.parse(json['estimatedDelivery'])
          : null,
    );
  }
}

/// Individual tracking update points
class TrackingUpdate {
  final String updateId;
  final DateTime timestamp;
  final String location;
  final String description;
  final String status;
  final double? latitude;
  final double? longitude;

  TrackingUpdate({
    required this.updateId,
    required this.timestamp,
    required this.location,
    required this.description,
    required this.status,
    this.latitude,
    this.longitude,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'updateId': updateId,
      'timestamp': timestamp.toIso8601String(),
      'location': location,
      'description': description,
      'status': status,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  /// Create from JSON
  factory TrackingUpdate.fromJson(Map<String, dynamic> json) {
    return TrackingUpdate(
      updateId: json['updateId'],
      timestamp: DateTime.parse(json['timestamp']),
      location: json['location'],
      description: json['description'],
      status: json['status'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
    );
  }
}