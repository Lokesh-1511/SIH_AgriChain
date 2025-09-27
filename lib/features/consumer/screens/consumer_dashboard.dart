import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class ConsumerDashboard extends StatelessWidget {
  const ConsumerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Consumer Dashboard'),
        backgroundColor: AppColors.consumerPrimary,
      ),
      body: const Center(
        child: Text('Consumer Dashboard - Coming Soon'),
      ),
    );
  }
}