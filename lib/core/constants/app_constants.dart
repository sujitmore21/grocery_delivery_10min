class AppConstants {
  // --------------------
  // Delivery Settings
  // --------------------
  static const int deliveryTimeMinutes = 10;
  static const double minimumOrderValue = 99.0;
  static const double deliveryFee = 0.0;
  static const double platformChargePercent = 2.5;
  static const double taxRate = 5.0;
  static const int maxQuantityPerItem = 10;

  // --------------------
  // Location Defaults
  // --------------------
  static const double defaultLatitude = 28.6139;
  static const double defaultLongitude = 77.2090;
  static const double maxDeliveryRadiusKm = 5.0; // serviceable area

  // --------------------
  // App Info
  // --------------------
  static const String appVersion = '1.0.0';
  static const String appName = "QuickBasket";
  static const String appDescription =
      "10-minute delivery app for groceries & daily essentials.";

  // --------------------
  // API Endpoints
  // --------------------
  static const String baseUrl = "https://api.quickbasket.in";
  static const String imageBaseUrl = "https://cdn.quickbasket.in/images/";
  static const int apiTimeoutSeconds = 20;

  // --------------------
  // UI / Theme
  // --------------------
  static const String primaryFont = "Poppins";
  static const double defaultPadding = 16.0;
  static const double cornerRadius = 12.0;

  // --------------------
  // Pagination
  // --------------------
  static const int productsPageLimit = 20;
  static const int notificationsPageLimit = 30;

  // --------------------
  // Order Status Strings
  // --------------------
  static const String orderStatusPending = "PENDING";
  static const String orderStatusAccepted = "ACCEPTED";
  static const String orderStatusPicked = "PICKED";
  static const String orderStatusOutForDelivery = "OUT_FOR_DELIVERY";
  static const String orderStatusDelivered = "DELIVERED";
  static const String orderStatusCancelled = "CANCELLED";

  // --------------------
  // Payment
  // --------------------
  static const List<String> paymentMethods = [
    "UPI",
    "Cash on Delivery",
    "Credit Card",
    "Debit Card",
    "Wallet",
  ];

  // --------------------
  // Firebase Collections
  // --------------------
  static const String usersCollection = "users";
  static const String cartCollection = "carts";
  static const String ordersCollection = "orders";
  static const String bannersCollection = "banners";
  static const String productsCollection = "products";

  // --------------------
  // Animation Durations
  // --------------------
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationMedium = Duration(milliseconds: 350);
  static const Duration animationSlow = Duration(milliseconds: 600);

  // --------------------
  // Misc
  // --------------------
  static const int otpLength = 6;
  static const int searchDebounceMilliseconds = 300;
  static const String customerSupportNumber = "+91 90000 12345";
}
