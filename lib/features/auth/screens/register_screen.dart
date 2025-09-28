import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import 'farmer_registration_screen.dart';
import '../../farmer/screens/farmer_dashboard.dart';
import '../../distributor/screens/distributor_dashboard.dart';
import '../../retailer/screens/retailer_dashboard.dart';
import '../../consumer/screens/consumer_dashboard.dart';

class RegisterScreen extends StatefulWidget {
  final String role;

  const RegisterScreen({super.key, required this.role});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _addressController = TextEditingController();
  
  // Role-specific controllers
  final _landSizeController = TextEditingController(); // For Farmer
  final _vehicleCountController = TextEditingController(); // For Distributor
  final _storeTypeController = TextEditingController(); // For Retailer
  
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  bool _agreeToTerms = false;
  
  String _selectedStoreType = 'Grocery Store'; // For Retailer

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _addressController.dispose();
    _landSizeController.dispose();
    _vehicleCountController.dispose();
    _storeTypeController.dispose();
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

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (!_agreeToTerms) {
      _showErrorSnackBar('Please agree to Terms & Conditions');
      return;
    }

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Prepare registration data
    Map<String, dynamic> userData = {
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'phone': _phoneController.text.trim(),
      'password': _passwordController.text,
      'address': _addressController.text.trim(),
      'role': widget.role,
    };

    // Add role-specific data
    switch (widget.role) {
      case AppConstants.roleFarmer:
        userData['landSize'] = double.tryParse(_landSizeController.text) ?? 0.0;
        break;
      case AppConstants.roleDistributor:
        userData['vehicleCount'] = int.tryParse(_vehicleCountController.text) ?? 0;
        break;
      case AppConstants.roleRetailer:
        userData['storeType'] = _selectedStoreType;
        break;
    }

    final success = await authProvider.register(userData);

    setState(() => _isLoading = false);

    if (success) {
      _showSuccessDialog();
    } else {
      _showErrorSnackBar(authProvider.error ?? 'Registration failed');
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success),
            const SizedBox(width: 8),
            const Text('Success!'),
          ],
        ),
        content: Text('Your $_roleTitle account has been created successfully!'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => _nextScreen),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: _roleColor),
            child: const Text('Continue', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => LoginScreen(role: widget.role),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // For farmers, redirect to specialized registration screen
    if (widget.role == AppConstants.roleFarmer) {
      return const FarmerRegistrationScreen();
    }
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: _roleColor,
        foregroundColor: Colors.white,
        title: Text('$_roleTitle Registration'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _roleColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _getRoleIcon(),
                        size: 48,
                        color: _roleColor,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Join as a $_roleTitle',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _roleColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getRoleDescription(),
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Basic Information
                _buildSectionTitle('Personal Information'),
                const SizedBox(height: 16),
                
                _buildTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  icon: Icons.person,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your full name';
                    }
                    if (value.length < 2) {
                      return 'Name must be at least 2 characters';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                _buildTextField(
                  controller: _emailController,
                  label: 'Email Address',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                _buildTextField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    if (value.length < 10) {
                      return 'Please enter a valid phone number';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                _buildTextField(
                  controller: _addressController,
                  label: 'Address',
                  icon: Icons.location_on,
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your address';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // Role-specific fields
                if (_shouldShowRoleSpecificFields()) ...[
                  _buildSectionTitle('${_roleTitle} Information'),
                  const SizedBox(height: 16),
                  ..._buildRoleSpecificFields(),
                  const SizedBox(height: 24),
                ],

                // Security Information
                _buildSectionTitle('Security'),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _passwordController,
                  label: 'Password',
                  icon: Icons.lock,
                  obscureText: !_isPasswordVisible,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                _buildTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirm Password',
                  icon: Icons.lock_outline,
                  obscureText: !_isConfirmPasswordVisible,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // Terms and Conditions
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: _agreeToTerms,
                      onChanged: (value) => setState(() => _agreeToTerms = value ?? false),
                      activeColor: _roleColor,
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _agreeToTerms = !_agreeToTerms),
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                            children: [
                              const TextSpan(text: 'I agree to the '),
                              TextSpan(
                                text: 'Terms & Conditions',
                                style: TextStyle(
                                  color: _roleColor,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              const TextSpan(text: ' and '),
                              TextSpan(
                                text: 'Privacy Policy',
                                style: TextStyle(
                                  color: _roleColor,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Register Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _roleColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Create $_roleTitle Account',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),

                const SizedBox(height: 24),

                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    GestureDetector(
                      onTap: _navigateToLogin,
                      child: Text(
                        'Sign In',
                        style: TextStyle(
                          color: _roleColor,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: _roleColor),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _roleColor, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.error, width: 2),
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
        return Icons.person;
      default:
        return Icons.person;
    }
  }

  String _getRoleDescription() {
    switch (widget.role) {
      case AppConstants.roleFarmer:
        return 'Sell your agricultural products directly to distributors and retailers';
      case AppConstants.roleDistributor:
        return 'Connect farmers with retailers and manage logistics efficiently';
      case AppConstants.roleRetailer:
        return 'Source quality products from farmers and distributors for your store';
      case AppConstants.roleConsumer:
        return 'Buy fresh agricultural products at the best prices';
      default:
        return 'Join the agricultural supply chain ecosystem';
    }
  }

  bool _shouldShowRoleSpecificFields() {
    return widget.role != AppConstants.roleConsumer;
  }

  List<Widget> _buildRoleSpecificFields() {
    switch (widget.role) {
      case AppConstants.roleFarmer:
        return [
          _buildTextField(
            controller: _landSizeController,
            label: 'Land Size (in acres)',
            icon: Icons.landscape,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your land size';
              }
              if (double.tryParse(value) == null || double.parse(value) <= 0) {
                return 'Please enter a valid land size';
              }
              return null;
            },
          ),
        ];
      
      case AppConstants.roleDistributor:
        return [
          _buildTextField(
            controller: _vehicleCountController,
            label: 'Number of Vehicles',
            icon: Icons.local_shipping,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter number of vehicles';
              }
              if (int.tryParse(value) == null || int.parse(value) < 0) {
                return 'Please enter a valid number';
              }
              return null;
            },
          ),
        ];
      
      case AppConstants.roleRetailer:
        return [
          DropdownButtonFormField<String>(
            value: _selectedStoreType,
            decoration: InputDecoration(
              labelText: 'Store Type',
              prefixIcon: Icon(Icons.store, color: _roleColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: _roleColor, width: 2),
              ),
            ),
            items: [
              'Grocery Store',
              'Supermarket',
              'Organic Store',
              'Farmers Market',
              'Online Store',
              'Other',
            ].map((type) => DropdownMenuItem(
              value: type,
              child: Text(type),
            )).toList(),
            onChanged: (value) => setState(() => _selectedStoreType = value!),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a store type';
              }
              return null;
            },
          ),
        ];
      
      default:
        return [];
    }
  }
}