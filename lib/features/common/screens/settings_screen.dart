import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/providers/auth_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _locationEnabled = true;
  bool _biometricEnabled = false;
  String _selectedLanguage = 'English';
  String _selectedCurrency = 'INR (₹)';

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    
    Color primaryColor = _getPrimaryColorForRole(user?.role ?? 'consumer');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Account Settings
          _buildSectionHeader('Account', Icons.person),
          _buildSettingsGroup([
            _buildSettingsTile(
              'Profile Information',
              'Update your personal details',
              Icons.edit,
              onTap: () => Navigator.pushNamed(context, '/profile'),
            ),
            _buildSettingsTile(
              'Privacy & Security',
              'Manage your privacy settings',
              Icons.security,
              onTap: () => _showPrivacySettings(context),
            ),
            _buildSwitchTile(
              'Biometric Authentication',
              'Use fingerprint or face ID',
              Icons.fingerprint,
              _biometricEnabled,
              (value) => setState(() => _biometricEnabled = value),
            ),
          ]),

          const SizedBox(height: 24),

          // Notifications
          _buildSectionHeader('Notifications', Icons.notifications),
          _buildSettingsGroup([
            _buildSwitchTile(
              'Push Notifications',
              'Receive app notifications',
              Icons.notifications_active,
              _notificationsEnabled,
              (value) => setState(() => _notificationsEnabled = value),
            ),
            _buildSettingsTile(
              'Notification Preferences',
              'Customize notification types',
              Icons.tune,
              onTap: () => _showNotificationPreferences(context),
            ),
          ]),

          const SizedBox(height: 24),

          // App Settings
          _buildSectionHeader('App Settings', Icons.settings),
          _buildSettingsGroup([
            _buildSwitchTile(
              'Dark Mode',
              'Switch to dark theme',
              Icons.dark_mode,
              _darkModeEnabled,
              (value) => setState(() => _darkModeEnabled = value),
            ),
            _buildDropdownTile(
              'Language',
              'App display language',
              Icons.language,
              _selectedLanguage,
              ['English', 'Hindi', 'Tamil', 'Telugu', 'Bengali'],
              (value) => setState(() => _selectedLanguage = value),
            ),
            _buildDropdownTile(
              'Currency',
              'Display currency',
              Icons.currency_rupee,
              _selectedCurrency,
              ['INR (₹)', 'USD (\$)', 'EUR (€)'],
              (value) => setState(() => _selectedCurrency = value),
            ),
            _buildSwitchTile(
              'Location Services',
              'Allow location access',
              Icons.location_on,
              _locationEnabled,
              (value) => setState(() => _locationEnabled = value),
            ),
          ]),

          const SizedBox(height: 24),

          // Data & Storage
          _buildSectionHeader('Data & Storage', Icons.storage),
          _buildSettingsGroup([
            _buildSettingsTile(
              'Download Quality',
              'High quality images and videos',
              Icons.hd,
              trailing: const Text('High', style: TextStyle(color: AppColors.textSecondary)),
              onTap: () => _showQualitySettings(context),
            ),
            _buildSettingsTile(
              'Storage Usage',
              '2.3 GB used',
              Icons.folder,
              onTap: () => _showStorageUsage(context),
            ),
            _buildSettingsTile(
              'Clear Cache',
              'Free up storage space',
              Icons.cleaning_services,
              onTap: () => _showClearCacheDialog(context),
            ),
          ]),

          const SizedBox(height: 24),

          // Help & Support
          _buildSectionHeader('Help & Support', Icons.help),
          _buildSettingsGroup([
            _buildSettingsTile(
              'Help Center',
              'Get help and support',
              Icons.help_outline,
              onTap: () => _showHelpCenter(context),
            ),
            _buildSettingsTile(
              'Contact Us',
              'Reach out to our team',
              Icons.contact_support,
              onTap: () => _showContactUs(context),
            ),
            _buildSettingsTile(
              'Rate App',
              'Rate us on app store',
              Icons.star_rate,
              onTap: () => _rateApp(context),
            ),
            _buildSettingsTile(
              'Share App',
              'Share with friends',
              Icons.share,
              onTap: () => _shareApp(context),
            ),
          ]),

          const SizedBox(height: 24),

          // About
          _buildSectionHeader('About', Icons.info),
          _buildSettingsGroup([
            _buildSettingsTile(
              'App Version',
              'v1.0.0',
              Icons.info_outline,
              onTap: () => _showAppInfo(context),
            ),
            _buildSettingsTile(
              'Terms of Service',
              'Read our terms',
              Icons.description,
              onTap: () => _showTermsOfService(context),
            ),
            _buildSettingsTile(
              'Privacy Policy',
              'Read our privacy policy',
              Icons.privacy_tip,
              onTap: () => _showPrivacyPolicy(context),
            ),
          ]),

          const SizedBox(height: 32),

          // Logout Button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              onPressed: () => _showLogoutDialog(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Logout',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> children) {
    return Container(
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
        children: children.asMap().entries.map((entry) {
          final index = entry.key;
          final child = entry.value;
          return Column(
            children: [
              child,
              if (index < children.length - 1)
                Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.border.withOpacity(0.3),
                  indent: 56,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSettingsTile(
    String title,
    String subtitle,
    IconData icon, {
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
      ),
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
    );
  }

  Widget _buildDropdownTile(
    String title,
    String subtitle,
    IconData icon,
    String currentValue,
    List<String> options,
    ValueChanged<String> onChanged,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
      ),
      trailing: DropdownButton<String>(
        value: currentValue,
        underline: const SizedBox.shrink(),
        items: options.map((option) {
          return DropdownMenuItem(
            value: option,
            child: Text(option),
          );
        }).toList(),
        onChanged: (value) => onChanged(value!),
      ),
    );
  }

  Color _getPrimaryColorForRole(String role) {
    switch (role.toLowerCase()) {
      case 'farmer':
        return AppColors.farmerPrimary;
      case 'distributor':
        return AppColors.distributorPrimary;
      case 'retailer':
        return AppColors.retailerPrimary;
      case 'consumer':
        return AppColors.consumerPrimary;
      default:
        return AppColors.primary;
    }
  }

  // Dialog and action methods
  void _showPrivacySettings(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Privacy settings coming soon!')),
    );
  }

  void _showNotificationPreferences(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notification preferences coming soon!')),
    );
  }

  void _showQualitySettings(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Quality settings coming soon!')),
    );
  }

  void _showStorageUsage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Storage usage details coming soon!')),
    );
  }

  void _showClearCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text('This will free up storage space by clearing temporary files. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache cleared successfully!')),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showHelpCenter(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Help center coming soon!')),
    );
  }

  void _showContactUs(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Contact support coming soon!')),
    );
  }

  void _rateApp(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Rate app functionality coming soon!')),
    );
  }

  void _shareApp(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share app functionality coming soon!')),
    );
  }

  void _showAppInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('AgriChain'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version: 1.0.0'),
            SizedBox(height: 8),
            Text('Build: 1001'),
            SizedBox(height: 8),
            Text('Developed for Smart India Hackathon 2024'),
          ],
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

  void _showTermsOfService(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Terms of service coming soon!')),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Privacy policy coming soon!')),
    );
  }

  void _showLogoutDialog(BuildContext context) {
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
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              authProvider.logout();
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/landing',
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
}