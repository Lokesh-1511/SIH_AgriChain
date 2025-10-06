import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Service for showing real-looking notifications
class NotificationService {
  static OverlayEntry? _currentNotification;

  /// Show a notification that looks like a real system notification
  static void showNotification({
    required BuildContext context,
    required String title,
    required String message,
    String? otp,
    Duration duration = const Duration(seconds: 6),
    VoidCallback? onTap,
    Color primaryColor = const Color(0xFF4CAF50),
  }) {
    // Remove any existing notification
    hideNotification();

    final overlay = Overlay.of(context);

    _currentNotification = OverlayEntry(
      builder: (context) => NotificationWidget(
        title: title,
        message: message,
        otp: otp,
        onTap: onTap,
        onDismiss: hideNotification,
        primaryColor: primaryColor,
      ),
    );

    overlay.insert(_currentNotification!);

    // Auto-hide after duration
    Future.delayed(duration, () {
      hideNotification();
    });
  }

  /// Hide the current notification
  static void hideNotification() {
    _currentNotification?.remove();
    _currentNotification = null;
  }
}

class NotificationWidget extends StatefulWidget {
  final String title;
  final String message;
  final String? otp;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;
  final Color primaryColor;

  const NotificationWidget({
    super.key,
    required this.title,
    required this.message,
    this.otp,
    this.onTap,
    this.onDismiss,
    this.primaryColor = const Color(0xFF4CAF50),
  });

  @override
  State<NotificationWidget> createState() => _NotificationWidgetState();
}

class _NotificationWidgetState extends State<NotificationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutBack,
          ),
        );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _dismiss() {
    _animationController.reverse().then((_) {
      widget.onDismiss?.call();
    });
  }

  void _copyOtp() {
    if (widget.otp != null) {
      Clipboard.setData(ClipboardData(text: widget.otp!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP copied to clipboard'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Material(
        color: Colors.transparent,
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          spreadRadius: 2,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // App icon
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: widget.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.security,
                            color: widget.primaryColor,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.title,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                widget.message,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              if (widget.otp != null) ...[
                                const SizedBox(height: 8),
                                GestureDetector(
                                  onTap: _copyOtp,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: widget.primaryColor.withOpacity(
                                        0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: widget.primaryColor.withOpacity(
                                          0.3,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'OTP: ${widget.otp}',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: widget.primaryColor,
                                            letterSpacing: 2,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Icon(
                                          Icons.copy,
                                          size: 16,
                                          color: widget.primaryColor,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                        // Close button
                        GestureDetector(
                          onTap: _dismiss,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              Icons.close,
                              size: 20,
                              color: Colors.grey[400],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
