import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/local_aadhaar_service.dart';
import '../services/notification_service.dart';

/// Custom formatter for Aadhaar number with dashes (####-####-####)
class AadhaarNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Only allow digits and dashes
    final text = newValue.text
        .replaceAll(RegExp(r'[^0-9-]'), '')
        .replaceAll('-', '');

    if (text.length > 12) {
      return oldValue;
    }

    String formatted = '';
    for (int i = 0; i < text.length; i++) {
      if (i == 4 || i == 8) {
        formatted += '-';
      }
      formatted += text[i];
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Simple Aadhaar Verification Widget for Local OTP Generation
class SimpleAadhaarWidget extends StatefulWidget {
  final Function(bool isVerified, Map<String, dynamic>? kycData)
  onVerificationComplete;
  final Color primaryColor;

  const SimpleAadhaarWidget({
    super.key,
    required this.onVerificationComplete,
    this.primaryColor = const Color(0xFF4CAF50),
  });

  @override
  State<SimpleAadhaarWidget> createState() => _SimpleAadhaarWidgetState();
}

class _SimpleAadhaarWidgetState extends State<SimpleAadhaarWidget>
    with TickerProviderStateMixin {
  final _aadhaarController = TextEditingController();
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _otpGenerated = false;
  bool _isVerified = false;
  String? _errorMessage;
  int _remainingTime = 0;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _aadhaarController.dispose();
    _otpController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _startOtpTimer() {
    _remainingTime = LocalAadhaarService.getRemainingOtpTime();
    if (_remainingTime > 0) {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted && _otpGenerated) {
          setState(() {
            _remainingTime = LocalAadhaarService.getRemainingOtpTime();
          });
          if (_remainingTime > 0) {
            _startOtpTimer();
          } else {
            _otpGenerated = false;
            _otpController.clear();
          }
        }
      });
    }
  }

  Future<void> _generateOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Generate OTP using local service (strip dashes from Aadhaar number)
      final aadhaarNumber = _aadhaarController.text.replaceAll('-', '');
      final otp = LocalAadhaarService.generateOtp(aadhaarNumber);

      // Show OTP in a real-looking notification
      NotificationService.showNotification(
        context: context,
        title: 'AgriChain - Aadhaar OTP',
        message:
            'For: ${aadhaarNumber.substring(0, 4)} **** ${aadhaarNumber.substring(8)}',
        otp: otp,
        duration: const Duration(seconds: 10),
        primaryColor: widget.primaryColor,
      );

      setState(() {
        _otpGenerated = true;
        _isLoading = false;
      });

      _startOtpTimer();
      _pulseController.repeat(reverse: true);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('OTP sent! Check the notification above.'),
          backgroundColor: widget.primaryColor,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter the OTP';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = LocalAadhaarService.verifyOtp(_otpController.text);

      if (result['success']) {
        setState(() {
          _isVerified = true;
          _isLoading = false;
          _otpGenerated = false;
        });

        _pulseController.stop();
        _pulseController.reset();

        // Call the completion callback
        widget.onVerificationComplete(true, result['kycData']);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Aadhaar verification successful!'),
            backgroundColor: widget.primaryColor,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = result['message'];
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      color: Colors.white, // Explicitly set white background
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: widget.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.security,
                      color: widget.primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Aadhaar Verification',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          _isVerified
                              ? 'Verification Complete'
                              : _otpGenerated
                              ? 'Enter OTP to verify'
                              : 'Enter your 12-digit Aadhaar number',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_isVerified)
                    Icon(
                      Icons.check_circle,
                      color: widget.primaryColor,
                      size: 28,
                    ),
                ],
              ),

              const SizedBox(height: 24),

              // Aadhaar Number Input
              if (!_isVerified) ...[
                TextFormField(
                  controller: _aadhaarController,
                  enabled: !_otpGenerated && !_isLoading,
                  keyboardType: TextInputType.number,
                  maxLength:
                      14, // Updated to accommodate dashes (####-####-####)
                  inputFormatters: [
                    AadhaarNumberFormatter(), // Custom formatter for dashes
                  ],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Aadhaar Number',
                    labelStyle: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    hintText: '1234-5678-9012',
                    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
                    prefixIcon: Icon(
                      Icons.credit_card,
                      color: widget.primaryColor,
                      size: 20,
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.grey[300]!,
                        width: 1.5,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.grey[300]!,
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: widget.primaryColor,
                        width: 2,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.red,
                        width: 1.5,
                      ),
                    ),
                    counterText: '',
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Aadhaar number';
                    }
                    final digitsOnly = value.replaceAll('-', '');
                    if (digitsOnly.length != 12) {
                      return 'Aadhaar number must be 12 digits';
                    }
                    if (!RegExp(r'^\d{12}$').hasMatch(digitsOnly)) {
                      return 'Invalid Aadhaar number format';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Generate OTP Button
                if (!_otpGenerated)
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _generateOtp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: widget.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                          ),
                          child: _isLoading
                              ? const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Text('Generating OTP...'),
                                  ],
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.sms),
                                    SizedBox(width: 8),
                                    Text('Generate OTP'),
                                  ],
                                ),
                        ),
                      );
                    },
                  ),

                // OTP Input Section
                if (_otpGenerated) ...[
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _otpController,
                          enabled: !_isLoading,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(6),
                          ],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            letterSpacing: 3,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Enter OTP',
                            labelStyle: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            hintText: '123456',
                            hintStyle: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 18,
                              letterSpacing: 3,
                            ),
                            prefixIcon: Icon(
                              Icons.lock,
                              color: widget.primaryColor,
                              size: 20,
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey[300]!,
                                width: 1.5,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey[300]!,
                                width: 1.5,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: widget.primaryColor,
                                width: 2,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Colors.red,
                                width: 1.5,
                              ),
                            ),
                            counterText: '',
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (_remainingTime > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: widget.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _formatTime(_remainingTime),
                            style: TextStyle(
                              color: widget.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Verify OTP Button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _verifyOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    child: _isLoading
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Text('Verifying...'),
                            ],
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.verified_user),
                              SizedBox(width: 8),
                              Text('Verify OTP'),
                            ],
                          ),
                  ),

                  const SizedBox(height: 12),

                  // Resend OTP option
                  if (_remainingTime == 0)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _otpGenerated = false;
                          _otpController.clear();
                        });
                      },
                      child: Text(
                        'Generate New OTP',
                        style: TextStyle(color: widget.primaryColor),
                      ),
                    ),
                ],
              ],

              // Success State
              if (_isVerified) ...[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: widget.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: widget.primaryColor,
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Aadhaar Verification Successful!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your identity has been verified successfully.',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      // Removed "Verify Another Number" button as requested
                    ],
                  ),
                ),
              ],

              // Error Message
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
