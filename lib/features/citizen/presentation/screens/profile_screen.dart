import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../domain/usecases/get_citizen_profile_usecase.dart';
import '../providers/citizen_providers.dart';
import '../widgets/citizen_scaffold_parts.dart';
import '../widgets/profile_widgets.dart';

/// Onglet « Profil » — identité, activité et réglages du citoyen.
///
/// Aucune donnée médicale ici : le profil porte le groupe sanguin déclaré et
/// la zone, vérifiés en centre agréé au moment du don.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(citizenProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.ivoire,
      body: SafeArea(
        bottom: false,
        child: profileAsync.when(
          loading: () => const _ProfileSkeleton(),
          error: (error, _) => _ProfileError(
            onRetry: () => ref.invalidate(citizenProfileProvider),
          ),
          data: (profile) => _ProfileBody(profile: profile),
        ),
      ),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody({required this.profile});

  final CitizenProfile profile;

  @override
  Widget build(BuildContext context) {
    final user = profile.user;
    final city = user.city;
    final commune = user.commune;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: [
        const CitizenScreenHeader(
          contextLabel: 'Citoyen',
          contextIcon: Icons.person_outline,
        ),
        const SizedBox(height: 18),
        const CitizenPageTitle('Profil'),
        const SizedBox(height: 22),

        _IdentityCard(profile: profile),
        const SizedBox(height: 26),

        const ProfileSectionLabel('Mon compte'),
        const SizedBox(height: 10),
        ProfileCard(
          rows: [
            ProfileRow(
              icon: Icons.person_outline,
              title: 'Informations personnelles',
              subtitle: 'Nom, téléphone, email',
              onTap: () => _notAvailable(context, 'Informations personnelles'),
            ),
            ProfileRow(
              icon: Icons.water_drop_outlined,
              title: 'Groupe sanguin',
              subtitle: user.bloodType == null
                  ? 'Non renseigné'
                  : '${user.bloodType!.label} · modifiable si vous le découvrez',
              onTap: () => _notAvailable(context, 'Groupe sanguin'),
            ),
            ProfileRow(
              icon: Icons.location_on_outlined,
              title: 'Ville et commune',
              subtitle: [city, commune].whereType<String>().join(' · '),
              onTap: () => _notAvailable(context, 'Ville et commune'),
            ),
          ],
        ),
        const SizedBox(height: 24),

        const ProfileSectionLabel('Mon activité'),
        const SizedBox(height: 10),
        ProfileCard(
          rows: [
            ProfileRow(
              icon: Icons.calendar_today_outlined,
              title: 'Mes collectes',
              subtitle: _collectsSubtitle(profile.upcomingCollectCount),
              count: profile.upcomingCollectCount,
              onTap: () => context.go(AppRoutes.citizenDonate),
            ),
            ProfileRow(
              icon: Icons.send_outlined,
              title: 'Mes mises en relation',
              subtitle: 'Demandes envoyées et reçues',
              count: profile.matchCount,
              onTap: () => _notAvailable(context, 'Mes mises en relation'),
            ),
          ],
        ),
        const SizedBox(height: 24),

        const ProfileSectionLabel('Paramètres'),
        const SizedBox(height: 10),
        ProfileCard(
          rows: [
            ProfileRow(
              icon: Icons.notifications_none,
              title: 'Notifications',
              subtitle: 'Collectes, mises en relation',
              onTap: () => _notAvailable(context, 'Notifications'),
            ),
            ProfileRow(
              icon: Icons.lock_outline,
              title: 'Mot de passe et sécurité',
              onTap: () => _notAvailable(context, 'Mot de passe et sécurité'),
            ),
            ProfileRow(
              icon: Icons.shield_outlined,
              title: 'Confidentialité',
              subtitle: 'Données partagées avec les donneurs et centres',
              onTap: () => _notAvailable(context, 'Confidentialité'),
            ),
            ProfileRow(
              icon: Icons.help_outline,
              title: 'Aide et contact',
              onTap: () => _notAvailable(context, 'Aide et contact'),
            ),
          ],
        ),
        const SizedBox(height: 26),

        _SignOutButton(onTap: () => _notAvailable(context, 'Déconnexion')),
        const SizedBox(height: 22),
        const Center(
          child: Text(
            'BloodCollect · version 1.0',
            style: TextStyle(color: AppColors.gris, fontSize: 12.5),
          ),
        ),
      ],
    );
  }

  static String _collectsSubtitle(int count) => count > 1
      ? '$count participations à venir'
      : '$count participation à venir';

  void _notAvailable(BuildContext context, String feature) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$feature — bientôt disponible')));
  }
}

class _IdentityCard extends StatelessWidget {
  const _IdentityCard({required this.profile});

  final CitizenProfile profile;

  @override
  Widget build(BuildContext context) {
    final user = profile.user;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _Avatar(initials: profile.initials),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${user.firstName} ${user.lastName}',
                      style: const TextStyle(
                        color: AppColors.encre,
                        fontSize: 22,
                        height: 1.1,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.6,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.phone ?? user.email,
                      style: const TextStyle(
                        color: AppColors.slate,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _Fact(
                  label: 'Groupe',
                  value: user.bloodType?.label ?? 'Non renseigné',
                  highlight: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _Fact(
                  label: 'Commune',
                  value: user.commune ?? 'Non renseignée',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 62,
      height: 62,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.bleuSurface,
        shape: BoxShape.circle,
      ),
      child: Text(
        initials,
        style: const TextStyle(
          color: AppColors.bleu,
          fontSize: 22,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final String value;

  /// Groupe sanguin mis en avant : c'est la donnée la plus lue de l'écran.
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.encart,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.gris, fontSize: 12.5),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              color: highlight ? AppColors.rouge : AppColors.encre,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

/// Déconnexion. L'authentification étant partagée entre les rôles, l'appel à
/// Firebase Auth n'est pas câblé ici : le bouton est en place et attend le
/// use case de session.
class _SignOutButton extends StatelessWidget {
  const _SignOutButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.rouge,
          minimumSize: const Size(double.infinity, 54),
          side: const BorderSide(color: AppColors.ligne, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.logout, size: 18),
        label: const Text(
          'Se déconnecter',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _ProfileSkeleton extends StatelessWidget {
  const _ProfileSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: [
        const _SkeletonBar(width: 110, height: 28),
        const SizedBox(height: 22),
        const _SkeletonBar(height: 150),
        const SizedBox(height: 26),
        const _SkeletonBar(width: 110, height: 12),
        const SizedBox(height: 10),
        const _SkeletonBar(height: 200),
        const SizedBox(height: 24),
        const _SkeletonBar(width: 110, height: 12),
        const SizedBox(height: 10),
        const _SkeletonBar(height: 120),
      ],
    );
  }
}

class _ProfileError extends StatelessWidget {
  const _ProfileError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 36, color: AppColors.gris),
            const SizedBox(height: 12),
            const Text(
              'Le profil n\'a pas pu être chargé.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.slate),
            ),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: onRetry, child: const Text('Réessayer')),
          ],
        ),
      ),
    );
  }
}

class _SkeletonBar extends StatelessWidget {
  const _SkeletonBar({this.width, required this.height});

  final double? width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
