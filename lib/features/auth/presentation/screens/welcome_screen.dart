import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.rouge,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        AppAssets.logoWhite,
                        width: 40,
                        height: 40,
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "BloodCollect",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    "DON DE SANG",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Donner. Trouver.\nSauver.",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Une seule application pour les citoyens, les centres de santé et les centres de transfusion sanguine.",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _NotionCard(
                          icon: Icons.person_outline,
                          title: "Une personne",
                          body: "Un donneur potentiel, jamais une poche de sang.",
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _NotionCard(
                          icon: Icons.water_drop_outlined,
                          title: "Du sang",
                          body:
                              "Collecté et géré par un centre de transfusion.",
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Spacer(),
            Container(
              decoration: const BoxDecoration(
                color: AppColors.ivoire,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              // La zone ivoire descend sous la barre de navigation du téléphone :
              // sa hauteur s'ajoute à la marge pour que le bouton reste dégagé.
              padding: EdgeInsets.fromLTRB(
                24,
                24,
                24,
                32 + MediaQuery.viewPaddingOf(context).bottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    onPressed: () => context.go(AppRoutes.registerChoice),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      "Créer un compte",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
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
                    child: const Text("Se connecter"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotionCard extends StatelessWidget {
  const _NotionCard({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            body,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
