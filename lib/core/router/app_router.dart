import 'package:go_router/go_router.dart';
import '../../features/onboarding/pages/onboarding_page.dart';
import '../../features/home/pages/home_page.dart';
import '../../features/restaurant_detail/pages/restaurant_detail_page.dart';
import '../../features/profile/pages/profile_page.dart';
import '../../features/orders/pages/orders_page.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/onboarding',
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomePage(),
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
    ],
  );
}


