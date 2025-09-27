import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../providers/auth_provider.dart';
import '../../farmer/screens/farmer_dashboard.dart';
import '../../distributor/screens/distributor_dashboard.dart';
import '../../retailer/screens/retailer_dashboard.dart';
import '../../consumer/screens/consumer_dashboard.dart';

class LoginScreen extends StatefulWidget {
  final String role;

  const LoginScreen({super.key, required this.role});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String get _roleTitle {
    switch (widget.role) {
      case AppConstants.roleFarmer:
        return 'Farmer';
      case AppConstants.roleDistributor:
        return 'Distributor';
      case AppConstants.roleRetailer:
        return 'Retailer';
      case AppConstants.roleConsumer:
        return 'Consumer';
      default:
        return 'User';
    }
  }

  Color get _roleColor {
    switch (widget.role) {
      case AppConstants.roleFarmer:
        return AppColors.farmerPrimary;
      case AppConstants.roleDistributor:
        return AppColors.distributorPrimary;
      case AppConstants.roleRetailer:
        return AppColors.retailerPrimary;
      case AppConstants.roleConsumer:
        return AppColors.consumerPrimary;
      default:
        return AppColors.primary;
    }
  }

  Widget get _nextScreen {
    switch (widget.role) {
      case AppConstants.roleFarmer:
        return const FarmerDashboard();
      case AppConstants.roleDistributor:
        return const DistributorDashboard();
      case AppConstants.roleRetailer:
        return const RetailerDashboard();
      case AppConstants.roleConsumer:
        return const ConsumerDashboard();
      default:
        return const FarmerDashboard();
    }
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text,
      widget.role,
    );

    setState(() => _isLoading = false);

    if (success) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => _nextScreen),
      );
    } else {
      _showErrorSnackBar(authProvider.error ?? 'Login failed');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  void _navigateToRegister() {
    // Navigate to registration screen
    // This would be implemented based on the role
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: _roleColor,
        title: Text('$_roleTitle Login'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              
              // Role Icon
              Container(
                width: 80,
                height: 80,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: _roleColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  _getRoleIcon(),
                  size: 40,
                  color: _roleColor,
                ),
              ),
              
              Text(
                'Welcome Back, $_roleTitle!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 8),
              
              Text(
                'Sign in to continue to your dashboard',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 48),
              
              // Email Field
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined, color: _roleColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Password Field
              TextFormField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock_outline, color: _roleColor),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 24),
              
              // Login Button
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _roleColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : Text(
                          'Login',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Forgot Password
              TextButton(
                onPressed: () {
                  // Handle forgot password
                },
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(color: _roleColor),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Divider
              const Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('OR'),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Register Button
              OutlinedButton(
                onPressed: _navigateToRegister,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: _roleColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  'New $_roleTitle? Register Here',
                  style: TextStyle(color: _roleColor),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Demo Login Info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _roleColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _roleColor.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Text(
                      'Demo Login',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _roleColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Email: demo@${widget.role}.com\nPassword: 123456',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getRoleIcon() {
    switch (widget.role) {
      case AppConstants.roleFarmer:
        return Icons.agriculture;
      case AppConstants.roleDistributor:
        return Icons.local_shipping;
      case AppConstants.roleRetailer:
        return Icons.store;
      case AppConstants.roleConsumer:
        return Icons.shopping_cart;
      default:
        return Icons.person;
    }
  }
}