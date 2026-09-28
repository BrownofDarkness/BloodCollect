import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../constants/app_enums.dart';
import '../widgets/placeholder_screen.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/blood_center/presentation/screens/bc_shell.dart';
import '../../features/citizen/presentation/screens/citizen_shell.dart';
import '../../features/health_center/presentation/screens/hc_shell.dart';

part 'app_router.g.dart';

abstract final class AppRoutes {
  static const splash   = '/';
  static const login    = '/login';
  static const register = '/register/:role';

  static const citizenHome    = '/citizen/home';
  static const citizenDonors  = '/citizen/donors';
  static const citizenBlood   = '/citizen/blood';
  static const citizenDonate  = '/citizen/donate';
  static const citizenProfile = '/citizen/profile';

  static const hcHome     = '/hc/home';
  static const hcDonors   = '/hc/donors';
  static const hcBlood    = '/hc/blood';
  static const hcRequests = '/hc/requests';
  static const hcProfile  = '/hc/profile';

  static const bcHome      = '/bc/home';
  static const bcStocks    = '/bc/stocks';
  static const bcRequests  = '/bc/requests';
  static const bcCampaigns = '/bc/campaigns';
  static const bcProfile   = '/bc/profile';
}

@riverpod
class RouterNotifier extends _$RouterNotifier implements Listenable {
  VoidCallback? _routerListener;

  @override
  Future<void> build() async {
    ref.listen<AsyncValue<User?>>(
      authStateProvider,
      (_, _) => _routerListener?.call(),
    );
    ref.listen<AsyncValue<UserRole?>>(
      currentUserRoleProvider,
      (_, _) => _routerListener?.call(),
    );
  }

  @override
  void addListener(VoidCallback listener) => _routerListener = listener;

  @override
  void removeListener(VoidCallback listener) => _routerListener = null;

  String? redirect(BuildContext context, GoRouterState state) {
    final authAsync = ref.read(authStateProvider);
    final roleAsync = ref.read(currentUserRoleProvider);

    if (authAsync.isLoading || roleAsync.isLoading) return null;

    final user = authAsync.asData?.value;
    final role = roleAsync.asData?.value;
    final loc  = state.matchedLocation;

    final isPublic = loc == AppRoutes.splash ||
        loc == AppRoutes.login ||
        loc.startsWith('/register');

    if (user == null) {
      return isPublic ? null : AppRoutes.login;
    }

    if (isPublic) return _homeForRole(role);

    if (role == UserRole.citizen && !loc.startsWith('/citizen')) {
      return AppRoutes.citizenHome;
    }
    if (role == UserRole.healthCenter && !loc.startsWith('/hc')) {
      return AppRoutes.hcHome;
    }
    if (role == UserRole.bloodCenter && !loc.startsWith('/bc')) {
      return AppRoutes.bcHome;
    }

    return null;
  }

  String _homeForRole(UserRole? role) => switch (role) {
    UserRole.citizen      => AppRoutes.citizenHome,
    UserRole.healthCenter => AppRoutes.hcHome,
    UserRole.bloodCenter  => AppRoutes.bcHome,
    UserRole.admin        => AppRoutes.citizenHome,
    null                  => AppRoutes.login,
  };
}

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final notifier = ref.watch(routerProvider.notifier);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: notifier,
    redirect: notifier.redirect,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register/:role',
        builder: (context, state) => RegisterScreen(
          role: state.pathParameters['role'] ?? 'citizen',
        ),
      ),

      // ── Citoyen ──────────────────────────────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            CitizenShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.citizenHome,
              builder: (context, state) =>
                  const PlaceholderScreen(title: 'Accueil'),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.citizenDonors,
              builder: (context, state) =>
                  const PlaceholderScreen(title: 'Donneurs'),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.citizenBlood,
              builder: (context, state) =>
                  const PlaceholderScreen(title: 'Sang'),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.citizenDonate,
              builder: (context, state) =>
                  const PlaceholderScreen(title: 'Donner'),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.citizenProfile,
              builder: (context, state) =>
                  const PlaceholderScreen(title: 'Profil'),
            ),
          ]),
        ],
      ),

      // ── Centre de santé ───────────────────────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            HealthCenterShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.hcHome,
              builder: (context, state) =>
                  const PlaceholderScreen(title: 'Accueil'),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.hcDonors,
              builder: (context, state) =>
                  const PlaceholderScreen(title: 'Donneurs'),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.hcBlood,
              builder: (context, state) =>
                  const PlaceholderScreen(title: 'Sang'),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.hcRequests,
              builder: (context, state) =>
                  const PlaceholderScreen(title: 'Demandes'),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.hcProfile,
              builder: (context, state) =>
                  const PlaceholderScreen(title: 'Profil'),
            ),
          ]),
        ],
      ),

      // ── Centre de transfusion ─────────────────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            BloodCenterShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.bcHome,
              builder: (context, state) =>
                  const PlaceholderScreen(title: 'Accueil'),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.bcStocks,
              builder: (context, state) =>
                  const PlaceholderScreen(title: 'Stocks'),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.bcRequests,
              builder: (context, state) =>
                  const PlaceholderScreen(title: 'Demandes'),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.bcCampaigns,
              builder: (context, state) =>
                  const PlaceholderScreen(title: 'Collectes'),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.bcProfile,
              builder: (context, state) =>
                  const PlaceholderScreen(title: 'Profil'),
            ),
          ]),
        ],
      ),
    ],
  );
}
