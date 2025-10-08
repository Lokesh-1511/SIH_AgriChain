import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
<<<<<<< HEAD
=======
import 'package:easy_localization/easy_localization.dart';
>>>>>>> 5b3ae447a7a6f15554647b4ed5c427121e8f156b
import '../../../core/theme/app_colors.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../common/screens/landing_screen.dart';
import '../../common/screens/profile_screen.dart';
import '../../common/screens/settings_screen.dart';
import '../../common/screens/notifications_screen.dart';
import '../widgets/retailer_stats_card.dart';
import '../widgets/product_inventory_card.dart';
<<<<<<< HEAD
import '../../common/widgets/floating_chat_button.dart';
=======
>>>>>>> 5b3ae447a7a6f15554647b4ed5c427121e8f156b
import 'inventory_screen.dart';
import 'price_calculator_screen.dart';
import 'qr_generator_screen.dart';
import 'customer_analytics_screen.dart';
import 'supplier_management_screen.dart';
import 'sales_tracking_screen.dart';

class RetailerDashboard extends StatefulWidget {
  const RetailerDashboard({super.key});

  @override
  State<RetailerDashboard> createState() => _RetailerDashboardState();
}

class _RetailerDashboardState extends State<RetailerDashboard> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
<<<<<<< HEAD
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: [
              RetailerHomeTab(),
              InventoryScreen(),
              PriceCalculatorScreen(),
              CustomerAnalyticsScreen(),
            ],
          ),
          const FloatingChatButton(),
=======
      body: IndexedStack(
        index: _currentIndex,
        children: [
          RetailerHomeTab(),
          InventoryScreen(),
          PriceCalculatorScreen(),
          CustomerAnalyticsScreen(),
>>>>>>> 5b3ae447a7a6f15554647b4ed5c427121e8f156b
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.retailerPrimary,
        unselectedItemColor: AppColors.textSecondary,
        backgroundColor: Colors.white,
        elevation: 8,
<<<<<<< HEAD
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Inventory',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate),
            label: 'Pricing',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analytics',
=======
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: 'common.home'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.inventory),
            label: 'common.inventory'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.calculate),
            label: 'retailer.pricing'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.analytics),
            label: 'retailer.analytics'.tr(),
>>>>>>> 5b3ae447a7a6f15554647b4ed5c427121e8f156b
          ),
        ],
      ),
      appBar: _currentIndex == 0 ? _buildAppBar() : null,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.retailerPrimary,
      foregroundColor: Colors.white,
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Welcome Back!',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
          ),
          Text(
            'Retail Manager',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
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

class RetailerHomeTab extends StatelessWidget {
  const RetailerHomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sales Summary
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.retailerPrimary,
                  AppColors.retailerPrimary.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Today's Sales",
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "₹12,450",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.trending_up,
                            color: Colors.white.withOpacity(0.9),
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "+18.5% from yesterday",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.point_of_sale,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ],
            ),
          ),

          // Stats Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.3,
            children: [
              RetailerStatsCard(
                title: 'Products',
                value: '247',
                subtitle: 'In stock',
                icon: Icons.inventory_2,
                color: AppColors.info,
              ),
              RetailerStatsCard(
                title: 'Low Stock',
                value: '12',
                subtitle: 'Need reorder',
                icon: Icons.warning,
                color: AppColors.warning,
              ),
              RetailerStatsCard(
                title: 'Customers',
                value: '1,234',
                subtitle: 'Total served',
                icon: Icons.people,
                color: AppColors.success,
              ),
              RetailerStatsCard(
                title: 'Revenue',
                value: '₹2.4L',
                subtitle: 'This month',
                icon: Icons.currency_rupee,
                color: AppColors.retailerPrimary,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Quick Actions
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 16),

          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _buildQuickActionCard(
                context,
                'QR Generator',
                Icons.qr_code,
                AppColors.info,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const QRGeneratorScreen()),
                ),
              ),
              _buildQuickActionCard(
                context,
                'Sales Tracking',
                Icons.trending_up,
                AppColors.success,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SalesTrackingScreen(),
                  ),
                ),
              ),
              _buildQuickActionCard(
                context,
                'Suppliers',
                Icons.business,
                AppColors.warning,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SupplierManagementScreen(),
                  ),
                ),
              ),
              _buildQuickActionCard(
                context,
                'Reports',
                Icons.assessment,
                AppColors.error,
                () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Reports screen coming soon!')),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Recent Products
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recently Added Products',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const InventoryScreen()),
                ),
                child: const Text('View All'),
              ),
            ],
          ),

          const SizedBox(height: 12),

          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _recentProducts.length,
              itemBuilder: (context, index) {
                final product = _recentProducts[index];
                return ProductInventoryCard(
                  name: product['name'],
                  category: product['category'],
                  price: product['price'],
                  stock: product['stock'],
                  minStock: product['minStock'],
                  image: product['image'],
                  margin: const EdgeInsets.only(right: 12),
                  width: 160,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
              maxLines: 2, // Allow 2 lines for longer titles
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  static final List<Map<String, dynamic>> _recentProducts = [
    {
      'name': 'Alphonso Mango',
      'category': 'Fruits',
      'price': 450.0,
      'stock': 25,
      'minStock': 10,
      'image': '🥭',
    },
    {
      'name': 'Basmati Rice',
      'category': 'Grains',
      'price': 85.0,
      'stock': 50,
      'minStock': 20,
      'image': '🍚',
    },
    {
      'name': 'Red Onion',
      'category': 'Vegetables',
      'price': 25.0,
      'stock': 8,
      'minStock': 15,
      'image': '🧅',
    },
    {
      'name': 'Fresh Milk',
      'category': 'Dairy',
      'price': 52.0,
      'stock': 30,
      'minStock': 12,
      'image': '🥛',
    },
  ];
}
