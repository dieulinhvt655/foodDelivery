import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/onboarding/pages/onboarding_page.dart';
import '../../features/home/pages/home_page.dart';
import '../../features/restaurant_detail/pages/restaurant_detail_page.dart';
import '../../features/profile/pages/profile_page.dart';
import '../../features/orders/pages/orders_page.dart';
import '../../features/welcome/pages/welcome_page.dart';
import '../../features/auth/pages/login_page.dart';
import '../../features/auth/pages/signup_page.dart';
import '../../features/filters/pages/category_filter_page.dart';
import '../../features/cart/pages/cart_page.dart';
import '../../features/notifications/pages/notifications_page.dart';
import '../../features/profile/pages/profile_edit_page.dart';
import '../../features/profile/pages/change_password_page.dart';
import '../../features/address/pages/address_list_page.dart';
import '../../features/address/pages/address_form_page.dart';
import '../../features/payment/pages/payment_methods_page.dart';
import '../../features/foods/pages/foods_list_page.dart';
import '../../features/restaurants/pages/restaurants_list_page.dart';
// import '../../features/favorites/pages/favorites_page.dart';
import '../../features/orders/pages/confirm_order_page.dart';
import '../../features/orders/pages/order_confirmed_page.dart';
import '../../features/orders/pages/qr_payment_page.dart';
import '../../features/foods/pages/search_results_page.dart';
import '../../features/foods/pages/food_detail_page.dart';

// Fast transition với duration ngắn (150ms)
Page<T> _fastTransition<T extends Object?>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const duration = Duration(milliseconds: 150);
      const curve = Curves.easeOut;
      
      return FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: curve,
        ).drive(
          Tween(begin: 0.0, end: 1.0).chain(
            CurveTween(curve: curve),
          ),
        ),
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 150),
  );
}

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/onboarding',
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomePage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignUpPage(),
      ),
      GoRoute(
        path: '/home',
        pageBuilder: (context, state) => _fastTransition(
          context: context,
          state: state,
          child: const HomePage(),
        ),
      ),
      GoRoute(
        path: '/restaurant/:id',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return _fastTransition(
            context: context,
            state: state,
            child: RestaurantDetailPage(restaurantId: id),
          );
        },
      ),
      GoRoute(
        path: '/orders',
        builder: (context, state) => const OrdersPage(),
      ),
      GoRoute(
        path: '/profile',
        pageBuilder: (context, state) => _fastTransition(
          context: context,
          state: state,
          child: const ProfilePage(),
        ),
      ),
      GoRoute(
        path: '/profile/edit',
        builder: (context, state) => const ProfileEditPage(),
      ),
      GoRoute(
        path: '/change-password',
        builder: (context, state) => const ChangePasswordPage(),
      ),
      GoRoute(
        path: '/addresses',
        builder: (context, state) => const AddressListPage(),
      ),
      GoRoute(
        path: '/addresses/new',
        builder: (context, state) => const AddressFormPage(),
      ),
      GoRoute(
        path: '/payment-methods',
        builder: (context, state) => const PaymentMethodsPage(),
      ),
      GoRoute(
        path: '/filter/:category',
        builder: (context, state) {
          final cat = state.pathParameters['category']!;
          return CategoryFilterPage(category: cat);
        },
      ),
      GoRoute(
        path: '/cart',
        builder: (context, state) => const CartPage(),
      ),
      GoRoute(
        path: '/confirm-order',
        builder: (context, state) => const ConfirmOrderPage(),
      ),
      GoRoute(
        path: '/order-confirmed',
        builder: (context, state) {
          final deliveryDateStr = state.uri.queryParameters['deliveryDate'];
          final deliveryDate = deliveryDateStr != null
              ? DateTime.parse(deliveryDateStr)
              : DateTime.now().add(const Duration(days: 2));
          return OrderConfirmedPage(deliveryDate: deliveryDate);
        },
      ),
      GoRoute(
        path: '/qr-payment',
        builder: (context, state) {
          final amountStr = state.uri.queryParameters['amount'] ?? '0';
          final orderCode = state.uri.queryParameters['orderCode'] ?? '#UNKNOWN';
          final amount = double.tryParse(amountStr) ?? 0.0;
          return QrPaymentPage(amount: amount, orderCode: orderCode);
        },
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsPage(),
      ),
      GoRoute(
        path: '/foods',
        pageBuilder: (context, state) {
          final categoryId = state.uri.queryParameters['categoryId'];
          final showFavorites = state.uri.queryParameters['favorites'] == '1';
          return _fastTransition(
            context: context,
            state: state,
            child: FoodsListPage(
              showFavoritesOnly: showFavorites,
              categoryId: categoryId,
            ),
          );
        },
      ),
      GoRoute(
        path: '/restaurants',
        pageBuilder: (context, state) => _fastTransition(
          context: context,
          state: state,
          child: const RestaurantsListPage(),
        ),
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) {
          final q = state.uri.queryParameters['q'] ?? '';
          return SearchResultsPage(initialQuery: q);
        },
      ),
      GoRoute(
        path: '/food/:id',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          final rid = state.uri.queryParameters['rid'];
          return _fastTransition(
            context: context,
            state: state,
            child: FoodDetailPage(foodId: id, restaurantId: rid),
          );
        },
      ),
      GoRoute(
        path: '/favorites',
        pageBuilder: (context, state) => _fastTransition(
          context: context,
          state: state,
          child: const FoodsListPage(showFavoritesOnly: true),
        ),
      ),
    ],
  );
}


