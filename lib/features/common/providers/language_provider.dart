import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/constants/app_constants.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _currentLocale = const Locale('en');
  SharedPreferences? _prefs;

  Locale get currentLocale => _currentLocale;

  LanguageProvider() {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    _prefs = await SharedPreferences.getInstance();
    final languageCode = _prefs?.getString(AppConstants.keyLanguage) ?? 'en';
    _currentLocale = _getLocaleFromCode(languageCode);
    notifyListeners();
  }

  Future<void> changeLanguage(
    String languageCode, [
    BuildContext? context,
  ]) async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setString(AppConstants.keyLanguage, languageCode);
    _currentLocale = _getLocaleFromCode(languageCode);

    // Update easy_localization locale if context is provided
    if (context != null) {
      await context.setLocale(_currentLocale);
    }

    notifyListeners();
  }

  Locale _getLocaleFromCode(String code) {
    switch (code) {
      case AppConstants.langHindi:
        return const Locale('hi');
      case AppConstants.langTamil:
        return const Locale('ta');
      case AppConstants.langOdia:
        return const Locale('or');
      case AppConstants.langTelugu:
        return const Locale('te');
      case AppConstants.langKannada:
        return const Locale('kn');
      case AppConstants.langMalayalam:
        return const Locale('ml');
      default:
        return const Locale('en');
    }
  }

  String getLanguageName(String code) {
    switch (code) {
      case AppConstants.langEnglish:
        return 'English';
      case AppConstants.langHindi:
        return 'हिन्दी';
      case AppConstants.langTamil:
        return 'தமிழ்';
      case AppConstants.langOdia:
        return 'ଓଡ଼ିଆ';
      case AppConstants.langTelugu:
        return 'తెలుగు';
      case AppConstants.langKannada:
        return 'ಕನ್ನಡ';
      case AppConstants.langMalayalam:
        return 'മലയാളം';
      default:
        return 'English';
    }
  }

  List<Map<String, String>> get supportedLanguages => [
    {'code': AppConstants.langEnglish, 'name': 'English'},
    {'code': AppConstants.langHindi, 'name': 'हिन्दी'},
    {'code': AppConstants.langTamil, 'name': 'தமிழ்'},
    {'code': AppConstants.langOdia, 'name': 'ଓଡ଼ିଆ'},
    {'code': AppConstants.langTelugu, 'name': 'తెలుగు'},
    {'code': AppConstants.langKannada, 'name': 'ಕನ್ನಡ'},
    {'code': AppConstants.langMalayalam, 'name': 'മലയാളം'},
  ];

  String get currentLanguageCode {
    switch (_currentLocale.languageCode) {
      case 'hi':
        return AppConstants.langHindi;
      case 'ta':
        return AppConstants.langTamil;
      case 'or':
        return AppConstants.langOdia;
      case 'te':
        return AppConstants.langTelugu;
      case 'kn':
        return AppConstants.langKannada;
      case 'ml':
        return AppConstants.langMalayalam;
      default:
        return AppConstants.langEnglish;
    }
  }
}
