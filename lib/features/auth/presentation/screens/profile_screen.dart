import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../data/repositories/auth_repository_impl.dart';

// Profil temporaire : les interfaces profil complètes viendront plus tard.
// Pour l'instant : titre + déconnexion.
//cette interface sera surement supprimé ou déconnecté lorsque celle à cet effet sera disponnible dans chaque feature
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.person_outline,
              size: 48,
              color: AppColors.gris,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text("Interface complète à venir"),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () async {
                await AuthRepositoryImpl().signOut();
                if (context.mounted) context.go(AppRoutes.welcome);
              },
              icon: const Icon(Icons.logout_outlined),
              label: const Text("Se déconnecter"),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.rouge,
                side: const BorderSide(color: AppColors.rouge),
                minimumSize: const Size(200, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
