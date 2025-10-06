// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/simple_aadhaar_widget.dart';

import '../../../core/services/aadhaar_state_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../screens/consumer_dashboard.dart';

class ConsumerRegistrationScreen extends StatefulWidget {
  const ConsumerRegistrationScreen({super.key});

  @override
  State<ConsumerRegistrationScreen> createState() =>
      _ConsumerRegistrationScreenState();
}

class _ConsumerRegistrationScreenState
    extends State<ConsumerRegistrationScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  bool _isLoading = false;

  // Form Controllers
  final _personalFormKey = GlobalKey<FormState>();

  final _preferencesFormKey = GlobalKey<FormState>();
  final _securityFormKey = GlobalKey<FormState>();

  // Personal Information
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  // Aadhaar Verification
  bool _aadhaarVerified = false;
  Map<String, dynamic>? _kycDetails;

  // Preferences
  final _dietaryPreferencesController = TextEditingController();
  final _allergyInfoController = TextEditingController();
  String _preferredDeliveryTime = 'morning';
  bool _organicPreference = false;
  bool _localProductsPreference = false;

  // Security
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _agreeToTerms = false;

  // Generated ID
  String? _generatedConsumerId;

  @override
  void initState() {
    super.initState();
    _loadSavedVerificationState();
  }

  /// Load saved Aadhaar verification state from local storage
  Future<void> _loadSavedVerificationState() async {
    try {
      final savedState = await AadhaarStateService.loadVerificationState(
        userId: _generatedConsumerId ?? 'temp_consumer',
        userRole: 'consumer',
      );

      if (savedState != null && savedState.isVerified) {
        setState(() {
          _aadhaarVerified = true;
          _kycDetails = savedState.kycDetails;
        });
        debugPrint('✅ Restored Aadhaar verification state for consumer');
      }
    } catch (e) {
      debugPrint('❌ Failed to load saved verification state: $e');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();

    _dietaryPreferencesController.dispose();
    _allergyInfoController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.consumerPrimary,
        foregroundColor: Colors.white,
        title: const Text('Consumer Registration'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Progress Indicator
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.consumerPrimary,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: _buildProgressIndicator(),
          ),

          // Page Content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) => setState(() => _currentStep = index),
              children: [
                _buildPersonalInfoStep(),
                _buildAadhaarVerificationStep(),
                _buildPreferencesStep(),
                _buildSecurityStep(),
                _buildSuccessStep(),
              ],
            ),
          ),

          // Navigation Buttons
          if (_currentStep < 4) _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Column(
      children: [
        Row(
          children: [
            Icon(Icons.shopping_cart, color: Colors.white, size: 24),
            const SizedBox(width: 8),
            Text(
              'Join as a Consumer',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: List.generate(4, (index) {
            return Expanded(
              child: Container(
                margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
                height: 4,
                decoration: BoxDecoration(
                  color: index <= _currentStep
                      ? Colors.white
                      : Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Text(
          _getStepTitle(),
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
      ],
    );
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case 0:
        return 'Personal Information';
      case 1:
        return 'Aadhaar Verification';
      case 2:
        return 'Preferences';
      case 3:
        return 'Security Setup';
      case 4:
        return 'Registration Complete';
      default:
        return '';
    }
  }

  Widget _buildPersonalInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _personalFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildStepHeader(
              'Personal Information',
              'Enter your basic details to get started',
              Icons.person,
            ),
            const SizedBox(height: 24),
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
                if (!RegExp(
                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                ).hasMatch(value)) {
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
              label: 'Delivery Address',
              icon: Icons.location_on,
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your delivery address';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAadhaarVerificationStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildStepHeader(
            'Aadhaar Verification',
            'Verify your identity with Aadhaar for secure shopping',
            Icons.verified_user,
          ),
          const SizedBox(height: 24),

          // Simple Aadhaar Verification Widget
          SimpleAadhaarWidget(
            primaryColor: AppColors.consumerPrimary,
            onVerificationComplete: (isVerified, kycData) {
              debugPrint(
                '📥 Consumer verification callback: isVerified=$isVerified',
              );

              setState(() {
                _aadhaarVerified = isVerified;
                _kycDetails = kycData;
              });

              debugPrint(
                '📊 Consumer current state: _aadhaarVerified=$_aadhaarVerified',
              );

              if (isVerified && kycData != null) {
                // Auto-fill name from KYC if available
                if (_nameController.text.isEmpty &&
                    kycData['name'] != null &&
                    kycData['name'].toString().isNotEmpty) {
                  _nameController.text = kycData['name'];
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Aadhaar verified successfully! Welcome ${kycData['name'] ?? 'User'}',
                    ),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _preferencesFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildStepHeader(
              'Shopping Preferences',
              'Tell us about your preferences for better recommendations',
              Icons.favorite,
            ),
            const SizedBox(height: 24),

            _buildTextField(
              controller: _dietaryPreferencesController,
              label: 'Dietary Preferences (Optional)',
              icon: Icons.restaurant,
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _allergyInfoController,
              label: 'Allergy Information (Optional)',
              icon: Icons.warning,
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            // Preferred Delivery Time Dropdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.consumerPrimary),
                borderRadius: BorderRadius.circular(20),
              ),
              child: DropdownButtonFormField<String>(
                value: _preferredDeliveryTime,
                dropdownColor: Colors.white,
                decoration: InputDecoration(
                  labelText: 'Preferred Delivery Time',
                  labelStyle: TextStyle(color: AppColors.textSecondary),
                  prefixIcon: Icon(
                    Icons.schedule,
                    color: AppColors.consumerPrimary,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'morning',
                    child: Text(
                      'Morning (6AM - 12PM)',
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'afternoon',
                    child: Text(
                      'Afternoon (12PM - 6PM)',
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'evening',
                    child: Text(
                      'Evening (6PM - 10PM)',
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'any',
                    child: Text(
                      'Any time',
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                  ),
                ],
                onChanged: (value) =>
                    setState(() => _preferredDeliveryTime = value!),
              ),
            ),

            const SizedBox(height: 24),

            // Preference Switches
            Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                border: Border.all(color: AppColors.consumerPrimary),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Product Preferences',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),

                    SwitchListTile(
                      title: const Text(
                        'Prefer Organic Products',
                        style: TextStyle(color: AppColors.textPrimary),
                      ),
                      subtitle: const Text(
                        'Get recommendations for organic products',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      value: _organicPreference,
                      onChanged: (value) =>
                          setState(() => _organicPreference = value),
                      activeColor: AppColors.consumerPrimary,
                      inactiveTrackColor: AppColors.border,
                      contentPadding: EdgeInsets.zero,
                    ),

                    SwitchListTile(
                      title: const Text(
                        'Prefer Local Products',
                        style: TextStyle(color: AppColors.textPrimary),
                      ),
                      subtitle: const Text(
                        'Support local farmers and reduce carbon footprint',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      value: _localProductsPreference,
                      onChanged: (value) =>
                          setState(() => _localProductsPreference = value),
                      activeColor: AppColors.consumerPrimary,
                      inactiveTrackColor: AppColors.border,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _securityFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildStepHeader(
              'Security Setup',
              'Create a secure password for your account',
              Icons.lock,
            ),
            const SizedBox(height: 24),

            _buildTextField(
              controller: _passwordController,
              label: 'Password',
              icon: Icons.lock,
              obscureText: !_isPasswordVisible,
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                ),
                color: AppColors.textSecondary,
                onPressed: () =>
                    setState(() => _isPasswordVisible = !_isPasswordVisible),
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
                  _isConfirmPasswordVisible
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
                color: AppColors.textSecondary,
                onPressed: () => setState(
                  () => _isConfirmPasswordVisible = !_isConfirmPasswordVisible,
                ),
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

            Row(
              children: [
                Transform.scale(
                  scale: 1.5,
                  child: Checkbox(
                    value: _agreeToTerms,
                    shape: BeveledRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    onChanged: (value) =>
                        setState(() => _agreeToTerms = value ?? false),
                    fillColor: MaterialStateProperty.resolveWith<Color>((
                      states,
                    ) {
                      if (states.contains(MaterialState.selected)) {
                        return AppColors.consumerPrimary;
                      }
                      return AppColors.textHint;
                    }),
                  ),
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
                              color: AppColors.consumerPrimary,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          const TextSpan(text: ' and '),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: TextStyle(
                              color: AppColors.consumerPrimary,
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
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_circle, size: 64, color: AppColors.success),
          ),

          const SizedBox(height: 32),

          Text(
            'Registration Successful!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          if (_generatedConsumerId != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.consumerPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.consumerPrimary.withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Your Unique Consumer ID',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _generatedConsumerId!,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.consumerPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          Text(
            'Welcome to AGRICHAIN! Your consumer account has been successfully created and verified.',
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 32),

          ElevatedButton(
            onPressed: _navigateToDashboard,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.consumerPrimary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Go to Dashboard',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepHeader(String title, String subtitle, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.consumerPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.consumerPrimary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
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
    bool enabled = true,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: maxLines,
      enabled: enabled,
      validator: validator,
      style: TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppColors.textSecondary),
        prefixIcon: Icon(icon, color: AppColors.consumerPrimary),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.consumerPrimary, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.consumerPrimary, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border.withOpacity(0.5)),
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

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.consumerPrimary),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  'Previous',
                  style: TextStyle(color: AppColors.consumerPrimary),
                ),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                _isLoading ? null : _nextStep();
                FocusScope.of(context).unfocus();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.consumerPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
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
                  : Text(_getNextButtonText()),
            ),
          ),
        ],
      ),
    );
  }

  String _getNextButtonText() {
    switch (_currentStep) {
      case 0:
        return 'Continue';
      case 1:
        return _aadhaarVerified ? 'Continue' : 'Complete Verification';
      case 2:
        return 'Continue';
      case 3:
        return 'Complete Registration';
      default:
        return 'Next';
    }
  }

  // Navigation Methods
  void _nextStep() {
    if (_validateCurrentStep()) {
      if (_currentStep == 3) {
        _completeRegistration();
      } else {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void _previousStep() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _personalFormKey.currentState?.validate() ?? false;
      case 1:
        // Strengthened Aadhaar verification validation
        if (!_aadhaarVerified) {
          _showErrorSnackBar(
            'Please complete Aadhaar verification to continue',
          );
          return false;
        }
        if (_kycDetails == null) {
          _showErrorSnackBar(
            'Aadhaar verification incomplete. Please verify your Aadhaar number.',
          );
          return false;
        }
        return true;
      case 2:
        // Preferences are optional, so always return true
        return true;
      case 3:
        if (!(_securityFormKey.currentState?.validate() ?? false)) return false;
        if (!_agreeToTerms) {
          _showErrorSnackBar('Please agree to Terms & Conditions');
          return false;
        }
        return true;
      default:
        return true;
    }
  }

  // Verification Methods (now handled by AadhaarVerificationWidget)

  Future<void> _completeRegistration() async {
    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Prepare registration data
      Map<String, dynamic> userData = {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'password': _passwordController.text,
        'role': AppConstants.roleConsumer,
        'dietaryPreferences': _dietaryPreferencesController.text.trim(),
        'allergyInfo': _allergyInfoController.text.trim(),
        'preferredDeliveryTime': _preferredDeliveryTime,
        'organicPreference': _organicPreference,
        'localProductsPreference': _localProductsPreference,
        'aadhaarNumber': _kycDetails?['aadhaarNumber'] ?? '',
        'aadhaarVerified': _aadhaarVerified,
        'verifiedName': _kycDetails?['name'] ?? '',
      };

      final success = await authProvider.register(userData);

      if (success) {
        // Generate unique consumer ID
        _generatedConsumerId = _generateConsumerId();

        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        _showErrorSnackBar(authProvider.error ?? 'Registration failed');
      }
    } catch (e) {
      _showErrorSnackBar('Registration failed: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _generateConsumerId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final nameInitials = _nameController.text
        .split(' ')
        .map((word) => word.isNotEmpty ? word[0].toUpperCase() : '')
        .join('');
    return 'CSM$nameInitials${timestamp.toString().substring(8)}';
  }

  void _navigateToDashboard() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const ConsumerDashboard()),
      (route) => false,
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(message),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
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
}
