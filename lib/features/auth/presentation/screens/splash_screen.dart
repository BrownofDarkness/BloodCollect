import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/backend_config.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_enums.dart';
import '../../../../core/router/app_router.dart';
import '../../domain/entities/auth_user.dart';
import '../providers/auth_providers.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const _minDisplay = Duration(milliseconds: 2500);

  late final AnimationController _progressController;
  late final Animation<double> _progress;
  bool _minTimeDone = false;
  bool _exited = false;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: _minDisplay,
    );
    _progress = CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    );
    _progressController.forward().whenComplete(() {
      _minTimeDone = true;
      _tryExit();
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  void _tryExit() {
    if (_exited || !_minTimeDone || !mounted) return;
    // Mode simulation : pas d'attente Firebase, direction le welcome.
    if (BackendConfig.simulate) {
      _exited = true;
      context.go(AppRoutes.welcome);
      return;
    }
    final authAsync = ref.read(authStateProvider);
    final roleAsync = ref.read(currentUserRoleProvider);
    final verificationAsync = ref.read(centerVerificationStatusProvider);
    if (authAsync.isLoading ||
        roleAsync.isLoading ||
        verificationAsync.isLoading) {
      return;
    }

    _exited = true;
    final AuthUser? user = authAsync.asData?.value;
    if (user == null) {
      context.go(AppRoutes.welcome);
      return;
    }
    final UserRole? role = roleAsync.asData?.value;
    final isCenter =
        role == UserRole.healthCenter || role == UserRole.bloodCenter;
    if (isCenter &&
        verificationAsync.asData?.value != VerificationStatus.verified) {
      context.go(AppRoutes.pendingVerification);
      return;
    }
    context.go(switch (role) {
      UserRole.citizen => AppRoutes.citizenHome,
      UserRole.healthCenter => AppRoutes.hcHome,
      UserRole.bloodCenter => AppRoutes.bcHome,
      UserRole.admin => AppRoutes.citizenHome,
      null => AppRoutes.welcome,
    });
  }

  @override
  Widget build(BuildContext context) {
    // Re-tente la sortie à chaque résolution auth/rôle après le timer.
    ref.listen<AsyncValue<AuthUser?>>(
      authStateProvider,
      (_, _) => _tryExit(),
    );
    ref.listen<AsyncValue<UserRole?>>(
      currentUserRoleProvider,
      (_, _) => _tryExit(),
    );
    ref.listen<AsyncValue<VerificationStatus?>>(
      centerVerificationStatusProvider,
      (_, _) => _tryExit(),
    );

    return Scaffold(
      backgroundColor: AppColors.rouge,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Spacer(flex: 3),
              Image.asset(
                AppAssets.logoWhite,
                width: 120,
                height: 120,
              ),
              const SizedBox(height: 24),
              const Text(
                "BloodCollect",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Donner. Trouver. Sauver.",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const Spacer(flex: 5),
              AnimatedBuilder(
                animation: _progress,
                builder: (context, _) => Container(
                  width: 120,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: _progress.value.clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "DON DE SANG",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
