import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/user_service.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../common/screens/landing_screen.dart';
import '../../common/screens/profile_screen.dart';
import '../../common/screens/settings_screen.dart';
import '../../common/screens/notifications_screen.dart';
import '../widgets/distributor_stats_card.dart';
import '../widgets/batch_request_card.dart';
import 'available_batches_screen.dart';
import 'cost_prediction_screen.dart';
import 'inventory_management_screen.dart';
import 'distributor_analytics_screen.dart';
import 'vehicle_management_screen.dart';
import 'delivery_tracking_screen.dart';

class DistributorDashboard extends StatefulWidget {
  const DistributorDashboard({super.key});

  @override
  State<DistributorDashboard> createState() => _DistributorDashboardState();
}

class _DistributorDashboardState extends State<DistributorDashboard> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          DistributorHomeTab(),
          DeliveryTrackingScreen(),
          InventoryManagementScreen(),
          DistributorAnalyticsScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.distributorPrimary,
        unselectedItemColor: AppColors.textSecondary,
        backgroundColor: Colors.white,
        elevation: 8,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: 'common.home'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.local_shipping),
            label: 'distributor.delivery'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.inventory),
            label: 'common.inventory'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.analytics),
            label: 'distributor.analytics'.tr(),
          ),
        ],
      ),
      appBar: _currentIndex == 0 ? _buildAppBar() : null,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.distributorPrimary,
      foregroundColor: Colors.white,
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'common.welcome_back'.tr(),
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.normal,
            ),
          ),
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return FutureBuilder<Map<String, dynamic>?>(
                future: authProvider.currentUser?.email != null
                    ? UserService.getUserByEmail(
                        authProvider.currentUser!.email,
                      )
                    : null,
                builder: (context, snapshot) {
                  String companyName = 'AgriChain User';

                  if (snapshot.hasData && snapshot.data != null) {
                    companyName =
                        snapshot.data!['companyName'] ??
                        snapshot.data!['name'] ??
                        'AgriChain User';
                  }

                  return Text(
                    companyName,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () => _showNotifications(),
          icon: Badge(
            label: const Text('3'),
            child: const Icon(Icons.notifications_outlined),
          ),
        ),
        PopupMenuButton(
          icon: const Icon(Icons.more_vert),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'profile',
              child: Row(
                children: [
                  const Icon(Icons.person, size: 20),
                  const SizedBox(width: 8),
                  Text('common.profile'.tr()),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'settings',
              child: Row(
                children: [
                  const Icon(Icons.settings, size: 20),
                  const SizedBox(width: 8),
                  Text('common.settings'.tr()),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'logout',
              child: Row(
                children: [
                  const Icon(Icons.logout, size: 20),
                  const SizedBox(width: 8),
                  Text('common.logout'.tr()),
                ],
              ),
            ),
          ],
          onSelected: (value) => _handleMenuAction(value.toString()),
        ),
      ],
    );
  }

  void _showNotifications() {
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

class DistributorHomeTab extends StatelessWidget {
  const DistributorHomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.1,
            children: [
              DistributorStatsCard(
                title: 'Active Orders',
                value: '24',
                subtitle: '+3 from yesterday',
                icon: Icons.local_shipping,
                color: AppColors.distributorPrimary,
              ),
              DistributorStatsCard(
                title: 'Revenue Today',
                value: '₹45K',
                subtitle: '+12% from avg',
                icon: Icons.currency_rupee,
                color: AppColors.success,
              ),
              DistributorStatsCard(
                title: 'Deliveries',
                value: '156',
                subtitle: 'This month',
                icon: Icons.done_all,
                color: AppColors.info,
              ),
              DistributorStatsCard(
                title: 'Efficiency',
                value: '94%',
                subtitle: 'On-time delivery',
                icon: Icons.speed,
                color: AppColors.warning,
              ),
            ],
          ),

          const SizedBox(height: 24),

          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 16),

          LayoutBuilder(
            builder: (context, constraints) {
              // Calculate dynamic crossAxisCount based on screen width
              int crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
              double childAspectRatio = constraints.maxWidth > 600 ? 1.2 : 1.1;

              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: childAspectRatio,
                children: [
                  _buildQuickActionCard(
                    context,
                    'Available Batches',
                    Icons.agriculture,
                    AppColors.distributorPrimary,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AvailableBatchesScreen(),
                      ),
                    ),
                  ),
                  _buildQuickActionCard(
                    context,
                    'Cost Prediction',
                    Icons.analytics,
                    AppColors.info,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CostPredictionScreen(),
                      ),
                    ),
                  ),
                  _buildQuickActionCard(
                    context,
                    'Vehicle Management',
                    Icons.local_shipping,
                    AppColors.warning,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const VehicleManagementScreen(),
                      ),
                    ),
                  ),
                  _buildQuickActionCard(
                    context,
                    'Route Optimizer',
                    Icons.route,
                    AppColors.success,
                    () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Route Optimizer screen coming soon!'),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 24),

          Text(
            'Pending Batch Requests',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 16),

          // Mock batch requests
          ..._pendingBatches
              .take(3)
              .map(
                (batch) => BatchRequestCard(
                  batch: batch,
                  onAccept: () => _acceptBatch(context, batch),
                  onReject: () => _rejectBatch(context, batch),
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
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _acceptBatch(BuildContext context, Map<String, dynamic> batch) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${batch['product']} batch accepted!')),
    );
  }

  void _rejectBatch(BuildContext context, Map<String, dynamic> batch) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${batch['product']} batch rejected!')),
    );
  }

  static final List<Map<String, dynamic>> _pendingBatches = [
    {
      'product': 'Fresh Tomatoes',
      'productEmoji': '🍅',
      'farmer': 'Ramesh Farm',
      'location': 'Nashik, MH',
      'quantity': '500 kg',
      'price': '45',
      'totalValue': '22,500',
      'harvestDate': 'Today',
      'distance': '25 km',
      'qualityScore': 92,
      'shelfLife': 5,
    },
    {
      'product': 'Organic Onions',
      'productEmoji': '🧅',
      'farmer': 'Green Valley Co-op',
      'location': 'Pune, MH',
      'quantity': '800 kg',
      'price': '35',
      'totalValue': '28,000',
      'harvestDate': 'Tomorrow',
      'distance': '45 km',
      'qualityScore': 88,
      'shelfLife': 14,
    },
    {
      'product': 'Fresh Carrots',
      'productEmoji': '🥕',
      'farmer': 'Sunrise Organics',
      'location': 'Satara, MH',
      'quantity': '300 kg',
      'price': '40',
      'totalValue': '12,000',
      'harvestDate': 'Today',
      'distance': '35 km',
      'qualityScore': 95,
      'shelfLife': 7,
    },
  ];
}
