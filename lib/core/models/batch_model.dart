class Batch {
  final String id;
  final String farmerId;
  final String productName;
  final double quantity;
  final String unit;
  final double basePrice;
  final double? currentPrice;
  final String status;
  final DateTime createdAt;
  final DateTime? harvestedAt;
  final String? imageUrl;
  final Map<String, dynamic>? qualityMetrics;
  final String? distributorId;
  final String? retailerId;
  final DateTime? deliveredAt;

  Batch({
    required this.id,
    required this.farmerId,
    required this.productName,
    required this.quantity,
    required this.unit,
    required this.basePrice,
    this.currentPrice,
    required this.status,
    required this.createdAt,
    this.harvestedAt,
    this.imageUrl,
    this.qualityMetrics,
    this.distributorId,
    this.retailerId,
    this.deliveredAt,
  });

  factory Batch.fromJson(Map<String, dynamic> json) {
    return Batch(
      id: json['id'],
      farmerId: json['farmer_id'],
      productName: json['product_name'],
      quantity: json['quantity']?.toDouble() ?? 0.0,
      unit: json['unit'],
      basePrice: json['base_price']?.toDouble() ?? 0.0,
      currentPrice: json['current_price']?.toDouble(),
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      harvestedAt: json['harvested_at'] != null 
          ? DateTime.parse(json['harvested_at']) 
          : null,
      imageUrl: json['image_url'],
      qualityMetrics: json['quality_metrics'],
      distributorId: json['distributor_id'],
      retailerId: json['retailer_id'],
      deliveredAt: json['delivered_at'] != null 
          ? DateTime.parse(json['delivered_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmer_id': farmerId,
      'product_name': productName,
      'quantity': quantity,
      'unit': unit,
      'base_price': basePrice,
      'current_price': currentPrice,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'harvested_at': harvestedAt?.toIso8601String(),
      'image_url': imageUrl,
      'quality_metrics': qualityMetrics,
      'distributor_id': distributorId,
      'retailer_id': retailerId,
      'delivered_at': deliveredAt?.toIso8601String(),
    };
  }

  Batch copyWith({
    String? id,
    String? farmerId,
    String? productName,
    double? quantity,
    String? unit,
    double? basePrice,
    double? currentPrice,
    String? status,
    DateTime? createdAt,
    DateTime? harvestedAt,
    String? imageUrl,
    Map<String, dynamic>? qualityMetrics,
    String? distributorId,
    String? retailerId,
    DateTime? deliveredAt,
  }) {
    return Batch(
      id: id ?? this.id,
      farmerId: farmerId ?? this.farmerId,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      basePrice: basePrice ?? this.basePrice,
      currentPrice: currentPrice ?? this.currentPrice,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      harvestedAt: harvestedAt ?? this.harvestedAt,
      imageUrl: imageUrl ?? this.imageUrl,
      qualityMetrics: qualityMetrics ?? this.qualityMetrics,
      distributorId: distributorId ?? this.distributorId,
      retailerId: retailerId ?? this.retailerId,
      deliveredAt: deliveredAt ?? this.deliveredAt,
    );
  }
}

class Transaction {
  final String id;
  final String batchId;
  final String fromUserId;
  final String toUserId;
  final String transactionType;
  final double amount;
  final String status;
  final DateTime timestamp;
  final String? blockchainHash;
  final Map<String, dynamic>? metadata;

  Transaction({
    required this.id,
    required this.batchId,
    required this.fromUserId,
    required this.toUserId,
    required this.transactionType,
    required this.amount,
    required this.status,
    required this.timestamp,
    this.blockchainHash,
    this.metadata,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      batchId: json['batch_id'],
      fromUserId: json['from_user_id'],
      toUserId: json['to_user_id'],
      transactionType: json['transaction_type'],
      amount: json['amount']?.toDouble() ?? 0.0,
      status: json['status'],
      timestamp: DateTime.parse(json['timestamp']),
      blockchainHash: json['blockchain_hash'],
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'batch_id': batchId,
      'from_user_id': fromUserId,
      'to_user_id': toUserId,
      'transaction_type': transactionType,
      'amount': amount,
      'status': status,
      'timestamp': timestamp.toIso8601String(),
      'blockchain_hash': blockchainHash,
      'metadata': metadata,
    };
  }
}

class DeliveryTracking {
  final String id;
  final String batchId;
  final String distributorId;
  final String status;
  final DateTime startTime;
  final DateTime? endTime;
  final String route;
  final String vehicleId;
  final List<TrackingPoint> trackingPoints;

  DeliveryTracking({
    required this.id,
    required this.batchId,
    required this.distributorId,
    required this.status,
    required this.startTime,
    this.endTime,
    required this.route,
    required this.vehicleId,
    this.trackingPoints = const [],
  });

  factory DeliveryTracking.fromJson(Map<String, dynamic> json) {
    return DeliveryTracking(
      id: json['id'],
      batchId: json['batch_id'],
      distributorId: json['distributor_id'],
      status: json['status'],
      startTime: DateTime.parse(json['start_time']),
      endTime: json['end_time'] != null 
          ? DateTime.parse(json['end_time']) 
          : null,
      route: json['route'],
      vehicleId: json['vehicle_id'],
      trackingPoints: (json['tracking_points'] as List<dynamic>? ?? [])
          .map((point) => TrackingPoint.fromJson(point))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'batch_id': batchId,
      'distributor_id': distributorId,
      'status': status,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'route': route,
      'vehicle_id': vehicleId,
      'tracking_points': trackingPoints.map((point) => point.toJson()).toList(),
    };
  }
}

class TrackingPoint {
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final String description;

  TrackingPoint({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.description,
  });

  factory TrackingPoint.fromJson(Map<String, dynamic> json) {
    return TrackingPoint(
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
      timestamp: DateTime.parse(json['timestamp']),
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.toIso8601String(),
      'description': description,
    };
  }
}