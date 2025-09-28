import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class PriceComparisonScreen extends StatefulWidget {
  const PriceComparisonScreen({super.key});

  @override
  State<PriceComparisonScreen> createState() => _PriceComparisonScreenState();
}

class _PriceComparisonScreenState extends State<PriceComparisonScreen> {
  String _selectedLocation = 'Mumbai';
  String _sortBy = 'Price: Low to High';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.consumerPrimary,
        foregroundColor: Colors.white,
        title: const Text('Price Comparison'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filters Section
          Container(
            color: AppColors.consumerPrimary,
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedLocation,
                        onChanged: (value) => setState(() => _selectedLocation = value!),
                        dropdownColor: Colors.white,
                        style: const TextStyle(color: Colors.white),
                        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                        items: ['Mumbai', 'Delhi', 'Bangalore', 'Chennai', 'Kolkata']
                            .map((location) => DropdownMenuItem(
                                  value: location,
                                  child: Row(
                                    children: [
                                      const Icon(Icons.location_on, color: Colors.black, size: 16),
                                      const SizedBox(width: 8),
                                      Text(location, style: const TextStyle(color: Colors.black)),
                                    ],
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _sortBy,
                        onChanged: (value) => setState(() => _sortBy = value!),
                        dropdownColor: Colors.white,
                        style: const TextStyle(color: Colors.white),
                        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                        items: ['Price: Low to High', 'Price: High to Low', 'Distance', 'Rating']
                            .map((sort) => DropdownMenuItem(
                                  value: sort,
                                  child: Text(sort, style: const TextStyle(color: Colors.black)),
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Best Deals Banner
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.success, AppColors.success.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.local_offer, color: Colors.white, size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Best Deals in $_selectedLocation',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Compare prices from multiple sellers',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Products List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _getComparisonData().length,
              itemBuilder: (context, index) {
                final productData = _getComparisonData()[index];
                return _buildComparisonCard(productData);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonCard(Map<String, dynamic> productData) {
    final product = productData['product'];
    final sellers = productData['sellers'] as List<Map<String, dynamic>>;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      product['image'],
                      style: const TextStyle(fontSize: 30),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product['name'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.consumerPrimary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          product['category'],
                          style: TextStyle(
                            color: AppColors.consumerPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Best Price Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'From ₹${sellers.first['price'].toInt()}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Sellers List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sellers.length,
            separatorBuilder: (context, index) => const Divider(height: 1, indent: 16, endIndent: 16),
            itemBuilder: (context, index) {
              final seller = sellers[index];
              final isLowestPrice = index == 0;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    // Seller Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                seller['name'],
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (seller['verified'])
                                Icon(
                                  Icons.verified,
                                  color: AppColors.success,
                                  size: 16,
                                ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: AppColors.textSecondary,
                                size: 12,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '${seller['distance']}km away',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Icon(
                                Icons.star,
                                color: AppColors.warning,
                                size: 12,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '${seller['rating']}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Price and Actions
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '₹${seller['price'].toInt()}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isLowestPrice ? AppColors.success : AppColors.consumerPrimary,
                              ),
                            ),
                            if (seller['originalPrice'] != null) ...[
                              const SizedBox(width: 8),
                              Text(
                                '₹${seller['originalPrice'].toInt()}',
                                style: TextStyle(
                                  fontSize: 12,
                                  decoration: TextDecoration.lineThrough,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                            if (isLowestPrice)
                              Container(
                                margin: const EdgeInsets.only(left: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.success,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'LOWEST',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            OutlinedButton(
                              onPressed: () => _viewSellerProfile(seller),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: AppColors.consumerPrimary),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                minimumSize: const Size(60, 28),
                              ),
                              child: Text(
                                'View',
                                style: TextStyle(
                                  color: AppColors.consumerPrimary,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () => _addToCart(product, seller),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.consumerPrimary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                minimumSize: const Size(60, 28),
                              ),
                              child: const Text(
                                'Add',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getComparisonData() {
    return [
      {
        'product': {
          'id': '1',
          'name': 'Alphonso Mango',
          'category': 'Fruits',
          'image': '🥭',
        },
        'sellers': [
          {
            'name': 'Fresh Fruits Co.',
            'price': 420.0,
            'originalPrice': 480.0,
            'distance': 2.1,
            'rating': 4.8,
            'verified': true,
          },
          {
            'name': 'Mango Mart',
            'price': 450.0,
            'originalPrice': 520.0,
            'distance': 3.5,
            'rating': 4.6,
            'verified': true,
          },
          {
            'name': 'Local Farm Shop',
            'price': 480.0,
            'originalPrice': null,
            'distance': 1.8,
            'rating': 4.3,
            'verified': false,
          },
        ],
      },
      {
        'product': {
          'id': '2',
          'name': 'Red Onion',
          'category': 'Vegetables',
          'image': '🧅',
        },
        'sellers': [
          {
            'name': 'Veggie World',
            'price': 22.0,
            'originalPrice': 28.0,
            'distance': 1.5,
            'rating': 4.5,
            'verified': true,
          },
          {
            'name': 'Local Farm Fresh',
            'price': 25.0,
            'originalPrice': 30.0,
            'distance': 2.3,
            'rating': 4.3,
            'verified': true,
          },
          {
            'name': 'Green Grocers',
            'price': 27.0,
            'originalPrice': null,
            'distance': 4.1,
            'rating': 4.7,
            'verified': true,
          },
        ],
      },
    ];
  }

  void _viewSellerProfile(Map<String, dynamic> seller) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.consumerPrimary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.store,
                    color: AppColors.consumerPrimary,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            seller['name'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (seller['verified'])
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Icon(
                                Icons.verified,
                                color: AppColors.success,
                                size: 20,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: AppColors.warning,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${seller['rating']} rating',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Visiting ${seller['name']} store...')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.consumerPrimary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Visit Store'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _addToCart(Map<String, dynamic> product, Map<String, dynamic> seller) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${product['name']} from ${seller['name']} added to cart!',
        ),
        action: SnackBarAction(
          label: 'View Cart',
          onPressed: () {
            // Navigate to cart
          },
        ),
      ),
    );
  }
}