import 'package:flutter/material.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Terms of Service'),
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
              'Terms of Service',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Last updated: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 24),

            _buildSection(
              'Agreement to Terms',
              'By accessing and using the AgriChain mobile application ("Service"), you accept and agree to be bound by the terms and provision of this agreement. If you do not agree to abide by the above, please do not use this service.',
            ),

            _buildSection(
              'Description of Service',
              'AgriChain is an agricultural supply chain platform that connects farmers, distributors, retailers, and consumers. Our services include:\n\n'
              '• Crop listing and marketplace functionality\n'
              '• Supply chain management and tracking\n'
              '• Payment processing and financial services\n'
              '• Quality assurance and certification\n'
              '• Weather and agricultural insights\n'
              '• Communication and collaboration tools',
            ),

            _buildSection(
              'User Accounts and Registration',
              'To access certain features, you must register for an account. You agree to:\n\n'
              '• Provide accurate, complete, and current information\n'
              '• Maintain the security of your password and account\n'
              '• Accept responsibility for all activities under your account\n'
              '• Notify us immediately of any unauthorized use\n'
              '• Verify your identity using Aadhaar or other approved methods',
            ),

            _buildSection(
              'User Conduct and Responsibilities',
              'You agree to use our services responsibly and not to:\n\n'
              '• Violate any laws or regulations\n'
              '• Infringe on intellectual property rights\n'
              '• Upload false, misleading, or fraudulent content\n'
              '• Interfere with the proper functioning of the service\n'
              '• Attempt to gain unauthorized access to our systems\n'
              '• Use the service for illegal or unauthorized purposes\n'
              '• Harass, abuse, or harm other users',
            ),

            _buildSection(
              'Product Listings and Transactions',
              'For farmers and sellers:\n\n'
              '• You are responsible for accurate product descriptions\n'
              '• You must comply with quality and safety standards\n'
              '• You agree to fulfill orders in a timely manner\n'
              '• You are responsible for product quality and freshness\n\n'
              'For buyers:\n\n'
              '• You agree to pay for confirmed orders\n'
              '• You must inspect products upon delivery\n'
              '• You agree to report any issues promptly',
            ),

            _buildSection(
              'Payment Terms',
              'All transactions are subject to our payment terms:\n\n'
              '• Payments are processed through secure, third-party providers\n'
              '• Transaction fees may apply as disclosed\n'
              '• Refunds are subject to our refund policy\n'
              '• Disputes will be handled through our resolution process\n'
              '• All prices are subject to applicable taxes',
            ),

            _buildSection(
              'Intellectual Property Rights',
              'The Service and its original content, features, and functionality are owned by AgriChain and are protected by international copyright, trademark, patent, trade secret, and other intellectual property laws.\n\n'
              'You retain ownership of content you submit but grant us a license to use, display, and distribute such content through our service.',
            ),

            _buildSection(
              'Privacy and Data Protection',
              'Your privacy is important to us. Please review our Privacy Policy, which also governs your use of the Service, to understand our practices regarding the collection, use, and disclosure of your personal information.',
            ),

            _buildSection(
              'Service Availability',
              'We strive to maintain service availability but cannot guarantee uninterrupted access. We reserve the right to:\n\n'
              '• Modify or discontinue the service with notice\n'
              '• Perform maintenance that may temporarily affect availability\n'
              '• Suspend accounts that violate these terms\n'
              '• Update features and functionality',
            ),

            _buildSection(
              'Limitation of Liability',
              'To the maximum extent permitted by law:\n\n'
              '• AgriChain shall not be liable for any indirect, incidental, or consequential damages\n'
              '• Our total liability shall not exceed the amount paid by you for the service\n'
              '• We do not guarantee specific outcomes from using our service\n'
              '• Users participate at their own risk',
            ),

            _buildSection(
              'Indemnification',
              'You agree to indemnify and hold AgriChain harmless from any claims, damages, losses, or expenses (including attorney fees) arising from:\n\n'
              '• Your use of the service\n'
              '• Your violation of these terms\n'
              '• Your violation of any rights of another party\n'
              '• Your content or conduct on the platform',
            ),

            _buildSection(
              'Dispute Resolution',
              'Any disputes arising from these terms or your use of the service will be resolved through:\n\n'
              '• Good faith negotiations between the parties\n'
              '• Mediation if negotiations fail\n'
              '• Arbitration in accordance with Indian Arbitration laws\n'
              '• Courts in Bangalore, India as the exclusive jurisdiction',
            ),

            _buildSection(
              'Termination',
              'We may terminate or suspend your account and access to the service immediately, without prior notice, for conduct that we believe:\n\n'
              '• Violates these Terms of Service\n'
              '• Is harmful to other users or third parties\n'
              '• Is harmful to our business or reputation\n'
              '• Violates applicable laws or regulations',
            ),

            _buildSection(
              'Governing Law',
              'These Terms shall be interpreted and governed by the laws of India, without regard to conflict of law principles. Any legal action or proceeding shall be brought exclusively in the courts of Bangalore, India.',
            ),

            _buildSection(
              'Changes to Terms',
              'We reserve the right to modify these terms at any time. We will notify users of material changes through:\n\n'
              '• Email notifications\n'
              '• In-app notifications\n'
              '• Updates posted on our website\n\n'
              'Continued use of the service after changes constitutes acceptance of the new terms.',
            ),

            _buildSection(
              'Severability',
              'If any provision of these Terms is found to be unenforceable or invalid, that provision will be limited or eliminated to the minimum extent necessary so that these Terms will otherwise remain in full force and effect.',
            ),

            _buildSection(
              'Contact Information',
              'If you have any questions about these Terms of Service, please contact us:\n\n'
              'Email: legal@agrichain.com\n'
              'Phone: +91 1800-XXX-XXXX\n'
              'Address: Tech Hub, Bangalore, India',
            ),

            const SizedBox(height: 32),

            // Acceptance Section
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
                    'Acceptance of Terms',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'By using AgriChain, you acknowledge that you have read these Terms of Service and agree to be bound by them.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.gavel, color: Colors.green[700]),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'These terms are legally binding',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
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
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 14,
                ),
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