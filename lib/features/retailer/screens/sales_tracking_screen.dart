import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class SalesTrackingScreen extends StatefulWidget {
  const SalesTrackingScreen({super.key});

  @override
  State<SalesTrackingScreen> createState() => _SalesTrackingScreenState();
}

class _SalesTrackingScreenState extends State<SalesTrackingScreen> {
  String _selectedPeriod = 'Today';
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Sales Tracking'),
        backgroundColor: AppColors.retailerPrimary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => _addManualSale(context),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period Selector
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedPeriod,
                    decoration: const InputDecoration(
                      labelText: 'Period',
                      border: OutlineInputBorder(),
                    ),
                    items: ['Today', 'This Week', 'This Month', 'This Year']
                        .map(
                          (period) => DropdownMenuItem(
                            value: period,
                            child: Text(period),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedPeriod = value!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    items:
                        [
                              'All',
                              'Fruits',
                              'Vegetables',
                              'Grains',
                              'Dairy',
                              'Spices',
                            ]
                            .map(
                              (category) => DropdownMenuItem(
                                value: category,
                                child: Text(category),
                              ),
                            )
                            .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedCategory = value!),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Sales Summary
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.retailerPrimary,
                    AppColors.retailerPrimary.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.retailerPrimary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildSummaryItem(
                      'Sales',
                      '₹12,450',
                      Icons.currency_rupee,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  Expanded(
                    child: _buildSummaryItem(
                      'Transactions',
                      '89',
                      Icons.receipt,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  Expanded(
                    child: _buildSummaryItem(
                      'Avg. Sale',
                      '₹140',
                      Icons.trending_up,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Sales Chart Placeholder
            Container(
              height: 200,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sales Trend',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.retailerPrimary.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.show_chart, size: 48),
                            SizedBox(height: 8),
                            Text('Sales trend chart'),
                            Text('will be displayed here'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Top Selling Products
            Text(
              'Top Selling Products',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 16),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: _topProducts
                    .map((product) => _buildProductSalesItem(product))
                    .toList(),
              ),
            ),

            const SizedBox(height: 24),

            // Recent Sales
            Text(
              'Recent Sales',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 16),

            ..._recentSales.map((sale) => _buildSaleCard(sale)),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildProductSalesItem(Map<String, dynamic> product) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.textSecondary.withOpacity(0.1)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.retailerPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                product['emoji'],
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name'],
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  '${product['quantity']} kg sold',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${product['revenue']}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.retailerPrimary,
                ),
              ),
              Text(
                '${product['growth']}% ↑',
                style: TextStyle(color: AppColors.success, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSaleCard(Map<String, dynamic> sale) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.retailerPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.receipt,
              color: AppColors.retailerPrimary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sale #${sale['id']}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  '${sale['items']} items • ${sale['time']}',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${sale['amount']}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.retailerPrimary,
                ),
              ),
              Text(
                sale['method'],
                style: TextStyle(color: AppColors.textSecondary, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _addManualSale(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Manual Sale'),
        content: const Text(
          'Manual sale entry feature will be available soon!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  static final List<Map<String, dynamic>> _topProducts = [
    {
      'name': 'Red Onion',
      'emoji': '🧅',
      'quantity': 45,
      'revenue': '1,125',
      'growth': 18,
    },
    {
      'name': 'Tomato',
      'emoji': '🍅',
      'quantity': 38,
      'revenue': '1,330',
      'growth': 12,
    },
    {
      'name': 'Alphonso Mango',
      'emoji': '🥭',
      'quantity': 25,
      'revenue': '11,250',
      'growth': 35,
    },
    {
      'name': 'Basmati Rice',
      'emoji': '🍚',
      'quantity': 67,
      'revenue': '5,695',
      'growth': 8,
    },
    {
      'name': 'Fresh Milk',
      'emoji': '🥛',
      'quantity': 89,
      'revenue': '4,628',
      'growth': 15,
    },
  ];

  static final List<Map<String, dynamic>> _recentSales = [
    {
      'id': '001',
      'items': 5,
      'amount': '1,245',
      'time': '2:30 PM',
      'method': 'Cash',
    },
    {
      'id': '002',
      'items': 3,
      'amount': '567',
      'time': '2:15 PM',
      'method': 'UPI',
    },
    {
      'id': '003',
      'items': 8,
      'amount': '2,134',
      'time': '1:45 PM',
      'method': 'Card',
    },
    {
      'id': '004',
      'items': 2,
      'amount': '389',
      'time': '1:20 PM',
      'method': 'Cash',
    },
    {
      'id': '005',
      'items': 6,
      'amount': '1,567',
      'time': '12:55 PM',
      'method': 'UPI',
    },
  ];
}
