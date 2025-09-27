import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class RetailerDashboard extends StatelessWidget {
  const RetailerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Retailer Dashboard'),
        backgroundColor: AppColors.retailerPrimary,
      ),
      body: const Center(
        child: Text('Retailer Dashboard - Coming Soon'),
      ),
    );
  }
}