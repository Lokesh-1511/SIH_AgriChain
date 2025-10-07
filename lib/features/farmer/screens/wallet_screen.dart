import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/auth_service.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  String? _walletAddress;
  bool _isLoadingWallet = true;

  @override
  void initState() {
    super.initState();
    _loadWalletAddress();
  }

  Future<void> _loadWalletAddress() async {
    try {
      final wallet = await AuthService.instance.getCurrentUserWallet();
      if (mounted) {
        setState(() {
          _walletAddress = wallet;
          _isLoadingWallet = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingWallet = false;
        });
      }
    }
  }

  Future<void> _refreshWallet() async {
    setState(() {
      _isLoadingWallet = true;
    });
    await _loadWalletAddress();
  }

  void _copyWalletAddress() {
    if (_walletAddress != null) {
      Clipboard.setData(ClipboardData(text: _walletAddress!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Wallet address copied to clipboard!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('AgriWallet'),
        backgroundColor: AppColors.farmerPrimary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _refreshWallet,
            icon: _isLoadingWallet
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.refresh),
            tooltip: 'Refresh Wallet',
          ),
          IconButton(
            onPressed: () => _showTransactionHistory(context),
            icon: const Icon(Icons.history),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Wallet Balance Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.farmerPrimary,
                    AppColors.farmerPrimary.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Wallet Address Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.account_balance_wallet_outlined,
                              color: Colors.white.withOpacity(0.9),
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Wallet Address',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _isLoadingWallet
                            ? Row(
                                children: [
                                  SizedBox(
                                    width: 12,
                                    height: 12,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Loading wallet address...',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              )
                            : _walletAddress != null
                                ? GestureDetector(
                                    onTap: _copyWalletAddress,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              _walletAddress!,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontFamily: 'monospace',
                                                fontWeight: FontWeight.bold,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Icon(
                                            Icons.copy,
                                            color: Colors.white.withOpacity(0.8),
                                            size: 16,
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : Container(
                                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.red.withOpacity(0.5),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.error_outline,
                                          color: Colors.red.shade300,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'No wallet assigned',
                                          style: TextStyle(
                                            color: Colors.red.shade300,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                      ],
                    ),
                  ),
                  
                  // Available Balance Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Available Balance',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '₹45,670.50',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.account_balance_wallet,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'This Month',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '+₹12,450',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Last Transaction',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '2 hours ago',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Quick Actions
            Row(
              children: [
                Icon(
                  Icons.flash_on,
                  color: AppColors.farmerPrimary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.farmerPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _buildActionCard(
                  icon: Icons.send,
                  title: 'Send Money',
                  subtitle: 'Transfer funds',
                  color: Colors.blue,
                  onTap: () => _sendMoney(context),
                ),
                _buildActionCard(
                  icon: Icons.qr_code_scanner,
                  title: 'Scan QR',
                  subtitle: 'Quick payment',
                  color: Colors.green,
                  onTap: () => _scanQR(context),
                ),
                _buildActionCard(
                  icon: Icons.add_circle,
                  title: 'Add Money',
                  subtitle: 'Top up wallet',
                  color: Colors.orange,
                  onTap: () => _addMoney(context),
                ),
                _buildActionCard(
                  icon: Icons.receipt_long,
                  title: 'Pay Bills',
                  subtitle: 'Utility payments',
                  color: Colors.purple,
                  onTap: () => _payBills(context),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Recent Transactions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.history,
                      color: AppColors.farmerPrimary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Recent Transactions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.farmerPrimary,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () => _showTransactionHistory(context),
                  child: Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              itemBuilder: (context, index) => _buildTransactionItem(
                icon: index == 0
                    ? Icons.add_circle
                    : index == 1
                        ? Icons.remove_circle
                        : Icons.shopping_cart,
                title: index == 0
                    ? 'Money Added'
                    : index == 1
                        ? 'Payment Sent'
                        : 'Product Purchase',
                subtitle: index == 0
                    ? 'Bank Transfer'
                    : index == 1
                        ? 'To: Distributor'
                        : 'Organic Wheat Seeds',
                amount: index == 0
                    ? '+₹15,000'
                    : index == 1
                        ? '-₹8,500'
                        : '-₹2,450',
                time: index == 0
                    ? '2 hours ago'
                    : index == 1
                        ? '1 day ago'
                        : '2 days ago',
                isCredit: index == 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      color: Colors.white, 
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: color,
                size: 24,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String amount,
    required String time,
    required bool isCredit,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: AppColors.background,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isCredit ? Colors.green[100] : Colors.red[100],
          child: Icon(
            icon,
            color: isCredit ? Colors.green[700] : Colors.red[700],
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w500, color: AppColors.textPrimary),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(subtitle, style: TextStyle(color: AppColors.textPrimary)),
            Text(
              time,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: Text(
          amount,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isCredit ? Colors.green[700] : Colors.red[700],
            fontSize: 16,
          ),
        ),
        isThreeLine: true,
      ),
    );
  }

  // Action methods
  void _sendMoney(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Send Money feature coming soon!')),
    );
  }

  void _scanQR(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('QR Scanner feature coming soon!')),
    );
  }

  void _addMoney(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add Money feature coming soon!')),
    );
  }

  void _payBills(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pay Bills feature coming soon!')),
    );
  }

  void _showTransactionHistory(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transaction History feature coming soon!')),
    );
  }
}