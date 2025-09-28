import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class ProductInventoryCard extends StatelessWidget {
  final String name;
  final String category;
  final double price;
  final int stock;
  final int minStock;
  final String image;
  final EdgeInsets? margin;
  final double? width;

  const ProductInventoryCard({
    super.key,
    required this.name,
    required this.category,
    required this.price,
    required this.stock,
    required this.minStock,
    required this.image,
    this.margin,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    bool isLowStock = stock <= minStock;
    
    return Container(
      width: width,
      margin: margin ?? const EdgeInsets.all(8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isLowStock ? Border.all(color: AppColors.warning, width: 2) : null,
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
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.retailerPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    image,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      category,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Text(
            '₹${price.toStringAsFixed(0)}/kg',
            style: TextStyle(
              color: AppColors.retailerPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Stock',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    '$stock kg',
                    style: TextStyle(
                      color: isLowStock ? AppColors.warning : AppColors.success,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              if (isLowStock)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Low Stock',
                    style: TextStyle(
                      color: AppColors.warning,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          LinearProgressIndicator(
            value: (stock / (minStock * 2)).clamp(0.0, 1.0),
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              isLowStock ? AppColors.warning : AppColors.success,
            ),
          ),
        ],
      ),
    );
  }
}