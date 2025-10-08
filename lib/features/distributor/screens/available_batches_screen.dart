import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/product_storage_service.dart';
import '../../../core/models/blockchain_product.dart';

class AvailableBatchesScreen extends StatefulWidget {
  const AvailableBatchesScreen({super.key});

  @override
  State<AvailableBatchesScreen> createState() => _AvailableBatchesScreenState();
}

class _AvailableBatchesScreenState extends State<AvailableBatchesScreen> {
  String _selectedFilter = 'All';
  String _selectedSort = 'Distance';
  List<BlockchainProduct> _availableProducts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAvailableProducts();
  }

  Future<void> _loadAvailableProducts() async {
    try {
      final allProducts = await ProductStorageService.getPostedProducts();
      // Show only active products that are available for distributors
      final availableProducts = allProducts
          .where((product) => product.status.toLowerCase() == 'active')
          .toList();

      setState(() {
        _availableProducts = availableProducts;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading available products: $e');
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
        title: const Text('Available Batches'),
        backgroundColor: AppColors.distributorPrimary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _showFilterDialog,
            icon: const Icon(Icons.filter_list),
          ),
          IconButton(onPressed: _showSortDialog, icon: const Icon(Icons.sort)),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Nearby'),
                  const SizedBox(width: 8),
                  _buildFilterChip('High Quality'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Organic'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Urgent'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Batch List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _availableProducts.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    onRefresh: _loadAvailableProducts,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = _filteredProducts[index];
                        return _buildProductCard(product);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  List<BlockchainProduct> get _filteredProducts {
    List<BlockchainProduct> filtered = _availableProducts;

    if (_selectedFilter != 'All') {
      switch (_selectedFilter) {
        case 'Nearby':
          // For now, just return all since we don't have location data
          break;
        case 'High Quality':
          filtered = filtered
              .where((product) => product.qualityCertifications.isNotEmpty)
              .toList();
          break;
        case 'Organic':
          filtered = filtered
              .where(
                (product) =>
                    product.qualityCertifications.contains('Organic Certified'),
              )
              .toList();
          break;
        case 'Urgent':
          // For now, show products posted in last 24 hours
          final yesterday = DateTime.now().subtract(const Duration(days: 1));
          filtered = filtered
              .where((product) => product.postedAt.isAfter(yesterday))
              .toList();
          break;
      }
    }

    // Apply sorting
    switch (_selectedSort) {
      case 'Distance':
        // For now, sort by posted date (newest first)
        filtered.sort((a, b) => b.postedAt.compareTo(a.postedAt));
        break;
      case 'Price':
        filtered.sort((a, b) => a.pricePerUnit.compareTo(b.pricePerUnit));
        break;
      case 'Quantity':
        filtered.sort((a, b) => b.quantity.compareTo(a.quantity));
        break;
    }

    return filtered;
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 80,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No Products Available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No farmers have posted products yet. Check back later!',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(BlockchainProduct product) {
    return Card(
      color: AppColors.background,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Category: ${product.category}',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.distributorPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.qr_code,
                    color: AppColors.distributorPrimary,
                    size: 24,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildInfoItem(
                  'Quantity',
                  '${product.quantity} ${product.unit}',
                ),
                const SizedBox(width: 20),
                _buildInfoItem(
                  'Price',
                  '₹${product.pricePerUnit}/${product.unit}',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildInfoItem('Farmer', product.farmerName),
                const SizedBox(width: 20),
                _buildInfoItem(
                  'Posted',
                  '${product.postedAt.day}/${product.postedAt.month}/${product.postedAt.year}',
                ),
              ],
            ),
            if (product.qualityCertifications.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: product.qualityCertifications
                    .map(
                      (cert) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          cert,
                          style: TextStyle(
                            color: AppColors.success,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _rejectProduct(product),
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Decline'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: BorderSide(color: AppColors.error),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _acceptProduct(product),
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Accept'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.distributorPrimary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  void _acceptProduct(BlockchainProduct product) async {
    try {
      // Generate distributor details (in real app, this would come from logged in user)
      final distributorId = 'dist_${DateTime.now().millisecondsSinceEpoch}';
      final distributorName =
          'AgriChain Distributor'; // Replace with actual distributor name
      final distributorWallet = 'wallet_${distributorId}';

      // Update product with distributor details and enhanced QR code
      await ProductStorageService.updateProductWithDistributor(
        productId: product.productId,
        distributorId: distributorId,
        distributorName: distributorName,
        distributorWallet: distributorWallet,
      );

      // Start delivery tracking
      await ProductStorageService.startDeliveryTracking(
        productId: product.productId,
        distributorId: distributorId,
        distributorName: distributorName,
        distributorWallet: distributorWallet,
        farmerName: product.farmerName,
        farmerWallet: product.farmerWallet,
      );

      // Create a transaction for distributor acceptance
      final acceptTransaction = BlockchainTransaction(
        txHash: 'accept_${DateTime.now().millisecondsSinceEpoch}',
        type: 'product_accepted',
        productId: product.productId,
        fromWallet: distributorWallet,
        toWallet: product.farmerWallet,
        amount: null, // No money transfer yet
        timestamp: DateTime.now(),
        status: 'confirmed',
        transactionData: {
          'productName': product.name,
          'distributorId': distributorId,
          'distributorName': distributorName,
          'distributorAction': 'accepted',
          'description': 'Product accepted by distributor and tracking started',
          'deliveryStarted': true,
        },
      );

      await ProductStorageService.saveTransaction(acceptTransaction);

      // Refresh the list
      _loadAvailableProducts();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Product "${product.name}" accepted! QR updated & delivery tracking started.',
          ),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error accepting product: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _rejectProduct(BlockchainProduct product) async {
    try {
      // Update product status to declined
      await ProductStorageService.updateProductStatus(
        product.productId,
        'declined',
      );

      // Create a transaction for distributor rejection
      final rejectTransaction = BlockchainTransaction(
        txHash: 'reject_${DateTime.now().millisecondsSinceEpoch}',
        type: 'product_rejected',
        productId: product.productId,
        fromWallet:
            'dist_${DateTime.now().millisecondsSinceEpoch}', // Distributor wallet
        toWallet: product.farmerWallet,
        amount: null,
        timestamp: DateTime.now(),
        status: 'confirmed',
        transactionData: {
          'productName': product.name,
          'distributorAction': 'rejected',
          'description': 'Product declined by distributor',
        },
      );

      await ProductStorageService.saveTransaction(rejectTransaction);

      // Refresh the list
      _loadAvailableProducts();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Product "${product.name}" declined.'),
          backgroundColor: AppColors.warning,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error declining product: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Widget _buildFilterChip(String label) {
    bool isSelected = _selectedFilter == label;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = label;
        });
      },
      backgroundColor: Colors.white,
      selectedColor: AppColors.distributorPrimary.withOpacity(0.2),
      labelStyle: TextStyle(
        color: isSelected
            ? AppColors.distributorPrimary
            : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected
            ? AppColors.distributorPrimary
            : AppColors.textSecondary.withOpacity(0.3),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Products'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('All Products'),
              leading: Radio<String>(
                value: 'All',
                groupValue: _selectedFilter,
                onChanged: (value) {
                  setState(() {
                    _selectedFilter = value!;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('Nearby'),
              leading: Radio<String>(
                value: 'Nearby',
                groupValue: _selectedFilter,
                onChanged: (value) {
                  setState(() {
                    _selectedFilter = value!;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('High Quality'),
              leading: Radio<String>(
                value: 'High Quality',
                groupValue: _selectedFilter,
                onChanged: (value) {
                  setState(() {
                    _selectedFilter = value!;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('Organic'),
              leading: Radio<String>(
                value: 'Organic',
                groupValue: _selectedFilter,
                onChanged: (value) {
                  setState(() {
                    _selectedFilter = value!;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sort Products'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('By Date'),
              leading: Radio<String>(
                value: 'Distance',
                groupValue: _selectedSort,
                onChanged: (value) {
                  setState(() {
                    _selectedSort = value!;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('By Price'),
              leading: Radio<String>(
                value: 'Price',
                groupValue: _selectedSort,
                onChanged: (value) {
                  setState(() {
                    _selectedSort = value!;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('By Quantity'),
              leading: Radio<String>(
                value: 'Quantity',
                groupValue: _selectedSort,
                onChanged: (value) {
                  setState(() {
                    _selectedSort = value!;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
