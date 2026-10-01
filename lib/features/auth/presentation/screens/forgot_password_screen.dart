import 'package:flutter/material.dart';
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

// Écran mot de passe oublié. Envoie le lien de réinitialisation Firebase à l'email saisi.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _submitting = false;
  bool _sent = false;
  String? _serverError;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _serverError = null);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);
    // Mode simulation : délai puis état succès.
    if (BackendConfig.simulate) {
      await Future.delayed(BackendConfig.simulatedDelay);
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _sent = true;
      });
      return;
    }
    try {
      await AuthRepositoryImpl().sendPasswordResetEmail(
        _emailController.text.trim(),
      );
      if (mounted) setState(() => _sent = true);
    } on AuthException catch (e) {
      setState(
        () => _serverError = e is UserNotFoundException
            ? "Aucun compte associé à cet email."
            : authErrorMessage(e),
      );
    } catch (_) {
      setState(
        () => _serverError =
            "Envoi impossible. Vérifiez votre connexion puis réessayez.",
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
          child: _sent ? _buildSuccess() : _buildForm(),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppBackButton(
            onPressed: () => context.go(AppRoutes.login),
          ),
          const SizedBox(height: 16),
          Image.asset(AppAssets.logoRed, width: 64, height: 64),
          const SizedBox(height: 20),
          const Text(
            'Mot de passe\noublié ?',
            style: TextStyle(
              color: AppColors.encre,
              fontSize: 30,
              fontWeight: FontWeight.w800,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "Saisissez l’email de votre compte : nous vous envoyons un lien pour créer un nouveau mot de passe.",
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
            autovalidateMode: AutovalidateMode.onUserInteraction,
            autocorrect: false,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _submit(),
            decoration: const InputDecoration(
              hintText: "nom@exemple.com",
            ),
            validator: Validators.email,
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
          const SizedBox(height: 24),
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
                    "Envoyer le lien",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccess() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppBackButton(
          onPressed: () => context.go(AppRoutes.login),
        ),
        const SizedBox(height: 16),
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.bleuLight,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(
            Icons.mark_email_read_outlined,
            color: AppColors.bleu,
            size: 32,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          "Email envoyé",
          style: TextStyle(
            color: AppColors.encre,
            fontSize: 30,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "Si un compte existe pour ${_emailController.text.trim()}, vous recevrez un lien de réinitialisation dans quelques minutes. Pensez à vérifier vos spams.",
          style: const TextStyle(
            color: AppColors.gris,
            fontSize: 16,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 24),
        OutlinedButton(
          onPressed: () => context.go(AppRoutes.login),
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.encre,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            side: const BorderSide(color: AppColors.ligne),
            textStyle: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          child: const Text("Retour à la connexion"),
        ),
      ],
    );
  }
}
