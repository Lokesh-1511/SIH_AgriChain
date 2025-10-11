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
import '../widgets/farmer_stats_card.dart';
import '../widgets/batch_status_card.dart';
import '../widgets/ai_advisory_card.dart';
import '../screens/post_product_screen.dart';
import '../screens/my_batches_screen.dart';
import '../screens/transactions_screen.dart';
import '../screens/agri_score_screen.dart';
import '../screens/insurance_screen.dart';
import '../screens/loan_screen.dart';
import '../screens/govt_schemes_screen.dart';
import '../screens/crop_advisory_screen.dart';
import '../screens/wallet_screen.dart';
import '../../common/widgets/floating_chat_button.dart';

class FarmerDashboard extends StatefulWidget {
  const FarmerDashboard({super.key});

  @override
  State<FarmerDashboard> createState() => _FarmerDashboardState();
}

class _FarmerDashboardState extends State<FarmerDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const FarmerHomeTab(),
    const MyBatchesScreen(),
    const TransactionsScreen(),
    const WalletScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.farmerPrimary,
<<<<<<< HEAD
        title: const Text(
          'Farmer Dashboard',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
=======
        title: Text(
          'farmer.title'.tr(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
>>>>>>> 5b3ae447a7a6f15554647b4ed5c427121e8f156b
        ),
        actions: [
          IconButton(
            onPressed: () => _showNotifications(context),
            icon: const Icon(Icons.notifications, color: Colors.white),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
<<<<<<< HEAD
              const PopupMenuItem(value: 'profile', child: Text('Profile')),
              const PopupMenuItem(value: 'settings', child: Text('Settings')),
              const PopupMenuItem(value: 'logout', child: Text('Logout')),
=======
              PopupMenuItem(
                value: 'profile',
                child: Text('common.profile'.tr()),
              ),
              PopupMenuItem(
                value: 'settings',
                child: Text('common.settings'.tr()),
              ),
              PopupMenuItem(value: 'logout', child: Text('common.logout'.tr())),
>>>>>>> 5b3ae447a7a6f15554647b4ed5c427121e8f156b
            ],
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.farmerPrimary,
        unselectedItemColor: AppColors.textSecondary,
<<<<<<< HEAD
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'My Batches',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Transactions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Wallet',
=======
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: 'common.home'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.inventory),
            label: 'farmer.my_batches'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.receipt_long),
            label: 'farmer.transactions'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.account_balance_wallet),
            label: 'farmer.wallet'.tr(),
>>>>>>> 5b3ae447a7a6f15554647b4ed5c427121e8f156b
          ),
        ],
      ),
      floatingActionButton: const FloatingChatButton(),
    );
  }

  void _showNotifications(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
<<<<<<< HEAD
        title: const Text('Notifications'),
=======
        title: Text('common.notifications'.tr()),
>>>>>>> 5b3ae447a7a6f15554647b4ed5c427121e8f156b
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildNotificationItem(
              'AI Alert',
              'Tomato prices expected to rise by 15% next week',
              Icons.trending_up,
              AppColors.success,
            ),
            _buildNotificationItem(
              'Weather Update',
              'Rain expected in your area. Check your crops',
              Icons.cloud,
              AppColors.info,
            ),
            _buildNotificationItem(
              'Batch Update',
              'Your onion batch #1234 has been picked up for delivery',
              Icons.local_shipping,
              AppColors.warning,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
<<<<<<< HEAD
            child: const Text('Close'),
=======
            child: Text('common.close'.tr()),
>>>>>>> 5b3ae447a7a6f15554647b4ed5c427121e8f156b
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(
    String title,
    String message,
    IconData icon,
    Color color,
  ) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.1),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(message),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'profile':
        // Navigate to profile
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
        );
        break;
      case 'settings':
        // Navigate to settings
        break;
      case 'logout':
        _logout();
        break;
    }
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
<<<<<<< HEAD
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
=======
        title: Text('common.logout'.tr()),
        content: Text('common.logout_confirmation'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('common.cancel'.tr()),
>>>>>>> 5b3ae447a7a6f15554647b4ed5c427121e8f156b
          ),
          TextButton(
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LandingScreen()),
                (route) => false,
              );
            },
<<<<<<< HEAD
            child: const Text('Logout'),
=======
            child: Text('common.logout'.tr()),
>>>>>>> 5b3ae447a7a6f15554647b4ed5c427121e8f156b
          ),
        ],
      ),
    );
  }
}

class FarmerHomeTab extends StatelessWidget {
  const FarmerHomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.farmerPrimary,
                  AppColors.farmerPrimary.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
<<<<<<< HEAD
                  'Welcome Back!',
=======
                  'farmer.welcome_back_farmer',
>>>>>>> 5b3ae447a7a6f15554647b4ed5c427121e8f156b
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
<<<<<<< HEAD
                ),
=======
                ).tr(),
>>>>>>> 5b3ae447a7a6f15554647b4ed5c427121e8f156b
                const SizedBox(height: 8),
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return Text(
                      'Farmer', // Placeholder until user data is available
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.eco, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    const Text(
<<<<<<< HEAD
                      'Growing sustainably with technology',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
=======
                      'farmer.growing_sustainably',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ).tr(),
>>>>>>> 5b3ae447a7a6f15554647b4ed5c427121e8f156b
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Quick Stats
          Row(
            children: [
              Expanded(
                child: FarmerStatsCard(
<<<<<<< HEAD
                  title: 'Active Batches',
=======
                  title: 'farmer.active_batches'.tr(),
>>>>>>> 5b3ae447a7a6f15554647b4ed5c427121e8f156b
                  value: '12',
                  icon: Icons.inventory,
                  color: AppColors.info,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FarmerStatsCard(
<<<<<<< HEAD
                  title: 'Total Earnings',
=======
                  title: 'farmer.total_earnings'.tr(),
>>>>>>> 5b3ae447a7a6f15554647b4ed5c427121e8f156b
                  value: '₹45,230',
                  icon: Icons.currency_rupee,
                  color: AppColors.success,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: FarmerStatsCard(
<<<<<<< HEAD
                  title: 'Agri Score',
=======
                  title: 'farmer.agri_score'.tr(),
>>>>>>> 5b3ae447a7a6f15554647b4ed5c427121e8f156b
                  value: '85%',
                  icon: Icons.star,
                  color: AppColors.warning,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FarmerStatsCard(
<<<<<<< HEAD
                  title: 'Orders',
=======
                  title: 'farmer.orders'.tr(),
>>>>>>> 5b3ae447a7a6f15554647b4ed5c427121e8f156b
                  value: '28',
                  icon: Icons.shopping_cart,
                  color: AppColors.farmerPrimary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Quick Actions
          Text(
<<<<<<< HEAD
            'Quick Actions',
=======
            'farmer.quick_actions'.tr(),
>>>>>>> 5b3ae447a7a6f15554647b4ed5c427121e8f156b
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
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
            children: [
              _buildQuickActionCard(
                context,
<<<<<<< HEAD
                'Post Product',
=======
                'farmer.post_product'.tr(),
>>>>>>> 5b3ae447a7a6f15554647b4ed5c427121e8f156b
                Icons.add_circle,
                AppColors.farmerPrimary,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PostProductScreen()),
                ),
              ),
              _buildQuickActionCard(
                context,
<<<<<<< HEAD
                'Crop Advisory',
=======
                'farmer.crop_advisory'.tr(),
>>>>>>> 5b3ae447a7a6f15554647b4ed5c427121e8f156b
                Icons.lightbulb,
                AppColors.info,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CropAdvisoryScreen()),
                ),
              ),
              _buildQuickActionCard(
                context,
<<<<<<< HEAD
                'Insurance',
=======
                'farmer.insurance'.tr(),
>>>>>>> 5b3ae447a7a6f15554647b4ed5c427121e8f156b
                Icons.security,
                AppColors.warning,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const InsuranceScreen()),
                ),
              ),
              _buildQuickActionCard(
                context,
<<<<<<< HEAD
                'Loan Apply',
=======
                'farmer.loan_apply'.tr(),
>>>>>>> 5b3ae447a7a6f15554647b4ed5c427121e8f156b
                Icons.account_balance,
                AppColors.success,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoanScreen()),
                ),
              ),
              _buildQuickActionCard(
                context,
<<<<<<< HEAD
                'Agri Score',
=======
                'farmer.agri_score'.tr(),
>>>>>>> 5b3ae447a7a6f15554647b4ed5c427121e8f156b
                Icons.assessment,
                AppColors.farmerPrimary,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AgriScoreScreen()),
                ),
              ),
              _buildQuickActionCard(
                context,
<<<<<<< HEAD
                'Govt Schemes',
=======
                'farmer.govt_schemes'.tr(),
>>>>>>> 5b3ae447a7a6f15554647b4ed5c427121e8f156b
                Icons.account_balance,
                AppColors.info,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GovtSchemesScreen()),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Recent Batch Status
          Text(
<<<<<<< HEAD
            'Recent Batch Status',
=======
            'farmer.recent_batch_status'.tr(),
>>>>>>> 5b3ae447a7a6f15554647b4ed5c427121e8f156b
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 16),

          const BatchStatusCard(
            batchId: 'BTH001',
            productName: 'Tomatoes',
            quantity: '500 kg',
            status: 'Pending',
            statusColor: AppColors.warning,
          ),

          const SizedBox(height: 12),

          const BatchStatusCard(
            batchId: 'BTH002',
            productName: 'Onions',
            quantity: '800 kg',
            status: 'In Transit',
            statusColor: AppColors.info,
          ),

          const SizedBox(height: 24),

          // AI Advisory
          const AIAdvisoryCard(),

          const SizedBox(height: 80), // Space for FAB
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
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
<<<<<<< HEAD
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                fontSize: 14, // Explicit font size
              ),
              textAlign: TextAlign.center,
              maxLines: 2, // Allow 2 lines for longer titles
              overflow: TextOverflow.ellipsis,
            ),
          ],
=======
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    fontSize: 11, // Smaller font size to prevent overflow
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2, // Allow 2 lines for longer titles
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
>>>>>>> 5b3ae447a7a6f15554647b4ed5c427121e8f156b
        ),
      ),
    );
  }
}
