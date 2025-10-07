import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart';

/// Enhanced Aadhaar Verification Service with Blockchain Integration
/// Handles consumer verification for order-based payment release
class BlockchainAadhaarService {
  // Backend URLs
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
      return 'https://your-production-api.com';
    }
  }

  // Blockchain node URL (Hardhat local)
  static String get _blockchainUrl {
    if (kDebugMode) {
      return 'http://localhost:8545'; // Hardhat default
    } else {
      return 'https://your-blockchain-node.com';
    }
  }

  static const Duration _timeoutDuration = Duration(seconds: 10);
  static const bool _useMockMode = true; // For development

  /// Headers for API requests
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Mock wallet addresses for testing (from Hardhat)
  static const Map<String, List<String>> _mockWallets = {
    'farmer': [
      '0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266',
      '0x70997970c51812dc3a010c7d01b50e0d17dc79c8',
      '0x3c44cdddb6a900fa2b585dd299e03d12fa4293bc',
      '0x90f79bf6eb2c4f870365e785982e1f101e93b906',
      '0x15d34aaf54267db7d7c367839aaf71a00a2c6a65',
    ],
    'distributor': [
      '0x9965507d1a55bcc2695c58ba16fb37d819b0a4dc',
      '0x976ea74026e726554db657fa54763abd0c3a0aa9',
      '0x14dc79964da2c08b23698b3d3cc7ca32193d9955',
      '0x23618e81e3f5cdf7f54c3d65f7fbc0abf5b21e8f',
      '0xa0ee7a142d267c1f36714e4a8f75612f20a79720',
    ],
    'retailer': [
      '0xbcd4042de499d14e55001ccbb24a551f3b954096',
      '0x71be63f3384f5fb98995898a86b02fb2426c5788',
      '0xfabb0ac9d68b0b445fb7357272ff202c5651694a',
      '0x1cbd3b2770909d4e10f157cabc84c7264073c9ec',
      '0xdf3e18d64bc6a983f673ab319ccae4f1a57c7097',
    ],
    'consumer': [
      '0xcd3b766ccdd6ae721141f452c550ca635964ce71',
      '0x2546bcd3c84621e976d8185a91a922ae77ecec30',
      '0xbda5747bfd65f08deb54cb465eb87d40e51b197e',
      '0xdd2fd4581271e230360230f9337d5c0430bf44c0',
      '0x8626f6940e2eb28930efb4cef49b2d1f2c9c1199',
    ],
  };

  /// Test blockchain and backend connectivity
  static Future<BlockchainConnectivityStatus> testConnectivity() async {
    debugPrint('🔍 Testing blockchain and backend connectivity...');
    
    bool backendConnected = false;
    bool blockchainConnected = false;
    
    // Test backend connection
    try {
      final url = Uri.parse('$_backendUrl/api/health');
      final response = await http.get(url, headers: _headers)
          .timeout(_timeoutDuration);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        backendConnected = data['status'] == 'OK';
      }
    } catch (e) {
      debugPrint('❌ Backend connection failed: $e');
    }

    // Test blockchain connection
    try {
      final url = Uri.parse(_blockchainUrl);
      final rpcCall = {
        'jsonrpc': '2.0',
        'method': 'eth_blockNumber',
        'params': [],
        'id': 1,
      };
      
      final response = await http.post(
        url,
        headers: _headers,
        body: jsonEncode(rpcCall),
      ).timeout(_timeoutDuration);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        blockchainConnected = data['result'] != null;
      }
    } catch (e) {
      debugPrint('❌ Blockchain connection failed: $e');
    }

    return BlockchainConnectivityStatus(
      backendConnected: backendConnected,
      blockchainConnected: blockchainConnected,
      mockMode: _useMockMode || !backendConnected || !blockchainConnected,
    );
  }

  /// Assign wallet address to user based on role
  static String assignWalletToUser(String userId, String userRole) {
    debugPrint('🏦 Assigning wallet to user: $userId, role: $userRole');
    
    final roleWallets = _mockWallets[userRole.toLowerCase()];
    if (roleWallets == null || roleWallets.isEmpty) {
      throw BlockchainException('No wallets available for role: $userRole');
    }

    // Use user ID hash to deterministically assign wallet
    final userIdHash = sha256.convert(utf8.encode(userId)).toString();
    final walletIndex = int.parse(userIdHash.substring(0, 8), radix: 16) % roleWallets.length;
    final assignedWallet = roleWallets[walletIndex];
    
    debugPrint('💰 Assigned wallet: $assignedWallet');
    return assignedWallet;
  }

  /// Enhanced Aadhaar verification with blockchain integration
  static Future<BlockchainAadhaarResponse> verifyAadhaarForBlockchain({
    required String aadhaarNumber,
    required String userId,
    required String userRole,
    String? orderId,
    String? productQrId,
  }) async {
    try {
      debugPrint('🔐 Starting blockchain Aadhaar verification...');
      debugPrint('👤 User: $userId, Role: $userRole');
      if (orderId != null) debugPrint('📦 Order: $orderId');
      if (productQrId != null) debugPrint('📱 QR: $productQrId');

      final connectivity = await testConnectivity();
      
      if (connectivity.mockMode) {
        debugPrint('🎭 Using mock mode for verification');
        return _performMockVerification(
          aadhaarNumber: aadhaarNumber,
          userId: userId,
          userRole: userRole,
          orderId: orderId,
          productQrId: productQrId,
        );
      }

      // Real verification flow
      return _performRealVerification(
        aadhaarNumber: aadhaarNumber,
        userId: userId,
        userRole: userRole,
        orderId: orderId,
        productQrId: productQrId,
      );
      
    } catch (e) {
      debugPrint('❌ Blockchain Aadhaar verification failed: $e');
      throw BlockchainException('Verification failed: $e');
    }
  }

  /// Verify consumer order before payment release
  static Future<ConsumerOrderVerificationResult> verifyConsumerOrder({
    required String consumerId,
    required String productQrId,
    required String aadhaarNumber,
  }) async {
    try {
      debugPrint('🛒 Verifying consumer order for payment release...');
      debugPrint('👤 Consumer: $consumerId');
      debugPrint('📱 QR: $productQrId');

      final connectivity = await testConnectivity();
      
      if (connectivity.mockMode) {
        return _performMockOrderVerification(
          consumerId: consumerId,
          productQrId: productQrId,
          aadhaarNumber: aadhaarNumber,
        );
      }

      // Real verification - check order existence and ownership
      final verificationUrl = Uri.parse('$_backendUrl/api/orders/verify');
      final requestBody = {
        'consumer_id': consumerId,
        'product_qr_id': productQrId,
        'aadhaar_number': aadhaarNumber,
        'verification_type': 'payment_release',
      };

      final response = await http.post(
        verificationUrl,
        headers: _headers,
        body: jsonEncode(requestBody),
      ).timeout(_timeoutDuration);

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        // Trigger smart contract payment release
        final paymentResult = await _triggerSmartContractPayment(
          productQrId: productQrId,
          consumerWallet: assignWalletToUser(consumerId, 'consumer'),
          orderDetails: responseData['order_details'],
        );

        return ConsumerOrderVerificationResult(
          verified: true,
          orderId: responseData['order_id'],
          totalAmount: responseData['total_amount']?.toDouble() ?? 0.0,
          paymentBreakdown: Map<String, double>.from(responseData['payment_breakdown'] ?? {}),
          transactionHash: paymentResult.transactionHash,
          blockNumber: paymentResult.blockNumber,
          message: 'Order verified and payment released successfully',
        );
      } else {
        return ConsumerOrderVerificationResult(
          verified: false,
          message: responseData['error'] ?? 'Order verification failed',
        );
      }

    } catch (e) {
      debugPrint('❌ Consumer order verification failed: $e');
      return ConsumerOrderVerificationResult(
        verified: false,
        message: 'Verification failed: $e',
      );
    }
  }

  /// Trigger smart contract payment release
  static Future<SmartContractPaymentResult> _triggerSmartContractPayment({
    required String productQrId,
    required String consumerWallet,
    required Map<String, dynamic> orderDetails,
  }) async {
    try {
      debugPrint('⛓️ Triggering smart contract payment release...');
      
      if (_useMockMode) {
        // Mock smart contract interaction
        await Future.delayed(const Duration(seconds: 2));
        
        return SmartContractPaymentResult(
          success: true,
          transactionHash: '0x${DateTime.now().millisecondsSinceEpoch.toRadixString(16)}',
          blockNumber: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          gasUsed: 250000,
          message: 'Mock payment released successfully',
        );
      }

      // Real smart contract interaction
      final contractUrl = Uri.parse('$_backendUrl/api/blockchain/release-payment');
      final requestBody = {
        'product_qr_id': productQrId,
        'consumer_wallet': consumerWallet,
        'order_details': orderDetails,
        'contract_function': 'releasePayment',
      };

      final response = await http.post(
        contractUrl,
        headers: _headers,
        body: jsonEncode(requestBody),
      ).timeout(_timeoutDuration);

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        return SmartContractPaymentResult(
          success: true,
          transactionHash: responseData['transaction_hash'],
          blockNumber: responseData['block_number'],
          gasUsed: responseData['gas_used'],
          message: responseData['message'] ?? 'Payment released successfully',
        );
      } else {
        throw BlockchainException(responseData['error'] ?? 'Smart contract execution failed');
      }

    } catch (e) {
      debugPrint('❌ Smart contract payment failed: $e');
      throw BlockchainException('Payment release failed: $e');
    }
  }

  /// Mock verification for development
  static Future<BlockchainAadhaarResponse> _performMockVerification({
    required String aadhaarNumber,
    required String userId,
    required String userRole,
    String? orderId,
    String? productQrId,
  }) async {
    await Future.delayed(const Duration(seconds: 2));

    if (!_isValidAadhaar(aadhaarNumber)) {
      throw BlockchainException('Invalid Aadhaar number');
    }

    final walletAddress = assignWalletToUser(userId, userRole);
    
    return BlockchainAadhaarResponse(
      success: true,
      userId: userId,
      walletAddress: walletAddress,
      verificationHash: '0x${DateTime.now().millisecondsSinceEpoch.toRadixString(16)}',
      kycDetails: {
        'name': 'Mock User',
        'aadhaar_hash': sha256.convert(utf8.encode(aadhaarNumber)).toString(),
        'verified_at': DateTime.now().toIso8601String(),
        'role': userRole,
      },
      blockchainStatus: BlockchainStatus(
        registered: true,
        walletBalance: '1000.0 ETH',
        transactionCount: 5,
      ),
      message: 'Mock verification completed successfully',
    );
  }

  /// Mock order verification
  static Future<ConsumerOrderVerificationResult> _performMockOrderVerification({
    required String consumerId,
    required String productQrId,
    required String aadhaarNumber,
  }) async {
    await Future.delayed(const Duration(seconds: 2));

    // Simulate order verification
    final mockOrder = {
      'order_id': 'ORD_${DateTime.now().millisecondsSinceEpoch}',
      'consumer_id': consumerId,
      'product_qr_id': productQrId,
      'total_amount': 1250.0,
      'payment_breakdown': {
        'farmer': 750.0,    // Base price
        'distributor': 250.0, // Transport cost
        'retailer': 250.0,   // Retail margin
      },
    };

    return ConsumerOrderVerificationResult(
      verified: true,
      orderId: mockOrder['order_id'] as String,
      totalAmount: mockOrder['total_amount'] as double,
      paymentBreakdown: Map<String, double>.from(mockOrder['payment_breakdown'] as Map),
      transactionHash: '0x${DateTime.now().millisecondsSinceEpoch.toRadixString(16)}',
      blockNumber: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      message: 'Mock order verified and payment released',
    );
  }

  /// Real verification implementation
  static Future<BlockchainAadhaarResponse> _performRealVerification({
    required String aadhaarNumber,
    required String userId,
    required String userRole,
    String? orderId,
    String? productQrId,
  }) async {
    // Implementation for real Aadhaar verification with blockchain
    final url = Uri.parse('$_backendUrl/api/blockchain/verify-aadhaar');
    final requestBody = {
      'aadhaar_number': aadhaarNumber,
      'user_id': userId,
      'user_role': userRole,
      'order_id': orderId,
      'product_qr_id': productQrId,
    };

    final response = await http.post(
      url,
      headers: _headers,
      body: jsonEncode(requestBody),
    ).timeout(_timeoutDuration);

    final responseData = jsonDecode(response.body);

    if (response.statusCode == 200 && responseData['success'] == true) {
      return BlockchainAadhaarResponse.fromJson(responseData);
    } else {
      throw BlockchainException(responseData['error'] ?? 'Verification failed');
    }
  }

  /// Validate Aadhaar number format
  static bool _isValidAadhaar(String aadhaar) {
    return RegExp(r'^\d{12}$').hasMatch(aadhaar);
  }

  /// Get user's blockchain wallet info
  static Future<WalletInfo> getUserWalletInfo(String userId, String userRole) async {
    final walletAddress = assignWalletToUser(userId, userRole);
    
    if (_useMockMode) {
      return WalletInfo(
        address: walletAddress,
        balance: '1000.0 ETH',
        transactionCount: 5,
        isActive: true,
      );
    }

    // Real wallet info retrieval
    try {
      final url = Uri.parse('$_backendUrl/api/blockchain/wallet-info');
      final response = await http.post(
        url,
        headers: _headers,
        body: jsonEncode({'wallet_address': walletAddress}),
      ).timeout(_timeoutDuration);

      final data = jsonDecode(response.body);
      return WalletInfo.fromJson(data);
    } catch (e) {
      throw BlockchainException('Failed to get wallet info: $e');
    }
  }
}

/// Blockchain connectivity status
class BlockchainConnectivityStatus {
  final bool backendConnected;
  final bool blockchainConnected;
  final bool mockMode;

  BlockchainConnectivityStatus({
    required this.backendConnected,
    required this.blockchainConnected,
    required this.mockMode,
  });

  bool get isFullyConnected => backendConnected && blockchainConnected;
}

/// Enhanced response for blockchain Aadhaar verification
class BlockchainAadhaarResponse {
  final bool success;
  final String userId;
  final String walletAddress;
  final String verificationHash;
  final Map<String, dynamic> kycDetails;
  final BlockchainStatus blockchainStatus;
  final String message;

  BlockchainAadhaarResponse({
    required this.success,
    required this.userId,
    required this.walletAddress,
    required this.verificationHash,
    required this.kycDetails,
    required this.blockchainStatus,
    required this.message,
  });

  factory BlockchainAadhaarResponse.fromJson(Map<String, dynamic> json) {
    return BlockchainAadhaarResponse(
      success: json['success'] ?? false,
      userId: json['user_id'] ?? '',
      walletAddress: json['wallet_address'] ?? '',
      verificationHash: json['verification_hash'] ?? '',
      kycDetails: Map<String, dynamic>.from(json['kyc_details'] ?? {}),
      blockchainStatus: BlockchainStatus.fromJson(json['blockchain_status'] ?? {}),
      message: json['message'] ?? '',
    );
  }
}

/// Blockchain status information
class BlockchainStatus {
  final bool registered;
  final String walletBalance;
  final int transactionCount;

  BlockchainStatus({
    required this.registered,
    required this.walletBalance,
    required this.transactionCount,
  });

  factory BlockchainStatus.fromJson(Map<String, dynamic> json) {
    return BlockchainStatus(
      registered: json['registered'] ?? false,
      walletBalance: json['wallet_balance'] ?? '0 ETH',
      transactionCount: json['transaction_count'] ?? 0,
    );
  }
}

/// Consumer order verification result
class ConsumerOrderVerificationResult {
  final bool verified;
  final String? orderId;
  final double? totalAmount;
  final Map<String, double>? paymentBreakdown;
  final String? transactionHash;
  final int? blockNumber;
  final String message;

  ConsumerOrderVerificationResult({
    required this.verified,
    this.orderId,
    this.totalAmount,
    this.paymentBreakdown,
    this.transactionHash,
    this.blockNumber,
    required this.message,
  });
}

/// Smart contract payment result
class SmartContractPaymentResult {
  final bool success;
  final String transactionHash;
  final int blockNumber;
  final int gasUsed;
  final String message;

  SmartContractPaymentResult({
    required this.success,
    required this.transactionHash,
    required this.blockNumber,
    required this.gasUsed,
    required this.message,
  });
}

/// Wallet information
class WalletInfo {
  final String address;
  final String balance;
  final int transactionCount;
  final bool isActive;

  WalletInfo({
    required this.address,
    required this.balance,
    required this.transactionCount,
    required this.isActive,
  });

  factory WalletInfo.fromJson(Map<String, dynamic> json) {
    return WalletInfo(
      address: json['address'] ?? '',
      balance: json['balance'] ?? '0 ETH',
      transactionCount: json['transaction_count'] ?? 0,
      isActive: json['is_active'] ?? false,
    );
  }
}

/// Custom exception for blockchain operations
class BlockchainException implements Exception {
  final String message;

  BlockchainException(this.message);

  @override
  String toString() => 'BlockchainException: $message';
}