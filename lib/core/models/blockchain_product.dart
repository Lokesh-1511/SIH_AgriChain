/// Blockchain product model for storing posted products
class BlockchainProduct {
  final String productId;
  final String name;
  final String category;
  final double quantity;
  final String unit;
  final double pricePerUnit;
  final String description;
  final String farmerName;
  final String farmerWallet;
  final String txHash;
  final DateTime postedAt;
  final String status; // 'active', 'accepted', 'in_transit', 'delivered', 'declined'
  final List<String> qualityCertifications;
  final String? currentOwnerWallet;
  final String? qrCodeData;
  final Map<String, dynamic>? additionalData;
  
  // Distributor information (added when product is accepted)
  final String? distributorId;
  final String? distributorName;
  final String? distributorWallet;
  final DateTime? acceptedAt;

  BlockchainProduct({
    required this.productId,
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.pricePerUnit,
    required this.description,
    required this.farmerName,
    required this.farmerWallet,
    required this.txHash,
    required this.postedAt,
    this.status = 'active',
    this.qualityCertifications = const [],
    this.currentOwnerWallet,
    this.qrCodeData,
    this.additionalData,
    this.distributorId,
    this.distributorName,
    this.distributorWallet,
    this.acceptedAt,
  });

  /// Create a copy of this product with updated fields
  BlockchainProduct copyWith({
    String? productId,
    String? name,
    String? category,
    double? quantity,
    String? unit,
    double? pricePerUnit,
    String? description,
    String? farmerName,
    String? farmerWallet,
    String? txHash,
    DateTime? postedAt,
    String? status,
    List<String>? qualityCertifications,
    String? currentOwnerWallet,
    String? qrCodeData,
    Map<String, dynamic>? additionalData,
    String? distributorId,
    String? distributorName,
    String? distributorWallet,
    DateTime? acceptedAt,
  }) {
    return BlockchainProduct(
      productId: productId ?? this.productId,
      name: name ?? this.name,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
      description: description ?? this.description,
      farmerName: farmerName ?? this.farmerName,
      farmerWallet: farmerWallet ?? this.farmerWallet,
      txHash: txHash ?? this.txHash,
      postedAt: postedAt ?? this.postedAt,
      status: status ?? this.status,
      qualityCertifications:
          qualityCertifications ?? this.qualityCertifications,
      currentOwnerWallet: currentOwnerWallet ?? this.currentOwnerWallet,
      qrCodeData: qrCodeData ?? this.qrCodeData,
      additionalData: additionalData ?? this.additionalData,
      distributorId: distributorId ?? this.distributorId,
      distributorName: distributorName ?? this.distributorName,
      distributorWallet: distributorWallet ?? this.distributorWallet,
      acceptedAt: acceptedAt ?? this.acceptedAt,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'name': name,
      'category': category,
      'quantity': quantity,
      'unit': unit,
      'pricePerUnit': pricePerUnit,
      'description': description,
      'farmerName': farmerName,
      'farmerWallet': farmerWallet,
      'txHash': txHash,
      'postedAt': postedAt.toIso8601String(),
      'status': status,
      'qualityCertifications': qualityCertifications,
      'currentOwnerWallet': currentOwnerWallet,
      'qrCodeData': qrCodeData,
      'additionalData': additionalData,
      'distributorId': distributorId,
      'distributorName': distributorName,
      'distributorWallet': distributorWallet,
      'acceptedAt': acceptedAt?.toIso8601String(),
    };
  }

  /// Create from JSON
  factory BlockchainProduct.fromJson(Map<String, dynamic> json) {
    return BlockchainProduct(
      productId: json['productId'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      quantity: (json['quantity'] ?? 0.0).toDouble(),
      unit: json['unit'] ?? '',
      pricePerUnit: (json['pricePerUnit'] ?? 0.0).toDouble(),
      description: json['description'] ?? '',
      farmerName: json['farmerName'] ?? '',
      farmerWallet: json['farmerWallet'] ?? '',
      txHash: json['txHash'] ?? '',
      postedAt: json['postedAt'] != null
          ? DateTime.parse(json['postedAt'])
          : DateTime.now(),
      status: json['status'] ?? 'active',
      qualityCertifications: List<String>.from(
        json['qualityCertifications'] ?? [],
      ),
      currentOwnerWallet: json['currentOwnerWallet'],
      qrCodeData: json['qrCodeData'],
      additionalData: json['additionalData'] != null
          ? Map<String, dynamic>.from(json['additionalData'])
          : null,
      distributorId: json['distributorId'],
      distributorName: json['distributorName'],
      distributorWallet: json['distributorWallet'],
      acceptedAt: json['acceptedAt'] != null
          ? DateTime.parse(json['acceptedAt'])
          : null,
    );
  }

  /// Get total value of the product
  double get totalValue => quantity * pricePerUnit;

  /// Get formatted price
  String get formattedPrice => '₹${pricePerUnit.toStringAsFixed(2)}';

  /// Get formatted total value
  String get formattedTotalValue => '₹${totalValue.toStringAsFixed(2)}';

  /// Get formatted quantity
  String get formattedQuantity => '$quantity $unit';

  /// Get status color
  String get statusColor {
    switch (status.toLowerCase()) {
      case 'active':
        return '#28a745'; // Green
      case 'in_transit':
        return '#ffc107'; // Yellow
      case 'delivered':
        return '#17a2b8'; // Blue
      default:
        return '#6c757d'; // Gray
    }
  }

  /// Get status display name
  String get statusDisplayName {
    switch (status.toLowerCase()) {
      case 'active':
        return 'Available';
      case 'in_transit':
        return 'In Transit';
      case 'delivered':
        return 'Delivered';
      default:
        return status;
    }
  }

  /// Generate QR code data with product traceability information
  String generateQRData() {
    Map<String, dynamic> qrData = {
      'productId': productId,
      'name': name,
      'category': category,
      'farmer': farmerName,
      'farmerWallet': farmerWallet,
      'txHash': txHash,
      'postedAt': postedAt.toIso8601String(),
      'price': pricePerUnit,
      'quantity': quantity,
      'unit': unit,
      'certifications': qualityCertifications,
      'currentOwner': currentOwnerWallet ?? farmerWallet,
      'traceabilityUrl': 'https://agrichain.app/trace/$productId',
    };

    return Uri.encodeComponent(qrData.toString());
  }
}

/// Blockchain transaction model
class BlockchainTransaction {
  final String txHash;
  final String type; // 'product_post', 'ownership_transfer', 'scan_record'
  final String productId;
  final String fromWallet;
  final String? toWallet;
  final double? amount;
  final DateTime timestamp;
  final String status; // 'pending', 'confirmed', 'failed'
  final Map<String, dynamic>? transactionData;

  BlockchainTransaction({
    required this.txHash,
    required this.type,
    required this.productId,
    required this.fromWallet,
    this.toWallet,
    this.amount,
    required this.timestamp,
    this.status = 'confirmed',
    this.transactionData,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'txHash': txHash,
      'type': type,
      'productId': productId,
      'fromWallet': fromWallet,
      'toWallet': toWallet,
      'amount': amount,
      'timestamp': timestamp.toIso8601String(),
      'status': status,
      'transactionData': transactionData,
    };
  }

  /// Create from JSON
  factory BlockchainTransaction.fromJson(Map<String, dynamic> json) {
    return BlockchainTransaction(
      txHash: json['txHash'] ?? '',
      type: json['type'] ?? '',
      productId: json['productId'] ?? '',
      fromWallet: json['fromWallet'] ?? '',
      toWallet: json['toWallet'],
      amount: json['amount']?.toDouble(),
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      status: json['status'] ?? 'confirmed',
      transactionData: json['transactionData'] != null
          ? Map<String, dynamic>.from(json['transactionData'])
          : null,
    );
  }

  /// Get formatted amount
  String? get formattedAmount {
    if (amount == null) return null;
    return '₹${amount!.toStringAsFixed(2)}';
  }

  /// Get transaction type display name
  String get typeDisplayName {
    switch (type) {
      case 'product_post':
        return 'Product Posted';
      case 'ownership_transfer':
        return 'Ownership Transfer';
      case 'scan_record':
        return 'QR Scan';
      default:
        return type;
    }
  }

  /// Get status color
  String get statusColor {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return '#28a745'; // Green
      case 'pending':
        return '#ffc107'; // Yellow
      case 'failed':
        return '#dc3545'; // Red
      default:
        return '#6c757d'; // Gray
    }
  }
}
