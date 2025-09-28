import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class QRGeneratorScreen extends StatefulWidget {
  const QRGeneratorScreen({super.key});

  @override
  State<QRGeneratorScreen> createState() => _QRGeneratorScreenState();
}

class _QRGeneratorScreenState extends State<QRGeneratorScreen> {
  String _selectedProduct = 'Alphonso Mango';
  String _selectedTemplate = 'Product Info';
  String _customText = '';
  bool _includePrice = true;
  bool _includeOrigin = true;
  bool _includeBatch = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('QR Code Generator'),
        backgroundColor: AppColors.retailerPrimary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => _shareQR(context),
            icon: const Icon(Icons.share),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // QR Code Display
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.qr_code, size: 80),
                            SizedBox(height: 8),
                            Text('QR Code Preview'),
                            Text('(Generated QR will appear here)'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _selectedProduct,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'QR Code for $_selectedTemplate',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Template Selection
            Text(
              'QR Code Template',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 16),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: DropdownButtonFormField<String>(
                value: _selectedTemplate,
                decoration: const InputDecoration(
                  labelText: 'Select Template',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                items: _qrTemplates.map((template) => 
                  DropdownMenuItem(value: template, child: Text(template))
                ).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedTemplate = value!;
                  });
                },
              ),
            ),

            const SizedBox(height: 16),

            // Product Selection
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: DropdownButtonFormField<String>(
                value: _selectedProduct,
                decoration: const InputDecoration(
                  labelText: 'Select Product',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                items: _products.keys.map((product) => 
                  DropdownMenuItem(value: product, child: Text(product))
                ).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedProduct = value!;
                  });
                },
              ),
            ),

            const SizedBox(height: 24),

            // QR Content Options
            Text(
              'Include Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CheckboxListTile(
                    title: const Text('Product Price'),
                    value: _includePrice,
                    onChanged: (value) {
                      setState(() {
                        _includePrice = value!;
                      });
                    },
                    activeColor: AppColors.retailerPrimary,
                  ),
                  CheckboxListTile(
                    title: const Text('Origin/Source'),
                    value: _includeOrigin,
                    onChanged: (value) {
                      setState(() {
                        _includeOrigin = value!;
                      });
                    },
                    activeColor: AppColors.retailerPrimary,
                  ),
                  CheckboxListTile(
                    title: const Text('Batch Information'),
                    value: _includeBatch,
                    onChanged: (value) {
                      setState(() {
                        _includeBatch = value!;
                      });
                    },
                    activeColor: AppColors.retailerPrimary,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Custom Text Input
            Text(
              'Additional Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 16),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Custom Message (Optional)',
                  hintText: 'Enter any additional information...',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(16),
                ),
                onChanged: (value) {
                  setState(() {
                    _customText = value;
                  });
                },
              ),
            ),

            const SizedBox(height: 24),

            // Preview Information
            Text(
              'QR Code Content Preview',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 16),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Product: $_selectedProduct',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  if (_includePrice && _products[_selectedProduct] != null)
                    Text('Price: ₹${_products[_selectedProduct]!['price']}/kg'),
                  if (_includeOrigin && _products[_selectedProduct] != null)
                    Text('Origin: ${_products[_selectedProduct]!['origin']}'),
                  if (_includeBatch)
                    Text('Batch: ${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}'),
                  if (_customText.isNotEmpty)
                    Text('Note: $_customText'),
                  const SizedBox(height: 8),
                  Text(
                    'Scan Date: ${DateTime.now().toString().split('.').first}',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _downloadQR(context),
                    icon: const Icon(Icons.download),
                    label: const Text('Download'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _generateQR(context),
                    icon: const Icon(Icons.qr_code),
                    label: const Text('Generate QR'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.retailerPrimary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Bulk Generate Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _bulkGenerateQR(context),
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Bulk Generate for All Products'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _generateQR(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('QR Code Generated'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.qr_code, size: 60),
                    SizedBox(height: 8),
                    Text('Generated QR Code'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('QR code has been generated successfully!'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _downloadQR(context);
            },
            child: const Text('Download'),
          ),
        ],
      ),
    );
  }

  void _downloadQR(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('QR Code downloaded to gallery!')),
    );
  }

  void _shareQR(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('QR Code sharing feature coming soon!')),
    );
  }

  void _bulkGenerateQR(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bulk Generate QR Codes'),
        content: const Text(
          'This will generate QR codes for all products in your inventory. Do you want to continue?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Generating QR codes for all products...'),
                  duration: Duration(seconds: 3),
                ),
              );
            },
            child: const Text('Generate All'),
          ),
        ],
      ),
    );
  }

  static final List<String> _qrTemplates = [
    'Product Info',
    'Price Tag',
    'Full Details',
    'Traceability',
    'Marketing',
    'Custom',
  ];

  static final Map<String, Map<String, dynamic>> _products = {
    'Alphonso Mango': {
      'price': 450.0,
      'origin': 'Ratnagiri, Maharashtra',
      'category': 'Fruits',
    },
    'Basmati Rice': {
      'price': 85.0,
      'origin': 'Punjab, India',
      'category': 'Grains',
    },
    'Red Onion': {
      'price': 25.0,
      'origin': 'Nashik, Maharashtra',
      'category': 'Vegetables',
    },
    'Fresh Milk': {
      'price': 52.0,
      'origin': 'Local Dairy Farm',
      'category': 'Dairy',
    },
    'Turmeric Powder': {
      'price': 280.0,
      'origin': 'Kerala, India',
      'category': 'Spices',
    },
    'Green Apple': {
      'price': 180.0,
      'origin': 'Kashmir, India',
      'category': 'Fruits',
    },
    'Tomato': {
      'price': 35.0,
      'origin': 'Nashik, Maharashtra',
      'category': 'Vegetables',
    },
    'Wheat Flour': {
      'price': 45.0,
      'origin': 'Madhya Pradesh',
      'category': 'Grains',
    },
  };
}