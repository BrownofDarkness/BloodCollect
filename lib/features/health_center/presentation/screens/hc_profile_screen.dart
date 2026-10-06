import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_enums.dart';
import '../../../../core/constants/app_info.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/domain/entities/app_user.dart';
import '../../../../shared/domain/entities/blood_request.dart';
import '../../../../shared/domain/entities/health_center.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/hc_providers.dart';
import '../widgets/hc_role_badge.dart';
import '../../../../shared/presentation/widgets/password_reset_dialog.dart';
import '../../../../shared/presentation/widgets/profile_menu_section.dart';

// Onglet « Profil » — Profil centre de santé.
// Fiche de l'établissement, compteurs de demandes et menu du compte.
// Les rubriques sans écran dédié affichent leur contenu en lecture seule
// ou un message « bientôt disponible ».
class HcProfileScreen extends ConsumerWidget {
  const HcProfileScreen({super.key});

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    await ref.read(authRepositoryProvider).signOut();
    if (context.mounted) context.go(AppRoutes.welcome);
  }

  void _comingSoon(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Bientôt disponible.')),
      );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final centerAsync = ref.watch(currentHealthCenterProvider);

    return Scaffold(
      backgroundColor: AppColors.ivoire,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HcRoleBadge(),
              const SizedBox(height: 12),
              const Text(
                'Profil',
                style: TextStyle(
                  color: AppColors.encre,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              centerAsync.when(
                skipLoadingOnReload: true,
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.rouge),
                  ),
                ),
                error: (_, _) => const _Notice(
                  icon: Icons.cloud_off_outlined,
                  title: 'Chargement impossible',
                  body: 'Vérifiez votre connexion puis réessayez.',
                ),
                data: (center) => center == null
                    ? const _Notice(
                        icon: Icons.search_off_outlined,
                        title: 'Fiche introuvable',
                        body: 'Aucun centre de santé n’est rattaché à ce '
                            'compte.',
                      )
                    : _ProfileContent(
                        center: center,
                        onComingSoon: () => _comingSoon(context),
                        onResetPassword: (email) =>
                            confirmPasswordReset(context, ref, email),
                      ),
              ),
              const SizedBox(height: 24),
              // Toujours accessible, même si la fiche ne charge pas.
              Material(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: AppColors.ligne),
                ),
                clipBehavior: Clip.antiAlias,
                child: ProfileMenuItem(
                  icon: Icons.logout_outlined,
                  title: 'Se déconnecter',
                  color: AppColors.rouge,
                  showChevron: false,
                  onTap: () => _signOut(context, ref),
                ),
              ),
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  AppInfo.versionLabel,
                  style: TextStyle(color: AppColors.gris, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileContent extends ConsumerWidget {
  const _ProfileContent({
    required this.center,
    required this.onComingSoon,
    required this.onResetPassword,
  });

  final HealthCenter center;
  final VoidCallback onComingSoon;
  final ValueChanged<String> onResetPassword;

  void _showDetails(
    BuildContext context,
    String title,
    List<(String, String)> fields,
  ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: true,
      isScrollControlled: true,
      // Toute la largeur : sans cela la feuille se réduit à son contenu.
      builder: (_) => SizedBox(
        width: double.infinity,
        child: _DetailsSheet(title: title, fields: fields),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppUser? user = ref.watch(currentAppUserProvider).value;
    final requests =
        ref.watch(healthCenterRequestsProvider).value ?? const <BloodRequest>[];
    final email = user?.email ?? ref.watch(authStateProvider).value?.email;
    final managerName = user?.fullName ?? '';
    final place = '${center.commune}, ${center.city}';
    final verification = _VerificationStyle.of(center.verificationStatus);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HeaderCard(
          center: center,
          verification: verification,
          ongoingCount: requests.where((r) => r.progress.isOngoing).length,
          processedCount: requests.where((r) => r.progress.isProcessed).length,
        ),
        const SizedBox(height: 24),
        ProfileMenuSection(
          title: 'ÉTABLISSEMENT',
          items: [
            ProfileMenuItem(
              icon: Icons.business_outlined,
              title: 'Informations de l’établissement',
              subtitle: 'Nom, type, numéro d’autorisation',
              onTap: () => _showDetails(
                context,
                'Informations de l’établissement',
                [
                  ('Nom', center.name),
                  ('Type', center.establishmentType),
                  ('Numéro d’autorisation', center.authorizationNumber),
                ],
              ),
            ),
            ProfileMenuItem(
              icon: Icons.location_on_outlined,
              title: 'Localisation',
              subtitle: center.address.isEmpty
                  ? place
                  : '$place · ${center.address}',
              onTap: () => _showDetails(context, 'Localisation', [
                ('Commune', center.commune),
                ('Ville', center.city),
                ('Adresse', center.address),
              ]),
            ),
            ProfileMenuItem(
              icon: Icons.phone_outlined,
              title: 'Coordonnées',
              subtitle: 'Téléphone et email professionnels',
              onTap: () => _showDetails(context, 'Coordonnées', [
                ('Téléphone', center.phone),
                ('Email', email ?? ''),
              ]),
            ),
            ProfileMenuItem(
              icon: Icons.description_outlined,
              title: 'Justificatifs',
              subtitle: verification.documentLabel,
              onTap: () => _showDetails(context, 'Justificatifs', [
                ('Statut', verification.documentLabel),
                ('Numéro d’autorisation', center.authorizationNumber),
              ]),
            ),
          ],
        ),
        const SizedBox(height: 24),
        ProfileMenuSection(
          title: 'ÉQUIPE',
          items: [
            ProfileMenuItem(
              icon: Icons.person_outline,
              title: 'Responsable du compte',
              subtitle: [managerName, center.contactFunction]
                  .where((part) => part.isNotEmpty)
                  .join(' · '),
              onTap: () => _showDetails(context, 'Responsable du compte', [
                ('Nom', managerName),
                ('Fonction', center.contactFunction),
                ('Email', email ?? ''),
              ]),
            ),
            // « Membres de l'équipe » : masqué en v1, le modèle ne gère
            // pas encore plusieurs comptes par centre.
          ],
        ),
        const SizedBox(height: 24),
        ProfileMenuSection(
          title: 'ACTIVITÉ',
          items: [
            ProfileMenuItem(
              icon: Icons.list_alt_outlined,
              title: 'Historique des demandes de sang',
              onTap: () => context.go(AppRoutes.hcRequests),
            ),
            ProfileMenuItem(
              icon: Icons.near_me_outlined,
              title: 'Historique des mises en relation',
              onTap: () => context.go(AppRoutes.hcDonorMatches),
            ),
          ],
        ),
        const SizedBox(height: 24),
        ProfileMenuSection(
          title: 'PARAMÈTRES',
          items: [
            // « Notifications » : masqué en v1, aucune notification n'est
            // encore envoyée (Cloud Functions à venir).
            ProfileMenuItem(
              icon: Icons.lock_outline,
              title: 'Mot de passe et sécurité',
              onTap: email == null || email.isEmpty
                  ? onComingSoon
                  : () => onResetPassword(email),
            ),
            // « Aide et contact » : masqué en v1, pas encore de contenu.
          ],
        ),
      ],
    );
  }
}

// Libellés et couleurs du statut de vérification du compte.
class _VerificationStyle {
  const _VerificationStyle({
    required this.accountLabel,
    required this.documentLabel,
    required this.color,
    required this.background,
  });

  factory _VerificationStyle.of(VerificationStatus status) => switch (status) {
        VerificationStatus.verified => const _VerificationStyle(
            accountLabel: 'Compte vérifié',
            documentLabel: 'Autorisation validée',
            color: AppColors.disponible,
            background: AppColors.disponibleLight,
          ),
        VerificationStatus.pending => const _VerificationStyle(
            accountLabel: 'Vérification en cours',
            documentLabel: 'Autorisation en cours de vérification',
            color: AppColors.limite,
            background: AppColors.limiteLight,
          ),
        VerificationStatus.rejected => const _VerificationStyle(
            accountLabel: 'Compte refusé',
            documentLabel: 'Autorisation refusée',
            color: AppColors.rouge,
            background: AppColors.indisponibleLight,
          ),
      };

  final String accountLabel;
  final String documentLabel;
  final Color color;
  final Color background;
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.center,
    required this.verification,
    required this.ongoingCount,
    required this.processedCount,
  });

  final HealthCenter center;
  final _VerificationStyle verification;
  final int ongoingCount;
  final int processedCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.ligne),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.ligne.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.business_outlined,
                  color: AppColors.encre,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      center.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.encre,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      [center.establishmentType, center.city]
                          .where((part) => part.isNotEmpty)
                          .join(' · '),
                      style: const TextStyle(
                        color: AppColors.gris,
                        fontSize: 13,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: verification.background,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified_user_outlined,
                            color: verification.color,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              verification.accountLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: verification.color,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  label: 'Demandes en cours',
                  value: ongoingCount,
                  color: AppColors.rouge,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatTile(
                  label: 'Traitées',
                  value: processedCount,
                  color: AppColors.encre,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.ivoire,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.slate, fontSize: 13),
          ),
          const SizedBox(height: 2),
          Text(
            '$value',
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// Contenu d'une rubrique en lecture seule (pas encore d'écran d'édition).
class _DetailsSheet extends StatelessWidget {
  const _DetailsSheet({required this.title, required this.fields});

  final String title;
  final List<(String, String)> fields;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: AppColors.encre,
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            for (final (label, value) in fields)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: AppColors.gris,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value.isEmpty ? 'Non renseigné' : value,
                      style: const TextStyle(
                        color: AppColors.encre,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
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

class _Notice extends StatelessWidget {
  const _Notice({required this.icon, required this.title, required this.body});

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.ligne),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.gris, size: 40),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.encre,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            body,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.gris,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
