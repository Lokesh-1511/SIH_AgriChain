import 'package:flutter/material.dart';
import '../core/widgets/simple_aadhaar_widget.dart';

/// Test screen for the new local Aadhaar verification system
class AadhaarTestScreen extends StatelessWidget {
  const AadhaarTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aadhaar Verification Test'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'New Local Aadhaar Verification System',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'How it works:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              '1. Enter any 12-digit Aadhaar number\n'
              '2. Click "Generate OTP" - a popup will show the OTP\n'
              '3. Copy the OTP and enter it in the verification field\n'
              '4. Click "Verify OTP" to complete verification\n\n'
              'No backend needed - everything works locally!',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SimpleAadhaarWidget(
                primaryColor: const Color(0xFF4CAF50),
                onVerificationComplete: (isVerified, kycData) {
                  if (isVerified) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Success! Welcome ${kycData?['name'] ?? 'User'}',
                        ),
                        backgroundColor: const Color(0xFF4CAF50),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
