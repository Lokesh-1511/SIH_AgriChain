import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../core/theme/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../screens/retailer_dashboard.dart';

class RetailerRegistrationScreen extends StatefulWidget {
  const RetailerRegistrationScreen({Key? key}) : super(key: key);

  @override
  State<RetailerRegistrationScreen> createState() => _RetailerRegistrationScreenState();
}

class _RetailerRegistrationScreenState extends State<RetailerRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentStep = 0;
  bool _isLoading = false;

  // Personal Information
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Business Information
  final _businessNameController = TextEditingController();
  final _storeAddressController = TextEditingController();
  String _storeType = 'grocery';
  final _businessHoursController = TextEditingController();
  final _gstNumberController = TextEditingController();

  // Aadhaar Verification
  final _aadhaarController = TextEditingController();
  final _otpController = TextEditingController();
  bool _isAadhaarVerified = false;
  bool _otpSent = false;

  // License Verification
  final _licenseNumberController = TextEditingController();
  File? _licenseImage;
  final _picker = ImagePicker();

  // Generated ID
  String? _generatedRetailerId;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _businessNameController.dispose();
    _storeAddressController.dispose();
    _businessHoursController.dispose();
    _gstNumberController.dispose();
    _aadhaarController.dispose();
    _otpController.dispose();
    _licenseNumberController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _pickLicenseImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _licenseImage = File(pickedFile.path);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('License image uploaded successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<void> _sendAadhaarOTP() async {
    if (_aadhaarController.text.length != 12) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 12-digit Aadhaar number')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.sendAadhaarOTP(_aadhaarController.text);
      
      setState(() {
        _otpSent = true;
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP sent to registered mobile number')),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending OTP: $e')),
      );
    }
  }

  Future<void> _verifyAadhaarOTP() async {
    if (_otpController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 6-digit OTP')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.verifyAadhaarOTP(_aadhaarController.text, _otpController.text);
      
      setState(() {
        _isAadhaarVerified = true;
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aadhaar verified successfully')),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error verifying OTP: $e')),
      );
    }
  }

  Future<void> _completeRegistration() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_isAadhaarVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please verify your Aadhaar first')),
      );
      return;
    }
    if (_licenseImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload your license document')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // Generate Unique Retailer ID
      _generatedRetailerId = 'RET${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
      
      final userData = {
        'name': _nameController.text,
        'phone': _phoneController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
        'role': 'retailer',
        'businessName': _businessNameController.text,
        'storeAddress': _storeAddressController.text,
        'storeType': _storeType,
        'businessHours': _businessHoursController.text,
        'gstNumber': _gstNumberController.text,
        'aadhaarNumber': _aadhaarController.text,
        'aadhaarVerified': _isAadhaarVerified,
        'licenseNumber': _licenseNumberController.text,
        'licenseImagePath': _licenseImage!.path,
        'retailerId': _generatedRetailerId,
      };

      await authProvider.register(userData);
      
      setState(() => _isLoading = false);
      
      // Show success dialog with generated ID
      _showSuccessDialog();
      
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: $e')),
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Registration Successful!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your retailer account has been created successfully.'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.purple),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Unique Retailer ID:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _generatedRetailerId!,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Please save this ID for future reference.',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.orange,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const RetailerDashboard()),
              );
            },
            child: const Text('Continue to Dashboard'),
          ),
        ],
      ),
    );
  }

  void _nextStep() {
    if (_currentStep < 3) {
      if (_validateCurrentStep()) {
        setState(() => _currentStep++);
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } else {
      _completeRegistration();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _nameController.text.isNotEmpty &&
               _phoneController.text.isNotEmpty &&
               _emailController.text.isNotEmpty &&
               _passwordController.text.isNotEmpty &&
               _confirmPasswordController.text.isNotEmpty &&
               _passwordController.text == _confirmPasswordController.text;
      case 1:
        return _businessNameController.text.isNotEmpty &&
               _storeAddressController.text.isNotEmpty &&
               _businessHoursController.text.isNotEmpty;
      case 2:
        return _isAadhaarVerified;
      case 3:
        return _licenseNumberController.text.isNotEmpty && _licenseImage != null;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Retailer Registration'),
        backgroundColor: AppColors.retailerPrimary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // Progress Indicator
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: List.generate(4, (index) {
                return Expanded(
                  child: Container(
                    height: 4,
                    margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
                    decoration: BoxDecoration(
                      color: index <= _currentStep
                          ? AppColors.retailerPrimary
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),
          
          // Step Content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildPersonalInfoStep(),
                _buildBusinessInfoStep(),
                _buildAadhaarVerificationStep(),
                _buildLicenseVerificationStep(),
              ],
            ),
          ),
          
          // Navigation Buttons
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousStep,
                      child: const Text('Previous'),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _nextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.retailerPrimary,
                      foregroundColor: Colors.white,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(_currentStep == 3 ? 'Complete Registration' : 'Next'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoStep() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personal Information',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.retailerPrimary,
              ),
            ),
            const SizedBox(height: 24),
            
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name *',
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) => value?.isEmpty ?? true ? 'Please enter your name' : null,
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number *',
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) => value?.isEmpty ?? true ? 'Please enter your phone number' : null,
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email Address *',
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) => value?.isEmpty ?? true ? 'Please enter your email' : null,
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password *',
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
              validator: (value) => value?.isEmpty ?? true ? 'Please enter a password' : null,
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _confirmPasswordController,
              decoration: const InputDecoration(
                labelText: 'Confirm Password *',
                prefixIcon: Icon(Icons.lock_outline),
              ),
              obscureText: true,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Please confirm your password';
                if (value != _passwordController.text) return 'Passwords do not match';
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBusinessInfoStep() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Store Information',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.retailerPrimary,
            ),
          ),
          const SizedBox(height: 24),
          
          TextFormField(
            controller: _businessNameController,
            decoration: const InputDecoration(
              labelText: 'Store Name *',
              prefixIcon: Icon(Icons.store),
            ),
          ),
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _storeAddressController,
            decoration: const InputDecoration(
              labelText: 'Store Address *',
              prefixIcon: Icon(Icons.location_on),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          
          DropdownButtonFormField<String>(
            value: _storeType,
            decoration: const InputDecoration(
              labelText: 'Store Type *',
              prefixIcon: Icon(Icons.category),
            ),
            items: const [
              DropdownMenuItem(value: 'grocery', child: Text('Grocery Store')),
              DropdownMenuItem(value: 'supermarket', child: Text('Supermarket')),
              DropdownMenuItem(value: 'organic', child: Text('Organic Store')),
              DropdownMenuItem(value: 'wholesale', child: Text('Wholesale')),
              DropdownMenuItem(value: 'other', child: Text('Other')),
            ],
            onChanged: (value) => setState(() => _storeType = value!),
          ),
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _businessHoursController,
            decoration: const InputDecoration(
              labelText: 'Business Hours *',
              prefixIcon: Icon(Icons.access_time),
              hintText: 'e.g., 9:00 AM - 9:00 PM',
            ),
          ),
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _gstNumberController,
            decoration: const InputDecoration(
              labelText: 'GST Number (Optional)',
              prefixIcon: Icon(Icons.receipt),
              hintText: 'Enter GST number if applicable',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAadhaarVerificationStep() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Aadhaar Verification',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.retailerPrimary,
            ),
          ),
          const SizedBox(height: 24),
          
          TextFormField(
            controller: _aadhaarController,
            decoration: const InputDecoration(
              labelText: 'Aadhaar Number *',
              prefixIcon: Icon(Icons.credit_card),
              hintText: 'Enter 12-digit Aadhaar number',
            ),
            keyboardType: TextInputType.number,
            maxLength: 12,
            enabled: !_isAadhaarVerified,
          ),
          const SizedBox(height: 16),
          
          if (!_otpSent && !_isAadhaarVerified)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _sendAadhaarOTP,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                ),
                child: const Text('Send OTP'),
              ),
            ),
          
          if (_otpSent && !_isAadhaarVerified) ...[
            TextFormField(
              controller: _otpController,
              decoration: const InputDecoration(
                labelText: 'Enter OTP *',
                prefixIcon: Icon(Icons.sms),
                hintText: 'Enter 6-digit OTP',
              ),
              keyboardType: TextInputType.number,
              maxLength: 6,
            ),
            const SizedBox(height: 16),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _verifyAadhaarOTP,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.retailerPrimary,
                ),
                child: const Text('Verify OTP'),
              ),
            ),
          ],
          
          if (_isAadhaarVerified)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 12),
                  Text(
                    'Aadhaar verified successfully!',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLicenseVerificationStep() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'License Verification',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.retailerPrimary,
            ),
          ),
          const SizedBox(height: 24),
          
          TextFormField(
            controller: _licenseNumberController,
            decoration: const InputDecoration(
              labelText: 'Trade License Number *',
              prefixIcon: Icon(Icons.assignment),
              hintText: 'Enter your trade license number',
            ),
          ),
          const SizedBox(height: 24),
          
          const Text(
            'Upload License Document *',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          
          GestureDetector(
            onTap: _pickLicenseImage,
            child: Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey.shade300,
                  style: BorderStyle.solid,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _licenseImage != null
                  ? Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.file(
                            _licenseImage!,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    )
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.cloud_upload,
                          size: 48,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Tap to upload license document',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Supported formats: JPG, PNG, PDF',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
