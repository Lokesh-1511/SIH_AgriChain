import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              'Privacy Policy',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Last updated: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),

            const SizedBox(height: 24),

            // Introduction
            _buildSection(
              'Introduction',
              'AgriChain ("we," "our," or "us") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application and services.',
            ),

            _buildSection(
              'Information We Collect',
              'We collect information you provide directly to us, such as:\n\n'
                  '• Personal Information: Name, email address, phone number, Aadhaar number for verification\n'
                  '• Agricultural Data: Crop information, farm details, harvest data\n'
                  '• Transaction Information: Payment details, order history, financial transactions\n'
                  '• Location Data: GPS coordinates for delivery and logistics\n'
                  '• Device Information: Device identifiers, operating system, app usage statistics\n'
                  '• Communication Data: Messages, support tickets, feedback',
            ),

            _buildSection(
              'How We Use Your Information',
              'We use the collected information for:\n\n'
                  '• Providing and maintaining our services\n'
                  '• Processing transactions and payments\n'
                  '• Verifying user identity and preventing fraud\n'
                  '• Improving our application and user experience\n'
                  '• Sending important notifications and updates\n'
                  '• Providing customer support\n'
                  '• Compliance with legal obligations\n'
                  '• Agricultural market analysis and insights',
            ),

            _buildSection(
              'Information Sharing and Disclosure',
              'We do not sell, trade, or otherwise transfer your personal information to third parties without your consent, except in the following circumstances:\n\n'
                  '• Service Providers: Trusted partners who assist in operating our application\n'
                  '• Business Transactions: In case of merger, acquisition, or asset sale\n'
                  '• Legal Requirements: When required by law or to protect our rights\n'
                  '• Safety and Security: To prevent fraud or protect user safety\n'
                  '• Anonymized Data: Aggregated, non-identifiable data for research and analytics',
            ),

            _buildSection(
              'Data Security',
              'We implement robust security measures to protect your information:\n\n'
                  '• End-to-end encryption for sensitive data transmission\n'
                  '• Secure servers with regular security audits\n'
                  '• Multi-factor authentication for account access\n'
                  '• Regular security updates and patches\n'
                  '• Limited access controls for our staff\n'
                  '• Blockchain technology for transaction integrity',
            ),

            _buildSection(
              'Data Retention',
              'We retain your personal information for as long as necessary to:\n\n'
                  '• Provide our services to you\n'
                  '• Comply with legal obligations\n'
                  '• Resolve disputes and enforce agreements\n'
                  '• Maintain business records as required by law\n\n'
                  'You may request deletion of your account and data at any time, subject to legal retention requirements.',
            ),

            _buildSection(
              'Your Rights',
              'You have the following rights regarding your personal information:\n\n'
                  '• Access: Request access to your personal data\n'
                  '• Correction: Update or correct inaccurate information\n'
                  '• Deletion: Request deletion of your personal data\n'
                  '• Portability: Request a copy of your data in a portable format\n'
                  '• Objection: Object to certain processing of your data\n'
                  '• Withdrawal: Withdraw consent for data processing\n\n'
                  'To exercise these rights, contact us at privacy@agrichain.com',
            ),

            _buildSection(
              'Cookies and Tracking Technologies',
              'We use cookies and similar technologies to:\n\n'
                  '• Remember your preferences and settings\n'
                  '• Analyze app usage and performance\n'
                  '• Provide personalized content and recommendations\n'
                  '• Ensure security and prevent fraud\n\n'
                  'You can manage cookie preferences in your device settings.',
            ),

            _buildSection(
              'Children\'s Privacy',
              'Our services are not intended for children under 13 years of age. We do not knowingly collect personal information from children under 13. If we become aware that we have collected personal information from a child under 13, we will take steps to delete such information.',
            ),

            _buildSection(
              'International Data Transfers',
              'Your information may be transferred to and processed in countries other than your own. We ensure appropriate safeguards are in place to protect your data during international transfers in accordance with applicable data protection laws.',
            ),

            _buildSection(
              'Third-Party Services',
              'Our app may contain links to third-party services. This Privacy Policy applies only to AgriChain. We encourage you to review the privacy policies of any third-party services you access through our app.',
            ),

            _buildSection(
              'Changes to Privacy Policy',
              'We may update this Privacy Policy from time to time. We will notify you of any changes by:\n\n'
                  '• Posting the new Privacy Policy on this page\n'
                  '• Sending an email notification\n'
                  '• Displaying an in-app notification\n\n'
                  'Changes are effective when posted on this page.',
            ),

            _buildSection(
              'Contact Information',
              'If you have questions about this Privacy Policy or our privacy practices, please contact us:\n\n'
                  'Email: privacy@agrichain.com\n'
                  'Phone: +91 1800-XXX-XXXX\n'
                  'Address: Tech Hub, Bangalore, India\n\n'
                  'Data Protection Officer: dpo@agrichain.com',
            ),

            const SizedBox(height: 32),

            // Consent Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Consent',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'By using our app, you consent to our Privacy Policy and agree to its terms. If you do not agree with this policy, please discontinue use of our services.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green[700]),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'You have read and understood this Privacy Policy',
                          style: TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Footer
            Center(
              child: Text(
                '© 2025 AgriChain. All rights reserved.',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
