import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class InventoryManagementScreen extends StatefulWidget {
  const InventoryManagementScreen({super.key});

  @override
  State<InventoryManagementScreen> createState() =>
      _InventoryManagementScreenState();
}

class _InventoryManagementScreenState extends State<InventoryManagementScreen> {
  String _selectedCategory = 'All';
  String _selectedSort = 'Name A-Z';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Inventory Management'),
        backgroundColor: AppColors.distributorPrimary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => _showAddProductDialog(context),
            icon: const Icon(Icons.add),
          ),
          IconButton(
            onPressed: () => _showFilterOptions(context),
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: Column(
        children: [
          // Inventory Summary
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.distributorPrimary,
                  AppColors.distributorPrimary.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.distributorPrimary.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    'Total Items',
                    '143',
                    Icons.inventory,
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.white.withOpacity(0.3),
                ),
                Expanded(
                  child: _buildSummaryItem('Low Stock', '7', Icons.warning),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.white.withOpacity(0.3),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    'Value',
                    '₹2.4L',
                    Icons.currency_rupee,
                  ),
                ),
              ],
            ),
          ),

          // Quick Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildQuickAction(
                    'Stock Alert',
                    Icons.notifications,
                    AppColors.warning,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickAction(
                    'Generate Report',
                    Icons.description,
                    AppColors.info,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickAction(
                    'Forecast',
                    Icons.trending_up,
                    AppColors.success,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Category Filter
          Container(
            height: 40,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildCategoryChip('All'),
                _buildCategoryChip('Fruits'),
                _buildCategoryChip('Vegetables'),
                _buildCategoryChip('Grains'),
                _buildCategoryChip('Dairy'),
                _buildCategoryChip('Spices'),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Inventory List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _getFilteredInventory().length,
              itemBuilder: (context, index) {
                final item = _getFilteredInventory()[index];
                return _buildInventoryItem(context, item);
              },
            ),
          ),
        ],
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
            fontSize: 20,
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

  Widget _buildQuickAction(String title, IconData icon, Color color) {
    return GestureDetector(
      onTap: () => _handleQuickAction(title),
      child: Container(
        padding: const EdgeInsets.all(12),
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
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 10),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    bool isSelected = _selectedCategory == category;
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(category),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = category;
          });
        },
        selectedColor: AppColors.distributorPrimary.withOpacity(0.2),
        checkmarkColor: AppColors.distributorPrimary,
        labelStyle: TextStyle(
          color: isSelected
              ? AppColors.distributorPrimary
              : AppColors.textSecondary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildInventoryItem(BuildContext context, Map<String, dynamic> item) {
    Color stockColor = _getStockColor(item['stock'], item['minStock']);

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
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.distributorPrimary.withOpacity(0.1),
                      AppColors.distributorPrimary.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getCategoryIcon(item['category']),
                  color: AppColors.distributorPrimary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['name'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      item['variety'] ?? '',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          '₹${item['price']}/kg',
                          style: TextStyle(
                            color: AppColors.distributorPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '• ${item['supplier']}',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: stockColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${item['stock']} kg',
                      style: TextStyle(
                        color: stockColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Min: ${item['minStock']} kg',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textSecondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor:
                        (item['stock'] /
                                (item['maxStock'] ?? item['stock'] * 2))
                            .clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: stockColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Last Updated: ${item['lastUpdated']}',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _editStock(context, item),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit Stock'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _reorderStock(context, item),
                  icon: const Icon(Icons.shopping_cart, size: 16),
                  label: const Text('Reorder'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.distributorPrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStockColor(int stock, int minStock) {
    if (stock <= minStock) return AppColors.error;
    if (stock <= minStock * 1.5) return AppColors.warning;
    return AppColors.success;
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'fruits':
        return Icons.local_grocery_store;
      case 'vegetables':
        return Icons.eco;
      case 'grains':
        return Icons.grain;
      case 'dairy':
        return Icons.local_drink;
      case 'spices':
        return Icons.spa;
      default:
        return Icons.inventory;
    }
  }

  List<Map<String, dynamic>> _getFilteredInventory() {
    List<Map<String, dynamic>> filtered = _selectedCategory == 'All'
        ? List.from(_inventoryItems)
        : _inventoryItems
              .where((item) => item['category'] == _selectedCategory)
              .toList();

    // Apply sorting
    filtered.sort((a, b) {
      switch (_selectedSort) {
        case 'Name A-Z':
          return a['name'].compareTo(b['name']);
        case 'Name Z-A':
          return b['name'].compareTo(a['name']);
        case 'Stock Low-High':
          return a['stock'].compareTo(b['stock']);
        case 'Stock High-Low':
          return b['stock'].compareTo(a['stock']);
        case 'Price Low-High':
          return a['price'].compareTo(b['price']);
        case 'Price High-Low':
          return b['price'].compareTo(a['price']);
        default:
          return 0;
      }
    });

    return filtered;
  }

  void _showFilterOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Sort & Filter',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Sort By:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children:
                  [
                        'Name A-Z',
                        'Name Z-A',
                        'Stock Low-High',
                        'Stock High-Low',
                        'Price Low-High',
                        'Price High-Low',
                      ]
                      .map(
                        (sort) => FilterChip(
                          label: Text(sort),
                          selected: _selectedSort == sort,
                          onSelected: (selected) {
                            setState(() {
                              _selectedSort = sort;
                            });
                            Navigator.pop(context);
                          },
                        ),
                      )
                      .toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddProductDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Product'),
        content: const Text('Product addition feature will be available soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _handleQuickAction(String action) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$action feature coming soon!')));
  }

  void _editStock(BuildContext context, Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Stock - ${item['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Current Stock: ${item['stock']} kg'),
            const SizedBox(height: 8),
            Text('Minimum Stock: ${item['minStock']} kg'),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'New Stock Quantity (kg)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Stock updated successfully!')),
              );
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _reorderStock(BuildContext context, Map<String, dynamic> item) {
    int suggestedQuantity = (item['minStock'] * 3) - item['stock'];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reorder - ${item['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Supplier: ${item['supplier']}'),
            Text('Current Stock: ${item['stock']} kg'),
            Text('Minimum Required: ${item['minStock']} kg'),
            const SizedBox(height: 16),
            Text('Suggested Quantity: $suggestedQuantity kg'),
            Text(
              'Estimated Cost: ₹${(suggestedQuantity * item['price']).toStringAsFixed(0)}',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Reorder request sent to supplier!'),
                ),
              );
            },
            child: const Text('Send Reorder'),
          ),
        ],
      ),
    );
  }

  static final List<Map<String, dynamic>> _inventoryItems = [
    {
      'name': 'Alphonso Mango',
      'variety': 'Premium Grade A',
      'category': 'Fruits',
      'stock': 45,
      'minStock': 50,
      'maxStock': 200,
      'price': 450.0,
      'supplier': 'Ratnagiri Farms',
      'lastUpdated': '2 hours ago',
    },
    {
      'name': 'Basmati Rice',
      'variety': '1121 Golden Sella',
      'category': 'Grains',
      'stock': 120,
      'minStock': 100,
      'maxStock': 500,
      'price': 85.0,
      'supplier': 'Punjab Mills',
      'lastUpdated': '4 hours ago',
    },
    {
      'name': 'Red Onion',
      'variety': 'Nashik Special',
      'category': 'Vegetables',
      'stock': 15,
      'minStock': 25,
      'maxStock': 150,
      'price': 25.0,
      'supplier': 'Local Farmers',
      'lastUpdated': '1 hour ago',
    },
    {
      'name': 'Fresh Milk',
      'variety': 'Toned Milk',
      'category': 'Dairy',
      'stock': 80,
      'minStock': 60,
      'maxStock': 300,
      'price': 52.0,
      'supplier': 'Amul Dairy',
      'lastUpdated': '30 mins ago',
    },
    {
      'name': 'Turmeric Powder',
      'variety': 'Organic Curcumin',
      'category': 'Spices',
      'stock': 25,
      'minStock': 20,
      'maxStock': 100,
      'price': 280.0,
      'supplier': 'Kerala Spices',
      'lastUpdated': '6 hours ago',
    },
    {
      'name': 'Green Peas',
      'variety': 'Fresh Podded',
      'category': 'Vegetables',
      'stock': 35,
      'minStock': 30,
      'maxStock': 120,
      'price': 65.0,
      'supplier': 'Valley Fresh',
      'lastUpdated': '3 hours ago',
    },
  ];
}
