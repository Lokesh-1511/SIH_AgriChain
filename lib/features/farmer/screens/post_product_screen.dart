import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class PostProductScreen extends StatefulWidget {
  const PostProductScreen({super.key});

  @override
  State<PostProductScreen> createState() => _PostProductScreenState();
}

class _PostProductScreenState extends State<PostProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  
  String _selectedUnit = 'kg';
  String _selectedCategory = 'Vegetables';

  final List<String> _units = ['kg', 'tons', 'quintal', 'bags'];
  final List<String> _categories = ['Vegetables', 'Fruits', 'Grains', 'Pulses'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.farmerPrimary,
        title: const Text('Post Product', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Product Image Upload
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: AppColors.farmerPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.farmerPrimary.withOpacity(0.3)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt, size: 48, color: AppColors.farmerPrimary),
                    const SizedBox(height: 12),
                    Text(
                      'Upload Product Image',
                      style: TextStyle(color: AppColors.farmerPrimary, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        // Handle image upload
                        _showImageSourceDialog();
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.farmerPrimary),
                      child: const Text('Choose Image', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Product Name
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Product Name',
                  hintText: 'e.g., Fresh Tomatoes',
                  prefixIcon: Icon(Icons.agriculture, color: AppColors.farmerPrimary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) => value?.isEmpty == true ? 'Please enter product name' : null,
              ),

              const SizedBox(height: 16),

              // Category
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category, color: AppColors.farmerPrimary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: _categories.map((category) => 
                  DropdownMenuItem(value: category, child: Text(category))
                ).toList(),
                onChanged: (value) => setState(() => _selectedCategory = value!),
              ),

              const SizedBox(height: 16),

              // Quantity and Unit
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Quantity',
                        prefixIcon: Icon(Icons.scale, color: AppColors.farmerPrimary),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (value) => value?.isEmpty == true ? 'Enter quantity' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedUnit,
                      decoration: InputDecoration(
                        labelText: 'Unit',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: _units.map((unit) => 
                        DropdownMenuItem(value: unit, child: Text(unit))
                      ).toList(),
                      onChanged: (value) => setState(() => _selectedUnit = value!),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // AI Price Suggestion
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.info.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.psychology, color: AppColors.info, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'AI Price Suggestion',
                          style: TextStyle(
                            color: AppColors.info,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Based on market trends and quality: ₹45-52 per kg',
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        _priceController.text = '48';
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.info,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      child: const Text('Use AI Price', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Base Price
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Base Price (₹ per $_selectedUnit)',
                  prefixIcon: Icon(Icons.currency_rupee, color: AppColors.farmerPrimary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) => value?.isEmpty == true ? 'Enter base price' : null,
              ),

              const SizedBox(height: 24),

              // Quality Metrics
              Text(
                'Quality Information',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 12),

              _buildQualityMetric('Organic Certified', true),
              _buildQualityMetric('Pesticide Free', true),
              _buildQualityMetric('Fresh (< 24 hours)', false),

              const SizedBox(height: 32),

              // Post Product Button
              ElevatedButton(
                onPressed: _postProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.farmerPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Post Product to Blockchain',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQualityMetric(String label, bool isSelected) {
    return CheckboxListTile(
      title: Text(label),
      value: isSelected,
      onChanged: (value) {
        // Handle quality metric toggle
      },
      activeColor: AppColors.farmerPrimary,
      contentPadding: EdgeInsets.zero,
    );
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                // Handle camera capture
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                // Handle gallery selection
              },
            ),
          ],
        ),
      ),
    );
  }

  void _postProduct() {
    if (_formKey.currentState!.validate()) {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Posting to Blockchain...'),
            ],
          ),
        ),
      );

      // Simulate blockchain posting
      Future.delayed(const Duration(seconds: 3), () {
        Navigator.pop(context); // Close loading
        
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Success!'),
            content: const Text('Your product has been posted to the blockchain successfully.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back to dashboard
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      });
    }
  }
}