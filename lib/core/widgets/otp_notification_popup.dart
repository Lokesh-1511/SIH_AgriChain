import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

/// OTP Notification Popup Widget
/// Shows generated OTP in a realistic SMS-like notification for 10 seconds
class OtpNotificationPopup extends StatefulWidget {
  final String otp;
  final String mobileNumber;
  final VoidCallback onDismiss;

  const OtpNotificationPopup({
    super.key,
    required this.otp,
    required this.mobileNumber,
    required this.onDismiss,
  });

  /// Show OTP notification popup
  static void show({
    required BuildContext context,
    required String otp,
    required String mobileNumber,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black26,
      builder: (context) => OtpNotificationPopup(
        otp: otp,
        mobileNumber: mobileNumber,
        onDismiss: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  State<OtpNotificationPopup> createState() => _OtpNotificationPopupState();
}

class _OtpNotificationPopupState extends State<OtpNotificationPopup>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _progressController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _progressAnimation;

  static const Duration _displayDuration = Duration(seconds: 10);

  @override
  void initState() {
    super.initState();

    // Slide animation controller
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Progress animation controller
    _progressController = AnimationController(
      duration: _displayDuration,
      vsync: this,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
        );

    _progressAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.linear),
    );

    // Start animations
    _slideController.forward();
    _progressController.forward();

    // Auto-dismiss after 10 seconds
    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _dismissNotification();
      }
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _dismissNotification() {
    _slideController.reverse().then((_) {
      if (mounted) {
        widget.onDismiss();
      }
    });
  }

  void _copyOtp() {
    Clipboard.setData(ClipboardData(text: widget.otp));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('OTP copied to clipboard'),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SlideTransition(
            position: _slideAnimation,
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Progress indicator
                    AnimatedBuilder(
                      animation: _progressAnimation,
                      builder: (context, child) {
                        return LinearProgressIndicator(
                          value: _progressAnimation.value,
                          backgroundColor: Colors.white24,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        );
                      },
                    ),

                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white24,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.sms,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    const Text(
                                      'SMS from UIDAI',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    //TODO: change the number to the actual number
                                    Text(
                                      'To: ${widget.mobileNumber}',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: _dismissNotification,
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // SMS Content
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Your Aadhaar OTP for AgriChain verification:',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // OTP Display
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          widget.otp,
                                          style: const TextStyle(
                                            color: AppColors.textPrimary,
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 4,
                                            fontFamily: 'monospace',
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: _copyOtp,
                                        icon: Icon(
                                          Icons.copy,
                                          color: AppColors.primary,
                                          size: 20,
                                        ),
                                        tooltip: 'Copy OTP',
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 12),

                                const Text(
                                  'Valid for 10 minutes. Do not share with anyone.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.red,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),

                                const SizedBox(height: 8),

                                const Text(
                                  '- Government of India, UIDAI',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Auto-dismiss countdown
                          AnimatedBuilder(
                            animation: _progressAnimation,
                            builder: (context, child) {
                              final remainingSeconds =
                                  (_progressAnimation.value * 10).ceil();
                              return Text(
                                'Auto-dismiss in ${remainingSeconds}s',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
