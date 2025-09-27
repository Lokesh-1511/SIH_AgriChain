import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

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
                    '₹45,670',
                    AppColors.success,
                    Icons.trending_up,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    'This Month',
                    '₹8,950',
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
                  _buildFilterChip('All', true),
                  const SizedBox(width: 8),
                  _buildFilterChip('Completed', false),
                  const SizedBox(width: 8),
                  _buildFilterChip('Pending', false),
                  const SizedBox(width: 8),
                  _buildFilterChip('This Month', false),
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
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _mockTransactions.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final transaction = _mockTransactions[index];
                return _buildTransactionCard(context, transaction);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String amount, Color color, IconData icon) {
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
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
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
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {},
      backgroundColor: Colors.white,
      selectedColor: AppColors.farmerPrimary.withOpacity(0.2),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.farmerPrimary : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? AppColors.farmerPrimary : AppColors.textSecondary.withOpacity(0.3),
      ),
    );
  }

  Widget _buildTransactionCard(BuildContext context, Map<String, dynamic> transaction) {
    bool isCredit = transaction['type'] == 'credit';
    Color amountColor = isCredit ? AppColors.success : AppColors.error;
    IconData icon = isCredit ? Icons.add_circle : Icons.remove_circle;

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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: amountColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: amountColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction['title'],
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      transaction['description'],
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
                    '${isCredit ? '+' : '-'}₹${transaction['amount']}',
                    style: TextStyle(
                      color: amountColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    transaction['date'],
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (transaction['batchId'] != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.farmerPrimary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.qr_code,
                    size: 16,
                    color: AppColors.farmerPrimary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Batch ID: ${transaction['batchId']}',
                    style: TextStyle(
                      color: AppColors.farmerPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getStatusColor(transaction['status']).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      transaction['status'],
                      style: TextStyle(
                        color: _getStatusColor(transaction['status']),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Completed':
        return AppColors.success;
      case 'Pending':
        return AppColors.warning;
      case 'Processing':
        return AppColors.info;
      default:
        return AppColors.textSecondary;
    }
  }

  static final List<Map<String, dynamic>> _mockTransactions = [
    {
      'title': 'Tomato Batch Sale',
      'description': 'Green Transport Co. - 500kg',
      'amount': '22,500',
      'type': 'credit',
      'date': '26 Sep',
      'batchId': 'BTH001',
      'status': 'Completed',
    },
    {
      'title': 'Seeds Purchase',
      'description': 'AgriMart Store - Hybrid Seeds',
      'amount': '3,200',
      'type': 'debit',
      'date': '25 Sep',
      'status': 'Completed',
    },
    {
      'title': 'Carrot Batch Sale',
      'description': 'City Logistics - 300kg',
      'amount': '12,000',
      'type': 'credit',
      'date': '24 Sep',
      'batchId': 'BTH003',
      'status': 'Completed',
    },
    {
      'title': 'Government Subsidy',
      'description': 'PM-KISAN Scheme Payment',
      'amount': '6,000',
      'type': 'credit',
      'date': '22 Sep',
      'status': 'Completed',
    },
    {
      'title': 'Fertilizer Purchase',
      'description': 'Green Valley Agro - NPK Fertilizer',
      'amount': '4,500',
      'type': 'debit',
      'date': '20 Sep',
      'status': 'Completed',
    },
    {
      'title': 'Onion Batch Sale',
      'description': 'Fresh Delivery - 800kg',
      'amount': '28,000',
      'type': 'credit',
      'date': '18 Sep',
      'batchId': 'BTH002',
      'status': 'Processing',
    },
  ];
}