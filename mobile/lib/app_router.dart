import 'package:flutter/material.dart';
import 'features/splash/presentation/pages/splash_screen.dart';
import 'features/auth/presentation/pages/login_screen.dart';
import 'features/auth/presentation/pages/register_screen.dart';
import 'features/home/presentation/pages/main_navigation_screen.dart';
import 'features/product/presentation/pages/product_detail_screen.dart';
import 'features/store/presentation/pages/store_screen.dart';
import 'features/gift_box/presentation/pages/gift_boxes_screen.dart';
import 'features/checkout/presentation/pages/checkout_screen.dart';
import 'features/orders/presentation/pages/orders_screen.dart';
import 'features/search/presentation/pages/search_screen.dart';
import 'features/ai_assistant/presentation/pages/ai_assistant_screen.dart';
import 'features/phone_verification/presentation/pages/phone_entry_screen.dart';
import 'features/phone_verification/presentation/pages/otp_verification_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
      case '/splash':
        return _buildRoute(const SplashScreen(), settings);

      case '/login':
        return _buildRoute(const LoginScreen(), settings);

      case '/register':
        return _buildRoute(const RegisterScreen(), settings);

      case '/home':
        return _buildRoute(const MainNavigationScreen(), settings);

      case '/product':
        final productId = settings.arguments as String? ?? '';
        return _buildRoute(ProductDetailScreen(productId: productId), settings);

      case '/store':
        final storeId = settings.arguments as String? ?? '';
        return _buildRoute(StoreScreen(storeId: storeId), settings);

      case '/gift-boxes':
        return _buildRoute(const GiftBoxesScreen(), settings);

      case '/checkout':
        return _buildRoute(const CheckoutScreen(), settings);

      case '/orders':
        return _buildRoute(const OrdersScreen(), settings);

      case '/search':
        return _buildRoute(const SearchScreen(), settings);

      case '/ai-assistant':
        return _buildRoute(const AiAssistantScreen(), settings);

      case '/products':
        return _buildRoute(const SearchScreen(), settings);

      case '/phone-entry':
        return _buildRoute(const PhoneEntryScreen(), settings);

      case '/otp-verification':
        return _buildRoute(const OtpVerificationScreen(), settings);

      default:
        return _buildRoute(
          Scaffold(
            body: Center(
              child: Text('الصفحة غير موجودة: ${settings.name}'),
            ),
          ),
          settings,
        );
    }
  }

  static MaterialPageRoute _buildRoute(Widget page, RouteSettings settings) {
    return MaterialPageRoute(
      builder: (_) => page,
      settings: settings,
    );
  }
}
