import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import 'register_screen.dart';
import 'login_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  final bool isRegistration;

  const RoleSelectionScreen({
    super.key,
    this.isRegistration = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        title: Text(isRegistration ? 'Join AGRICHAIN' : 'Select Your Role'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.agriculture,
                      size: 64,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'AGRICHAIN',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isRegistration 
                          ? 'Choose your role to get started'
                          : 'Select your role to sign in',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              Text(
                'I am a...',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildRoleCard(
                      context,
                      role: AppConstants.roleFarmer,
                      title: 'Farmer',
                      description: 'Sell your agricultural products',
                      icon: Icons.agriculture,
                      color: AppColors.farmerPrimary,
                    ),
                    _buildRoleCard(
                      context,
                      role: AppConstants.roleDistributor,
                      title: 'Distributor',
                      description: 'Manage logistics & distribution',
                      icon: Icons.local_shipping,
                      color: AppColors.distributorPrimary,
                    ),
                    _buildRoleCard(
                      context,
                      role: AppConstants.roleRetailer,
                      title: 'Retailer',
                      description: 'Source products for your store',
                      icon: Icons.store,
                      color: AppColors.retailerPrimary,
                    ),
                    _buildRoleCard(
                      context,
                      role: AppConstants.roleConsumer,
                      title: 'Consumer',
                      description: 'Buy fresh agricultural products',
                      icon: Icons.person,
                      color: AppColors.consumerPrimary,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Switch between login and register
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isRegistration 
                        ? 'Already have an account? '
                        : 'New to AGRICHAIN? ',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => RoleSelectionScreen(
                          isRegistration: !isRegistration,
                        ),
                      ),
                    ),
                    child: Text(
                      isRegistration ? 'Sign In' : 'Register',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context, {
    required String role,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () => _navigateToAuthScreen(context, role),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 32,
                color: color,
              ),
            ),
            
            const SizedBox(height: 12),
            
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              description,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isRegistration ? 'Register' : 'Sign In',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToAuthScreen(BuildContext context, String role) {
    if (isRegistration) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => RegisterScreen(role: role),
        ),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => LoginScreen(role: role),
        ),
      );
    }
  }
}