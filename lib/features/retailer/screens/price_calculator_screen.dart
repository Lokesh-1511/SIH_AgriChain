import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class PriceCalculatorScreen extends StatefulWidget {
  const PriceCalculatorScreen({super.key});

  @override
  State<PriceCalculatorScreen> createState() => _PriceCalculatorScreenState();
}

class _PriceCalculatorScreenState extends State<PriceCalculatorScreen> {
  final TextEditingController _costPriceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  double _profitMargin = 25.0;
  double _gst = 5.0;
  String _selectedProduct = 'Custom Product';
  
  double _calculatedPrice = 0.0;
  double _totalProfit = 0.0;
  double _gstAmount = 0.0;

  @override
  void dispose() {
    _costPriceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Price Calculator'),
        backgroundColor: AppColors.retailerPrimary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => _saveCalculation(context),
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Calculator Summary Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.retailerPrimary,
                    AppColors.retailerPrimary.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.retailerPrimary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Selling Price',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₹${_calculatedPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'per kg',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Input Form
            Text(
              'Product Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
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
                items: _productTemplates.keys.map((product) => 
                  DropdownMenuItem(value: product, child: Text(product))
                ).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedProduct = value!;
                    if (_productTemplates.containsKey(value)) {
                      final template = _productTemplates[value]!;
                      _costPriceController.text = template['costPrice'].toString();
                      _profitMargin = template['profitMargin'];
                      _gst = template['gst'];
                    }
                    _calculatePrice();
                  });
                },
              ),
            ),

            const SizedBox(height: 16),

            // Cost Price Input
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
                controller: _costPriceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Cost Price (₹/kg)',
                  prefixIcon: Icon(Icons.currency_rupee),
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => _calculatePrice(),
              ),
            ),

            const SizedBox(height: 16),

            // Quantity Input
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
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Quantity (kg)',
                  prefixIcon: Icon(Icons.scale),
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => _calculatePrice(),
              ),
            ),

            const SizedBox(height: 24),

            // Profit Margin Slider
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Profit Margin',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '${_profitMargin.toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: AppColors.retailerPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _profitMargin,
                    min: 0,
                    max: 100,
                    divisions: 20,
                    activeColor: AppColors.retailerPrimary,
                    onChanged: (value) {
                      setState(() {
                        _profitMargin = value;
                      });
                      _calculatePrice();
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // GST Slider
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'GST Rate',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '${_gst.toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: AppColors.retailerPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _gst,
                    min: 0,
                    max: 28,
                    divisions: 28,
                    activeColor: AppColors.retailerPrimary,
                    onChanged: (value) {
                      setState(() {
                        _gst = value;
                      });
                      _calculatePrice();
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Calculation Breakdown
            Text(
              'Price Breakdown',
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
                  _buildBreakdownRow('Cost Price', '₹${_costPriceController.text}'),
                  const Divider(),
                  _buildBreakdownRow('Profit (${_profitMargin.toStringAsFixed(1)}%)', 
                    '₹${_totalProfit.toStringAsFixed(2)}', AppColors.success),
                  const Divider(),
                  _buildBreakdownRow('GST (${_gst.toStringAsFixed(1)}%)', 
                    '₹${_gstAmount.toStringAsFixed(2)}', AppColors.warning),
                  const Divider(thickness: 2),
                  _buildBreakdownRow('Selling Price', 
                    '₹${_calculatedPrice.toStringAsFixed(2)}', 
                    AppColors.retailerPrimary, true),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Quick Preset Buttons
            Text(
              'Quick Presets',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(child: _buildPresetButton('Low Margin', 15.0, AppColors.info)),
                const SizedBox(width: 8),
                Expanded(child: _buildPresetButton('Standard', 25.0, AppColors.success)),
                const SizedBox(width: 8),
                Expanded(child: _buildPresetButton('Premium', 40.0, AppColors.warning)),
              ],
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _resetCalculator,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reset'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _updateProductPrice(context),
                    icon: const Icon(Icons.update),
                    label: const Text('Update Price'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.retailerPrimary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakdownRow(String label, String value, [Color? color, bool isBold = false]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color ?? AppColors.textSecondary,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color ?? AppColors.textPrimary,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetButton(String label, double margin, Color color) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _profitMargin = margin;
        });
        _calculatePrice();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 8),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }

  void _calculatePrice() {
    if (_costPriceController.text.isNotEmpty) {
      double costPrice = double.tryParse(_costPriceController.text) ?? 0;
      
      _totalProfit = costPrice * (_profitMargin / 100);
      double priceWithProfit = costPrice + _totalProfit;
      _gstAmount = priceWithProfit * (_gst / 100);
      _calculatedPrice = priceWithProfit + _gstAmount;
      
      setState(() {});
    }
  }

  void _resetCalculator() {
    setState(() {
      _costPriceController.clear();
      _quantityController.clear();
      _profitMargin = 25.0;
      _gst = 5.0;
      _selectedProduct = 'Custom Product';
      _calculatedPrice = 0.0;
      _totalProfit = 0.0;
      _gstAmount = 0.0;
    });
  }

  void _saveCalculation(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Price calculation saved!')),
    );
  }

  void _updateProductPrice(BuildContext context) {
    if (_calculatedPrice > 0) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Update Product Price'),
          content: Text(
            'Update ${_selectedProduct} price to ₹${_calculatedPrice.toStringAsFixed(2)}/kg?'
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
                  const SnackBar(content: Text('Product price updated successfully!')),
                );
              },
              child: const Text('Update'),
            ),
          ],
        ),
      );
    }
  }

  static final Map<String, Map<String, dynamic>> _productTemplates = {
    'Custom Product': {'costPrice': 0.0, 'profitMargin': 25.0, 'gst': 5.0},
    'Alphonso Mango': {'costPrice': 350.0, 'profitMargin': 30.0, 'gst': 0.0},
    'Basmati Rice': {'costPrice': 70.0, 'profitMargin': 20.0, 'gst': 5.0},
    'Red Onion': {'costPrice': 20.0, 'profitMargin': 25.0, 'gst': 0.0},
    'Fresh Milk': {'costPrice': 45.0, 'profitMargin': 15.0, 'gst': 0.0},
    'Turmeric Powder': {'costPrice': 200.0, 'profitMargin': 40.0, 'gst': 5.0},
    'Green Apple': {'costPrice': 140.0, 'profitMargin': 30.0, 'gst': 0.0},
    'Tomato': {'costPrice': 25.0, 'profitMargin': 40.0, 'gst': 0.0},
    'Wheat Flour': {'costPrice': 35.0, 'profitMargin': 25.0, 'gst': 5.0},
  };
}