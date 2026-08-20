import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'theme/ais_theme.dart';
import 'screens/home_screen.dart';
import 'screens/packages_screen.dart';
import 'screens/package_detail_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/checkout_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/ld_demo_screen.dart';
import 'screens/success_screen.dart';
import 'features/launchdarkly_mpay_demo/presentation/launchdarkly_mpay_demo_screen.dart';

class AISApp extends StatelessWidget {
  const AISApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'AIS Package Store',
      debugShowCheckedModeBanner: false,
      theme: AISTheme.theme,
      routerConfig: _router,
    );
  }
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (ctx, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/packages',
      builder: (ctx, state) {
        final category = state.uri.queryParameters['category'];
        return PackagesScreen(categoryFilter: category);
      },
    ),
    GoRoute(
      path: '/packages/:id',
      builder: (ctx, state) => PackageDetailScreen(
        packageId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      path: '/cart',
      builder: (ctx, state) => const CartScreen(),
    ),
    GoRoute(
      path: '/checkout',
      builder: (ctx, state) => const CheckoutScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (ctx, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/ld-demo',
      builder: (ctx, state) => const LDDemoScreen(),
    ),
    GoRoute(
      path: '/launchdarkly-mpay-demo',
      builder: (ctx, state) => const LaunchDarklyMpayDemoScreen(),
    ),
    GoRoute(
      path: '/success',
      builder: (ctx, state) => const SuccessScreen(),
    ),
  ],
);
