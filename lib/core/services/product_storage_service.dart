import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/blockchain_product.dart';
import '../models/delivery_tracking.dart';

/// Service to store and retrieve blockchain products locally
class ProductStorageService {
  static const String _productsKey = 'blockchain_products';
  static const String _transactionsKey = 'blockchain_transactions';

  /// Save a posted product to local storage
  static Future<void> savePostedProduct(BlockchainProduct product) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Get existing products
      List<BlockchainProduct> products = await getPostedProducts();

      // Add new product
      products.insert(0, product); // Add to beginning (most recent first)

      // Convert to JSON and save
      List<String> productsJson = products
          .map((p) => json.encode(p.toJson()))
          .toList();
      await prefs.setStringList(_productsKey, productsJson);

      print('✅ Product saved to local storage: ${product.productId}');
    } catch (e) {
      print('❌ Failed to save product: $e');
    }
  }

  /// Get all posted products from local storage
  static Future<List<BlockchainProduct>> getPostedProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String>? productsJson = prefs.getStringList(_productsKey);

      if (productsJson == null || productsJson.isEmpty) {
        return [];
      }

      return productsJson.map((jsonStr) {
        Map<String, dynamic> productData = json.decode(jsonStr);
        return BlockchainProduct.fromJson(productData);
      }).toList();
    } catch (e) {
      print('❌ Failed to load products: $e');
      return [];
    }
  }

  /// Save a blockchain transaction
  static Future<void> saveTransaction(BlockchainTransaction transaction) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Get existing transactions
      List<BlockchainTransaction> transactions = await getTransactions();

      // Add new transaction
      transactions.insert(0, transaction); // Most recent first

      // Keep only last 100 transactions
      if (transactions.length > 100) {
        transactions = transactions.sublist(0, 100);
      }

      // Convert to JSON and save
      List<String> transactionsJson = transactions
          .map((t) => json.encode(t.toJson()))
          .toList();
      await prefs.setStringList(_transactionsKey, transactionsJson);

      print('✅ Transaction saved: ${transaction.txHash}');
    } catch (e) {
      print('❌ Failed to save transaction: $e');
    }
  }

  /// Get all blockchain transactions
  static Future<List<BlockchainTransaction>> getTransactions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String>? transactionsJson = prefs.getStringList(_transactionsKey);

      if (transactionsJson == null || transactionsJson.isEmpty) {
        return [];
      }

      return transactionsJson.map((jsonStr) {
        Map<String, dynamic> transactionData = json.decode(jsonStr);
        return BlockchainTransaction.fromJson(transactionData);
      }).toList();
    } catch (e) {
      print('❌ Failed to load transactions: $e');
      return [];
    }
  }

  /// Get products by status
  static Future<List<BlockchainProduct>> getProductsByStatus(
    String status,
  ) async {
    List<BlockchainProduct> allProducts = await getPostedProducts();
    return allProducts
        .where(
          (product) => product.status.toLowerCase() == status.toLowerCase(),
        )
        .toList();
  }

  /// Get product by ID
  static Future<BlockchainProduct?> getProductById(String productId) async {
    List<BlockchainProduct> allProducts = await getPostedProducts();
    try {
      return allProducts.firstWhere(
        (product) => product.productId == productId,
      );
    } catch (e) {
      return null;
    }
  }

  /// Update product with distributor details when accepted
  static Future<void> updateProductWithDistributor({
    required String productId,
    required String distributorId,
    required String distributorName,
    required String distributorWallet,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<BlockchainProduct> products = await getPostedProducts();

      for (int i = 0; i < products.length; i++) {
        if (products[i].productId == productId) {
          final now = DateTime.now();
          
          // Create enhanced QR code data with distributor information
          final enhancedQrData = json.encode({
            'productId': products[i].productId,
            'name': products[i].name,
            'farmer': {
              'name': products[i].farmerName,
              'wallet': products[i].farmerWallet,
            },
            'distributor': {
              'id': distributorId,
              'name': distributorName,
              'wallet': distributorWallet,
              'acceptedAt': now.toIso8601String(),
            },
            'originalTxHash': products[i].txHash,
            'trackingEnabled': true,
            'lastUpdated': now.toIso8601String(),
          });

          // Update product with distributor details
          products[i] = products[i].copyWith(
            status: 'accepted',
            distributorId: distributorId,
            distributorName: distributorName,
            distributorWallet: distributorWallet,
            acceptedAt: now,
            currentOwnerWallet: distributorWallet,
            qrCodeData: enhancedQrData,
          );

          // Save updated products
          List<String> productsJson = products
              .map((p) => json.encode(p.toJson()))
              .toList();
          await prefs.setStringList(_productsKey, productsJson);

          print('✅ Product updated with distributor details: $productId');
          return;
        }
      }
    } catch (e) {
      print('❌ Failed to update product with distributor: $e');
      throw e;
    }
  }

  /// Update product status (e.g., when transferred to distributor)
  static Future<void> updateProductStatus(
    String productId,
    String newStatus,
  ) async {
    try {
      List<BlockchainProduct> products = await getPostedProducts();
      int index = products.indexWhere((p) => p.productId == productId);

      if (index != -1) {
        products[index] = products[index].copyWith(status: newStatus);

        // Save updated products
        final prefs = await SharedPreferences.getInstance();
        List<String> productsJson = products
            .map((p) => json.encode(p.toJson()))
            .toList();
        await prefs.setStringList(_productsKey, productsJson);

        print('✅ Product status updated: $productId -> $newStatus');
      }
    } catch (e) {
      print('❌ Failed to update product status: $e');
    }
  }

  /// Clear all stored data (for testing purposes)
  static Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_productsKey);
      await prefs.remove(_transactionsKey);
      print('✅ All blockchain data cleared');
    } catch (e) {
      print('❌ Failed to clear data: $e');
    }
  }

  /// Get statistics for dashboard
  static Future<Map<String, int>> getProductStatistics() async {
    List<BlockchainProduct> products = await getPostedProducts();

    Map<String, int> stats = {
      'active': 0,
      'in_transit': 0,
      'delivered': 0,
      'total': products.length,
    };

    for (BlockchainProduct product in products) {
      String status = product.status.toLowerCase().replaceAll(' ', '_');
      if (stats.containsKey(status)) {
        stats[status] = stats[status]! + 1;
      } else {
        stats['active'] = stats['active']! + 1; // Default to active
      }
    }

    return stats;
  }

  /// Handle product sale to distributor
  static Future<void> sellProductToDistributor({
    required String productId,
    required String distributorName,
    required double salePrice,
    required String farmerWallet,
    required String distributorWallet,
  }) async {
    try {
      // Get the product
      BlockchainProduct? product = await getProductById(productId);
      if (product == null) {
        throw Exception('Product not found: $productId');
      }

      // Update product status to pending (awaiting payment)
      await updateProductStatus(productId, 'pending_payment');

      // Create sale transaction
      final saleTransaction = BlockchainTransaction(
        txHash: 'sale_${DateTime.now().millisecondsSinceEpoch}',
        type: 'product_sale',
        productId: productId,
        fromWallet: farmerWallet,
        toWallet: distributorWallet,
        amount: salePrice,
        timestamp: DateTime.now(),
        status: 'pending', // Pending until payment is received
        transactionData: {
          'productName': product.name,
          'distributorName': distributorName,
          'description': 'Product sold to $distributorName - Awaiting payment',
          'quantity': product.quantity,
          'unit': product.unit,
          'salePrice': salePrice,
          'originalPrice': product.pricePerUnit,
        },
      );

      await saveTransaction(saleTransaction);
      print('✅ Product sale recorded: $productId -> $distributorName');
    } catch (e) {
      print('❌ Failed to record product sale: $e');
      throw e;
    }
  }

  /// Handle payment received from distributor
  static Future<void> receivePaymentFromDistributor({
    required String productId,
    required double amount,
    required String farmerWallet,
    required String distributorWallet,
  }) async {
    try {
      // Get the product
      BlockchainProduct? product = await getProductById(productId);
      if (product == null) {
        throw Exception('Product not found: $productId');
      }

      // Update product status to in_transit
      await updateProductStatus(productId, 'in_transit');

      // Find and update the pending sale transaction
      List<BlockchainTransaction> transactions = await getTransactions();
      for (int i = 0; i < transactions.length; i++) {
        if (transactions[i].productId == productId &&
            transactions[i].type == 'product_sale' &&
            transactions[i].status == 'pending') {
          // Update the sale transaction to confirmed
          final updatedSaleTransaction = BlockchainTransaction(
            txHash: transactions[i].txHash,
            type: transactions[i].type,
            productId: transactions[i].productId,
            fromWallet: transactions[i].fromWallet,
            toWallet: transactions[i].toWallet,
            amount: transactions[i].amount,
            timestamp: transactions[i].timestamp,
            status: 'confirmed',
            transactionData: {
              ...transactions[i].transactionData ?? {},
              'description':
                  'Payment received from ${transactions[i].transactionData?['distributorName'] ?? 'distributor'}',
            },
          );

          // Replace the old transaction
          transactions[i] = updatedSaleTransaction;
          break;
        }
      }

      // Create payment received transaction
      final paymentTransaction = BlockchainTransaction(
        txHash: 'payment_${DateTime.now().millisecondsSinceEpoch}',
        type: 'payment_received',
        productId: productId,
        fromWallet: distributorWallet,
        toWallet: farmerWallet,
        amount: amount,
        timestamp: DateTime.now(),
        status: 'confirmed',
        transactionData: {
          'productName': product.name,
          'description': 'Payment received for ${product.name}',
          'paymentFor': 'product_sale',
        },
      );

      // Save updated transactions
      final prefs = await SharedPreferences.getInstance();
      List<String> transactionsJson = transactions
          .map((t) => json.encode(t.toJson()))
          .toList();
      await prefs.setStringList(_transactionsKey, transactionsJson);

      // Add the new payment transaction
      await saveTransaction(paymentTransaction);

      print('✅ Payment received: $productId - ₹$amount');
    } catch (e) {
      print('❌ Failed to record payment: $e');
      throw e;
    }
  }

  // DELIVERY TRACKING METHODS

  static const String _deliveriesKey = 'delivery_trackings';

  /// Start delivery tracking when distributor accepts and picks up product
  static Future<void> startDeliveryTracking({
    required String productId,
    required String distributorId,
    required String distributorName,
    required String distributorWallet,
    required String farmerName,
    required String farmerWallet,
    String? vehicleNumber,
    String? driverName,
    String? driverContact,
  }) async {
    try {
      final deliveryId = 'delivery_${DateTime.now().millisecondsSinceEpoch}';
      final now = DateTime.now();

      final delivery = DeliveryTracking(
        deliveryId: deliveryId,
        productId: productId,
        distributorId: distributorId,
        distributorName: distributorName,
        distributorWallet: distributorWallet,
        farmerName: farmerName,
        farmerWallet: farmerWallet,
        status: 'in_transit',
        pickupTime: now,
        vehicleNumber: vehicleNumber ?? 'VH${DateTime.now().millisecondsSinceEpoch % 10000}',
        driverName: driverName ?? 'Driver ${distributorName}',
        driverContact: driverContact ?? '+91 9876543210',
        trackingUpdates: [
          TrackingUpdate(
            updateId: 'update_${now.millisecondsSinceEpoch}',
            timestamp: now,
            location: 'Farm Location',
            description: 'Product picked up from farmer',
            status: 'picked_up',
          ),
        ],
        currentLocation: 'En route to distributor facility',
        estimatedDistance: 15.5, // km
        estimatedDelivery: now.add(const Duration(hours: 2)),
      );

      // Save delivery tracking
      final prefs = await SharedPreferences.getInstance();
      List<DeliveryTracking> deliveries = await getDeliveryTrackings();
      deliveries.insert(0, delivery);

      List<String> deliveriesJson = deliveries
          .map((d) => json.encode(d.toJson()))
          .toList();
      await prefs.setStringList(_deliveriesKey, deliveriesJson);

      // Update product status to in_transit
      await updateProductStatus(productId, 'in_transit');

      print('✅ Delivery tracking started: $deliveryId');
    } catch (e) {
      print('❌ Failed to start delivery tracking: $e');
      throw e;
    }
  }

  /// Get all delivery trackings
  static Future<List<DeliveryTracking>> getDeliveryTrackings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String>? deliveriesJson = prefs.getStringList(_deliveriesKey);

      if (deliveriesJson == null || deliveriesJson.isEmpty) {
        return [];
      }

      return deliveriesJson.map((jsonStr) {
        Map<String, dynamic> deliveryData = json.decode(jsonStr);
        return DeliveryTracking.fromJson(deliveryData);
      }).toList();
    } catch (e) {
      print('❌ Failed to load delivery trackings: $e');
      return [];
    }
  }

  /// Get active delivery trackings (in_transit status)
  static Future<List<DeliveryTracking>> getActiveDeliveries() async {
    try {
      final allDeliveries = await getDeliveryTrackings();
      return allDeliveries.where((delivery) => delivery.status == 'in_transit').toList();
    } catch (e) {
      print('❌ Failed to load active deliveries: $e');
      return [];
    }
  }

  /// Update delivery tracking with new location/status
  static Future<void> updateDeliveryTracking({
    required String deliveryId,
    String? newLocation,
    String? description,
    String? status,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<DeliveryTracking> deliveries = await getDeliveryTrackings();

      for (int i = 0; i < deliveries.length; i++) {
        if (deliveries[i].deliveryId == deliveryId) {
          final currentDelivery = deliveries[i];
          final now = DateTime.now();

          // Create new tracking update
          final newUpdate = TrackingUpdate(
            updateId: 'update_${now.millisecondsSinceEpoch}',
            timestamp: now,
            location: newLocation ?? currentDelivery.currentLocation ?? 'Unknown',
            description: description ?? 'Location updated',
            status: status ?? 'in_transit',
          );

          // Update delivery with new information
          final updatedDelivery = currentDelivery.copyWith(
            status: status ?? currentDelivery.status,
            currentLocation: newLocation ?? currentDelivery.currentLocation,
            trackingUpdates: [...currentDelivery.trackingUpdates, newUpdate],
            deliveryTime: (status == 'delivered') ? now : currentDelivery.deliveryTime,
          );

          deliveries[i] = updatedDelivery;

          // Save updated deliveries
          List<String> deliveriesJson = deliveries
              .map((d) => json.encode(d.toJson()))
              .toList();
          await prefs.setStringList(_deliveriesKey, deliveriesJson);

          // Update product status if delivered
          if (status == 'delivered') {
            await updateProductStatus(currentDelivery.productId, 'delivered');
          }

          break;
        }
      }

      print('✅ Delivery tracking updated: $deliveryId');
    } catch (e) {
      print('❌ Failed to update delivery tracking: $e');
      throw e;
    }
  }

  /// Complete delivery when product is received
  static Future<void> completeDelivery(String deliveryId) async {
    await updateDeliveryTracking(
      deliveryId: deliveryId,
      newLocation: 'Distributor Warehouse',
      description: 'Product delivered successfully to distributor',
      status: 'delivered',
    );
  }

  /// Get delivery tracking by product ID
  static Future<DeliveryTracking?> getDeliveryByProductId(String productId) async {
    try {
      final deliveries = await getDeliveryTrackings();
      return deliveries.where((delivery) => delivery.productId == productId).firstOrNull;
    } catch (e) {
      print('❌ Failed to get delivery by product ID: $e');
      return null;
    }
  }
}
