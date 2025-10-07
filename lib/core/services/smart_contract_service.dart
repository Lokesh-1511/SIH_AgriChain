import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';

/// Service for interacting with AgriChain smart contracts
class SmartContractService {
  // Dynamic contract addresses (loaded from backend or local storage)
  static String? _productRegistryAddress;
  static String? _traceabilityAddress;
  static String? _escrowPaymentAddress;
  
  // Fallback addresses for development
  static const String _defaultProductRegistryAddress = '0x5FbDB2315678afecb367f032d93F642f64180aa3';
  static const String _defaultTraceabilityAddress = '0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512';
  static const String _defaultEscrowPaymentAddress = '0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0';

  // Backend URL for blockchain interactions
  static String get _backendUrl {
    if (kDebugMode) {
      if (kIsWeb) {
        return 'http://localhost:3000';
      } else if (Platform.isAndroid) {
        return 'http://10.0.2.2:3000';
      } else {
        return 'http://localhost:3000';
      }
    } else {
      return 'https://your-production-backend.com';
    }
  }

  static const Duration _timeoutDuration = Duration(seconds: 30);
  static const bool _useMockMode = true;

  /// Headers for API requests
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Get contract addresses with fallbacks
  static String get productRegistryAddress => 
      _productRegistryAddress ?? _defaultProductRegistryAddress;
  
  static String get traceabilityAddress => 
      _traceabilityAddress ?? _defaultTraceabilityAddress;
      
  static String get escrowPaymentAddress => 
      _escrowPaymentAddress ?? _defaultEscrowPaymentAddress;

  /// Initialize contract addresses from backend or local deployment
  static Future<bool> initializeContracts() async {
    try {
      debugPrint('🔗 Initializing smart contract addresses...');

      if (_useMockMode) {
        // Use default addresses in mock mode
        _productRegistryAddress = _defaultProductRegistryAddress;
        _traceabilityAddress = _defaultTraceabilityAddress;
        _escrowPaymentAddress = _defaultEscrowPaymentAddress;
        
        debugPrint('🎭 Mock mode: Using default contract addresses');
        debugPrint('📦 ProductRegistry: $_productRegistryAddress');
        debugPrint('🔍 Traceability: $_traceabilityAddress');
        debugPrint('💳 EscrowPayment: $_escrowPaymentAddress');
        return true;
      }

      // Try to load from backend
      final url = Uri.parse('$_backendUrl/api/blockchain/contract-addresses');
      final response = await http.get(url, headers: _headers)
          .timeout(_timeoutDuration);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        _productRegistryAddress = data['contracts']['ProductRegistry'];
        _traceabilityAddress = data['contracts']['Traceability'];
        _escrowPaymentAddress = data['contracts']['EscrowPayment'];

        debugPrint('✅ Contract addresses loaded from backend');
        debugPrint('📦 ProductRegistry: $_productRegistryAddress');
        debugPrint('🔍 Traceability: $_traceabilityAddress');
        debugPrint('💳 EscrowPayment: $_escrowPaymentAddress');
        
        return true;
      } else {
        throw Exception('Failed to load contract addresses: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('⚠️ Failed to load contract addresses from backend: $e');
      debugPrint('🔄 Falling back to default addresses...');
      
      // Fallback to defaults
      _productRegistryAddress = _defaultProductRegistryAddress;
      _traceabilityAddress = _defaultTraceabilityAddress;
      _escrowPaymentAddress = _defaultEscrowPaymentAddress;
      
      return false;
    }
  }

  /// Load contract addresses from deployment file (for development)
  static Future<bool> loadFromDeploymentFile() async {
    try {
      debugPrint('📄 Loading contract addresses from deployment file...');
      
      // This would read from deployment/deployment-info.json
      // For now, we'll use a mock response
      final deploymentInfo = {
        'contracts': {
          'ProductRegistry': '0x5FbDB2315678afecb367f032d93F642f64180aa3',
          'Traceability': '0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512',
          'EscrowPayment': '0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0',
        }
      };

      _productRegistryAddress = deploymentInfo['contracts']!['ProductRegistry'];
      _traceabilityAddress = deploymentInfo['contracts']!['Traceability'];
      _escrowPaymentAddress = deploymentInfo['contracts']!['EscrowPayment'];

      debugPrint('✅ Contract addresses loaded from deployment file');
      return true;
    } catch (e) {
      debugPrint('❌ Failed to load from deployment file: $e');
      return false;
    }
  }

  /// Register a new product on blockchain (Farmer only)
  static Future<ProductRegistrationResult> registerProduct({
    required String productId,
    required String productName,
    required double basePrice,
    required String farmerId,
    required String farmerWalletAddress,
  }) async {
    try {
      debugPrint('🌾 Registering product on blockchain...');
      debugPrint('📦 Product: $productId - $productName');
      debugPrint('💰 Base Price: $basePrice ETH');

      if (_useMockMode) {
        return _mockRegisterProduct(productId, productName, basePrice);
      }

      // Generate QR code hash
      final qrCodeHash = _generateQRCodeHash(productId, farmerId);
      
      final url = Uri.parse('$_backendUrl/api/blockchain/register-product');
      final requestBody = {
        'product_id': productId,
        'product_name': productName,
        'base_price': basePrice.toString(),
        'farmer_id': farmerId,
        'farmer_wallet': farmerWalletAddress,
        'qr_code_hash': qrCodeHash,
        'contract_address': productRegistryAddress,
      };

      final response = await http.post(
        url,
        headers: _headers,
        body: jsonEncode(requestBody),
      ).timeout(_timeoutDuration);

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        return ProductRegistrationResult(
          success: true,
          productId: productId,
          qrCodeHash: qrCodeHash,
          transactionHash: responseData['transaction_hash'],
          blockNumber: responseData['block_number'],
          message: 'Product registered successfully on blockchain',
        );
      } else {
        throw SmartContractException(responseData['error'] ?? 'Product registration failed');
      }
    } catch (e) {
      debugPrint('❌ Product registration failed: $e');
      throw SmartContractException('Product registration failed: $e');
    }
  }

  /// Transfer product ownership (QR scan)
  static Future<OwnershipTransferResult> transferOwnership({
    required String productId,
    required String qrCodeHash,
    required String fromWallet,
    required String toWallet,
    required String fromRole,
    required String toRole,
    required double additionalCost,
    required String location,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      debugPrint('🔄 Transferring product ownership...');
      debugPrint('📦 Product: $productId');
      debugPrint('👤 From: $fromWallet ($fromRole)');
      debugPrint('👤 To: $toWallet ($toRole)');
      debugPrint('💰 Additional Cost: $additionalCost ETH');

      if (_useMockMode) {
        return _mockTransferOwnership(productId, fromRole, toRole, additionalCost);
      }

      final metaHash = _generateMetadataHash(metadata ?? {});
      
      final url = Uri.parse('$_backendUrl/api/blockchain/transfer-ownership');
      final requestBody = {
        'product_id': productId,
        'qr_code_hash': qrCodeHash,
        'from_wallet': fromWallet,
        'to_wallet': toWallet,
        'from_role': fromRole,
        'to_role': toRole,
        'additional_cost': additionalCost.toString(),
        'location': location,
        'meta_hash': metaHash,
        'contract_address': productRegistryAddress,
      };

      final response = await http.post(
        url,
        headers: _headers,
        body: jsonEncode(requestBody),
      ).timeout(_timeoutDuration);

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        return OwnershipTransferResult(
          success: true,
          productId: productId,
          newOwner: toWallet,
          newRole: toRole,
          transactionHash: responseData['transaction_hash'],
          blockNumber: responseData['block_number'],
          gasUsed: responseData['gas_used'],
          message: 'Ownership transferred successfully',
        );
      } else {
        throw SmartContractException(responseData['error'] ?? 'Ownership transfer failed');
      }
    } catch (e) {
      debugPrint('❌ Ownership transfer failed: $e');
      throw SmartContractException('Ownership transfer failed: $e');
    }
  }

  /// Record QR code scan for traceability
  static Future<ScanRecordResult> recordQRScan({
    required String qrCodeHash,
    required String scannerWallet,
    required String location,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      debugPrint('📱 Recording QR scan...');
      debugPrint('🔍 QR Hash: $qrCodeHash');
      debugPrint('👤 Scanner: $scannerWallet');

      if (_useMockMode) {
        return _mockRecordScan(qrCodeHash, scannerWallet);
      }

      final metaHash = _generateMetadataHash(metadata ?? {});
      
      final url = Uri.parse('$_backendUrl/api/blockchain/record-scan');
      final requestBody = {
        'qr_code_hash': qrCodeHash,
        'scanner_wallet': scannerWallet,
        'location': location,
        'meta_hash': metaHash,
        'contract_address': traceabilityAddress,
      };

      final response = await http.post(
        url,
        headers: _headers,
        body: jsonEncode(requestBody),
      ).timeout(_timeoutDuration);

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        return ScanRecordResult(
          success: true,
          qrCodeHash: qrCodeHash,
          scanner: scannerWallet,
          timestamp: responseData['timestamp'],
          transactionHash: responseData['transaction_hash'],
          message: 'QR scan recorded successfully',
        );
      } else {
        throw SmartContractException(responseData['error'] ?? 'QR scan recording failed');
      }
    } catch (e) {
      debugPrint('❌ QR scan recording failed: $e');
      throw SmartContractException('QR scan recording failed: $e');
    }
  }

  /// Create escrow order
  static Future<EscrowOrderResult> createEscrowOrder({
    required String orderId,
    required String productId,
    required String consumerWallet,
    required String farmerWallet,
    required String distributorWallet,
    required String retailerWallet,
    required double totalAmount,
  }) async {
    try {
      debugPrint('💳 Creating escrow order...');
      debugPrint('📦 Order: $orderId for Product: $productId');
      debugPrint('💰 Total Amount: $totalAmount ETH');

      if (_useMockMode) {
        return _mockCreateEscrowOrder(orderId, productId, totalAmount);
      }

      final url = Uri.parse('$_backendUrl/api/blockchain/create-escrow-order');
      final requestBody = {
        'order_id': orderId,
        'product_id': productId,
        'consumer_wallet': consumerWallet,
        'farmer_wallet': farmerWallet,
        'distributor_wallet': distributorWallet,
        'retailer_wallet': retailerWallet,
        'total_amount': totalAmount.toString(),
        'contract_address': escrowPaymentAddress,
      };

      final response = await http.post(
        url,
        headers: _headers,
        body: jsonEncode(requestBody),
      ).timeout(_timeoutDuration);

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        return EscrowOrderResult(
          success: true,
          orderId: orderId,
          productId: productId,
          totalAmount: totalAmount,
          transactionHash: responseData['transaction_hash'],
          blockNumber: responseData['block_number'],
          escrowAddress: responseData['escrow_address'],
          message: 'Escrow order created successfully',
        );
      } else {
        throw SmartContractException(responseData['error'] ?? 'Escrow order creation failed');
      }
    } catch (e) {
      debugPrint('❌ Escrow order creation failed: $e');
      throw SmartContractException('Escrow order creation failed: $e');
    }
  }

  /// Release escrow payment (Consumer delivery confirmation)
  static Future<PaymentReleaseResult> releaseEscrowPayment({
    required String orderId,
    required String qrCodeHash,
    required String consumerWallet,
  }) async {
    try {
      debugPrint('💸 Releasing escrow payment...');
      debugPrint('📦 Order: $orderId');
      debugPrint('👤 Consumer: $consumerWallet');

      if (_useMockMode) {
        return _mockReleasePayment(orderId, qrCodeHash);
      }

      final url = Uri.parse('$_backendUrl/api/blockchain/release-escrow-payment');
      final requestBody = {
        'order_id': orderId,
        'qr_code_hash': qrCodeHash,
        'consumer_wallet': consumerWallet,
        'contract_address': escrowPaymentAddress,
      };

      final response = await http.post(
        url,
        headers: _headers,
        body: jsonEncode(requestBody),
      ).timeout(_timeoutDuration);

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        final breakdown = Map<String, double>.from(responseData['payment_breakdown']);
        
        return PaymentReleaseResult(
          success: true,
          orderId: orderId,
          totalReleased: responseData['total_released'].toDouble(),
          paymentBreakdown: breakdown,
          transactionHash: responseData['transaction_hash'],
          blockNumber: responseData['block_number'],
          message: 'Payment released successfully to all stakeholders',
        );
      } else {
        throw SmartContractException(responseData['error'] ?? 'Payment release failed');
      }
    } catch (e) {
      debugPrint('❌ Payment release failed: $e');
      throw SmartContractException('Payment release failed: $e');
    }
  }

  /// Get complete product traceability
  static Future<ProductTraceability> getProductTraceability({
    required String productId,
    String? qrCodeHash,
  }) async {
    try {
      debugPrint('🔍 Getting product traceability...');
      debugPrint('📦 Product: $productId');

      if (_useMockMode) {
        return _mockGetTraceability(productId);
      }

      final url = Uri.parse('$_backendUrl/api/blockchain/get-traceability');
      final response = await http.post(
        url,
        headers: _headers,
        body: jsonEncode({
          'product_id': productId,
          'qr_code_hash': qrCodeHash,
          'contract_addresses': {
            'product_registry': productRegistryAddress,
            'traceability': traceabilityAddress,
          }
        }),
      ).timeout(_timeoutDuration);

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        return ProductTraceability.fromJson(responseData['traceability']);
      } else {
        throw SmartContractException(responseData['error'] ?? 'Failed to get traceability');
      }
    } catch (e) {
      debugPrint('❌ Traceability fetch failed: $e');
      throw SmartContractException('Traceability fetch failed: $e');
    }
  }

  /// Verify consumer order for payment release
  static Future<ConsumerVerificationResult> verifyConsumerForPayment({
    required String consumerWallet,
    required String productId,
    required String qrCodeHash,
  }) async {
    try {
      debugPrint('✅ Verifying consumer for payment...');
      debugPrint('👤 Consumer: $consumerWallet');
      debugPrint('📦 Product: $productId');

      if (_useMockMode) {
        return _mockVerifyConsumer(consumerWallet, productId);
      }

      final url = Uri.parse('$_backendUrl/api/blockchain/verify-consumer-order');
      final response = await http.post(
        url,
        headers: _headers,
        body: jsonEncode({
          'consumer_wallet': consumerWallet,
          'product_id': productId,
          'qr_code_hash': qrCodeHash,
          'contract_address': escrowPaymentAddress,
        }),
      ).timeout(_timeoutDuration);

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return ConsumerVerificationResult.fromJson(responseData);
      } else {
        throw SmartContractException(responseData['error'] ?? 'Consumer verification failed');
      }
    } catch (e) {
      debugPrint('❌ Consumer verification failed: $e');
      throw SmartContractException('Consumer verification failed: $e');
    }
  }

  // Mock implementations for development
  static Future<ProductRegistrationResult> _mockRegisterProduct(
    String productId, String productName, double basePrice
  ) async {
    await Future.delayed(const Duration(seconds: 2));
    
    final qrHash = _generateQRCodeHash(productId, 'mock_farmer');
    
    return ProductRegistrationResult(
      success: true,
      productId: productId,
      qrCodeHash: qrHash,
      transactionHash: '0x${DateTime.now().millisecondsSinceEpoch.toRadixString(16)}',
      blockNumber: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      message: 'Mock product registered successfully',
    );
  }

  static Future<OwnershipTransferResult> _mockTransferOwnership(
    String productId, String fromRole, String toRole, double additionalCost
  ) async {
    await Future.delayed(const Duration(seconds: 2));
    
    return OwnershipTransferResult(
      success: true,
      productId: productId,
      newOwner: 'mock_${toRole}_wallet',
      newRole: toRole,
      transactionHash: '0x${DateTime.now().millisecondsSinceEpoch.toRadixString(16)}',
      blockNumber: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      gasUsed: 150000,
      message: 'Mock ownership transfer completed',
    );
  }

  static Future<ScanRecordResult> _mockRecordScan(String qrHash, String scanner) async {
    await Future.delayed(const Duration(seconds: 1));
    
    return ScanRecordResult(
      success: true,
      qrCodeHash: qrHash,
      scanner: scanner,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      transactionHash: '0x${DateTime.now().millisecondsSinceEpoch.toRadixString(16)}',
      message: 'Mock QR scan recorded',
    );
  }

  static Future<EscrowOrderResult> _mockCreateEscrowOrder(
    String orderId, String productId, double totalAmount
  ) async {
    await Future.delayed(const Duration(seconds: 2));
    
    return EscrowOrderResult(
      success: true,
      orderId: orderId,
      productId: productId,
      totalAmount: totalAmount,
      transactionHash: '0x${DateTime.now().millisecondsSinceEpoch.toRadixString(16)}',
      blockNumber: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      escrowAddress: escrowPaymentAddress,
      message: 'Mock escrow order created',
    );
  }

  static Future<PaymentReleaseResult> _mockReleasePayment(
    String orderId, String qrHash
  ) async {
    await Future.delayed(const Duration(seconds: 2));
    
    return PaymentReleaseResult(
      success: true,
      orderId: orderId,
      totalReleased: 1.25,
      paymentBreakdown: {
        'farmer': 0.75,
        'distributor': 0.25,
        'retailer': 0.25,
      },
      transactionHash: '0x${DateTime.now().millisecondsSinceEpoch.toRadixString(16)}',
      blockNumber: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      message: 'Mock payment released successfully',
    );
  }

  static Future<ProductTraceability> _mockGetTraceability(String productId) async {
    await Future.delayed(const Duration(seconds: 1));
    
    return ProductTraceability(
      productId: productId,
      productName: 'Organic Tomatoes - 1kg',
      qrCodeHash: _generateQRCodeHash(productId, 'mock_farmer'),
      farmer: TraceabilityStep(
        wallet: 'farmer_wallet',
        timestamp: DateTime.now().subtract(const Duration(days: 7)),
        location: 'Farm Location',
        cost: 0.75,
        verified: true,
      ),
      distributor: TraceabilityStep(
        wallet: 'distributor_wallet',
        timestamp: DateTime.now().subtract(const Duration(days: 3)),
        location: 'Distribution Center',
        cost: 0.25,
        verified: true,
      ),
      retailer: TraceabilityStep(
        wallet: 'retailer_wallet',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        location: 'Retail Store',
        cost: 0.25,
        verified: true,
      ),
      consumer: null,
      totalCost: 1.25,
      isActive: true,
    );
  }

  static Future<ConsumerVerificationResult> _mockVerifyConsumer(
    String consumerWallet, String productId
  ) async {
    await Future.delayed(const Duration(seconds: 1));
    
    return ConsumerVerificationResult(
      verified: true,
      hasActiveOrder: true,
      orderId: 'ORD_${DateTime.now().millisecondsSinceEpoch}',
      totalAmount: 1.25,
      canReleasePayment: true,
      message: 'Consumer verified with active order',
    );
  }

  // Utility functions
  static String _generateQRCodeHash(String productId, String farmerId) {
    final input = '$productId:$farmerId:${DateTime.now().millisecondsSinceEpoch}';
    return sha256.convert(utf8.encode(input)).toString();
  }

  static String _generateMetadataHash(Map<String, dynamic> metadata) {
    final jsonString = jsonEncode(metadata);
    return sha256.convert(utf8.encode(jsonString)).toString();
  }

  /// Get contract addresses
  static Map<String, String> getContractAddresses() {
    return {
      'ProductRegistry': productRegistryAddress,
      'Traceability': traceabilityAddress,
      'EscrowPayment': escrowPaymentAddress,
    };
  }
}

/// Result classes
class ProductRegistrationResult {
  final bool success;
  final String productId;
  final String qrCodeHash;
  final String transactionHash;
  final int blockNumber;
  final String message;

  ProductRegistrationResult({
    required this.success,
    required this.productId,
    required this.qrCodeHash,
    required this.transactionHash,
    required this.blockNumber,
    required this.message,
  });
}

class OwnershipTransferResult {
  final bool success;
  final String productId;
  final String newOwner;
  final String newRole;
  final String transactionHash;
  final int blockNumber;
  final int gasUsed;
  final String message;

  OwnershipTransferResult({
    required this.success,
    required this.productId,
    required this.newOwner,
    required this.newRole,
    required this.transactionHash,
    required this.blockNumber,
    required this.gasUsed,
    required this.message,
  });
}

class ScanRecordResult {
  final bool success;
  final String qrCodeHash;
  final String scanner;
  final int timestamp;
  final String transactionHash;
  final String message;

  ScanRecordResult({
    required this.success,
    required this.qrCodeHash,
    required this.scanner,
    required this.timestamp,
    required this.transactionHash,
    required this.message,
  });
}

class EscrowOrderResult {
  final bool success;
  final String orderId;
  final String productId;
  final double totalAmount;
  final String transactionHash;
  final int blockNumber;
  final String escrowAddress;
  final String message;

  EscrowOrderResult({
    required this.success,
    required this.orderId,
    required this.productId,
    required this.totalAmount,
    required this.transactionHash,
    required this.blockNumber,
    required this.escrowAddress,
    required this.message,
  });
}

class PaymentReleaseResult {
  final bool success;
  final String orderId;
  final double totalReleased;
  final Map<String, double> paymentBreakdown;
  final String transactionHash;
  final int blockNumber;
  final String message;

  PaymentReleaseResult({
    required this.success,
    required this.orderId,
    required this.totalReleased,
    required this.paymentBreakdown,
    required this.transactionHash,
    required this.blockNumber,
    required this.message,
  });
}

class ProductTraceability {
  final String productId;
  final String productName;
  final String qrCodeHash;
  final TraceabilityStep farmer;
  final TraceabilityStep? distributor;
  final TraceabilityStep? retailer;
  final TraceabilityStep? consumer;
  final double totalCost;
  final bool isActive;

  ProductTraceability({
    required this.productId,
    required this.productName,
    required this.qrCodeHash,
    required this.farmer,
    this.distributor,
    this.retailer,
    this.consumer,
    required this.totalCost,
    required this.isActive,
  });

  factory ProductTraceability.fromJson(Map<String, dynamic> json) {
    return ProductTraceability(
      productId: json['product_id'],
      productName: json['product_name'],
      qrCodeHash: json['qr_code_hash'],
      farmer: TraceabilityStep.fromJson(json['farmer']),
      distributor: json['distributor'] != null ? TraceabilityStep.fromJson(json['distributor']) : null,
      retailer: json['retailer'] != null ? TraceabilityStep.fromJson(json['retailer']) : null,
      consumer: json['consumer'] != null ? TraceabilityStep.fromJson(json['consumer']) : null,
      totalCost: json['total_cost'].toDouble(),
      isActive: json['is_active'],
    );
  }
}

class TraceabilityStep {
  final String wallet;
  final DateTime timestamp;
  final String location;
  final double cost;
  final bool verified;

  TraceabilityStep({
    required this.wallet,
    required this.timestamp,
    required this.location,
    required this.cost,
    required this.verified,
  });

  factory TraceabilityStep.fromJson(Map<String, dynamic> json) {
    return TraceabilityStep(
      wallet: json['wallet'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
      location: json['location'],
      cost: json['cost'].toDouble(),
      verified: json['verified'],
    );
  }
}

class ConsumerVerificationResult {
  final bool verified;
  final bool hasActiveOrder;
  final String? orderId;
  final double? totalAmount;
  final bool canReleasePayment;
  final String message;

  ConsumerVerificationResult({
    required this.verified,
    required this.hasActiveOrder,
    this.orderId,
    this.totalAmount,
    required this.canReleasePayment,
    required this.message,
  });

  factory ConsumerVerificationResult.fromJson(Map<String, dynamic> json) {
    return ConsumerVerificationResult(
      verified: json['verified'],
      hasActiveOrder: json['has_active_order'],
      orderId: json['order_id'],
      totalAmount: json['total_amount']?.toDouble(),
      canReleasePayment: json['can_release_payment'],
      message: json['message'],
    );
  }
}

/// Custom exception for smart contract operations
class SmartContractException implements Exception {
  final String message;

  SmartContractException(this.message);

  @override
  String toString() => 'SmartContractException: $message';
}