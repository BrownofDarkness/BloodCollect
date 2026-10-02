import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../config/backend_config.dart';
import '../constants/app_enums.dart';
import '../widgets/placeholder_screen.dart';
import '../../features/auth/domain/entities/auth_user.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/pending_verification_screen.dart';
import '../../features/auth/presentation/screens/profile_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/role_choice_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/welcome_screen.dart';
import '../../features/blood_center/presentation/screens/bc_shell.dart';
import '../../features/citizen/presentation/screens/citizen_shell.dart';
import '../../features/health_center/presentation/screens/hc_blood_center_screen.dart';
import '../../features/health_center/presentation/screens/hc_blood_request_screen.dart';
import '../../features/health_center/presentation/screens/hc_blood_search_screen.dart';
import '../../features/health_center/presentation/screens/hc_requests_screen.dart';
import '../../features/health_center/presentation/screens/hc_shell.dart';

part 'app_router.g.dart';

abstract final class AppRoutes {
  static const splash   = '/';
  static const welcome  = '/welcome';
  static const login    = '/login';
  static const forgotPassword = '/forgot-password';
  static const registerChoice = '/register';
  static const register = '/register/:role';
  static const pendingVerification = '/pending-verification';

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
  static const hcBloodCenter = '/hc/blood/center/:centerId';
  static const hcBloodRequest = '/hc/blood/request';

  // [bloodType] : groupe recherché, repris si une demande est lancée ensuite.
  static String hcBloodCenterPath(String centerId, {BloodType? bloodType}) =>
      Uri(
        path: '$hcBlood/center/$centerId',
        queryParameters: _query({'bloodType': bloodType?.firestoreValue}),
      ).toString();

  static String hcBloodRequestPath({
    String? bloodCenterId,
    BloodType? bloodType,
  }) =>
      Uri(
        path: hcBloodRequest,
        queryParameters: _query({
          'bloodCenterId': bloodCenterId,
          'bloodType': bloodType?.firestoreValue,
        }),
      ).toString();

  static Map<String, String>? _query(Map<String, String?> params) {
    final query = {
      for (final e in params.entries)
        if (e.value != null) e.key: e.value!,
    };
    return query.isEmpty ? null : query;
  }

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
    ref.listen<AsyncValue<AuthUser?>>(
      authStateProvider,
      (_, _) => _routerListener?.call(),
    );
    ref.listen<AsyncValue<UserRole?>>(
      currentUserRoleProvider,
      (_, _) => _routerListener?.call(),
    );
    ref.listen<AsyncValue<VerificationStatus?>>(
      centerVerificationStatusProvider,
      (_, _) => _routerListener?.call(),
    );
  }

  @override
  void addListener(VoidCallback listener) => _routerListener = listener;

  @override
  void removeListener(VoidCallback listener) => _routerListener = null;

  String? redirect(BuildContext context, GoRouterState state) {
    // Mode simulation : navigation libre pour tester le flow sans Firebase.
    if (BackendConfig.simulate) return null;

    final authAsync = ref.read(authStateProvider);
    final roleAsync = ref.read(currentUserRoleProvider);
    final verificationAsync = ref.read(centerVerificationStatusProvider);

    if (authAsync.isLoading ||
        roleAsync.isLoading ||
        verificationAsync.isLoading) {
      return null;
    }

    final user = authAsync.asData?.value;
    final role = roleAsync.asData?.value;
    final loc  = state.matchedLocation;

    // Le splash est auto-géré (min-display + gating) : il sort tout seul.
    if (loc == AppRoutes.splash) return null;

    final isPublic = loc == AppRoutes.welcome ||
        loc == AppRoutes.login ||
        loc == AppRoutes.forgotPassword ||
        loc.startsWith('/register');

    if (user == null) {
      return isPublic ? null : AppRoutes.login;
    }

    // Centre non vérifié : cantonné à l'écran d'attente.
    final isCenter =
        role == UserRole.healthCenter || role == UserRole.bloodCenter;
    final verified =
        verificationAsync.asData?.value == VerificationStatus.verified;
    if (isCenter && !verified) {
      return loc == AppRoutes.pendingVerification
          ? null
          : AppRoutes.pendingVerification;
    }

    // Rôle encore inconnu (écritures d'inscription en cours, lecture lente)
    // : on ne yank nulle part, les écrans gèrent leur propre sortie.
    if (isPublic) {
      if (role == null) return null;
      return _homeForRole(role);
    }

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

  String _homeForRole(UserRole role) => switch (role) {
    UserRole.citizen      => AppRoutes.citizenHome,
    UserRole.healthCenter => AppRoutes.hcHome,
    UserRole.bloodCenter  => AppRoutes.bcHome,
    UserRole.admin        => AppRoutes.citizenHome,
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
        path: AppRoutes.welcome,
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.pendingVerification,
        builder: (context, state) => const PendingVerificationScreen(),
      ),
      GoRoute(
        path: AppRoutes.registerChoice,
        builder: (context, state) => const RoleChoiceScreen(),
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
                  const ProfileScreen(title: 'Profil'),
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
              builder: (context, state) => const HcBloodSearchScreen(),
              routes: [
                // → AppRoutes.hcBloodCenter
                GoRoute(
                  path: 'center/:centerId',
                  builder: (context, state) => HcBloodCenterScreen(
                    centerId: state.pathParameters['centerId']!,
                    bloodType: BloodType.fromString(
                      state.uri.queryParameters['bloodType'],
                    ),
                  ),
                ),
                // → AppRoutes.hcBloodRequest
                GoRoute(
                  path: 'request',
                  builder: (context, state) => HcBloodRequestScreen(
                    bloodCenterId: state.uri.queryParameters['bloodCenterId'],
                    bloodType: BloodType.fromString(
                      state.uri.queryParameters['bloodType'],
                    ),
                  ),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.hcRequests,
              builder: (context, state) => const HcRequestsScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.hcProfile,
              builder: (context, state) =>
                  const ProfileScreen(title: 'Profil'),
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
                  const ProfileScreen(title: 'Profil'),
            ),
          ]),
        ],
      ),
    ],
  );
}
