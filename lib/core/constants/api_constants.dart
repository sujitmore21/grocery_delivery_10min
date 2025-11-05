class ApiConstants {
  static const String baseUrl = 'https://api.tenminutedelivery.com';
  static const String wsUrl = 'wss://api.tenminutedelivery.com';

  // Endpoints
  static const String products = '/api/products';
  static const String categories = '/api/categories';
  static const String cart = '/api/cart';
  static const String orders = '/api/orders';
  static const String addresses = '/api/addresses';
  static const String auth = '/api/auth';
  static const String search = '/api/search';
  static const String deliveryTracking = '/api/delivery/tracking';

  // Timeouts
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
}
