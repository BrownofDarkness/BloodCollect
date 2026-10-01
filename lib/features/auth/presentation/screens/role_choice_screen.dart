import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/app_back_button.dart';

class RoleChoiceScreen extends StatelessWidget {
  const RoleChoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivoire,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppBackButton(
                onPressed: () => context.go(AppRoutes.welcome),
              ),
              const SizedBox(height: 8),
              const Text(
                "Quel compte souhaitez-\nvous créer ?",
                style: TextStyle(
                  color: AppColors.encre,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Choisissez votre profil : l’inscription s’adapte à votre rôle.",
                style: TextStyle(
                  color: AppColors.gris,
                  fontSize: 16,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              _RoleCard(
                icon: Icons.person_outline,
                iconColor: AppColors.bleu,
                tileColor: AppColors.bleuLight,
                title: "Citoyen",
                description: "Chercher un donneur, consulter la disponibilité du sang, donner mon sang.",
                needsVerification: false,
                onTap: () => context.go('/register/citizen'),
              ),
              const SizedBox(height: 16),
              _RoleCard(
                icon: Icons.business_outlined,
                iconColor: AppColors.encre,
                tileColor: AppColors.ligne,
                title: "Centre de santé",
                description: "Rechercher des donneurs pour vos patients et demander du sang aux centres de transfusion.",
                needsVerification: true,
                onTap: () => context.go('/register/health_center'),
              ),
              const SizedBox(height: 16),
              _RoleCard(
                icon: Icons.water_drop_outlined,
                iconColor: AppColors.rouge,
                tileColor: AppColors.rougeLight,
                title: "Centre de transfusion",
                description: "Gérer vos stocks, traiter les demandes et organiser des collectes.",
                needsVerification: true,
                onTap: () => context.go('/register/blood_center'),
              ),
              const SizedBox(height: 32),
              Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text(
                      "Déjà un compte ? ",
                      style: TextStyle(
                        color: AppColors.gris,
                        fontSize: 15,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.go(AppRoutes.login),
                      child: const Text(
                        "Se connecter",
                        style: TextStyle(
                          color: AppColors.bleu,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.bleu,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.icon,
    required this.iconColor,
    required this.tileColor,
    required this.title,
    required this.description,
    required this.needsVerification,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final Color tileColor;
  final String title;
  final String description;
  final bool needsVerification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.ligne),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: tileColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: iconColor, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.encre,
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        color: AppColors.gris,
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                    if (needsVerification) ...[
                      const SizedBox(height: 8),
                      const Row(
                        children: [
                          Icon(
                            Icons.verified_user_outlined,
                            color: AppColors.encre,
                            size: 18,
                          ),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              "Compte vérifié avant activation",
                              style: TextStyle(
                                color: AppColors.encre,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Icon(
                  Icons.chevron_right,
                  color: AppColors.gris,
                  size: 26,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
