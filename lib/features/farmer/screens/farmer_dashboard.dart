import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../../common/screens/landing_screen.dart';
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
import '../screens/wallet_screen.dart';
import '../screens/crop_advisory_screen.dart';
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
        title: const Text(
          'Farmer Dashboard',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
              const PopupMenuItem(value: 'profile', child: Text('Profile')),
              const PopupMenuItem(value: 'settings', child: Text('Settings')),
              const PopupMenuItem(value: 'logout', child: Text('Logout')),
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
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
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
        title: const Text('Notifications'),
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
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(String title, String message, IconData icon, Color color) {
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
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LandingScreen()),
                (route) => false,
              );
            },
            child: const Text('Logout'),
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
                colors: [AppColors.farmerPrimary, AppColors.farmerPrimary.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome Back!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    final user = authProvider.currentUser;
                    return Text(
                      user?.name ?? 'Farmer',
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
                      'Growing sustainably with technology',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
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
                  title: 'Active Batches',
                  value: '12',
                  icon: Icons.inventory,
                  color: AppColors.info,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FarmerStatsCard(
                  title: 'Total Earnings',
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
                  title: 'Agri Score',
                  value: '85%',
                  icon: Icons.star,
                  color: AppColors.warning,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FarmerStatsCard(
                  title: 'Orders',
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
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
            children: [
              _buildQuickActionCard(
                context,
                'Post Product',
                Icons.add_circle,
                AppColors.farmerPrimary,
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PostProductScreen())),
              ),
              _buildQuickActionCard(
                context,
                'Crop Advisory',
                Icons.lightbulb,
                AppColors.info,
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CropAdvisoryScreen())),
              ),
              _buildQuickActionCard(
                context,
                'Insurance',
                Icons.security,
                AppColors.warning,
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InsuranceScreen())),
              ),
              _buildQuickActionCard(
                context,
                'Loan Apply',
                Icons.account_balance,
                AppColors.success,
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoanScreen())),
              ),
              _buildQuickActionCard(
                context,
                'Agri Score',
                Icons.assessment,
                AppColors.farmerPrimary,
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AgriScoreScreen())),
              ),
              _buildQuickActionCard(
                context,
                'Govt Schemes',
                Icons.account_balance,
                AppColors.info,
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GovtSchemesScreen())),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Recent Batch Status
          Text(
            'Recent Batch Status',
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

  Widget _buildQuickActionCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
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
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}