import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class SupplierManagementScreen extends StatefulWidget {
  const SupplierManagementScreen({super.key});

  @override
  State<SupplierManagementScreen> createState() => _SupplierManagementScreenState();
}

class _SupplierManagementScreenState extends State<SupplierManagementScreen> {
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Supplier Management'),
        backgroundColor: AppColors.retailerPrimary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => _addNewSupplier(context),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary Cards
          Container(
            margin: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(child: _buildSummaryCard('Total Suppliers', '24', AppColors.info)),
                const SizedBox(width: 12),
                Expanded(child: _buildSummaryCard('Active', '22', AppColors.success)),
                const SizedBox(width: 12),
                Expanded(child: _buildSummaryCard('Pending Orders', '7', AppColors.warning)),
              ],
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

          // Suppliers List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _getFilteredSuppliers().length,
              itemBuilder: (context, index) {
                final supplier = _getFilteredSuppliers()[index];
                return _buildSupplierCard(context, supplier);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color) {
    return Container(
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
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
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
          color: isSelected ? AppColors.retailerPrimary : AppColors.textSecondary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildSupplierCard(BuildContext context, Map<String, dynamic> supplier) {
    Color statusColor = _getStatusColor(supplier['status']);
    
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
              CircleAvatar(
                backgroundColor: AppColors.retailerPrimary.withOpacity(0.1),
                child: Text(
                  supplier['name'][0],
                  style: TextStyle(
                    color: AppColors.retailerPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      supplier['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      supplier['category'],
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      supplier['location'],
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  supplier['status'],
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildInfoChip('Rating', '${supplier['rating']}★', AppColors.warning),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildInfoChip('Orders', '${supplier['totalOrders']}', AppColors.info),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildInfoChip('Avg Price', '₹${supplier['avgPrice']}', AppColors.success),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Products Supplied
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 4,
              runSpacing: 4,
              children: (supplier['products'] as List<String>).map((product) => 
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.retailerPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    product,
                    style: TextStyle(
                      color: AppColors.retailerPrimary,
                      fontSize: 9,
                    ),
                  ),
                ),
              ).toList(),
            ),
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _contactSupplier(context, supplier),
                  icon: const Icon(Icons.phone, size: 16),
                  label: const Text('Contact'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _placeOrder(context, supplier),
                  icon: const Icon(Icons.shopping_cart, size: 16),
                  label: const Text('Place Order'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.retailerPrimary,
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

  Widget _buildInfoChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      case 'inactive':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  List<Map<String, dynamic>> _getFilteredSuppliers() {
    if (_selectedCategory == 'All') {
      return _suppliers;
    }
    return _suppliers.where((supplier) => supplier['category'] == _selectedCategory).toList();
  }

  void _addNewSupplier(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Supplier'),
        content: const Text('Supplier registration feature will be available soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _contactSupplier(BuildContext context, Map<String, dynamic> supplier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Contact ${supplier['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Phone: ${supplier['phone']}'),
            Text('Email: ${supplier['email']}'),
            Text('Address: ${supplier['location']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Calling ${supplier['name']}...')),
              );
            },
            child: const Text('Call Now'),
          ),
        ],
      ),
    );
  }

  void _placeOrder(BuildContext context, Map<String, dynamic> supplier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Place Order - ${supplier['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Available Products: ${supplier['products'].join(', ')}'),
            const SizedBox(height: 16),
            const Text('Order placement feature will be available soon!'),
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
                const SnackBar(content: Text('Order placement coming soon!')),
              );
            },
            child: const Text('Place Order'),
          ),
        ],
      ),
    );
  }

  static final List<Map<String, dynamic>> _suppliers = [
    {
      'name': 'Ratnagiri Farms',
      'category': 'Fruits',
      'location': 'Ratnagiri, Maharashtra',
      'status': 'Active',
      'rating': 4.8,
      'totalOrders': 45,
      'avgPrice': 420,
      'phone': '+91 9876543210',
      'email': 'contact@ratnagirifarms.com',
      'products': ['Alphonso Mango', 'Cashew', 'Coconut'],
    },
    {
      'name': 'Punjab Mills',
      'category': 'Grains',
      'location': 'Ludhiana, Punjab',
      'status': 'Active',
      'rating': 4.6,
      'totalOrders': 67,
      'avgPrice': 75,
      'phone': '+91 9876543211',
      'email': 'orders@punjabmills.com',
      'products': ['Basmati Rice', 'Wheat', 'Corn'],
    },
    {
      'name': 'Local Farmers Coop',
      'category': 'Vegetables',
      'location': 'Nashik, Maharashtra',
      'status': 'Active',
      'rating': 4.3,
      'totalOrders': 89,
      'avgPrice': 28,
      'phone': '+91 9876543212',
      'email': 'coop@localfarmers.com',
      'products': ['Onion', 'Tomato', 'Potato', 'Cabbage'],
    },
    {
      'name': 'Amul Dairy',
      'category': 'Dairy',
      'location': 'Anand, Gujarat',
      'status': 'Active',
      'rating': 4.9,
      'totalOrders': 123,
      'avgPrice': 48,
      'phone': '+91 9876543213',
      'email': 'retail@amul.com',
      'products': ['Milk', 'Butter', 'Cheese', 'Paneer'],
    },
    {
      'name': 'Kerala Spices Co',
      'category': 'Spices',
      'location': 'Kochi, Kerala',
      'status': 'Active',
      'rating': 4.7,
      'totalOrders': 34,
      'avgPrice': 245,
      'phone': '+91 9876543214',
      'email': 'sales@keralaspices.com',
      'products': ['Turmeric', 'Cardamom', 'Pepper', 'Cinnamon'],
    },
    {
      'name': 'Kashmir Orchards',
      'category': 'Fruits',
      'location': 'Srinagar, Kashmir',
      'status': 'Pending',
      'rating': 4.5,
      'totalOrders': 12,
      'avgPrice': 165,
      'phone': '+91 9876543215',
      'email': 'info@kashmirorchards.com',
      'products': ['Apple', 'Pear', 'Cherry', 'Walnut'],
    },
  ];
}