import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import 'farmer_registration_screen.dart';
import '../../distributor/screens/distributor_registration_screen.dart';
import '../../retailer/screens/retailer_registration_screen.dart';
import '../../consumer/screens/consumer_registration_screen.dart';

class RegisterScreen extends StatelessWidget {
  final String role;

  const RegisterScreen({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    // Redirect to specialized registration screens for each role
    switch (role) {
      case AppConstants.roleFarmer:
        return const FarmerRegistrationScreen();
      case AppConstants.roleDistributor:
        return const DistributorRegistrationScreen();
      case AppConstants.roleRetailer:
        return const RetailerRegistrationScreen();
      case AppConstants.roleConsumer:
        return const ConsumerRegistrationScreen();
      default:
        return const FarmerRegistrationScreen();
    }
  }
}