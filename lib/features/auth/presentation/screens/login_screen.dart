import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/backend_config.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/errors/auth_error_messages.dart';
import '../../../../core/errors/auth_exceptions.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/validators.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../providers/auth_providers.dart';

// Interface 3 — Login pixel-perfect (PDF Authentication).
// Connexion par email uniquement. Le RouterNotifier redirige
// vers l'accueil du rôle dès que Firebase Auth émet un user.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _submitting = false;
  bool _signedIn = false;
  String? _serverError;
  // Rôle cible du mode simulation (debug uniquement).
  String _simRole = 'citizen';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _serverError = null);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);
    // Mode simulation : délai + navigation directe vers le home du rôle debug.
    if (BackendConfig.simulate) {
      await Future.delayed(BackendConfig.simulatedDelay);
      if (!mounted) return;
      setState(() => _submitting = false);
      context.go(switch (_simRole) {
        'health_center' => AppRoutes.hcHome,
        'blood_center' => AppRoutes.bcHome,
        _ => AppRoutes.citizenHome,
      });
      return;
    }
    try {
      await AuthRepositoryImpl().signInWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      // La redirection est gérée par RouterNotifier (refreshListenable).
      // Le banner ci-dessous couvre l'attente du profil.
      if (mounted) setState(() => _signedIn = true);
    } on AuthException catch (e) {
      setState(() => _serverError = authErrorMessage(e));
    } catch (_) {
      setState(
        () => _serverError =
            'Connexion impossible. Vérifiez votre connexion puis réessayez.',
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivoire,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppBackButton(
                  onPressed: () => context.go(AppRoutes.welcome),
                ),
                const SizedBox(height: 5),
                Image.asset(AppAssets.logoRed, width: 64, height: 64),
                const SizedBox(height: 15),
                const Text(
                  "Bon retour sur\nBloodCollect",
                  style: TextStyle(
                    color: AppColors.encre,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Une seule connexion pour tous les comptes : vous arrivez directement dans votre espace.",
                  style: TextStyle(
                    color: AppColors.gris,
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Email",
                  style: TextStyle(
                    color: AppColors.encre,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    hintText: "nom@exemple.com",
                  ),
                  validator: Validators.email,
                ),
                const SizedBox(height: 16),
                const Text(
                  "Mot de passe",
                  style: TextStyle(
                    color: AppColors.encre,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: InputDecoration(
                    hintText: "••••••••••",
                    suffixIcon: IconButton(
                      onPressed: () => setState(
                        () => _obscurePassword = !_obscurePassword,
                      ),
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      color: AppColors.gris,
                    ),
                  ),
                  validator: Validators.passwordStrong,
                ),
                if (_serverError != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.rougeLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _serverError!,
                      style: const TextStyle(
                        color: AppColors.rouge,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
                if (_signedIn && !BackendConfig.simulate)
                  _PostSignInStatus(
                    onRetry: () {
                      ref.invalidate(currentUserRoleProvider);
                      ref.invalidate(centerVerificationStatusProvider);
                    },
                    onSignOut: () async {
                      await AuthRepositoryImpl().signOut();
                      if (mounted) setState(() => _signedIn = false);
                    },
                  ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.go(AppRoutes.forgotPassword),
                    child: const Text(
                      "Mot de passe oublié ?",
                      style: TextStyle(
                        color: AppColors.bleu,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.bleu,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                if (BackendConfig.simulate) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.bleuLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "SIMULATION — espace de test",
                          style: TextStyle(
                            color: AppColors.bleu,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                "Espace de test",
                                style: TextStyle(
                                  color: AppColors.bleu,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _simRole,
                                isDense: true,
                                style: const TextStyle(
                                  color: AppColors.bleu,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: "citizen",
                                    child: Text("Citoyen"),
                                  ),
                                  DropdownMenuItem(
                                    value: "health_center",
                                    child: Text("Santé"),
                                  ),
                                  DropdownMenuItem(
                                    value: "blood_center",
                                    child: Text("Transfusion"),
                                  ),
                                ],
                                onChanged: (v) => setState(
                                  () => _simRole = v ?? "citizen",
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _submitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          "Se connecter",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
                const SizedBox(height: 32),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        const Text(
                          "Pas encore de compte ? ",
                          style: TextStyle(
                            color: AppColors.gris,
                            fontSize: 15,
                          ),
                        ),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () =>
                              context.go(AppRoutes.registerChoice),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 8,
                            ),
                            child: Text(
                              "Créer un compte",
                              style: TextStyle(
                                color: AppColors.bleu,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                decoration: TextDecoration.underline,
                                decorationColor: AppColors.bleu,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Banner post-connexion : couvre le laps entre Auth OK et profil résolu. Affiche le chargement, l'erreur Firestore éventuelle + réessayer.
class _PostSignInStatus extends ConsumerWidget {
  const _PostSignInStatus({
    required this.onRetry,
    required this.onSignOut,
  });

  final VoidCallback onRetry;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roleAsync = ref.watch(currentUserRoleProvider);
    final verificationAsync = ref.watch(centerVerificationStatusProvider);

    if (roleAsync.isLoading || verificationAsync.isLoading) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.bleuLight,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                color: AppColors.bleu,
                strokeWidth: 2,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                "Connexion réussie, chargement de votre espace…",
                style: TextStyle(
                  color: AppColors.bleu,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final error = roleAsync.hasError
        ? roleAsync.error
        : verificationAsync.hasError
            ? verificationAsync.error
            : null;
    final roleMissing =
        roleAsync.asData?.value == null && !roleAsync.hasError;
    if (error == null && !roleMissing) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.rougeLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            roleMissing
                ? "Profil introuvable pour ce compte. Contactez le support ou reconnectez-vous."
                : "Impossible de charger votre profil ($error). Vérifiez votre connexion.",
            style: const TextStyle(
              color: AppColors.rouge,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              TextButton(
                onPressed: onRetry,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 36),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  "Réessayer",
                  style: TextStyle(
                    color: AppColors.bleu,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.bleu,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              TextButton(
                onPressed: onSignOut,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 36),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  "Se déconnecter",
                  style: TextStyle(
                    color: AppColors.gris,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
