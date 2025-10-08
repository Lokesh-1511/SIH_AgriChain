import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class DistributorStatsCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const DistributorStatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
<<<<<<< HEAD
      padding: const EdgeInsets.all(16),
=======
      padding: const EdgeInsets.all(12),
>>>>>>> 5b3ae447a7a6f15554647b4ed5c427121e8f156b
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
<<<<<<< HEAD
=======
        mainAxisSize: MainAxisSize.min,
>>>>>>> 5b3ae447a7a6f15554647b4ed5c427121e8f156b
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
<<<<<<< HEAD
                padding: const EdgeInsets.all(8),
=======
                padding: const EdgeInsets.all(6),
>>>>>>> 5b3ae447a7a6f15554647b4ed5c427121e8f156b
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
<<<<<<< HEAD
                child: Icon(icon, color: color, size: 20),
              ),
              Icon(Icons.trending_up, color: AppColors.success, size: 16),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(fontSize: 10, color: AppColors.success),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
=======
                child: Icon(icon, color: color, size: 18),
              ),
              Icon(Icons.trending_up, color: AppColors.success, size: 14),
            ],
          ),
          const SizedBox(height: 8),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 2),
          Flexible(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 2),
          Flexible(
            child: Text(
              subtitle,
              style: TextStyle(fontSize: 9, color: AppColors.success),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
>>>>>>> 5b3ae447a7a6f15554647b4ed5c427121e8f156b
          ),
        ],
      ),
    );
  }
}
