import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../providers/auth_provider.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
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

<<<<<<< HEAD
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

=======
>>>>>>> 5b3ae447a7a6f15554647b4ed5c427121e8f156b
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

    if (!mounted) return; // Check if widget is still mounted

    setState(() => _isLoading = false);

    if (success && authProvider.currentUser != null) {
      // Navigate to appropriate dashboard based on user role
      Widget destination;
      switch (authProvider.currentUser!.role.name) {
        case AppConstants.roleFarmer:
          destination = const FarmerDashboard();
          break;
        case AppConstants.roleDistributor:
          destination = const DistributorDashboard();
          break;
        case AppConstants.roleRetailer:
          destination = const RetailerDashboard();
          break;
        case AppConstants.roleConsumer:
          destination = const ConsumerDashboard();
          break;
        default:
          destination = _nextScreen;
      }

      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => destination));
    } else {
<<<<<<< HEAD
      _showErrorSnackBar(authProvider.error ?? 'Login failed');
=======
      // Check if it's a role validation error
      if (authProvider.error != null &&
          (authProvider.error!.contains('registered as') ||
              authProvider.error!.contains('This account is'))) {
        _showRoleValidationDialog(authProvider.error!);
      } else {
        _showErrorSnackBar(authProvider.error ?? 'auth.login_failed'.tr());
      }
>>>>>>> 5b3ae447a7a6f15554647b4ed5c427121e8f156b
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

<<<<<<< HEAD
=======
  void _showRoleValidationDialog(String errorMessage) {
    // Extract the actual role from the error message with multiple patterns
    String actualRole = 'unknown';

    // Try different regex patterns to extract role
    final patterns = [
      RegExp(r'registered as (\w+)', caseSensitive: false),
      RegExp(r'account is (\w+)', caseSensitive: false),
      RegExp(r'role is (\w+)', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(errorMessage);
      if (match != null && match.group(1) != null) {
        actualRole = match.group(1)!.toLowerCase();
        break;
      }
    }

    // Get role-specific colors
    Color roleColor;
    Color roleBackgroundColor;
    IconData roleIcon;

    switch (actualRole.toLowerCase()) {
      case 'farmer':
        roleColor = AppColors.farmerPrimary;
        roleBackgroundColor = AppColors.farmerPrimary.withOpacity(0.1);
        roleIcon = Icons.agriculture;
        break;
      case 'distributor':
        roleColor = AppColors.distributorPrimary;
        roleBackgroundColor = AppColors.distributorPrimary.withOpacity(0.1);
        roleIcon = Icons.local_shipping;
        break;
      case 'retailer':
        roleColor = AppColors.retailerPrimary;
        roleBackgroundColor = AppColors.retailerPrimary.withOpacity(0.1);
        roleIcon = Icons.store;
        break;
      case 'consumer':
        roleColor = AppColors.consumerPrimary;
        roleBackgroundColor = AppColors.consumerPrimary.withOpacity(0.1);
        roleIcon = Icons.shopping_cart;
        break;
      default:
        roleColor = AppColors.primary;
        roleBackgroundColor = AppColors.primary.withOpacity(0.1);
        roleIcon = Icons.person;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 10,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Warning Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.warning,
                    size: 40,
                  ),
                ),

                const SizedBox(height: 20),

                // Title
                Text(
                  'Wrong Login Type',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                // Description
                Text(
                  'This account is registered as:',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                // Role Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: roleBackgroundColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: roleColor.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(roleIcon, color: roleColor, size: 28),
                      const SizedBox(width: 12),
                      Text(
                        actualRole.toUpperCase(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: roleColor,
                          fontSize: 20,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Instructions
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    'Please go back and use the correct ${actualRole.toUpperCase()} login option.',
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.textPrimary,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 24),

                // Action Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close dialog
                      Navigator.of(context).pop(); // Go back to landing screen
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: roleColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: Text(
                      'Go Back to Login Selection',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

>>>>>>> 5b3ae447a7a6f15554647b4ed5c427121e8f156b
  void _navigateToRegister() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => RegisterScreen(role: widget.role)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: _roleColor,
<<<<<<< HEAD
        title: Text('$_roleTitle Login'),
=======
        title: Text('auth.login_title'.tr()),
>>>>>>> 5b3ae447a7a6f15554647b4ed5c427121e8f156b
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
                child: Icon(_getRoleIcon(), size: 40, color: _roleColor),
              ),

              Text(
                'auth.login_title'.tr(),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              Text(
                'auth.login_subtitle'.tr(),
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              // Email Field
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  labelText: 'common.email'.tr(),
                  labelStyle: TextStyle(color: AppColors.textSecondary),
                  prefixIcon: Icon(Icons.email_outlined, color: _roleColor),

                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: _roleColor,
                      width: 1,
                    ), // light grey border
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: _roleColor,
                      width: 2,
                    ), // colored border when focused
                  ),
                ),

                validator: (value) {
                  if (value == null || value.isEmpty) {
<<<<<<< HEAD
                    return 'Please enter your email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
=======
                    return 'auth.email_required'.tr();
                  }
                  if (!value.contains('@')) {
                    return 'auth.invalid_email'.tr();
>>>>>>> 5b3ae447a7a6f15554647b4ed5c427121e8f156b
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Password Field
              TextFormField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                style: TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  labelText: 'common.password'.tr(),
                  labelStyle: TextStyle(color: AppColors.textSecondary),
                  prefixIcon: Icon(Icons.lock_outline, color: _roleColor),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: _roleColor,
                      width: 1,
                    ), // light grey border
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: _roleColor,
                      width: 2,
                    ), // colored border when focused
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
<<<<<<< HEAD
                    return 'Please enter your password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
=======
                    return 'auth.password_required'.tr();
                  }
                  if (value.length < 6) {
                    return 'auth.password_too_short'.tr();
>>>>>>> 5b3ae447a7a6f15554647b4ed5c427121e8f156b
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
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        )
                      : Text(
                          'common.login'.tr(),
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ForgotPasswordScreen(role: widget.role),
                    ),
                  );
                },
                child: Text(
<<<<<<< HEAD
                  'Forgot Password?',
=======
                  'auth.forgot_password'.tr(),
>>>>>>> 5b3ae447a7a6f15554647b4ed5c427121e8f156b
                  style: TextStyle(color: _roleColor),
                ),
              ),

              const SizedBox(height: 24),

              // Divider
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: AppColors.textSecondary,
                      thickness: 1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
<<<<<<< HEAD
                      'OR',
=======
                      'common.or'.tr(),
>>>>>>> 5b3ae447a7a6f15554647b4ed5c427121e8f156b
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: AppColors.textSecondary,
                      thickness: 1,
                    ),
                  ),
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
<<<<<<< HEAD
                  'New $_roleTitle? Register Here',
=======
                  'auth.dont_have_account'.tr(),
>>>>>>> 5b3ae447a7a6f15554647b4ed5c427121e8f156b
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
<<<<<<< HEAD
                      'Demo Login',
=======
                      'auth.demo_login'.tr(),
>>>>>>> 5b3ae447a7a6f15554647b4ed5c427121e8f156b
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _roleColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
<<<<<<< HEAD
                      'Email: demo@${widget.role}.com\nPassword: 123456',
=======
                      '${'auth.demo_email'.tr()}: demo@${widget.role}.com\n${'auth.demo_password'.tr()}: 123456',
>>>>>>> 5b3ae447a7a6f15554647b4ed5c427121e8f156b
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
