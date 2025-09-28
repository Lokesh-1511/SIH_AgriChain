import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('About AgriChain'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Logo and Title
            Center(
              child: Column(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.green[700],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.eco,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'AgriChain',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Mission Section
            _buildSection(
              'Our Mission',
              'AgriChain is dedicated to revolutionizing the agricultural supply chain by connecting farmers, distributors, retailers, and consumers through a transparent, efficient, and sustainable platform.',
              Icons.flag,
            ),

            const SizedBox(height: 24),

            // Vision Section
            _buildSection(
              'Our Vision',
              'To create a world where agricultural supply chains are transparent, farmers are empowered, and consumers have access to fresh, quality produce at fair prices.',
              Icons.visibility,
            ),

            const SizedBox(height: 24),

            // Features Section
            _buildSection(
              'Key Features',
              '• Direct connection between farmers and buyers\n'
              '• Real-time crop tracking and traceability\n'
              '• Secure blockchain-based transactions\n'
              '• Market price transparency\n'
              '• Quality assurance and certification\n'
              '• Weather and agricultural insights\n'
              '• Insurance and financial services integration',
              Icons.star,
            ),

            const SizedBox(height: 24),

            // Technology Section
            _buildSection(
              'Technology',
              'Built with cutting-edge technology including blockchain for transparency, IoT for real-time monitoring, AI for predictive analytics, and mobile-first design for accessibility.',
              Icons.computer,
            ),

            const SizedBox(height: 24),

            // Team Section
            _buildSection(
              'Development Team',
              'AgriChain is developed by a passionate team of engineers, agricultural experts, and blockchain specialists committed to transforming the agricultural industry.',
              Icons.group,
            ),

            const SizedBox(height: 32),

            // Contact Info
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
                    'Get in Touch',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildContactInfo(Icons.email, 'support@agrichain.com'),
                  const SizedBox(height: 8),
                  _buildContactInfo(Icons.phone, '+91 1800-XXX-XXXX'),
                  const SizedBox(height: 8),
                  _buildContactInfo(Icons.web, 'www.agrichain.com'),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Copyright
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

  Widget _buildSection(String title, String content, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.green[700], size: 24),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildContactInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.green[700]),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}