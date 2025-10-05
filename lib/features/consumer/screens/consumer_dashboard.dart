import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../../common/screens/landing_screen.dart';
import '../../common/screens/profile_screen.dart';
import '../../common/screens/settings_screen.dart';
import '../../common/screens/notifications_screen.dart';
import '../widgets/product_card.dart';
import '../widgets/category_chip.dart';
import '../../common/widgets/floating_chat_button.dart';
import 'product_details_screen.dart';
import 'shopping_cart_screen.dart';
import 'order_tracking_screen.dart';
import 'price_comparison_screen.dart';
import 'wishlist_screen.dart';
import 'search_screen.dart';

class ConsumerDashboard extends StatefulWidget {
  const ConsumerDashboard({super.key});

  @override
  State<ConsumerDashboard> createState() => _ConsumerDashboardState();
}

class _ConsumerDashboardState extends State<ConsumerDashboard> {
  int _currentIndex = 0;
  String _selectedCategory = 'All';
  final int _cartItemCount = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: [
              ConsumerHomeTab(
                selectedCategory: _selectedCategory,
                onCategoryChanged: (category) =>
                    setState(() => _selectedCategory = category),
              ),
              SearchScreen(),
              ShoppingCartScreen(),
              OrderTrackingScreen(),
            ],
          ),
          const FloatingChatButton(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.consumerPrimary,
        unselectedItemColor: AppColors.textSecondary,
        backgroundColor: Colors.white,
        elevation: 8,
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          const BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.shopping_cart),
                if (_cartItemCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$_cartItemCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Cart',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping),
            label: 'Orders',
          ),
        ],
      ),
      appBar: _currentIndex == 0 ? _buildAppBar() : null,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.consumerPrimary,
      foregroundColor: Colors.white,
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Good Morning!',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
          ),
          Text(
            'Shop Fresh Products',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const WishlistScreen()),
          ),
          icon: Stack(
            children: [
              const Icon(Icons.favorite_border),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => _showNotifications(context),
          icon: Stack(
            children: [
              const Icon(Icons.notifications),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
        PopupMenuButton<String>(
          onSelected: _handleMenuAction,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'profile',
              child: ListTile(
                leading: Icon(Icons.person),
                title: Text('Profile'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'settings',
              child: ListTile(
                leading: Icon(Icons.settings),
                title: Text('Settings'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: 'logout',
              child: ListTile(
                leading: Icon(Icons.logout, color: Colors.red),
                title: Text('Logout', style: TextStyle(color: Colors.red)),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showNotifications(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotificationsScreen()),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'profile':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        );
        break;
      case 'settings':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SettingsScreen()),
        );
        break;
      case 'logout':
        Provider.of<AuthProvider>(context, listen: false).logout();
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LandingScreen()),
          (route) => false,
        );
        break;
    }
  }
}

class ConsumerHomeTab extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onCategoryChanged;

  const ConsumerHomeTab({
    super.key,
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Promotional Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.consumerPrimary,
                  AppColors.consumerPrimary.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.consumerPrimary.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Fresh Deals!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Get up to 30% off on fresh fruits & vegetables',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PriceComparisonScreen(),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.consumerPrimary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        child: const Text('Shop Now'),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.local_offer, color: Colors.white, size: 64),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Quick Actions
          Row(
            children: [
              Expanded(
                child: _buildQuickAction(
                  'Price Compare',
                  Icons.compare_arrows,
                  AppColors.info,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickAction(
                  'Best Deals',
                  Icons.local_offer,
                  AppColors.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickAction(
                  'Fresh Today',
                  Icons.schedule,
                  AppColors.warning,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Categories
          Text(
            'Shop by Category',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 16),

          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                CategoryChip(
                  label: 'All',
                  isSelected: selectedCategory == 'All',
                  onTap: () => onCategoryChanged('All'),
                ),
                CategoryChip(
                  label: 'Fruits',
                  isSelected: selectedCategory == 'Fruits',
                  onTap: () => onCategoryChanged('Fruits'),
                ),
                CategoryChip(
                  label: 'Vegetables',
                  isSelected: selectedCategory == 'Vegetables',
                  onTap: () => onCategoryChanged('Vegetables'),
                ),
                CategoryChip(
                  label: 'Grains',
                  isSelected: selectedCategory == 'Grains',
                  onTap: () => onCategoryChanged('Grains'),
                ),
                CategoryChip(
                  label: 'Dairy',
                  isSelected: selectedCategory == 'Dairy',
                  onTap: () => onCategoryChanged('Dairy'),
                ),
                CategoryChip(
                  label: 'Spices',
                  isSelected: selectedCategory == 'Spices',
                  onTap: () => onCategoryChanged('Spices'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Featured Products
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Featured Products',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SearchScreen()),
                ),
                child: const Text('View All'),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Products Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio:
                  0.95, // Increased further from 0.85 to prevent overflow
            ),
            itemCount: _getFilteredProducts().length,
            itemBuilder: (context, index) {
              final product = _getFilteredProducts()[index];
              return ProductCard(
                product: product,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductDetailsScreen(product: product),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(String title, IconData icon, Color color) {
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredProducts() {
    if (selectedCategory == 'All') {
      return _products;
    }
    return _products
        .where((product) => product['category'] == selectedCategory)
        .toList();
  }

  static final List<Map<String, dynamic>> _products = [
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
    },
    {
      'id': '2',
      'name': 'Red Onion',
      'category': 'Vegetables',
      'price': 25.0,
      'originalPrice': 30.0,
      'image': '🧅',
      'rating': 4.3,
      'reviews': 156,
      'discount': 17,
      'inStock': true,
      'seller': 'Local Farm Fresh',
      'description': 'Fresh red onions, perfect for cooking',
      'origin': 'Nashik, Maharashtra',
      'organic': false,
    },
    {
      'id': '3',
      'name': 'Basmati Rice',
      'category': 'Grains',
      'price': 85.0,
      'originalPrice': 95.0,
      'image': '🍚',
      'rating': 4.6,
      'reviews': 89,
      'discount': 11,
      'inStock': true,
      'seller': 'Punjab Grains',
      'description': 'Premium aged basmati rice',
      'origin': 'Punjab, India',
      'organic': false,
    },
    {
      'id': '4',
      'name': 'Fresh Milk',
      'category': 'Dairy',
      'price': 52.0,
      'originalPrice': 55.0,
      'image': '🥛',
      'rating': 4.9,
      'reviews': 267,
      'discount': 5,
      'inStock': true,
      'seller': 'Dairy Fresh',
      'description': 'Pure cow milk, rich in nutrients',
      'origin': 'Local Dairy Farm',
      'organic': true,
    },
    {
      'id': '5',
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
    },
    {
      'id': '6',
      'name': 'Turmeric Powder',
      'category': 'Spices',
      'price': 280.0,
      'originalPrice': 320.0,
      'image': '🟡',
      'rating': 4.7,
      'reviews': 78,
      'discount': 13,
      'inStock': true,
      'seller': 'Spice World',
      'description': 'Pure turmeric powder with high curcumin',
      'origin': 'Kerala, India',
      'organic': true,
    },
  ];
}
