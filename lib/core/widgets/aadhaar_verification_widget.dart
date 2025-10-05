import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/aadhaar_verification_service.dart';
import '../../core/services/aadhaar_state_service.dart' as state_service;
import 'otp_notification_popup.dart';

/// Universal Aadhaar Verification Widget
/// Used across Farmer, Distributor, Retailer, Consumer, Admin apps
class AadhaarVerificationWidget extends StatefulWidget {
  final String userId;
  final String userRole;
  final Color primaryColor;
  final Function(bool isVerified, KYCDetails? kycDetails)
  onVerificationComplete;
  final VoidCallback? onVerificationStart;
  final bool? initialVerificationState;
  final KYCDetails? initialKycDetails;

  const AadhaarVerificationWidget({
    super.key,
    required this.userId,
    required this.userRole,
    required this.primaryColor,
    required this.onVerificationComplete,
    this.onVerificationStart,
    this.initialVerificationState,
    this.initialKycDetails,
  });

  @override
  State<AadhaarVerificationWidget> createState() =>
      _AadhaarVerificationWidgetState();
}

class _AadhaarVerificationWidgetState extends State<AadhaarVerificationWidget>
    with TickerProviderStateMixin {
  final _aadhaarController = TextEditingController();
  final _otpController = TextEditingController();
  final _aadhaarFormKey = GlobalKey<FormState>();
  final _otpFormKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _otpSent = false;
  bool _isVerified = false;
  String? _transactionId;
  String? _errorMessage;
  KYCDetails? _kycDetails;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late AnimationController _successController;
  late Animation<double> _successAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _successAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _successController, curve: Curves.elasticOut),
    );

    _animationController.forward();
    
    // Use initial state if provided, otherwise check existing verification
    if (widget.initialVerificationState == true && widget.initialKycDetails != null) {
      setState(() {
        _isVerified = true;
        _kycDetails = widget.initialKycDetails;
      });
      _successController.forward();
      debugPrint('✅ Using initial verification state provided by parent');
    } else {
      _checkExistingVerification();
    }
  }

  @override
  void dispose() {
    _aadhaarController.dispose();
    _otpController.dispose();
    _animationController.dispose();
    _successController.dispose();
    super.dispose();
  }

  /// Check if user already has verified Aadhaar (both local storage and backend)
  Future<void> _checkExistingVerification() async {
    try {
      // First check local storage for faster loading
      final savedState =
          await state_service.AadhaarStateService.loadVerificationState(
            userId: widget.userId,
            userRole: widget.userRole,
          );

      if (savedState != null && savedState.isVerified) {
        setState(() {
          _isVerified = true;
          _kycDetails = savedState.kycDetails;
        });
        _successController.forward();
        
        // Use a small delay to ensure parent widget has finished initializing
        Future.delayed(const Duration(milliseconds: 100), () {
          widget.onVerificationComplete(true, savedState.kycDetails);
        });
        
        debugPrint('✅ Loaded Aadhaar verification from local storage');
        return;
      }

      // If not in local storage, check backend
      final status = await AadhaarVerificationService.getVerificationStatus(
        userId: widget.userId,
        userRole: widget.userRole,
      );

      if (status.aadhaarVerified) {
        setState(() {
          _isVerified = true;
        });
        _successController.forward();
        widget.onVerificationComplete(true, null);
        debugPrint('✅ Loaded Aadhaar verification from backend');

        // Save to local storage for future quick access
        await state_service.AadhaarStateService.saveVerificationState(
          userId: widget.userId,
          userRole: widget.userRole,
          isVerified: true,
          kycDetails: null,
        );
      }
    } catch (e) {
      // User might not exist yet, continue with fresh verification
      debugPrint('No existing verification found: $e');
    }
  }

  /// Step 1: Send OTP to Aadhaar-linked mobile
  Future<void> _sendOTP() async {
    if (!_aadhaarFormKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    widget.onVerificationStart?.call();

    try {
      // Step 1: Test backend connectivity first
      debugPrint('🔍 Testing backend connectivity...');
      final isConnected = await AadhaarVerificationService.testConnectivity();

      if (!isConnected) {
        throw AadhaarVerificationException(
          'Cannot connect to verification server. Please check if backend is running.',
          AadhaarErrorCode.networkError,
        );
      }

      debugPrint('✅ Backend connected, initiating verification...');

      // Step 2: Initiate Aadhaar verification
      final response = await AadhaarVerificationService.initiateVerification(
        aadhaarNumber: _aadhaarController.text.replaceAll('-', ''),
        userId: widget.userId,
        userRole: widget.userRole,
      );

      if (response.success) {
        setState(() {
          _otpSent = true;
          _transactionId = response.transactionId;
        });
        _showSuccessSnackBar(
          'OTP sent successfully! Check your Aadhaar-linked mobile.\n',
        );

        // Show OTP popup notification with debug OTP (development only)
        if (response.debugOtp != null && response.mobileNumber != null) {
          OtpNotificationPopup.show(
            context: context,
            otp: response.debugOtp!,
            mobileNumber: response.mobileNumber!,
          );
        }
      }
    } on AadhaarVerificationException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });

      // Show more detailed error based on error type
      String errorMsg = e.message;
      if (e.errorCode == AadhaarErrorCode.networkError) {
        errorMsg =
            'Network Error: ${e.message}\n\n'
            'Please ensure:\n'
            '• Backend server is running on localhost:8000\n'
            '• Your device can connect to the server';
      }

      _showErrorSnackBar(errorMsg);
    } catch (e) {
      setState(() {
        _errorMessage = 'Connection failed: ${e.toString()}';
      });
      _showErrorSnackBar('Connection failed: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Step 2: Verify OTP and complete KYC
  Future<void> _verifyOTP() async {
    if (!_otpFormKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await AadhaarVerificationService.verifyOTP(
        aadhaarNumber: _aadhaarController.text.replaceAll('-', ''),
        otp: _otpController.text,
        transactionId: _transactionId!,
        userId: widget.userId,
      );

      if (response.success) {
        debugPrint('🎉 OTP Verification successful!');
        debugPrint('🔍 KYC Details: ${response.kycDetails?.toJson()}');
        
        setState(() {
          _isVerified = true;
          _kycDetails = response.kycDetails;
        });
        _successController.forward();
        _showSuccessSnackBar('Aadhaar verified successfully! ✅');

        // Save verification state to local storage
        await state_service.AadhaarStateService.saveVerificationState(
          userId: widget.userId,
          userRole: widget.userRole,
          isVerified: true,
          kycDetails: response.kycDetails,
        );

        debugPrint('✅ Calling onVerificationComplete with: isVerified=true, kycDetails=${response.kycDetails?.toJson()}');
        widget.onVerificationComplete(true, response.kycDetails);
      }
    } on AadhaarVerificationException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
      _showErrorSnackBar(e.message);

      // If OTP is invalid, allow user to try again
      if (e.errorCode == AadhaarErrorCode.invalidOTP) {
        _otpController.clear();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Verification failed. Please try again.';
      });
      _showErrorSnackBar('Verification failed. Please try again.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Reset verification process
  void _resetVerification() {
    setState(() {
      _otpSent = false;
      _isVerified = false;
      _transactionId = null;
      _errorMessage = null;
      _kycDetails = null;
    });
    _aadhaarController.clear();
    _otpController.clear();
    _successController.reset();

    // Clear saved verification state
    state_service.AadhaarStateService.clearVerificationState(
      userId: widget.userId,
      userRole: widget.userRole,
    );

    // Notify parent that verification is no longer valid
    widget.onVerificationComplete(false, null);
  }

  /// Get current verification status for external validation
  bool get isVerified => _isVerified;

  /// Get current KYC details
  KYCDetails? get kycDetails => _kycDetails;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),

            if (_isVerified)
              _buildSuccessView()
            else if (_otpSent)
              _buildOTPVerificationView()
            else
              _buildAadhaarInputView(),

            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              _buildErrorMessage(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: widget.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _isVerified ? Icons.verified_user : Icons.security,
            color: widget.primaryColor,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Aadhaar Verification',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _isVerified
                    ? 'Your Aadhaar has been successfully verified'
                    : _otpSent
                    ? 'Enter the OTP sent to your mobile'
                    : 'Verify your identity with Aadhaar',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        _buildStatusIcon(),
      ],
    );
  }

  Widget _buildStatusIcon() {
    if (_isVerified) {
      return ScaleTransition(
        scale: _successAnimation,
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.success,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, color: Colors.white, size: 20),
        ),
      );
    } else if (_otpSent) {
      return Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppColors.warning,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.sms, color: Colors.white, size: 20),
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppColors.textHint,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.security, color: Colors.white, size: 20),
      );
    }
  }

  Widget _buildAadhaarInputView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Security notice
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.info.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.info.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.shield, color: AppColors.info, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Your Aadhaar details are encrypted and secure',
                  style: TextStyle(fontSize: 12, color: AppColors.info),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        Form(
          key: _aadhaarFormKey,
          child: TextFormField(
            controller: _aadhaarController,
            keyboardType: TextInputType.number,
            style: TextStyle(color: AppColors.textPrimary),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(12),
              _AadhaarNumberFormatter(),
            ],
            decoration: InputDecoration(
              labelText: 'Aadhaar Number',
              labelStyle: TextStyle(color: AppColors.textSecondary),
              prefixIcon: Icon(Icons.credit_card, color: widget.primaryColor),
              hintText: 'XXXX-XXXX-XXXX',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: widget.primaryColor, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: widget.primaryColor, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.error),
              ),
            ),
            validator: (value) {
              final cleanValue = value?.replaceAll('-', '') ?? '';
              if (cleanValue.isEmpty) {
                return 'Please enter your Aadhaar number';
              }
              if (cleanValue.length != 12) {
                return 'Aadhaar number must be exactly 12 digits';
              }
              if (!RegExp(r'^\d{12}$').hasMatch(cleanValue)) {
                return 'Aadhaar number must contain only digits';
              }

              // Check for obviously fake patterns
              final fakePatterns = {
                '000000000000': 'All zeros are not valid',
                '111111111111': 'All ones are not valid',
                '123456789012': 'Sequential numbers are not valid',
                '999999999999': 'All nines are not valid',
                '123412341234': 'Repetitive patterns are not valid',
                '111122223333': 'Block patterns are not valid',
              };

              if (fakePatterns.containsKey(cleanValue)) {
                return 'Invalid Aadhaar: ${fakePatterns[cleanValue]}';
              }

              // Check if starts with 0 or 1 (invalid for real Aadhaar)
              if (cleanValue.startsWith('0') || cleanValue.startsWith('1')) {
                return 'Invalid Aadhaar: Cannot start with 0 or 1';
              }

              // Check for too many repeated digits
              final uniqueDigits = cleanValue.split('').toSet().length;
              if (uniqueDigits < 4) {
                return 'Invalid Aadhaar: Too many repeated digits';
              }

              return null;
            },
          ),
        ),

        const SizedBox(height: 20),

        ElevatedButton(
          onPressed: _isLoading ? null : _sendOTP,
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
          child: _isLoading
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.green,
                    strokeWidth: 2,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.send, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Send OTP',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildOTPVerificationView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // OTP info
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.warning.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.warning.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.sms, color: AppColors.warning, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'OTP sent to your Aadhaar-linked mobile',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.warning,
                      ),
                    ),
                    Text(
                      'Please enter the 6-digit OTP received',
                      style: TextStyle(fontSize: 11, color: AppColors.warning),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        Form(
          key: _otpFormKey,
          child: TextFormField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            style: TextStyle(color: AppColors.textPrimary),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            decoration: InputDecoration(
              labelText: 'Enter OTP',
              labelStyle: TextStyle(color: AppColors.textSecondary),
              prefixIcon: Icon(Icons.lock, color: widget.primaryColor),
              hintText: '123456',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: widget.primaryColor, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: widget.primaryColor, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.error),
              ),
            ),
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Please enter the OTP';
              }
              if (value!.length != 6) {
                return 'OTP must be 6 digits';
              }
              return null;
            },
          ),
        ),

        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _resetVerification,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: widget.primaryColor),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Re-enter ID',
                  style: TextStyle(color: widget.primaryColor),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _verifyOTP,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: _isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            'Verify OTP',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSuccessView() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.success.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              ScaleTransition(
                scale: _successAnimation,
                child: Icon(
                  Icons.verified_user,
                  color: AppColors.success,
                  size: 28,
                ),
              ),
              
            ],
          ),
        ),

        const SizedBox(height: 16),

        OutlinedButton(
          onPressed: _resetVerification,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: AppColors.textSecondary),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            'Verify Different Aadhaar',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error, color: AppColors.error, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(fontSize: 12, color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(message),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 3),
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
        duration: const Duration(seconds: 5),
      ),
    );
  }
}

/// Custom formatter for Aadhaar number input (XXXX-XXXX-XXXX)
class _AadhaarNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll('-', '');

    if (text.length <= 4) {
      return newValue.copyWith(text: text);
    } else if (text.length <= 8) {
      final formatted = '${text.substring(0, 4)}-${text.substring(4)}';
      return newValue.copyWith(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    } else if (text.length <= 12) {
      final formatted =
          '${text.substring(0, 4)}-${text.substring(4, 8)}-${text.substring(8)}';
      return newValue.copyWith(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }

    return oldValue;
  }
}
