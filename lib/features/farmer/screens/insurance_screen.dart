import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class InsuranceScreen extends StatelessWidget {
  const InsuranceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Crop Insurance'),
        backgroundColor: AppColors.farmerPrimary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Policy Card
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
                      Icon(Icons.security, color: Colors.white, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'Active Policy',
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
                    'PM Fasal Bima Yojana',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Coverage: ₹2,50,000',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Valid until: 31 March 2025',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Stats Row
            Row(
              children: [
                Expanded(
                  child: _buildStatCard('Premium Paid', '₹12,500', AppColors.info),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard('Claims Filed', '0', AppColors.warning),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard('Coverage', '85%', AppColors.success),
                ),
              ],
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

            // Insurance Schemes
            ..._insuranceSchemes.map((scheme) => _buildSchemeCard(context, scheme)).toList(),

            const SizedBox(height: 24),

            Text(
              'Claim History',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 16),

            // No claims message
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
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
                  Icon(
                    Icons.check_circle_outline,
                    color: AppColors.success,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Claims Filed',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Great! Your crops have been healthy. Keep up the good farming practices.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // File Claim Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showClaimDialog(context),
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('File New Claim'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.farmerPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
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
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSchemeCard(BuildContext context, Map<String, dynamic> scheme) {
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
              if (scheme['isActive']) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Active',
                    style: TextStyle(
                      color: AppColors.success,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildInfoItem('Coverage', scheme['coverage']),
              const SizedBox(width: 20),
              _buildInfoItem('Premium', scheme['premium']),
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
          if (!scheme['isActive']) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _applyForScheme(context, scheme),
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
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
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

  void _showClaimDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('File Insurance Claim'),
        content: const Text('To file a new claim, please contact our customer service at 1800-XXX-XXXX or visit the nearest branch with required documents.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
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
        content: const Text('Would you like to apply for this insurance scheme? You will be redirected to the application form.'),
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

  static final List<Map<String, dynamic>> _insuranceSchemes = [
    {
      'name': 'PM Fasal Bima Yojana',
      'type': 'Government Scheme',
      'coverage': '₹2,50,000',
      'premium': '₹12,500/year',
      'description': 'Comprehensive crop insurance covering yield losses due to natural calamities, pests, and diseases.',
      'icon': Icons.agriculture,
      'isActive': true,
    },
    {
      'name': 'Weather Based Crop Insurance',
      'type': 'Private Scheme',
      'coverage': '₹1,50,000',
      'premium': '₹8,000/year',
      'description': 'Protection against weather-related crop losses based on rainfall, temperature, and humidity data.',
      'icon': Icons.cloud,
      'isActive': false,
    },
    {
      'name': 'Livestock Insurance',
      'type': 'Additional Coverage',
      'coverage': '₹50,000',
      'premium': '₹3,000/year',
      'description': 'Insurance coverage for cattle, buffaloes, and other livestock against death and permanent disability.',
      'icon': Icons.pets,
      'isActive': false,
    },
  ];
}