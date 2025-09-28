import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/product_inventory_card.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Inventory Management'),
        backgroundColor: AppColors.retailerPrimary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => _addNewProduct(context),
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
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),

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

          // Inventory Stats
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.retailerPrimary,
                  AppColors.retailerPrimary.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatItem('Total', '247', Icons.inventory),
                ),
                Container(
                  width: 1,
                  height: 30,
                  color: Colors.white.withOpacity(0.3),
                ),
                Expanded(
                  child: _buildStatItem('Low Stock', '12', Icons.warning),
                ),
                Container(
                  width: 1,
                  height: 30,
                  color: Colors.white.withOpacity(0.3),
                ),
                Expanded(
                  child: _buildStatItem('Value', '₹4.2L', Icons.currency_rupee),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Products Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.0, // Increased further from 0.9 to prevent overflow
              ),
              itemCount: _getFilteredProducts().length,
              itemBuilder: (context, index) {
                final product = _getFilteredProducts()[index];
                return GestureDetector(
                  onTap: () => _showProductDetails(context, product),
                  child: ProductInventoryCard(
                    name: product['name'],
                    category: product['category'],
                    price: product['price'],
                    stock: product['stock'],
                    minStock: product['minStock'],
                    image: product['image'],
                  ),
                );
              },
            ),
          ),
        ],
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
        selectedColor: AppColors.retailerPrimary.withOpacity(0.2),
        checkmarkColor: AppColors.retailerPrimary,
        labelStyle: TextStyle(
          color: isSelected
              ? AppColors.retailerPrimary
              : AppColors.textSecondary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 11),
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _getFilteredProducts() {
    List<Map<String, dynamic>> filtered = _selectedCategory == 'All'
        ? List.from(_products)
        : _products
              .where((product) => product['category'] == _selectedCategory)
              .toList();

    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (product) =>
                product['name'].toLowerCase().contains(_searchQuery) ||
                product['category'].toLowerCase().contains(_searchQuery),
          )
          .toList();
    }

    return filtered;
  }

  void _addNewProduct(BuildContext context) {
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

  void _showFilterOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Filter & Sort Options',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.sort_by_alpha),
              title: const Text('Sort by Name'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.attach_money),
              title: const Text('Sort by Price'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.inventory),
              title: const Text('Sort by Stock'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.warning),
              title: const Text('Show Low Stock Only'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showProductDetails(BuildContext context, Map<String, dynamic> product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(product['name']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Category: ${product['category']}'),
            Text('Price: ₹${product['price']}/kg'),
            Text('Current Stock: ${product['stock']} kg'),
            Text('Minimum Stock: ${product['minStock']} kg'),
            Text('Supplier: ${product['supplier']}'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _editStock(context, product);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.retailerPrimary,
                    ),
                    child: const Text(
                      'Edit Stock',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _reorderProduct(context, product);
                    },
                    child: const Text('Reorder'),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _editStock(BuildContext context, Map<String, dynamic> product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Stock - ${product['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Current Stock: ${product['stock']} kg'),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'New Stock Quantity',
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

  void _reorderProduct(BuildContext context, Map<String, dynamic> product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reorder - ${product['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Supplier: ${product['supplier']}'),
            Text('Suggested Quantity: ${product['minStock'] * 2} kg'),
            Text(
              'Estimated Cost: ₹${(product['minStock'] * 2 * product['price']).toStringAsFixed(0)}',
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
                const SnackBar(content: Text('Reorder request sent!')),
              );
            },
            child: const Text('Send Order'),
          ),
        ],
      ),
    );
  }

  static final List<Map<String, dynamic>> _products = [
    {
      'name': 'Alphonso Mango',
      'category': 'Fruits',
      'price': 450.0,
      'stock': 25,
      'minStock': 10,
      'image': '🥭',
      'supplier': 'Ratnagiri Farms',
    },
    {
      'name': 'Basmati Rice',
      'category': 'Grains',
      'price': 85.0,
      'stock': 50,
      'minStock': 20,
      'image': '🍚',
      'supplier': 'Punjab Mills',
    },
    {
      'name': 'Red Onion',
      'category': 'Vegetables',
      'price': 25.0,
      'stock': 8,
      'minStock': 15,
      'image': '🧅',
      'supplier': 'Local Farmers',
    },
    {
      'name': 'Fresh Milk',
      'category': 'Dairy',
      'price': 52.0,
      'stock': 30,
      'minStock': 12,
      'image': '🥛',
      'supplier': 'Amul Dairy',
    },
    {
      'name': 'Turmeric Powder',
      'category': 'Spices',
      'price': 280.0,
      'stock': 15,
      'minStock': 8,
      'image': '🟡',
      'supplier': 'Kerala Spices',
    },
    {
      'name': 'Green Apple',
      'category': 'Fruits',
      'price': 180.0,
      'stock': 22,
      'minStock': 15,
      'image': '🍏',
      'supplier': 'Kashmir Orchards',
    },
    {
      'name': 'Tomato',
      'category': 'Vegetables',
      'price': 35.0,
      'stock': 40,
      'minStock': 25,
      'image': '🍅',
      'supplier': 'Nashik Farms',
    },
    {
      'name': 'Wheat Flour',
      'category': 'Grains',
      'price': 45.0,
      'stock': 35,
      'minStock': 20,
      'image': '🌾',
      'supplier': 'Madhya Pradesh Mills',
    },
  ];
}
