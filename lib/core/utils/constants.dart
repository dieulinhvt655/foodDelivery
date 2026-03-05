class AppConstants {
  // API Gateway base URL (khớp backend api-gateway)
  static const String baseUrl = 'http://localhost:3000';

  // Microservice route prefixes (khớp src/backend/services/api-gateway/config/services.js)
  static const String restaurantsPath = '/restaurants';
  static const String itemsPath = '/items';
  static const String categoriesPath = '/categories';
  static const String optionGroupsPath = '/option-groups';
  static const String optionsPath = '/options';
  static const String cartPath = '/api/carts';
  static const String ordersPath = '/api/orders';
  static const String authPath = '/api/auth';
  static const String notificationsPath = '/notifications';
  static const String deviceTokensPath = '/device-tokens';

  // Image paths
  static const String placeholderImage = 'assets/images/placeholder.png';

  // Settings
  static const int defaultTimeout = 30;
}

