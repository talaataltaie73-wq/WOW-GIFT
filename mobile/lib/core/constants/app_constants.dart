class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'http://localhost:8000/api/v1';

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh';
  static const String profile = '/auth/profile';

  // Categories
  static const String categories = '/categories';

  // Products
  static const String products = '/products';
  static const String productDetail = '/products/'; // + id
  static const String bestSellers = '/products/best-sellers';
  static const String latestProducts = '/products/latest';
  static const String bestDeals = '/products/best-deals';

  // Stores
  static const String stores = '/stores';
  static const String storeDetail = '/stores/'; // + id
  static const String featuredStores = '/stores/featured';

  // Gift Boxes
  static const String giftBoxes = '/gift-boxes';
  static const String giftBoxDetail = '/gift-boxes/'; // + id

  // Cart
  static const String cart = '/cart';
  static const String cartItems = '/cart/items';

  // Orders
  static const String orders = '/orders';
  static const String orderDetail = '/orders/'; // + id

  // Occasions
  static const String occasions = '/occasions';
  static const String occasionReminders = '/occasions/reminders';

  // AI Assistant
  static const String aiSuggestions = '/ai/suggestions';

  // Phone Verification
  static const String requestOtp = '/auth/phone/request-otp';
  static const String verifyOtp = '/auth/phone/verify-otp';
  static const String usersMe = '/users/me';

  // Search
  static const String search = '/search';

  // Favorites
  static const String favorites = '/favorites';

  // Addresses
  static const String addresses = '/addresses';

  // Notifications
  static const String notifications = '/notifications';

  // Banners
  static const String banners = '/banners';
}

class AppConstants {
  AppConstants._();

  static const String appName = 'Wow Gift';
  static const String appTagline = 'أهدي بطريقة تُبهر.';
  static const String currency = 'د.ع';
  static const int splashDuration = 4;
  static const String locale = 'ar_IQ';

  // SharedPreferences keys
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user_data';
  static const String darkModeKey = 'dark_mode';
  static const String onboardingKey = 'onboarding_done';
  static const String phoneVerifiedKey = 'phone_verified';
  static const String verifiedPhoneKey = 'verified_phone';
  static const String phoneVerifiedAtKey = 'phone_verified_at';
}
