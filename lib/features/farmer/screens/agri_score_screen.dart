import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class AgriScoreScreen extends StatelessWidget {
  const AgriScoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Score Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.farmerPrimary, AppColors.farmerPrimary.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    'Your AgriScore',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.3), width: 3),
                    ),
                    child: const Center(
                      child: Text(
                        '785',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Excellent Rating',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Top 15% of farmers in your region',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'Score Breakdown',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 16),

            // Score Factors
            ..._scoreFactors.map((factor) => _buildScoreFactorCard(factor)).toList(),

            const SizedBox(height: 24),

            Text(
              'Improvement Tips',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 16),

            // Tips
            ..._improvementTips.map((tip) => _buildTipCard(tip)).toList(),

            const SizedBox(height: 24),

            // Benefits Card
            Container(
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
                      Icon(Icons.stars, color: AppColors.warning),
                      const SizedBox(width: 8),
                      Text(
                        'Score Benefits',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildBenefitItem('Lower interest rates on loans'),
                  _buildBenefitItem('Priority in government schemes'),
                  _buildBenefitItem('Better price negotiations'),
                  _buildBenefitItem('Insurance premium discounts'),
                  _buildBenefitItem('Access to premium distributors'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreFactorCard(Map<String, dynamic> factor) {
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(factor['icon'], color: AppColors.farmerPrimary),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        factor['title'],
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        factor['description'],
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${factor['score']}/100',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.farmerPrimary,
                      fontSize: 16,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getRatingColor(factor['rating']).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      factor['rating'],
                      style: TextStyle(
                        color: _getRatingColor(factor['rating']),
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
          LinearProgressIndicator(
            value: factor['score'] / 100,
            backgroundColor: Colors.grey.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
              _getRatingColor(factor['rating']),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipCard(Map<String, dynamic> tip) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.info.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.lightbulb_outline, color: AppColors.info),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tip['title'],
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tip['description'],
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
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '+${tip['points']} pts',
              style: TextStyle(
                color: AppColors.success,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(String benefit) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: AppColors.success, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              benefit,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getRatingColor(String rating) {
    switch (rating) {
      case 'Excellent':
        return AppColors.success;
      case 'Good':
        return AppColors.info;
      case 'Average':
        return AppColors.warning;
      case 'Poor':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  static final List<Map<String, dynamic>> _scoreFactors = [
    {
      'title': 'Quality Rating',
      'description': 'Product quality & customer feedback',
      'score': 92,
      'rating': 'Excellent',
      'icon': Icons.star,
    },
    {
      'title': 'Delivery Performance',
      'description': 'On-time delivery & reliability',
      'score': 85,
      'rating': 'Good',
      'icon': Icons.local_shipping,
    },
    {
      'title': 'Transaction History',
      'description': 'Sales volume & frequency',
      'score': 78,
      'rating': 'Good',
      'icon': Icons.history,
    },
    {
      'title': 'Sustainability Practices',
      'description': 'Organic farming & eco-friendly methods',
      'score': 65,
      'rating': 'Average',
      'icon': Icons.eco,
    },
    {
      'title': 'Documentation',
      'description': 'Compliance & record keeping',
      'score': 88,
      'rating': 'Good',
      'icon': Icons.description,
    },
  ];

  static final List<Map<String, dynamic>> _improvementTips = [
    {
      'title': 'Get Quality Certifications',
      'description': 'Obtain organic or quality certifications for your products',
      'points': '25',
    },
    {
      'title': 'Improve Packaging',
      'description': 'Use better packaging materials to reduce damage',
      'points': '15',
    },
    {
      'title': 'Maintain Farm Records',
      'description': 'Keep detailed records of farming practices and expenses',
      'points': '20',
    },
    {
      'title': 'Customer Feedback',
      'description': 'Actively collect and respond to customer feedback',
      'points': '10',
    },
  ];
}