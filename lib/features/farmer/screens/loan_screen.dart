import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class LoanScreen extends StatelessWidget {
  const LoanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Agricultural Loans'),
        backgroundColor: AppColors.farmerPrimary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Loan Status
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.info, AppColors.info.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.account_balance, color: Colors.white, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'Current Loan Status',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Outstanding Amount',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹1,25,000',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        'Interest Rate: 7% p.a.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Next EMI: ₹15,600',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Loan Stats
            Row(
              children: [
                Expanded(
                  child: _buildStatCard('Credit Score', '785', AppColors.success),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard('EMI Due', '15 Oct', AppColors.warning),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard('Tenure Left', '18 months', AppColors.info),
                ),
              ],
            ),

            const SizedBox(height: 24),

            Text(
              'Available Loan Schemes',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 16),

            // Loan Schemes
            ..._loanSchemes.map((scheme) => _buildLoanSchemeCard(context, scheme)).toList(),

            const SizedBox(height: 24),

            Text(
              'Loan Calculator',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 16),

            // Loan Calculator
            _buildLoanCalculator(context),

            const SizedBox(height: 24),

            // Quick Actions
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _makePayment(context),
                    icon: const Icon(Icons.payment),
                    label: const Text('Pay EMI'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _applyNewLoan(context),
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('Apply New'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.farmerPrimary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
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
              fontSize: 18,
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

  Widget _buildLoanSchemeCard(BuildContext context, Map<String, dynamic> scheme) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.farmerPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  scheme['icon'],
                  color: AppColors.farmerPrimary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      scheme['name'],
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      scheme['type'],
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getInterestRateColor(scheme['interestRate']).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${scheme['interestRate']}% p.a.',
                  style: TextStyle(
                    color: _getInterestRateColor(scheme['interestRate']),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildLoanInfoItem('Max Amount', scheme['maxAmount']),
              const SizedBox(width: 20),
              _buildLoanInfoItem('Max Tenure', scheme['maxTenure']),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            scheme['description'],
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ...scheme['features'].take(2).map<Widget>((feature) => 
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    feature,
                    style: TextStyle(
                      color: AppColors.success,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ).toList(),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _applyForLoan(context, scheme),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.farmerPrimary.withOpacity(0.1),
                foregroundColor: AppColors.farmerPrimary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
              child: const Text('Apply Now'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoanInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildLoanCalculator(BuildContext context) {
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
              Icon(Icons.calculate, color: AppColors.farmerPrimary),
              const SizedBox(width: 8),
              Text(
                'Calculate Your EMI',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildCalculatorField('Loan Amount', '₹5,00,000'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCalculatorField('Interest Rate', '7%'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildCalculatorField('Tenure', '5 years'),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.farmerPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  'Monthly EMI',
                  style: TextStyle(
                    color: AppColors.farmerPrimary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '₹9,910',
                  style: TextStyle(
                    color: AppColors.farmerPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculatorField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.textSecondary.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Color _getInterestRateColor(double rate) {
    if (rate <= 6) return AppColors.success;
    if (rate <= 8) return AppColors.warning;
    return AppColors.error;
  }

  void _makePayment(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pay EMI'),
        content: const Text('You will be redirected to the payment gateway to pay your EMI of ₹15,600.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Payment gateway integration coming soon!')),
              );
            },
            child: const Text('Pay Now'),
          ),
        ],
      ),
    );
  }

  void _applyNewLoan(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Apply for New Loan'),
        content: const Text('Choose from the available loan schemes below or contact our loan officer for personalized assistance.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _applyForLoan(BuildContext context, Map<String, dynamic> scheme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Apply for ${scheme['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Loan Amount: Up to ${scheme['maxAmount']}'),
            Text('Interest Rate: ${scheme['interestRate']}% p.a.'),
            Text('Tenure: Up to ${scheme['maxTenure']}'),
            const SizedBox(height: 12),
            const Text('Required Documents:'),
            const Text('• Aadhar Card\n• Land Records\n• Bank Statements\n• Income Proof', 
                style: TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Loan application process will be available soon!')),
              );
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  static final List<Map<String, dynamic>> _loanSchemes = [
    {
      'name': 'Kisan Credit Card',
      'type': 'Government Scheme',
      'maxAmount': '₹3,00,000',
      'maxTenure': '5 years',
      'interestRate': 4.0,
      'description': 'Flexible credit facility for crop cultivation and related activities.',
      'icon': Icons.credit_card,
      'features': ['Flexible repayment', 'Lower interest', 'No collateral'],
    },
    {
      'name': 'Agriculture Term Loan',
      'type': 'Bank Loan',
      'maxAmount': '₹10,00,000',
      'maxTenure': '7 years',
      'interestRate': 7.5,
      'description': 'Long-term loan for farm mechanization, irrigation, and infrastructure.',
      'icon': Icons.agriculture,
      'features': ['Long tenure', 'Asset creation', 'Tax benefits'],
    },
    {
      'name': 'Self Help Group Loan',
      'type': 'Microfinance',
      'maxAmount': '₹50,000',
      'maxTenure': '3 years',
      'interestRate': 6.5,
      'description': 'Small loans through self-help groups for agricultural activities.',
      'icon': Icons.group,
      'features': ['Group guarantee', 'Easy approval', 'Community support'],
    },
  ];
}