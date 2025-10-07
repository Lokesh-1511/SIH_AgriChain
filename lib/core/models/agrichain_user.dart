/// Enhanced User model for AgriChain application with Firebase and MongoDB integration
class AgriChainUser {
  final String? id; // MongoDB ObjectId
  final String firebaseUid; // Firebase User UID
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final String address;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> kycDetails; // Aadhaar verification data
  final Map<String, dynamic>? additionalInfo;

  AgriChainUser({
    this.id,
    required this.firebaseUid,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.address,
    this.isVerified = false,
    required this.createdAt,
    required this.updatedAt,
    required this.kycDetails,
    this.additionalInfo,
  });

  /// Create from JSON (MongoDB document)
  factory AgriChainUser.fromJson(Map<String, dynamic> json) {
    // Handle role-specific IDs that might be at top level or in additionalInfo
    Map<String, dynamic> combinedAdditionalInfo = {};

    // Add any additionalInfo that exists
    if (json['additionalInfo'] != null) {
      combinedAdditionalInfo.addAll(
        Map<String, dynamic>.from(json['additionalInfo']),
      );
    }

    // Check for role-specific IDs at top level and move them to additionalInfo
    final roleSpecificFields = [
      'farmerId',
      'distributorId',
      'retailerId',
      'consumerId',
      'registrationDate',
    ];
    for (String field in roleSpecificFields) {
      if (json[field] != null) {
        combinedAdditionalInfo[field] = json[field];
        print('🔍 Found $field: ${json[field]}'); // Debug print
      }
    }

    print('🔍 Combined additionalInfo: $combinedAdditionalInfo'); // Debug print

    return AgriChainUser(
      id: json['_id']?.toString(),
      firebaseUid: json['firebaseUid'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: UserRole.fromString(json['role'] ?? 'farmer'),
      address: json['address'] ?? '',
      isVerified: json['isVerified'] ?? false,
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
      kycDetails: Map<String, dynamic>.from(json['kycDetails'] ?? {}),
      additionalInfo: combinedAdditionalInfo.isNotEmpty
          ? combinedAdditionalInfo
          : null,
    );
  }

  /// Convert to JSON (for MongoDB)
  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'firebaseUid': firebaseUid,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role.name,
      'address': address,
      'isVerified': isVerified,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'kycDetails': kycDetails,
      if (additionalInfo != null) 'additionalInfo': additionalInfo,
    };
  }

  /// Create copy with updated fields
  AgriChainUser copyWith({
    String? id,
    String? firebaseUid,
    String? name,
    String? email,
    String? phone,
    UserRole? role,
    String? address,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? kycDetails,
    Map<String, dynamic>? additionalInfo,
  }) {
    return AgriChainUser(
      id: id ?? this.id,
      firebaseUid: firebaseUid ?? this.firebaseUid,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      address: address ?? this.address,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      kycDetails: kycDetails ?? this.kycDetails,
      additionalInfo: additionalInfo ?? this.additionalInfo,
    );
  }

  @override
  String toString() {
    return 'AgriChainUser(id: $id, email: $email, name: $name, role: ${role.name})';
  }

  /// Get the role-specific unique ID
  String? get uniqueId {
    if (additionalInfo == null) return null;

    switch (role) {
      case UserRole.farmer:
        return additionalInfo!['farmerId']?.toString();
      case UserRole.distributor:
        return additionalInfo!['distributorId']?.toString();
      case UserRole.retailer:
        return additionalInfo!['retailerId']?.toString();
      case UserRole.consumer:
        return additionalInfo!['consumerId']?.toString();
    }
  }

  /// Get the role-specific unique ID prefix for display
  String get idPrefix {
    switch (role) {
      case UserRole.farmer:
        return 'Farmer ID';
      case UserRole.distributor:
        return 'Distributor ID';
      case UserRole.retailer:
        return 'Retailer ID';
      case UserRole.consumer:
        return 'Consumer ID';
    }
  }
}

/// User roles enum
enum UserRole {
  farmer,
  distributor,
  retailer,
  consumer;

  String get name => toString().split('.').last;

  String get displayName {
    switch (this) {
      case UserRole.farmer:
        return 'Farmer';
      case UserRole.distributor:
        return 'Distributor';
      case UserRole.retailer:
        return 'Retailer';
      case UserRole.consumer:
        return 'Consumer';
    }
  }

  static UserRole fromString(String role) {
    switch (role.toLowerCase()) {
      case 'farmer':
        return UserRole.farmer;
      case 'distributor':
        return UserRole.distributor;
      case 'retailer':
        return UserRole.retailer;
      case 'consumer':
        return UserRole.consumer;
      default:
        return UserRole.farmer; // Default fallback
    }
  }
}
