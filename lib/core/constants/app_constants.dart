class AppConstants {
  static const String appName = 'AGRICHAIN';
  static const String appTagline = 'Bridging Farmers, Distributors, Retailers & Consumers via Blockchain & AI';
  
  // User Roles
  static const String roleFarmer = 'farmer';
  static const String roleDistributor = 'distributor';
  static const String roleRetailer = 'retailer';
  static const String roleConsumer = 'consumer';
  
  // Languages
  static const String langEnglish = 'en';
  static const String langHindi = 'hi';
  static const String langTamil = 'ta';
  static const String langOdia = 'or';
  static const String langTelugu = 'te';
  static const String langKannada = 'kn';
  static const String langMalayalam = 'ml';
  
  // Blockchain Status
  static const String statusPending = 'pending';
  static const String statusTransported = 'transported';
  static const String statusSold = 'sold';
  static const String statusInTransit = 'in_transit';
  static const String statusDelivered = 'delivered';
  
  // API Endpoints (Mock)
  static const String baseUrl = 'https://api.agrichain.com';
  static const String authEndpoint = '/auth';
  static const String batchEndpoint = '/batches';
  static const String transactionEndpoint = '/transactions';
  static const String aiEndpoint = '/ai';
  
  // Storage Keys
  static const String keyUserId = 'user_id';
  static const String keyUserRole = 'user_role';
  static const String keyUserToken = 'user_token';
  static const String keyLanguage = 'language';
  static const String keyIsLoggedIn = 'is_logged_in';
  
  // File Paths
  static const String imagesPath = 'assets/images/';
  static const String iconsPath = 'assets/icons/';
  static const String animationsPath = 'assets/animations/';
}