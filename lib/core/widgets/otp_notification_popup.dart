import 'package:flutter/material.dart';

class OtpNotificationPopup {
  static void show(BuildContext context, String otp, String aadhaarNumber) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('OTP Generated'),
        content: Text('Your OTP: '),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
