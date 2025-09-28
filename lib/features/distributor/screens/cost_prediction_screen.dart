import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class CostPredictionScreen extends StatelessWidget {
  const CostPredictionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('AI Cost Prediction'),
        backgroundColor: AppColors.distributorPrimary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Prediction Summary Card
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
                      Icon(Icons.psychology, color: Colors.white, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'AI Cost Prediction',
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
                    'Next Week Delivery Cost',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₹18,450',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '↓ 12% decrease from current week',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Cost Breakdown
            Text(
              'Cost Breakdown',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 16),

            ..._costCategories.map(
              (category) => _buildCostCategoryCard(category),
            ),

            const SizedBox(height: 24),

            // Factors Affecting Cost
            Text(
              'Factors Affecting Cost',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 16),

            ..._costFactors.map((factor) => _buildFactorCard(factor)),

            const SizedBox(height: 24),

            // AI Recommendations
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
                      Icon(Icons.lightbulb_outline, color: AppColors.warning),
                      const SizedBox(width: 8),
                      Text(
                        'AI Recommendations',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ..._recommendations.map(
                    (rec) => _buildRecommendationItem(rec),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Route Optimization Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showRouteOptimization(context),
                icon: const Icon(Icons.route),
                label: const Text('Optimize Routes for Cost Saving'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.distributorPrimary,
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

  Widget _buildCostCategoryCard(Map<String, dynamic> category) {
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: category['color'].withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(category['icon'], color: category['color']),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category['name'],
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  category['description'],
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
                '₹${category['cost']}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: category['color'],
                  fontSize: 16,
                ),
              ),
              Text(
                '${category['percentage']}%',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFactorCard(Map<String, dynamic> factor) {
    Color impactColor = _getImpactColor(factor['impact']);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: impactColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: impactColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(factor['icon'], color: impactColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  factor['name'],
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
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: impactColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              factor['impact'],
              style: TextStyle(
                color: impactColor,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationItem(String recommendation) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: AppColors.success, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              recommendation,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Color _getImpactColor(String impact) {
    switch (impact) {
      case 'High':
        return AppColors.error;
      case 'Medium':
        return AppColors.warning;
      case 'Low':
        return AppColors.success;
      default:
        return AppColors.textSecondary;
    }
  }

  void _showRouteOptimization(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Route Optimization'),
        content: const Text(
          'AI has analyzed your delivery routes and found potential savings of ₹2,340 per week through optimized routing.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('View Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Route optimization applied successfully!'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.distributorPrimary,
            ),
            child: const Text(
              'Apply Optimization',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  static final List<Map<String, dynamic>> _costCategories = [
    {
      'name': 'Fuel Cost',
      'description': 'Diesel and transportation fuel',
      'cost': '8,500',
      'percentage': '46',
      'color': AppColors.distributorPrimary,
      'icon': Icons.local_gas_station,
    },
    {
      'name': 'Vehicle Maintenance',
      'description': 'Repairs and servicing',
      'cost': '3,200',
      'percentage': '17',
      'color': AppColors.warning,
      'icon': Icons.build,
    },
    {
      'name': 'Driver Wages',
      'description': 'Salary and overtime',
      'cost': '4,500',
      'percentage': '24',
      'color': AppColors.info,
      'icon': Icons.person,
    },
    {
      'name': 'Insurance & Permits',
      'description': 'Vehicle insurance and permits',
      'cost': '1,250',
      'percentage': '7',
      'color': AppColors.success,
      'icon': Icons.security,
    },
    {
      'name': 'Other Expenses',
      'description': 'Tolls, parking, misc',
      'cost': '1,000',
      'percentage': '6',
      'color': AppColors.textSecondary,
      'icon': Icons.more_horiz,
    },
  ];

  static final List<Map<String, dynamic>> _costFactors = [
    {
      'name': 'Fuel Price Trend',
      'description': 'Diesel prices expected to decrease by 3%',
      'impact': 'Low',
      'icon': Icons.trending_down,
    },
    {
      'name': 'Route Optimization',
      'description': 'Current routes have 18% optimization potential',
      'impact': 'High',
      'icon': Icons.route,
    },
    {
      'name': 'Vehicle Utilization',
      'description': 'Average load capacity at 78%',
      'impact': 'Medium',
      'icon': Icons.local_shipping,
    },
    {
      'name': 'Seasonal Demand',
      'description': 'High demand season approaching',
      'impact': 'Medium',
      'icon': Icons.trending_up,
    },
  ];

  static final List<String> _recommendations = [
    'Consolidate deliveries to nearby locations to reduce fuel costs',
    'Schedule maintenance during low-demand periods',
    'Use AI route optimization to save 18% on fuel',
    'Negotiate bulk fuel discounts with suppliers',
    'Optimize vehicle load distribution for better efficiency',
  ];
}
