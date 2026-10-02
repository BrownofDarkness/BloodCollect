import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/citizen/presentation/providers/donor_providers.dart';
import '../../shared/presentation/models/donor_search_candidate.dart';
import '../config/backend_config.dart';
import '../constants/app_enums.dart';
import '../widgets/placeholder_screen.dart';
import '../../features/auth/domain/entities/auth_user.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/pending_verification_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/role_choice_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/welcome_screen.dart';
import '../../features/blood_center/presentation/screens/bc_shell.dart';
import '../../features/citizen/presentation/screens/blood_availability_screen.dart';
import '../../features/citizen/presentation/screens/blood_center_detail_screen.dart';
import '../../features/citizen/presentation/screens/citizen_home_screen.dart';
import '../../features/citizen/presentation/screens/citizen_shell.dart';
import '../../features/citizen/presentation/screens/donor_results_screen.dart';
import '../../features/citizen/presentation/screens/donor_search_screen.dart';
import '../../features/citizen/presentation/screens/match_request_received_screen.dart';
import '../../features/citizen/presentation/screens/match_request_screen.dart';
import '../../features/citizen/presentation/screens/donate_screen.dart';
import '../../features/citizen/presentation/screens/profile_screen.dart' as citizen_profile;
import '../../features/health_center/presentation/screens/hc_shell.dart';

part 'app_router.g.dart';

/// Aiguille vers la section du rôle, ou vers son accueil depuis une route
/// publique. Une route déjà dans la bonne section n'est pas redirigée, ce qui
/// laisse la navigation libre.
///
/// Fonction pure : elle ne dépend ni du contexte ni de l'état d'auth, donc
/// elle est testable directement.
String? redirectForRole(String matchedLocation, String? roleValue) {
  final isPublicRoute =
      matchedLocation == AppRoutes.splash ||
      matchedLocation == AppRoutes.welcome ||
      matchedLocation == AppRoutes.login ||
      matchedLocation == AppRoutes.forgotPassword ||
      matchedLocation.startsWith('/register');

  final role = UserRole.fromString(roleValue);
  if (isPublicRoute) return homeForRole(role);

  return switch (role) {
    UserRole.citizen when !matchedLocation.startsWith('/citizen') =>
      AppRoutes.citizenHome,
    UserRole.healthCenter when !matchedLocation.startsWith('/hc') =>
      AppRoutes.hcHome,
    UserRole.bloodCenter when !matchedLocation.startsWith('/bc') =>
      AppRoutes.bcHome,
    _ => null,
  };
}

/// Accueil d'un rôle. `null` tombe sur la connexion.
String homeForRole(UserRole? role) => switch (role) {
  UserRole.citizen => AppRoutes.citizenHome,
  UserRole.healthCenter => AppRoutes.hcHome,
  UserRole.bloodCenter => AppRoutes.bcHome,
  UserRole.admin => AppRoutes.citizenHome,
  null => AppRoutes.login,
};

abstract final class AppRoutes {
  static const splash   = '/';
  static const welcome  = '/welcome';
  static const login    = '/login';
  static const forgotPassword = '/forgot-password';
  static const registerChoice = '/register';
  static const register = '/register/:role';
  static const pendingVerification = '/pending-verification';

  static const citizenHome = '/citizen/home';
  static const citizenDonors = '/citizen/donors';
  static const citizenBlood = '/citizen/blood';
  static const citizenBloodCenter = ':centerId';
  static const citizenDonorsResults = 'results';
  static const citizenDonorsRequest = 'request';
  static const citizenIncoming = '/citizen/incoming';
  static const citizenIncomingRequest = ':requestId';
  static const citizenDonate = '/citizen/donate';
  static const citizenProfile = '/citizen/profile';

  static const hcHome = '/hc/home';
  static const hcDonors = '/hc/donors';
  static const hcBlood = '/hc/blood';
  static const hcRequests = '/hc/requests';
  static const hcProfile = '/hc/profile';

  static const bcHome = '/bc/home';
  static const bcStocks = '/bc/stocks';
  static const bcRequests = '/bc/requests';
  static const bcCampaigns = '/bc/campaigns';
  static const bcProfile = '/bc/profile';
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
    final loc = state.matchedLocation;

    // Le splash est auto-géré (min-display + gating) : il sort tout seul.
    if (loc == AppRoutes.splash) return null;

    final isPublic =
        loc == AppRoutes.welcome ||
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

    return redirectForRole(loc, role?.firestoreValue);
  }

  String _homeForRole(UserRole role) => switch (role) {
    UserRole.citizen => AppRoutes.citizenHome,
    UserRole.healthCenter => AppRoutes.hcHome,
    UserRole.bloodCenter => AppRoutes.bcHome,
    UserRole.admin => AppRoutes.citizenHome,
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
        builder: (context, state) =>
            RegisterScreen(role: state.pathParameters['role'] ?? 'citizen'),
      ),

      // ── Citoyen ──────────────────────────────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            CitizenShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.citizenHome,
                builder: (context, state) => const CitizenHomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.citizenDonors,
                builder: (context, state) => const DonorSearchScreen(),
                routes: [
                  GoRoute(
                    path: AppRoutes.citizenDonorsResults,
                    builder: (context, state) => DonorResultsScreen(
                      filters: state.extra! as DonorSearchFilters,
                    ),
                  ),
                  GoRoute(
                    path: AppRoutes.citizenDonorsRequest,
                    builder: (context, state) => MatchRequestScreen(
                      candidate: state.extra! as DonorSearchCandidate,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.citizenBlood,
                builder: (context, state) => const BloodAvailabilityScreen(),
                routes: [
                  GoRoute(
                    path: AppRoutes.citizenBloodCenter,
                    builder: (context, state) => BloodCenterDetailScreen(
                      centerId: state.pathParameters['centerId'] ?? '',
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.citizenDonate,
                builder: (context, state) => const DonateScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.citizenProfile,
                builder: (context, state) => const citizen_profile.ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      
      GoRoute(
        path: '${AppRoutes.citizenIncoming}/${AppRoutes.citizenIncomingRequest}',
        builder: (context, state) => MatchRequestReceivedScreen(
          requestId: state.pathParameters['requestId'] ?? '',
        ),
      ),

      // ── Centre de santé ───────────────────────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            HealthCenterShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.hcHome,
                builder: (context, state) =>
                    const PlaceholderScreen(title: 'Accueil'),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.hcDonors,
                builder: (context, state) =>
                    const PlaceholderScreen(title: 'Donneurs'),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.hcBlood,
                builder: (context, state) =>
                    const PlaceholderScreen(title: 'Sang'),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.hcRequests,
                builder: (context, state) =>
                    const PlaceholderScreen(title: 'Demandes'),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.hcProfile,
                builder: (context, state) =>
                    const PlaceholderScreen(title: 'Profil'),
              ),
            ],
          ),
        ],
      ),

      // ── Centre de transfusion ─────────────────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            BloodCenterShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.bcHome,
                builder: (context, state) =>
                    const PlaceholderScreen(title: 'Accueil'),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.bcStocks,
                builder: (context, state) =>
                    const PlaceholderScreen(title: 'Stocks'),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.bcRequests,
                builder: (context, state) =>
                    const PlaceholderScreen(title: 'Demandes'),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.bcCampaigns,
                builder: (context, state) =>
                    const PlaceholderScreen(title: 'Collectes'),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.bcProfile,
                builder: (context, state) =>
                    const PlaceholderScreen(title: 'Profil'),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
