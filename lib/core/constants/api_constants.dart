class ApiConstants {
  // ----------------------
  // Base URLs (Environment based)
  // ----------------------
  static const String baseUrl = 'https://api.tenminutedelivery.com/v1';
  static const String cdnUrl = 'https://cdn.tenminutedelivery.com';
  static const String wsUrl = 'wss://api.tenminutedelivery.com/ws';

  // ----------------------
  // Auth
  // ----------------------
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String verifyOtp = '/auth/verify-otp';
  static const String refreshToken = '/auth/refresh-token';
  static const String logout = '/auth/logout';

  // ----------------------
  // User Profile
  // ----------------------
  static const String userProfile = '/user/profile';
  static const String updateProfile = '/user/update';
  static const String userWallet = '/user/wallet';
  static const String userNotifications = '/user/notifications';
  static const String unreadNotificationCount =
      '/user/notifications/unread-count';

  // ----------------------
  // Products
  // ----------------------
  static const String products = '/products';
  static const String productDetails = '/products/details';
  static const String trendingProducts = '/products/trending';
  static const String recommendedProducts = '/products/recommended';

  // ----------------------
  // Categories
  // ----------------------
  static const String categories = '/categories';
  static const String categoryProducts = '/categories/products';

  // ----------------------
  // Search
  // ----------------------
  static const String search = '/search';
  static const String searchSuggestions = '/search/suggestions';
  static const String recentSearches = '/search/recent';

  // ----------------------
  // Cart
  // ----------------------
  static const String cart = '/cart';
  static const String cartAdd = '/cart/add';
  static const String cartRemove = '/cart/remove';
  static const String cartUpdateQuantity = '/cart/update-qty';
  static const String cartApplyCoupon = '/cart/apply-coupon';

  // ----------------------
  // Orders
  // ----------------------
  static const String orders = '/orders';
  static const String orderDetails = '/orders/details';
  static const String orderCreate = '/orders/create';
  static const String cancelOrder = '/orders/cancel';
  static const String reorder = '/orders/reorder';

  // ----------------------
  // Payment
  // ----------------------
  static const String paymentInit = '/payment/init';
  static const String paymentVerify = '/payment/verify';
  static const String paymentMethods = '/payment/methods';

  // ----------------------
  // Delivery Tracking
  // ----------------------
  static const String deliveryTracking = '/delivery/tracking';
  static const String riderLocation = '/delivery/rider-location';
  static const String deliverySlotAvailability = '/delivery/slots';

  // ----------------------
  // Address
  // ----------------------
  static const String addresses = '/addresses';
  static const String addAddress = '/addresses/add';
  static const String updateAddress = '/addresses/update';
  static const String deleteAddress = '/addresses/delete';
  static const String defaultAddress = '/addresses/default';

  // ----------------------
  // Notifications
  // ----------------------
  static const String notifications = '/notifications';
  static const String notificationsMarkAllRead = '/notifications/mark-all-read';

  // ----------------------
  // WebSocket Feeds
  // ----------------------
  static const String wsOrderStatus = '/order-status';
  static const String wsLiveRiderTracking = '/rider-tracking';

  // ----------------------
  // App Config
  // ----------------------
  static const String appConfig = '/app/config';
  static const String banners = '/app/banners';
  static const String offers = '/app/offers';

  // ----------------------
  // Timeouts
  // ----------------------
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
}
