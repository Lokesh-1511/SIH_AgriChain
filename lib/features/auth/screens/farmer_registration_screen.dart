// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/simple_aadhaar_widget.dart';
import '../providers/auth_provider.dart';
import '../../farmer/screens/farmer_dashboard.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class FarmerRegistrationScreen extends StatefulWidget {
  const FarmerRegistrationScreen({super.key});

  @override
  State<FarmerRegistrationScreen> createState() =>
      _FarmerRegistrationScreenState();
}

class _FarmerRegistrationScreenState extends State<FarmerRegistrationScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  bool _isLoading = false;

  // Form Controllers
  final _personalFormKey = GlobalKey<FormState>();

  final _landFormKey = GlobalKey<FormState>();
  final _securityFormKey = GlobalKey<FormState>();

  // Personal Information
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  // Aadhaar Verification
  bool _aadhaarVerified = false;
  Map<String, dynamic>? _kycDetails;

  @override
  void initState() {
    super.initState();
  }

  // Land Information
  final _landSizeController = TextEditingController();
  String _landOwnership = 'owned';
  File? _ownerRecordFile;
  File? _leaseDocFile;

  // Security
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _agreeToTerms = false;

  // Generated ID
  String? _generatedFarmerId;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _landSizeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.farmerPrimary,
        foregroundColor: Colors.white,
<<<<<<< HEAD
        title: const Text('Farmer Registration'),
=======
        title: Text('farmer.registration'.tr()),
>>>>>>> 5b3ae447a7a6f15554647b4ed5c427121e8f156b
        elevation: 0,
      ),
      body: Column(
        children: [
          // Progress Indicator
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.farmerPrimary,
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
                _buildLandVerificationStep(),
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
            Icon(Icons.agriculture, color: Colors.white, size: 24),
            const SizedBox(width: 8),
            Text(
              'farmer.registration'.tr(),
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
<<<<<<< HEAD
        return 'Personal Information';
      case 1:
        return 'Aadhaar Verification';
      case 2:
        return 'Land Verification';
      case 3:
        return 'Security Setup';
      case 4:
        return 'Registration Complete';
=======
        return 'farmer.personal_info'.tr();
      case 1:
        return 'farmer.aadhar_verification'.tr();
      case 2:
        return 'farmer.land_verification'.tr();
      case 3:
        return 'farmer.security_setup'.tr();
      case 4:
        return 'farmer.registration_complete'.tr();
>>>>>>> 5b3ae447a7a6f15554647b4ed5c427121e8f156b
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
<<<<<<< HEAD
              'Personal Information',
              'Enter your basic details to get started',
=======
              'farmer.personal_info'.tr(),
              'farmer.enter_basic_details'.tr(),
>>>>>>> 5b3ae447a7a6f15554647b4ed5c427121e8f156b
              Icons.person,
            ),
            const SizedBox(height: 24),
            _buildTextField(
              controller: _nameController,
<<<<<<< HEAD
              label: 'Full Name',
              icon: Icons.person,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your full name';
                }
                if (value.length < 2) {
                  return 'Name must be at least 2 characters';
=======
              label: 'common.name'.tr(),
              icon: Icons.person,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'farmer.enter_full_name'.tr();
                }
                if (value.length < 2) {
                  return 'farmer.name_min_length'.tr();
>>>>>>> 5b3ae447a7a6f15554647b4ed5c427121e8f156b
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _emailController,
<<<<<<< HEAD
              label: 'Email Address',
=======
              label: 'common.email'.tr(),
>>>>>>> 5b3ae447a7a6f15554647b4ed5c427121e8f156b
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
<<<<<<< HEAD
                  return 'Please enter your email';
=======
                  return 'farmer.enter_email'.tr();
>>>>>>> 5b3ae447a7a6f15554647b4ed5c427121e8f156b
                }
                if (!RegExp(
                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                ).hasMatch(value)) {
<<<<<<< HEAD
                  return 'Please enter a valid email';
=======
                  return 'farmer.valid_email'.tr();
>>>>>>> 5b3ae447a7a6f15554647b4ed5c427121e8f156b
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _phoneController,
<<<<<<< HEAD
              label: 'Phone Number',
=======
              label: 'common.phone'.tr(),
>>>>>>> 5b3ae447a7a6f15554647b4ed5c427121e8f156b
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
<<<<<<< HEAD
                  return 'Please enter your phone number';
                }
                if (value.length < 10) {
                  return 'Please enter a valid phone number';
=======
                  return 'farmer.enter_phone'.tr();
                }
                if (value.length < 10) {
                  return 'farmer.valid_phone'.tr();
>>>>>>> 5b3ae447a7a6f15554647b4ed5c427121e8f156b
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _addressController,
<<<<<<< HEAD
              label: 'Farm Address',
=======
              label: 'farmer.farm_address'.tr(),
>>>>>>> 5b3ae447a7a6f15554647b4ed5c427121e8f156b
              icon: Icons.location_on,
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your farm address';
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
            'Verify your identity with Aadhaar for secure farming',
            Icons.verified_user,
          ),
          const SizedBox(height: 24),

          // Simple Aadhaar Verification Widget
          SimpleAadhaarWidget(
            primaryColor: AppColors.farmerPrimary,
            onVerificationComplete: (isVerified, kycDetails) {
              debugPrint(
                '📥 Received verification callback: isVerified=$isVerified',
              );

              setState(() {
                _aadhaarVerified = isVerified;
                _kycDetails = kycDetails;
              });

              if (isVerified && kycDetails != null) {
                // Auto-fill name from KYC if available
                if (_nameController.text.isEmpty &&
                    kycDetails['name'] != null &&
                    kycDetails['name'].toString().isNotEmpty) {
                  _nameController.text = kycDetails['name'];
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Aadhaar verified successfully! Welcome ${kycDetails['name'] ?? 'User'}',
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

  Widget _buildLandVerificationStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _landFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildStepHeader(
              'Land Verification',
              'Verify your land ownership or lease details',
              Icons.landscape,
            ),
            const SizedBox(height: 24),

            _buildTextField(
              controller: _landSizeController,
              label: 'Land Size (in acres)',
              icon: Icons.straighten,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your land size';
                }
                if (double.tryParse(value) == null ||
                    double.parse(value) <= 0) {
                  return 'Please enter a valid land size';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            Text(
              'Land Ownership Type',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 12),

            Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  RadioListTile<String>(
                    title: const Text(
                      'Owned',
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                    subtitle: const Text(
                      'I own this land',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),

                    value: 'owned',
                    groupValue: _landOwnership,
                    fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                      if (states.contains(WidgetState.selected)) {
                        return AppColors.farmerPrimary; // selected color
                      }
                      return Colors.grey; // unselected color
                    }),

                    onChanged: (value) =>
                        setState(() => _landOwnership = value!),
                  ),
                  Divider(height: 1, color: AppColors.border),
                  RadioListTile<String>(
                    title: const Text(
                      'Lease/Rent',
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                    subtitle: const Text(
                      'I lease or rent this land',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    value: 'lease',
                    groupValue: _landOwnership,
                    fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                      if (states.contains(WidgetState.selected)) {
                        return AppColors.farmerPrimary; // selected color
                      }
                      return Colors.grey; // unselected color
                    }),
                    onChanged: (value) =>
                        setState(() => _landOwnership = value!),
                  ),
                ],
              ),
            ),

            if (_landOwnership.isNotEmpty) ...[
              const SizedBox(height: 20),

              Text(
                'Required Documents',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 16),

              if (_landOwnership == 'owned') ...[
                _buildDocumentUpload(
                  title: 'Land Record',
                  subtitle:
                      'Upload your land ownership document (Khatiyan/Patta/Registry)',
                  file: _ownerRecordFile,
                  onTap: () => _pickDocument('owner_record'),
                ),

                const SizedBox(height: 8),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.success.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.verified, color: AppColors.success, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Required: Land ownership proof to verify your property rights',
                          style: TextStyle(
                            color: AppColors.success,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else if (_landOwnership == 'lease') ...[
                _buildDocumentUpload(
                  title: 'Land Owner\'s Record',
                  subtitle: 'Upload owner\'s land documents',
                  file: _ownerRecordFile,
                  onTap: () => _pickDocument('owner_record'),
                ),

                const SizedBox(height: 12),

                _buildDocumentUpload(
                  title: 'Lease Agreement',
                  subtitle: 'Upload lease/rent agreement',
                  file: _leaseDocFile,
                  onTap: () => _pickDocument('lease_doc'),
                ),
              ],
            ],

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.warning.withOpacity(0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info, color: AppColors.warning),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'All documents will be stored securely on IPFS blockchain for verification purposes.',
                      style: TextStyle(color: AppColors.warning, fontSize: 14),
                    ),
                  ),
                ],
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
                  scale: 1.5, // 1.0 = normal, increase for bigger size
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
                        return AppColors.farmerPrimary;
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
                              color: AppColors.farmerPrimary,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          const TextSpan(text: ' and '),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: TextStyle(
                              color: AppColors.farmerPrimary,
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
<<<<<<< HEAD
            'Registration Successful!',
=======
            'farmer.registration_successful'.tr(),
>>>>>>> 5b3ae447a7a6f15554647b4ed5c427121e8f156b
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          if (_generatedFarmerId != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.farmerPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.farmerPrimary.withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  Text(
<<<<<<< HEAD
                    'Your Unique Farmer ID',
=======
                    'farmer.unique_farmer_id'.tr(),
>>>>>>> 5b3ae447a7a6f15554647b4ed5c427121e8f156b
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _generatedFarmerId!,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.farmerPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          Text(
<<<<<<< HEAD
            'Welcome to AGRICHAIN! Your farmer account has been successfully created and verified.',
=======
            'farmer.welcome_message'.tr(),
>>>>>>> 5b3ae447a7a6f15554647b4ed5c427121e8f156b
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 32),

          ElevatedButton(
            onPressed: _navigateToDashboard,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.farmerPrimary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
<<<<<<< HEAD
            child: const Text(
              'Go to Dashboard',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
=======
            child: Text(
              'farmer.go_to_dashboard'.tr(),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
>>>>>>> 5b3ae447a7a6f15554647b4ed5c427121e8f156b
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
              color: AppColors.farmerPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.farmerPrimary, size: 24),
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
        prefixIcon: Icon(icon, color: AppColors.farmerPrimary),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.farmerPrimary,
            width: 1,
          ), // light grey border
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.farmerPrimary,
            width: 2,
          ), // colored border when focused
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

  Widget _buildDocumentUpload({
    required String title,
    required String subtitle,
    required File? file,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: file != null ? AppColors.success : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(12),
          color: file != null
              ? AppColors.success.withOpacity(0.05)
              : Colors.white,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: file != null
                    ? AppColors.success.withOpacity(0.1)
                    : AppColors.textSecondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                file != null ? Icons.check_circle : Icons.upload_file,
                color: file != null
                    ? AppColors.success
                    : AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: file != null
                          ? AppColors.success
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    file != null ? 'Document uploaded' : subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: file != null
                          ? AppColors.success
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              file != null ? Icons.check : Icons.arrow_forward_ios,
              size: 16,
              color: file != null ? AppColors.success : AppColors.textSecondary,
            ),
          ],
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
                  side: BorderSide(color: AppColors.farmerPrimary),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  'Previous',
                  style: TextStyle(color: AppColors.farmerPrimary),
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
                backgroundColor: AppColors.farmerPrimary,
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
        return (_aadhaarVerified && _kycDetails != null)
            ? 'Continue'
            : 'Complete Verification';
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
        if (!(_landFormKey.currentState?.validate() ?? false)) return false;
        if (_landOwnership == 'owned') {
          if (_ownerRecordFile == null) {
            _showErrorSnackBar('Please upload your land ownership document');
            return false;
          }
        } else if (_landOwnership == 'lease') {
          if (_ownerRecordFile == null || _leaseDocFile == null) {
            _showErrorSnackBar(
              'Please upload required documents for lease land',
            );
            return false;
          }
        }
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

  Future<void> _pickDocument(String type) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (pickedFile != null) {
        setState(() {
          if (type == 'owner_record') {
            _ownerRecordFile = File(pickedFile.path);
          } else if (type == 'lease_doc') {
            _leaseDocFile = File(pickedFile.path);
          }
        });
        _showSuccessSnackBar('Document uploaded successfully');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick document: $e');
    }
  }

  Future<void> _completeRegistration() async {
    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Prepare KYC details map
      Map<String, dynamic> kycDetails = {
        'aadhaarNumber': _kycDetails?['aadhaarNumber'] ?? '',
        'aadhaarVerified': _aadhaarVerified,
        'verifiedName': _kycDetails?['name'] ?? _nameController.text.trim(),
        'landSize': double.tryParse(_landSizeController.text) ?? 0.0,
        'landOwnership': _landOwnership,
      };

      // Add document info if lease
      if (_landOwnership == 'lease') {
        kycDetails['ownerRecordPath'] = _ownerRecordFile?.path ?? '';
        kycDetails['leaseDocPath'] = _leaseDocFile?.path ?? '';
      }

      // Prepare registration data
      Map<String, dynamic> userData = {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'password': _passwordController.text,
        'role': AppConstants.roleFarmer,
        'kycDetails': kycDetails,
        'additionalInfo': {
          'farmerId': _generateFarmerId(),
          'registrationDate': DateTime.now().toIso8601String(),
        },
      };

      final success = await authProvider.register(userData);

      if (success) {
        // Generate unique farmer ID
        _generatedFarmerId = _generateFarmerId();

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

  String _generateFarmerId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final nameInitials = _nameController.text
        .split(' ')
        .map((word) => word.isNotEmpty ? word[0].toUpperCase() : '')
        .join('');
    return 'FRM$nameInitials${timestamp.toString().substring(8)}';
  }

  void _navigateToDashboard() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const FarmerDashboard()),
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
