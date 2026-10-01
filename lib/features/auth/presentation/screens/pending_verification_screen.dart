import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../data/repositories/auth_repository_impl.dart';

// Compte centre créé mais pas encore vérifié par l'admin.
// Accessible uniquement connecté avec un statut != verified.
class PendingVerificationScreen extends StatelessWidget {
  const PendingVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivoire,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: AppColors.bleuLight,
                  borderRadius: BorderRadius.circular(44),
                ),
                child: const Icon(
                  Icons.hourglass_top_outlined,
                  color: AppColors.bleu,
                  size: 44,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Compte en cours\nde vérification",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.encre,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "L’équipe BloodCollect vérifie l’autorisation de votre établissement. Vous serez notifié dès que le compte sera actif.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.gris,
                  fontSize: 16,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),
              OutlinedButton(
                onPressed: () async {
                  await AuthRepositoryImpl().signOut();
                  if (context.mounted) context.go(AppRoutes.welcome);
                },
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.encre,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  side: const BorderSide(color: AppColors.ligne),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: const Text("Se déconnecter"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
