import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/product_storage_service.dart';
import '../../../core/models/blockchain_product.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  List<BlockchainTransaction> _transactions = [];
  bool _isLoading = true;
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    try {
      final transactions = await ProductStorageService.getTransactions();
      setState(() {
        _transactions = transactions;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading transactions: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  double get totalEarnings {
    return _transactions
        .where(
          (t) =>
              (t.type == 'product_sale' || t.type == 'payment_received') &&
              t.amount != null &&
              t.amount! > 0,
        )
        .fold(0.0, (sum, t) => sum + t.amount!);
  }

  double get thisMonthEarnings {
    final now = DateTime.now();
    final thisMonth = DateTime(now.year, now.month, 1);

    return _transactions
        .where(
          (t) =>
              (t.type == 'product_sale' || t.type == 'payment_received') &&
              t.amount != null &&
              t.amount! > 0 &&
              t.timestamp.isAfter(thisMonth),
        )
        .fold(0.0, (sum, t) => sum + t.amount!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Cards
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Total Earnings',
                    '₹${totalEarnings.toStringAsFixed(0)}',
                    AppColors.success,
                    Icons.trending_up,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    'This Month',
                    '₹${thisMonthEarnings.toStringAsFixed(0)}',
                    AppColors.farmerPrimary,
                    Icons.calendar_month,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All', _selectedFilter == 'All'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Sales', _selectedFilter == 'Sales'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Posts', _selectedFilter == 'Posts'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Payments', _selectedFilter == 'Payments'),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Text(
              'Recent Transactions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 16),

            // Transactions List
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _getFilteredTransactions().isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _getFilteredTransactions().length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final transaction = _getFilteredTransactions()[index];
                      return _buildRealTransactionCard(context, transaction);
                    },
                  ),
          ],
        ),
      ),
    );
  }

  List<BlockchainTransaction> _getFilteredTransactions() {
    if (_selectedFilter == 'All') {
      return _transactions;
    } else if (_selectedFilter == 'Sales') {
      return _transactions
          .where(
            (t) => t.type == 'product_sale' || t.type == 'payment_received',
          )
          .toList();
    } else if (_selectedFilter == 'Posts') {
      return _transactions.where((t) => t.type == 'product_post').toList();
    } else if (_selectedFilter == 'Payments') {
      return _transactions
          .where(
            (t) => t.type == 'payment_received' || t.type == 'payment_sent',
          )
          .toList();
    }
    return _transactions;
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 80,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No Transactions Yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start posting products and making sales to see your transaction history',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRealTransactionCard(
    BuildContext context,
    BlockchainTransaction transaction,
  ) {
    IconData icon;
    Color iconColor;
    String displayAmount;
    String displayTitle;
    String displayDescription;

    switch (transaction.type) {
      case 'product_post':
        icon = Icons.inventory_2;
        iconColor = AppColors.info;
        displayAmount = 'Posted';
        displayTitle = 'Product Posted';
        displayDescription =
            transaction.transactionData?['productName'] ??
            'Product posted to blockchain';
        break;
      case 'product_sale':
        icon = Icons.sell;
        iconColor = AppColors.success;
        displayAmount = transaction.amount != null
            ? '+₹${transaction.amount!.toStringAsFixed(0)}'
            : 'Sold';
        displayTitle = 'Product Sale';
        displayDescription =
            transaction.transactionData?['productName'] ??
            'Product sold to distributor';
        break;
      case 'payment_received':
        icon = Icons.payments;
        iconColor = AppColors.success;
        displayAmount = transaction.amount != null
            ? '+₹${transaction.amount!.toStringAsFixed(0)}'
            : 'Received';
        displayTitle = 'Payment Received';
        displayDescription =
            transaction.transactionData?['description'] ??
            'Payment received from buyer';
        break;
      case 'payment_sent':
        icon = Icons.send;
        iconColor = AppColors.error;
        displayAmount = transaction.amount != null
            ? '-₹${transaction.amount!.toStringAsFixed(0)}'
            : 'Sent';
        displayTitle = 'Payment Sent';
        displayDescription =
            transaction.transactionData?['description'] ?? 'Payment sent';
        break;
      default:
        icon = Icons.receipt;
        iconColor = AppColors.textSecondary;
        displayAmount = 'N/A';
        displayTitle = transaction.type;
        displayDescription = 'Blockchain transaction';
    }

    Color statusColor = _getStatusColorForTransaction(transaction.status);

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayTitle,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      displayDescription,
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
                    displayAmount,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color:
                          transaction.amount != null && transaction.amount! > 0
                          ? AppColors.success
                          : AppColors.textPrimary,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      transaction.status.toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.access_time, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                '${transaction.timestamp.day}/${transaction.timestamp.month}/${transaction.timestamp.year}',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              const Spacer(),
              if (transaction.txHash.isNotEmpty) ...[
                Icon(Icons.link, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  'TX: ${transaction.txHash.substring(0, 8)}...',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColorForTransaction(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
      case 'completed':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      case 'failed':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  Widget _buildSummaryCard(
    String title,
    String amount,
    Color color,
    IconData icon,
  ) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const Spacer(),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            amount,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = label;
        });
      },
      backgroundColor: Colors.white,
      selectedColor: AppColors.farmerPrimary.withOpacity(0.2),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.farmerPrimary : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected
            ? AppColors.farmerPrimary
            : AppColors.textSecondary.withOpacity(0.3),
      ),
    );
  }
}
