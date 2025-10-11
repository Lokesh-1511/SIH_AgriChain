import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/agrichain_user.dart';
<<<<<<< HEAD
=======
import '../../../core/services/user_service.dart';
>>>>>>> 5b3ae447a7a6f15554647b4ed5c427121e8f156b
import '../../auth/providers/auth_provider.dart';
import 'landing_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    if (user != null) {
      print('🔍 Profile Screen User Data:');
      print('ID: ${user.id}');
      print('Firebase UID: ${user.firebaseUid}');
      print('Name: "${user.name}"');
      print('Email: "${user.email}"');
      print('Phone: "${user.phone}"');
      print('Address: "${user.address}"');
      print('Role: ${user.role}');
      print('Is Verified: ${user.isVerified}');
      print('KYC Details: ${user.kycDetails}');
      print('Additional Info: ${user.additionalInfo}');

      _nameController.text = user.name;
      _emailController.text = user.email;
      _phoneController.text = user.phone;
      _addressController.text = user.address;
    } else {
      print('❌ No user data available in profile screen');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('No user data available')),
      );
    }

    Color primaryColor = _getPrimaryColorForRole(user.role);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        title: Text('profile.title'.tr()),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => setState(() => _isEditing = !_isEditing),
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Profile Avatar
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: primaryColor.withOpacity(0.1),
                        child: Icon(
                          _getIconForRole(user.role),
                          size: 48,
                          color: primaryColor,
                        ),
                      ),
                      if (_isEditing)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Role Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      user.role.displayName.toUpperCase(),
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // User ID - Show role-specific unique ID
                  _buildCopyableId(user, primaryColor),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Profile Details Form
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Personal Information',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Name Field
                  _buildProfileField(
                    'common.name'.tr(),
                    _nameController,
                    Icons.person,
                    _isEditing,
                  ),

                  const SizedBox(height: 16),

                  // Email Field
                  _buildProfileField(
                    'common.email'.tr(),
                    _emailController,
                    Icons.email,
                    false, // Email should not be editable
                  ),

                  const SizedBox(height: 16),

                  // Phone Field
                  _buildProfileField(
                    'common.phone'.tr(),
                    _phoneController,
                    Icons.phone,
                    _isEditing,
                  ),

                  const SizedBox(height: 16),

                  // Address Field
                  _buildProfileField(
                    'common.address'.tr(),
                    _addressController,
                    Icons.location_on,
                    _isEditing,
                    maxLines: 3,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Role-specific Information
            if (user.role == UserRole.farmer)
              _buildFarmerInfo(user, primaryColor),
            if (user.role == UserRole.distributor)
              _buildDistributorInfo(user, primaryColor),
            if (user.role == UserRole.retailer)
              _buildRetailerInfo(user, primaryColor),
            if (user.role == UserRole.consumer)
              _buildConsumerInfo(user, primaryColor),

            const SizedBox(height: 24),

            // Action Buttons
            Column(
              children: [
                if (_isEditing)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Save Changes',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => _showLogoutDialog(context, authProvider),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Logout',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
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

  Widget _buildProfileField(
    String label,
    TextEditingController controller,
    IconData icon,
    bool enabled, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: enabled,
          maxLines: maxLines,
          style: TextStyle(color: AppColors.textPrimary, fontSize: 16),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.textSecondary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.primary),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.border.withOpacity(0.5)),
            ),
            filled: !enabled,
            fillColor: enabled ? null : AppColors.background,
          ),
        ),
      ],
    );
  }

  Widget _buildFarmerInfo(dynamic user, Color primaryColor) {
    // Get land size from kycDetails - handle both string and number formats
    final landSizeRaw = user.kycDetails['landSize'];
    String landSize = 'Not provided';

    if (landSizeRaw != null) {
      if (landSizeRaw is String && landSizeRaw.isNotEmpty) {
        landSize = landSizeRaw;
      } else if (landSizeRaw is num) {
        landSize = landSizeRaw.toString();
      }
    }

    final agriScore = 'Not calculated yet'; // Will be calculated later

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'farmer.farming_details'.tr(),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInfoTile(
                  'farmer.land_size'.tr(),
                  landSize == 'Not provided' ? landSize : '$landSize acres',
                  Icons.landscape,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
<<<<<<< HEAD
                child: _buildInfoTile('farmer.agri_score'.tr(), agriScore, Icons.star),
=======
                child: _buildInfoTile(
                  'farmer.agri_score'.tr(),
                  agriScore,
                  Icons.star,
                ),
>>>>>>> 5b3ae447a7a6f15554647b4ed5c427121e8f156b
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDistributorInfo(dynamic user, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Distribution Details',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
<<<<<<< HEAD
                child: _buildInfoTile('Vehicles', '12', Icons.local_shipping),
              ),
              const SizedBox(width: 16),
              Expanded(child: _buildInfoTile('Rating', '4.8/5', Icons.star)),
=======
                child: FutureBuilder<int>(
                  future: UserService.getUserVehicleCount(user.id),
                  builder: (context, snapshot) {
                    String vehicleCount = 'Loading...';
                    if (snapshot.hasData) {
                      vehicleCount = snapshot.data.toString();
                    } else if (snapshot.hasError) {
                      vehicleCount = '0';
                    }
                    return _buildInfoTile(
                      'Vehicles',
                      vehicleCount,
                      Icons.local_shipping,
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoTile(
                  'Rating',
                  'Yet to be calculated',
                  Icons.star,
                ),
              ),
>>>>>>> 5b3ae447a7a6f15554647b4ed5c427121e8f156b
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRetailerInfo(dynamic user, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Retail Details',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInfoTile('Store Type', 'Grocery', Icons.store),
              ),
              const SizedBox(width: 16),
              Expanded(child: _buildInfoTile('Rating', '4.6/5', Icons.star)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConsumerInfo(dynamic user, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Purchase History',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInfoTile('Total Orders', '45', Icons.shopping_bag),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoTile('Savings', '₹2,340', Icons.savings),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.textSecondary),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Color _getPrimaryColorForRole(UserRole role) {
    switch (role) {
      case UserRole.farmer:
        return AppColors.farmerPrimary;
      case UserRole.distributor:
        return AppColors.distributorPrimary;
      case UserRole.retailer:
        return AppColors.retailerPrimary;
      case UserRole.consumer:
        return AppColors.consumerPrimary;
    }
  }

  IconData _getIconForRole(UserRole role) {
    switch (role) {
      case UserRole.farmer:
        return Icons.agriculture;
      case UserRole.distributor:
        return Icons.local_shipping;
      case UserRole.retailer:
        return Icons.store;
      case UserRole.consumer:
        return Icons.person;
    }
  }

  void _saveProfile() {
    // TODO: Implement profile save functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile saved successfully!'),
        backgroundColor: Colors.green,
      ),
    );
    setState(() => _isEditing = false);
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              authProvider.logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LandingScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildCopyableId(AgriChainUser user, Color primaryColor) {
    // Get the role-specific unique ID using the getter
    final uniqueId = user.uniqueId;
    final idType = user.idPrefix;

    // Fallback to Firebase UID if unique ID not found
    final displayId = uniqueId ?? user.firebaseUid.substring(0, 12);
    final displayType = uniqueId != null ? idType : 'User ID';

    return GestureDetector(
      onTap: () {
        Clipboard.setData(ClipboardData(text: displayId));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text('$displayType copied to clipboard!'),
              ],
            ),
            backgroundColor: primaryColor,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: primaryColor.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.copy, size: 14, color: primaryColor),
            const SizedBox(width: 6),
            Text(
              '$displayType: $displayId',
              style: TextStyle(
                fontSize: 12,
                color: primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}
