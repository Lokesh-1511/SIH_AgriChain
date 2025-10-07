import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/smart_contract_service.dart';
import '../../../core/services/auth_service.dart';

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
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  final List<String> _units = ['kg', 'tons', 'quintal', 'bags'];
  final List<String> _categories = ['Vegetables', 'Fruits', 'Grains', 'Pulses'];

  // Quality metrics with default values
  final Map<String, bool> _qualityMetrics = {
    'Organic Certified': false,
    'Pesticide Free': false,
    'Fresh (< 24 hours)': false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.farmerPrimary,
        title: const Text(
          'Post Product',
          style: TextStyle(color: Colors.white),
        ),
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
              GestureDetector(
                onTap: _selectedImage == null ? _showImageSourceDialog : null,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppColors.farmerPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.farmerPrimary.withOpacity(0.3),
                    ),
                  ),
                  child: _selectedImage != null
                      ? Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                _selectedImage!,
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: double.infinity,
                                    height: 200,
                                    color: AppColors.farmerPrimary.withOpacity(
                                      0.1,
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.error_outline,
                                          size: 48,
                                          color: Colors.red,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Error loading image',
                                          style: TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _selectedImage = null),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.7),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: _showImageSourceDialog,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.farmerPrimary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.camera_alt,
                              size: 48,
                              color: AppColors.farmerPrimary,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Upload Product Image',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () {
                                // Handle image upload
                                _showImageSourceDialog();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.farmerPrimary,
                              ),
                              child: const Text(
                                'Choose Image',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 24),

              // Product Name
              TextFormField(
                controller: _nameController,
                style: TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Product Name',
                  labelStyle: TextStyle(color: AppColors.textPrimary),
                  hintText: 'e.g., Fresh Tomatoes',
                  hintStyle: TextStyle(color: AppColors.textSecondary),
                  prefixIcon: Icon(
                    Icons.agriculture,
                    color: AppColors.farmerPrimary,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.farmerPrimary,
                      width: 1.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.farmerPrimary,
                      width: 2.0,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) =>
                    value?.isEmpty == true ? 'Please enter product name' : null,
              ),

              const SizedBox(height: 16),

              // Category
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                dropdownColor: AppColors.background,
                style: TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Category',
                  labelStyle: TextStyle(color: AppColors.textPrimary),
                  prefixIcon: Icon(
                    Icons.category,
                    color: AppColors.farmerPrimary,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.farmerPrimary,
                      width: 1.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.farmerPrimary,
                      width: 2.0,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _categories
                    .map(
                      (category) => DropdownMenuItem(
                        value: category,
                        child: Text(
                          category,
                          style: TextStyle(color: AppColors.textPrimary),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) =>
                    setState(() => _selectedCategory = value!),
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
                      style: TextStyle(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        labelText: 'Quantity',
                        labelStyle: TextStyle(color: AppColors.textPrimary),
                        prefixIcon: Icon(
                          Icons.scale,
                          color: AppColors.farmerPrimary,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.farmerPrimary,
                            width: 1.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.farmerPrimary,
                            width: 2.0,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) =>
                          value?.isEmpty == true ? 'Enter quantity' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedUnit,
                      style: TextStyle(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        labelText: 'Unit',
                        labelStyle: TextStyle(color: AppColors.textPrimary),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.farmerPrimary,
                            width: 1.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.farmerPrimary,
                            width: 2.0,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: _units
                          .map(
                            (unit) => DropdownMenuItem(
                              value: unit,
                              child: Text(
                                unit,
                                style: TextStyle(color: AppColors.textPrimary),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _selectedUnit = value!),
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
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Based on market trends and quality: ₹45-52 per kg',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _selectedImage != null
                          ? 'Image: ${_selectedImage!.path}'
                          : 'No image selected',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        _priceController.text = '48';
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.info,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      child: const Text(
                        'Use AI Price',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Base Price
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                style: TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Base Price (₹ per $_selectedUnit)',
                  labelStyle: TextStyle(color: AppColors.textPrimary),
                  prefixIcon: Icon(
                    Icons.currency_rupee,
                    color: AppColors.farmerPrimary,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.farmerPrimary,
                      width: 1.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.farmerPrimary,
                      width: 2.0,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) =>
                    value?.isEmpty == true ? 'Enter base price' : null,
              ),

              const SizedBox(height: 24),

              // Quality Metrics
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Quality Information',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.farmerPrimary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_getSelectedQualityMetrics.length} selected',
                      style: TextStyle(
                        color: AppColors.farmerPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Dynamic quality metrics
              ..._qualityMetrics.keys.map(
                (metric) =>
                    _buildQualityMetric(metric, _qualityMetrics[metric]!),
              ),

              const SizedBox(height: 32),

              // Post Product Button
              ElevatedButton(
                onPressed: _postProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.farmerPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? AppColors.textPrimary : Colors.grey,
        ),
      ),
      value: isSelected,
      onChanged: (value) {
        setState(() {
          _qualityMetrics[label] = value ?? false;
        });
      },
      activeColor: AppColors.farmerPrimary,
      checkColor: Colors.white,
      fillColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.farmerPrimary;
        }
        return Colors.grey.shade300;
      }),
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }

  List<String> get _getSelectedQualityMetrics {
    return _qualityMetrics.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        title: Text(
          'Select Image Source',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(
                Icons.camera_alt,
                color: AppColors.textPrimary,
              ),
              title: Text(
                'Camera',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: AppColors.textPrimary,
              ),
              title: Text(
                'Gallery',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromGallery();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
        print('📷 Camera image selected: ${image.path}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Image selected successfully!'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        print('📷 No camera image selected');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error accessing camera: $e',
            style: TextStyle(color: AppColors.textPrimary),
          ),
        ),
      );
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
        print('🖼️ Gallery image selected: ${image.path}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Image selected successfully!'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        print('🖼️ No gallery image selected');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error accessing gallery: $e',
            style: TextStyle(color: AppColors.textPrimary),
          ),
        ),
      );
    }
  }

  Future<void> _postProduct() async {
    if (_formKey.currentState!.validate()) {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Posting to Blockchain...',
                style: TextStyle(color: AppColors.textPrimary),
              ),
            ],
          ),
        ),
      );

      try {
        // Get current user wallet
        final userWallet = await AuthService.instance.getCurrentUserWallet();
        final userInfo = await AuthService.instance
            .getCurrentUserBlockchainInfo();

        if (userWallet == null || userInfo == null) {
          throw Exception('User wallet not found. Please login again.');
        }

        // Generate product ID
        final productId = 'PROD_${DateTime.now().millisecondsSinceEpoch}';

        // Get selected quality metrics
        final selectedQualities = _getSelectedQualityMetrics;

        // Log product details for debugging
        print('📦 Product Details:');
        print('   Name: ${_nameController.text}');
        print('   Category: $_selectedCategory');
        print('   Quantity: ${_quantityController.text} $_selectedUnit');
        print('   Price: ₹${_priceController.text}');
        print('   Quality Metrics: $selectedQualities');
        print('   Image: ${_selectedImage?.path ?? 'None'}');

        // Post to blockchain via smart contract service
        final result = await SmartContractService.registerProduct(
          productId: productId,
          productName: _nameController.text,
          basePrice: double.parse(_priceController.text),
          farmerId: userInfo['user_id'],
          farmerWalletAddress: userWallet,
        );

        Navigator.pop(context); // Close loading

        if (result.success) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: AppColors.background,
              title: Text(
                'Success!',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your product has been posted to the blockchain successfully.',
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Product ID: $productId',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (result.transactionHash.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Tx Hash: ${result.transactionHash}',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                  if (_getSelectedQualityMetrics.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Quality Certifications:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ..._getSelectedQualityMetrics.map(
                      (quality) => Padding(
                        padding: const EdgeInsets.only(left: 8.0, top: 2.0),
                        child: Text(
                          '• $quality',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
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
        } else {
          throw Exception(
            result.message.isNotEmpty
                ? result.message
                : 'Failed to post product',
          );
        }
      } catch (e) {
        Navigator.pop(context); // Close loading

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.background,
            title: Text(
              'Error',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            content: Text(
              'Failed to post product to blockchain:\n${e.toString()}',
              style: TextStyle(color: AppColors.textPrimary),
            ),
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
  }
}
