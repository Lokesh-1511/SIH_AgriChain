// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../common/providers/language_provider.dart';
import '../../auth/screens/login_screen.dart';
import 'about_screen.dart';
import 'contact_screen.dart';
import 'privacy_policy_screen.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );

    _animationController.forward();
  }

  void _navigateToLogin(String role) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => LoginScreen(role: role)));
  }

  void _showLanguagePicker() {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'common.select_language'.tr(),
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...languageProvider.supportedLanguages.map(
              (lang) => ListTile(
                title: Text(lang['name']!),
                trailing: languageProvider.currentLanguageCode == lang['code']
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () {
                  languageProvider.changeLanguage(lang['code']!, context);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Consumer<LanguageProvider>(
            builder: (context, languageProvider, child) {
              return TextButton.icon(
                onPressed: _showLanguagePicker,
                icon: const Icon(Icons.language, color: AppColors.primary),
                label: Text(
                  languageProvider.getLanguageName(
                    languageProvider.currentLanguageCode,
                  ),
                  style: const TextStyle(color: AppColors.primary),
                ),
              );
            },
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),

                    // Logo and Title
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.agriculture,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 24),

                    Text(
                      'app.title'.tr(),
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        letterSpacing: 1,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      'app.subtitle'.tr(),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 64),

                    // Role Selection Cards
                    Text(
                      'roles.select_role'.tr(),
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                    ),

                    const SizedBox(height: 32),

                    // Role Cards
                    _buildRoleGrid(),

                    const SizedBox(height: 48),

                    // Footer Links
                    _buildFooter(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRoleGrid() {
    final roles = [
      {
        'title': 'roles.farmer'.tr(),
        'subtitle': 'landing.farmer_desc'.tr(),
        'icon': Icons.agriculture,
        'color': AppColors.farmerPrimary,
        'role': AppConstants.roleFarmer,
      },
      {
        'title': 'roles.distributor'.tr(),
        'subtitle': 'landing.distributor_desc'.tr(),
        'icon': Icons.local_shipping,
        'color': AppColors.distributorPrimary,
        'role': AppConstants.roleDistributor,
      },
      {
        'title': 'roles.retailer'.tr(),
        'subtitle': 'landing.retailer_desc'.tr(),
        'icon': Icons.store,
        'color': AppColors.retailerPrimary,
        'role': AppConstants.roleRetailer,
      },
      {
        'title': 'roles.consumer'.tr(),
        'subtitle': 'landing.consumer_desc'.tr(),
        'icon': Icons.shopping_cart,
        'color': AppColors.consumerPrimary,
        'role': AppConstants.roleConsumer,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85, // Better ratio for multi-line text
      ),
      itemCount: roles.length,
      itemBuilder: (context, index) {
        final role = roles[index];
        return _buildRoleCard(
          title: role['title'] as String,
          subtitle: role['subtitle'] as String,
          icon: role['icon'] as IconData,
          color: role['color'] as Color,
          onTap: () => _navigateToLogin(role['role'] as String),
        );
      },
    );
  }

  Widget _buildRoleCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    // Calculate font sizes based on text length
    double titleFontSize = _calculateTitleFontSize(title);
    double subtitleFontSize = _calculateSubtitleFontSize(subtitle);
<<<<<<< HEAD
    
=======

>>>>>>> 5b3ae447a7a6f15554647b4ed5c427121e8f156b
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        color: Colors.white,
        shadowColor: color.withOpacity(0.3),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    fontSize: titleFontSize,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Flexible(
                child: Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: subtitleFontSize,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Calculate dynamic font size for title based on text length
  double _calculateTitleFontSize(String text) {
<<<<<<< HEAD
    if (text.length > 15) return 12.0;  // Very long text
    if (text.length > 10) return 14.0;  // Long text
    return 16.0;                        // Normal text
=======
    if (text.length > 15) return 12.0; // Very long text
    if (text.length > 10) return 14.0; // Long text
    return 16.0; // Normal text
>>>>>>> 5b3ae447a7a6f15554647b4ed5c427121e8f156b
  }

  // Calculate dynamic font size for subtitle based on text length
  double _calculateSubtitleFontSize(String text) {
<<<<<<< HEAD
    if (text.length > 30) return 10.0;  // Very long text
    if (text.length > 20) return 11.0;  // Long text
    return 12.0;                        // Normal text
=======
    if (text.length > 30) return 10.0; // Very long text
    if (text.length > 20) return 11.0; // Long text
    return 12.0; // Normal text
>>>>>>> 5b3ae447a7a6f15554647b4ed5c427121e8f156b
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
<<<<<<< HEAD
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AboutScreen()),
                );
              },
              child: const Text('About'),
            ),
            const Text(' • '),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ContactScreen(),
                  ),
                );
              },
              child: const Text('Contact'),
            ),
            const Text(' • '),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PrivacyPolicyScreen(),
                  ),
                );
              },
              child: const Text('Privacy Policy'),
=======
            Flexible(
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AboutScreen(),
                    ),
                  );
                },
                child: Text('common.about'.tr()),
              ),
            ),
            const Text(' • '),
            Flexible(
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ContactScreen(),
                    ),
                  );
                },
                child: Text('common.contact'.tr()),
              ),
            ),
            const Text(' • '),
            Flexible(
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PrivacyPolicyScreen(),
                    ),
                  );
                },
                child: Text('common.privacy_policy'.tr()),
              ),
>>>>>>> 5b3ae447a7a6f15554647b4ed5c427121e8f156b
            ),
          ],
        ),

        const SizedBox(height: 16),

        Text(
<<<<<<< HEAD
          '© 2025 AGRICHAIN. All rights reserved.',
=======
          'common.copyright'.tr(),
>>>>>>> 5b3ae447a7a6f15554647b4ed5c427121e8f156b
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.textHint),
        ),
      ],
    );
  }
}
