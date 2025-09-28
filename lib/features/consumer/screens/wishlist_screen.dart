import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'product_details_screen.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  List<Map<String, dynamic>> _wishlistItems = [
    {
      'id': '1',
      'name': 'Alphonso Mango',
      'category': 'Fruits',
      'price': 450.0,
      'originalPrice': 520.0,
      'image': '🥭',
      'rating': 4.8,
      'reviews': 234,
      'discount': 15,
      'inStock': true,
      'seller': 'Fresh Fruits Co.',
      'description': 'Premium quality Alphonso mangoes from Ratnagiri',
      'origin': 'Ratnagiri, Maharashtra',
      'organic': true,
      'addedDate': '2024-01-15',
    },
    {
      'id': '2',
      'name': 'Green Apple',
      'category': 'Fruits',
      'price': 180.0,
      'originalPrice': 200.0,
      'image': '🍏',
      'rating': 4.5,
      'reviews': 123,
      'discount': 10,
      'inStock': true,
      'seller': 'Mountain Fresh',
      'description': 'Crispy green apples from Kashmir',
      'origin': 'Kashmir, India',
      'organic': true,
      'addedDate': '2024-01-14',
    },
    {
      'id': '3',
      'name': 'Turmeric Powder',
      'category': 'Spices',
      'price': 280.0,
      'originalPrice': 320.0,
      'image': '🟡',
      'rating': 4.7,
      'reviews': 78,
      'discount': 13,
      'inStock': false,
      'seller': 'Spice World',
      'description': 'Pure turmeric powder with high curcumin',
      'origin': 'Kerala, India',
      'organic': true,
      'addedDate': '2024-01-12',
    },
  ];

  String _sortBy = 'Recently Added';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.consumerPrimary,
        foregroundColor: Colors.white,
        title: const Text('My Wishlist'),
        elevation: 0,
        actions: [
          if (_wishlistItems.isNotEmpty) ...[
            PopupMenuButton<String>(
              onSelected: (value) => setState(() => _sortBy = value),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'Recently Added',
                  child: Text('Recently Added'),
                ),
                const PopupMenuItem(
                  value: 'Price: Low to High',
                  child: Text('Price: Low to High'),
                ),
                const PopupMenuItem(
                  value: 'Price: High to Low',
                  child: Text('Price: High to Low'),
                ),
                const PopupMenuItem(
                  value: 'Name A-Z',
                  child: Text('Name A-Z'),
                ),
              ],
            ),
            TextButton(
              onPressed: _showClearWishlistDialog,
              child: const Text(
                'Clear All',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ],
      ),
      body: _wishlistItems.isEmpty ? _buildEmptyWishlist() : _buildWishlistContent(),
      bottomNavigationBar: _wishlistItems.isNotEmpty ? _buildAddAllToCartButton() : null,
    );
  }

  Widget _buildEmptyWishlist() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.consumerPrimary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.favorite_border,
              size: 60,
              color: AppColors.consumerPrimary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Your wishlist is empty',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Save items you love for later!',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.consumerPrimary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Start Shopping'),
          ),
        ],
      ),
    );
  }

  Widget _buildWishlistContent() {
    final sortedItems = _getSortedItems();

    return Column(
      children: [
        // Sort info
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_wishlistItems.length} items in wishlist',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              Text(
                'Sorted by: $_sortBy',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),

        // Wishlist Items
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: sortedItems.length,
            itemBuilder: (context, index) => _buildWishlistItem(sortedItems[index], index),
          ),
        ),
      ],
    );
  }

  Widget _buildWishlistItem(Map<String, dynamic> item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailsScreen(product: item),
          ),
        ),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Product Image
              Stack(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        item['image'],
                        style: const TextStyle(fontSize: 32),
                      ),
                    ),
                  ),
                  if (item['discount'] != null && item['discount'] > 0)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${item['discount']}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(width: 16),

              // Product Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item['name'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          onPressed: () => _removeFromWishlist(index),
                          icon: Icon(
                            Icons.favorite,
                            color: AppColors.error,
                            size: 20,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.consumerPrimary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            item['category'],
                            style: TextStyle(
                              color: AppColors.consumerPrimary,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (item['organic'] == true) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'ORGANIC',
                              style: TextStyle(
                                color: AppColors.success,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: AppColors.warning,
                          size: 14,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${item['rating']} (${item['reviews']})',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  '₹${item['price'].toInt()}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.consumerPrimary,
                                  ),
                                ),
                                if (item['originalPrice'] != null &&
                                    item['originalPrice'] > item['price'])
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8),
                                    child: Text(
                                      '₹${item['originalPrice'].toInt()}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        decoration: TextDecoration.lineThrough,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            Text(
                              'Added ${item['addedDate']}',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            SizedBox(
                              width: 100,
                              height: 32,
                              child: ElevatedButton(
                                onPressed: item['inStock'] ? () => _addToCart(item) : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: item['inStock']
                                      ? AppColors.consumerPrimary
                                      : AppColors.textSecondary,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  padding: EdgeInsets.zero,
                                ),
                                child: Text(
                                  item['inStock'] ? 'Add to Cart' : 'Out of Stock',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            if (!item['inStock'])
                              TextButton(
                                onPressed: () => _notifyWhenAvailable(item),
                                style: TextButton.styleFrom(
                                  minimumSize: const Size(0, 20),
                                  padding: EdgeInsets.zero,
                                ),
                                child: Text(
                                  'Notify Me',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppColors.consumerPrimary,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddAllToCartButton() {
    final inStockItems = _wishlistItems.where((item) => item['inStock']).length;
    
    if (inStockItems == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: _addAllToCart,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.consumerPrimary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            'Add All to Cart ($inStockItems items)',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getSortedItems() {
    final items = List<Map<String, dynamic>>.from(_wishlistItems);
    
    switch (_sortBy) {
      case 'Price: Low to High':
        items.sort((a, b) => a['price'].compareTo(b['price']));
        break;
      case 'Price: High to Low':
        items.sort((a, b) => b['price'].compareTo(a['price']));
        break;
      case 'Name A-Z':
        items.sort((a, b) => a['name'].compareTo(b['name']));
        break;
      case 'Recently Added':
      default:
        items.sort((a, b) => b['addedDate'].compareTo(a['addedDate']));
        break;
    }
    
    return items;
  }

  void _removeFromWishlist(int index) {
    final item = _wishlistItems[index];
    setState(() {
      _wishlistItems.removeAt(index);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item['name']} removed from wishlist'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              _wishlistItems.insert(index, item);
            });
          },
        ),
      ),
    );
  }

  void _addToCart(Map<String, dynamic> item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item['name']} added to cart!'),
        action: SnackBarAction(
          label: 'View Cart',
          onPressed: () {
            // Navigate to cart
          },
        ),
      ),
    );
  }

  void _addAllToCart() {
    final inStockItems = _wishlistItems.where((item) => item['inStock']).toList();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${inStockItems.length} items added to cart!'),
        action: SnackBarAction(
          label: 'View Cart',
          onPressed: () {
            // Navigate to cart
          },
        ),
      ),
    );
  }

  void _notifyWhenAvailable(Map<String, dynamic> item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('We\'ll notify you when ${item['name']} is back in stock!'),
      ),
    );
  }

  void _showClearWishlistDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Wishlist'),
        content: const Text('Are you sure you want to remove all items from your wishlist?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() => _wishlistItems.clear());
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Wishlist cleared')),
              );
            },
            child: Text(
              'Clear',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}