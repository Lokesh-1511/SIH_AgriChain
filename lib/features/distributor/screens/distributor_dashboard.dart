import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class DistributorDashboard extends StatelessWidget {
  const DistributorDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Distributor Dashboard'),
        backgroundColor: AppColors.distributorPrimary,
      ),
      body: const Center(
        child: Text('Distributor Dashboard - Coming Soon'),
      ),
    );
  }
}