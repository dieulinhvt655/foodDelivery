import 'package:go_router/go_router.dart';
import '../../features/onboarding/pages/onboarding_page.dart';
import '../../features/home/pages/home_page.dart';
import '../../features/restaurant_detail/pages/restaurant_detail_page.dart';
import '../../features/profile/pages/profile_page.dart';
import '../../features/orders/pages/orders_page.dart';
import '../../features/welcome/pages/welcome_page.dart';
import '../../features/auth/pages/login_page.dart';
import '../../features/auth/pages/signup_page.dart';
import '../../features/desserts/pages/desserts_filter_page.dart';
import '../../features/filters/pages/category_filter_page.dart';
import '../../features/cart/pages/cart_page.dart';
import '../../features/notifications/pages/notifications_page.dart';
import '../../features/profile/pages/profile_edit_page.dart';

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
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/desserts-filter',
        builder: (context, state) => const DessertsFilterPage(),
      ),
      GoRoute(
        path: '/restaurant/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return RestaurantDetailPage(restaurantId: id);
        },
      ),
      GoRoute(
        path: '/orders',
        builder: (context, state) => const OrdersPage(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: '/profile/edit',
        builder: (context, state) => const ProfileEditPage(),
      ),
      // GoRoute(
      //   path: '/category_filter_page',
      //   builder: (context, state) => const Dee(),
      // ),
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
        path: '/notifications',
        builder: (context, state) => const NotificationsPage(),
      ),
    ],
  );
}


