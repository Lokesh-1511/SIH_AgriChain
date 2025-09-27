import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class GovtSchemesScreen extends StatelessWidget {
  const GovtSchemesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Government Schemes'),
        backgroundColor: AppColors.farmerPrimary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Active Schemes Summary
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.success, AppColors.success.withOpacity(0.8)],
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
                        'Your Benefits',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Active Schemes',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              '5',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Benefits',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              '₹42,000',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'Available Schemes',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 16),

            // Scheme Categories
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildCategoryChip('All', true),
                  const SizedBox(width: 8),
                  _buildCategoryChip('Active', false),
                  const SizedBox(width: 8),
                  _buildCategoryChip('Financial', false),
                  const SizedBox(width: 8),
                  _buildCategoryChip('Insurance', false),
                  const SizedBox(width: 8),
                  _buildCategoryChip('Subsidy', false),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Schemes List
            ..._schemes.map((scheme) => _buildSchemeCard(context, scheme)).toList(),

            const SizedBox(height: 24),

            // Help Section
            Container(
              width: double.infinity,
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
                      Icon(Icons.help_outline, color: AppColors.info),
                      const SizedBox(width: 8),
                      Text(
                        'Need Help?',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'For assistance with government schemes and applications:',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.phone, size: 16, color: AppColors.info),
                      const SizedBox(width: 8),
                      Text(
                        'Helpline: 1800-180-1551',
                        style: TextStyle(
                          color: AppColors.info,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.language, size: 16, color: AppColors.info),
                      const SizedBox(width: 8),
                      Text(
                        'Visit: pmkisan.gov.in',
                        style: TextStyle(
                          color: AppColors.info,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected) {
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

  Widget _buildSchemeCard(BuildContext context, Map<String, dynamic> scheme) {
    Color statusColor = _getStatusColor(scheme['status']);
    
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
                  size: 20,
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
                      scheme['ministry'],
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
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  scheme['status'],
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
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
              _buildSchemeInfoItem('Benefit', scheme['benefit']),
              const SizedBox(width: 20),
              if (scheme['deadline'] != null)
                _buildSchemeInfoItem('Deadline', scheme['deadline']),
            ],
          ),
          if (scheme['eligibility'] != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Eligibility:',
                    style: TextStyle(
                      color: AppColors.info,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    scheme['eligibility'],
                    style: TextStyle(
                      color: AppColors.info,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              if (scheme['status'] == 'Active') ...[
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _viewDetails(context, scheme),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.farmerPrimary.withOpacity(0.1),
                      foregroundColor: AppColors.farmerPrimary,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: const Text('View Details'),
                  ),
                ),
              ] else ...[
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _applyForScheme(context, scheme),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.farmerPrimary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: const Text('Apply Now'),
                  ),
                ),
              ],
              if (scheme['documents'] != null) ...[
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => _showDocuments(context, scheme),
                  child: const Text('Docs Required'),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSchemeInfoItem(String label, String value) {
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Active':
        return AppColors.success;
      case 'Applied':
        return AppColors.warning;
      case 'Available':
        return AppColors.info;
      case 'Closed':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  void _viewDetails(BuildContext context, Map<String, dynamic> scheme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(scheme['name']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: ${scheme['status']}'),
            const SizedBox(height: 8),
            Text('Benefit: ${scheme['benefit']}'),
            if (scheme['nextPayment'] != null) ...[
              const SizedBox(height: 8),
              Text('Next Payment: ${scheme['nextPayment']}'),
            ],
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

  void _applyForScheme(BuildContext context, Map<String, dynamic> scheme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Apply for ${scheme['name']}'),
        content: const Text('Would you like to apply for this scheme? You will be redirected to the application portal.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Application process will be available soon!')),
              );
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _showDocuments(BuildContext context, Map<String, dynamic> scheme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Required Documents'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: scheme['documents'].map<Widget>((doc) => 
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('• $doc', style: const TextStyle(fontSize: 14)),
            )
          ).toList(),
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

  static final List<Map<String, dynamic>> _schemes = [
    {
      'name': 'PM-KISAN',
      'ministry': 'Ministry of Agriculture',
      'description': 'Direct income support to farmers - ₹6,000 per year in three equal installments.',
      'benefit': '₹6,000/year',
      'status': 'Active',
      'icon': Icons.currency_rupee,
      'nextPayment': '15 Dec 2024',
      'eligibility': 'All landholding farmers',
    },
    {
      'name': 'Pradhan Mantri Fasal Bima Yojana',
      'ministry': 'Ministry of Agriculture',
      'description': 'Crop insurance scheme providing financial support to farmers suffering crop loss.',
      'benefit': 'Up to ₹2 lakh',
      'status': 'Active',
      'icon': Icons.security,
      'eligibility': 'All farmers growing notified crops',
      'documents': ['Aadhar Card', 'Land Records', 'Bank Account Details', 'Sowing Certificate'],
    },
    {
      'name': 'Soil Health Card Scheme',
      'ministry': 'Ministry of Agriculture',
      'description': 'Provides soil health cards to farmers for appropriate nutrient management.',
      'benefit': 'Free soil testing',
      'status': 'Available',
      'icon': Icons.eco,
      'deadline': '31 Mar 2025',
      'eligibility': 'All farmers',
      'documents': ['Land ownership proof', 'Aadhar Card'],
    },
    {
      'name': 'Pradhan Mantri Krishi Sinchai Yojana',
      'ministry': 'Ministry of Agriculture',
      'description': 'Irrigation scheme to improve water use efficiency and expand irrigation coverage.',
      'benefit': '75% subsidy',
      'status': 'Available',
      'icon': Icons.water_drop,
      'deadline': '30 Nov 2024',
      'eligibility': 'Farmers with irrigation needs',
      'documents': ['Land Records', 'Project Report', 'Bank Account Details'],
    },
    {
      'name': 'National Agriculture Market (eNAM)',
      'ministry': 'Ministry of Agriculture',
      'description': 'Online trading platform for agricultural commodities.',
      'benefit': 'Better price discovery',
      'status': 'Available',
      'icon': Icons.store,
      'eligibility': 'All farmers',
      'documents': ['Aadhar Card', 'Bank Account Details'],
    },
    {
      'name': 'Kisan Credit Card',
      'ministry': 'Department of Financial Services',
      'description': 'Credit facility for farmers to meet their agricultural and consumption needs.',
      'benefit': 'Up to ₹3 lakh',
      'status': 'Applied',
      'icon': Icons.credit_card,
      'eligibility': 'All farmers',
      'documents': ['Aadhar Card', 'Land Records', 'Bank Account Details'],
    },
  ];
}