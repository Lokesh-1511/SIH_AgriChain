import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class CropAdvisoryScreen extends StatelessWidget {
  const CropAdvisoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Weather Alert Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.warning, AppColors.warning.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Weather Alert',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Heavy rain expected in 2 days. Avoid spraying pesticides.',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'Today\'s Recommendations',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 16),

            // Today's Tasks
            ..._todaysTasks.map((task) => _buildTaskCard(task)).toList(),

            const SizedBox(height: 24),

            Text(
              'Crop Health Monitor',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 16),

            // Crop Health Cards
            ..._cropHealth.map((crop) => _buildCropHealthCard(crop)).toList(),

            const SizedBox(height: 24),

            Text(
              'Expert Articles',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 16),

            // Articles
            ..._articles.map((article) => _buildArticleCard(article)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskCard(Map<String, dynamic> task) {
    Color priorityColor = _getPriorityColor(task['priority']);
    
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
              color: priorityColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(task['icon'], color: priorityColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task['title'],
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  task['description'],
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      task['time'],
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: priorityColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        task['priority'],
                        style: TextStyle(
                          color: priorityColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Checkbox(
            value: task['completed'],
            onChanged: (value) {},
            activeColor: AppColors.success,
          ),
        ],
      ),
    );
  }

  Widget _buildCropHealthCard(Map<String, dynamic> crop) {
    Color healthColor = _getHealthColor(crop['health']);
    
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
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: healthColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    crop['emoji'],
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      crop['name'],
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Area: ${crop['area']} | Age: ${crop['age']}',
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: healthColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      crop['health'],
                      style: TextStyle(
                        color: healthColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${crop['score']}/100',
                    style: TextStyle(
                      color: healthColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: crop['score'] / 100,
            backgroundColor: Colors.grey.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(healthColor),
          ),
          if (crop['issues'] != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.error.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: AppColors.error, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      crop['issues'],
                      style: TextStyle(
                        color: AppColors.error,
                        fontSize: 12,
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

  Widget _buildArticleCard(Map<String, dynamic> article) {
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
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.farmerPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              article['icon'],
              color: AppColors.farmerPrimary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  article['title'],
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  article['summary'],
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      article['author'],
                      style: TextStyle(
                        color: AppColors.farmerPrimary,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      ' • ${article['readTime']}',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: AppColors.textSecondary,
            size: 16,
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
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

  Color _getHealthColor(String health) {
    switch (health) {
      case 'Excellent':
        return AppColors.success;
      case 'Good':
        return AppColors.info;
      case 'Fair':
        return AppColors.warning;
      case 'Poor':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  static final List<Map<String, dynamic>> _todaysTasks = [
    {
      'title': 'Apply Fertilizer',
      'description': 'NPK fertilizer for tomato field - Section A',
      'time': '6:00 AM - 8:00 AM',
      'priority': 'High',
      'icon': Icons.scatter_plot,
      'completed': false,
    },
    {
      'title': 'Check Irrigation',
      'description': 'Inspect drip irrigation system for blockages',
      'time': '9:00 AM - 10:00 AM',
      'priority': 'Medium',
      'icon': Icons.water_drop,
      'completed': true,
    },
    {
      'title': 'Pest Control',
      'description': 'Spray neem oil on carrot crop - aphid prevention',
      'time': '5:00 PM - 6:00 PM',
      'priority': 'High',
      'icon': Icons.bug_report,
      'completed': false,
    },
    {
      'title': 'Soil Testing',
      'description': 'Collect soil samples from new planting area',
      'time': '11:00 AM - 12:00 PM',
      'priority': 'Low',
      'icon': Icons.science,
      'completed': false,
    },
  ];

  static final List<Map<String, dynamic>> _cropHealth = [
    {
      'name': 'Tomatoes',
      'emoji': '🍅',
      'area': '2.5 acres',
      'age': '45 days',
      'health': 'Excellent',
      'score': 92,
    },
    {
      'name': 'Onions',
      'emoji': '🧅',
      'area': '1.8 acres',
      'age': '60 days',
      'health': 'Good',
      'score': 78,
      'issues': 'Minor leaf spotting detected - apply fungicide',
    },
    {
      'name': 'Carrots',
      'emoji': '🥕',
      'area': '1.2 acres',
      'age': '35 days',
      'health': 'Fair',
      'score': 65,
      'issues': 'Aphid infestation - immediate treatment required',
    },
  ];

  static final List<Map<String, dynamic>> _articles = [
    {
      'title': 'Integrated Pest Management for Vegetable Crops',
      'summary': 'Learn sustainable pest control methods that protect your crops and the environment.',
      'author': 'Dr. Agricultural Expert',
      'readTime': '5 min read',
      'icon': Icons.eco,
    },
    {
      'title': 'Optimizing Irrigation for Better Yields',
      'summary': 'Water management techniques to maximize crop productivity while conserving resources.',
      'author': 'Irrigation Specialist',
      'readTime': '7 min read',
      'icon': Icons.water_drop,
    },
    {
      'title': 'Organic Fertilizers: Benefits and Application',
      'summary': 'How to use organic fertilizers effectively for healthier soil and better crops.',
      'author': 'Soil Science Expert',
      'readTime': '6 min read',
      'icon': Icons.grass,
    },
  ];
}