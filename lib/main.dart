import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:easy_localization/easy_localization.dart';
import 'core/theme/app_theme.dart';
import 'core/services/mongodb_service.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/common/providers/language_provider.dart';
import 'features/onboarding/screens/splash_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Easy Localization
  await EasyLocalization.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize MongoDB
  await MongoDBService.connect();

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('hi', 'IN'),
        Locale('ta', 'IN'),
        Locale('or', 'IN'),
        Locale('te', 'IN'),
        Locale('kn', 'IN'),
        Locale('ml', 'IN'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('en', 'US'),
      child: const AgriChainApp(),
    ),
  );
}

// TODO: Change the verification in the Aadhar screen to OTP verification
// TODO: Add the functionality to change the language in the settings screen
// TODO: picture update;

class AgriChainApp extends StatelessWidget {
  const AgriChainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: MaterialApp(
        title: 'AGRICHAIN',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        home: const SplashScreen(),
      ),
    );
  }
}
