class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String address;
  final bool isVerified;
  final DateTime createdAt;
  final Map<String, dynamic>? additionalInfo;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.address,
    this.isVerified = false,
    required this.createdAt,
    this.additionalInfo,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      role: json['role'],
      address: json['address'],
      isVerified: json['is_verified'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      additionalInfo: json['additional_info'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'address': address,
      'is_verified': isVerified,
      'created_at': createdAt.toIso8601String(),
      'additional_info': additionalInfo,
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? role,
    String? address,
    bool? isVerified,
    DateTime? createdAt,
    Map<String, dynamic>? additionalInfo,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      address: address ?? this.address,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      additionalInfo: additionalInfo ?? this.additionalInfo,
    );
  }
}

class Farmer extends User {
  final String farmerId;
  final String landOwnership;
  final double landSize;
  final String? landDocuments;
  final double agriScore;

  Farmer({
    required super.id,
    required super.name,
    required super.email,
    required super.phone,
    required super.address,
    super.isVerified,
    required super.createdAt,
    super.additionalInfo,
    required this.farmerId,
    required this.landOwnership,
    required this.landSize,
    this.landDocuments,
    this.agriScore = 0.0,
  }) : super(role: 'farmer');

  factory Farmer.fromJson(Map<String, dynamic> json) {
    return Farmer(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      isVerified: json['is_verified'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      additionalInfo: json['additional_info'],
      farmerId: json['farmer_id'],
      landOwnership: json['land_ownership'],
      landSize: json['land_size']?.toDouble() ?? 0.0,
      landDocuments: json['land_documents'],
      agriScore: json['agri_score']?.toDouble() ?? 0.0,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json.addAll({
      'farmer_id': farmerId,
      'land_ownership': landOwnership,
      'land_size': landSize,
      'land_documents': landDocuments,
      'agri_score': agriScore,
    });
    return json;
  }
}

class Distributor extends User {
  final String distributorId;
  final String vehicleDetails;
  final String licenseNumber;
  final double rating;

  Distributor({
    required super.id,
    required super.name,
    required super.email,
    required super.phone,
    required super.address,
    super.isVerified,
    required super.createdAt,
    super.additionalInfo,
    required this.distributorId,
    required this.vehicleDetails,
    required this.licenseNumber,
    this.rating = 0.0,
  }) : super(role: 'distributor');

  factory Distributor.fromJson(Map<String, dynamic> json) {
    return Distributor(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      isVerified: json['is_verified'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      additionalInfo: json['additional_info'],
      distributorId: json['distributor_id'],
      vehicleDetails: json['vehicle_details'],
      licenseNumber: json['license_number'],
      rating: json['rating']?.toDouble() ?? 0.0,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json.addAll({
      'distributor_id': distributorId,
      'vehicle_details': vehicleDetails,
      'license_number': licenseNumber,
      'rating': rating,
    });
    return json;
  }
}

class Retailer extends User {
  final String retailerId;
  final String shopName;
  final String location;
  final double rating;

  Retailer({
    required super.id,
    required super.name,
    required super.email,
    required super.phone,
    required super.address,
    super.isVerified,
    required super.createdAt,
    super.additionalInfo,
    required this.retailerId,
    required this.shopName,
    required this.location,
    this.rating = 0.0,
  }) : super(role: 'retailer');

  factory Retailer.fromJson(Map<String, dynamic> json) {
    return Retailer(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      isVerified: json['is_verified'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      additionalInfo: json['additional_info'],
      retailerId: json['retailer_id'],
      shopName: json['shop_name'],
      location: json['location'],
      rating: json['rating']?.toDouble() ?? 0.0,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json.addAll({
      'retailer_id': retailerId,
      'shop_name': shopName,
      'location': location,
      'rating': rating,
    });
    return json;
  }
}

class Consumer extends User {
  final String consumerId;
  final List<String> preferences;
  final bool hasActiveSubscriptions;

  Consumer({
    required super.id,
    required super.name,
    required super.email,
    required super.phone,
    required super.address,
    super.isVerified,
    required super.createdAt,
    super.additionalInfo,
    required this.consumerId,
    this.preferences = const [],
    this.hasActiveSubscriptions = false,
  }) : super(role: 'consumer');

  factory Consumer.fromJson(Map<String, dynamic> json) {
    return Consumer(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      isVerified: json['is_verified'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      additionalInfo: json['additional_info'],
      consumerId: json['consumer_id'],
      preferences: List<String>.from(json['preferences'] ?? []),
      hasActiveSubscriptions: json['has_active_subscriptions'] ?? false,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json.addAll({
      'consumer_id': consumerId,
      'preferences': preferences,
      'has_active_subscriptions': hasActiveSubscriptions,
    });
    return json;
  }
}