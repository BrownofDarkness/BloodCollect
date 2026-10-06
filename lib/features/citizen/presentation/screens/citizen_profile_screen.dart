import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_enums.dart';
import '../../../../core/constants/app_info.dart';
import '../../../../core/constants/app_locations.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/domain/entities/app_user.dart';
import '../../../../shared/presentation/widgets/password_reset_dialog.dart';
import '../../../../shared/presentation/widgets/profile_menu_section.dart';
import '../../../../shared/presentation/widgets/request_form_fields.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../auth/presentation/widgets/register_form_fields.dart';
import '../providers/citizen_profile_providers.dart';
import '../widgets/citizen_role_badge.dart';

// Onglet « Profil » — Profil citoyen.
// Identité de donneur, activité (collectes, mises en relation) et réglages
// du compte. Le groupe sanguin et la commune sont modifiables : ils
// déterminent ce que le citoyen voit et qui peut le solliciter.
class CitizenProfileScreen extends ConsumerWidget {
  const CitizenProfileScreen({super.key});

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    await ref.read(authRepositoryProvider).signOut();
    if (context.mounted) context.go(AppRoutes.welcome);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentAppUserProvider);

    return Scaffold(
      backgroundColor: AppColors.ivoire,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CitizenRoleBadge(),
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
              userAsync.when(
                skipLoadingOnReload: true,
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.bleu),
                  ),
                ),
                error: (_, _) => const _Notice(
                  icon: Icons.cloud_off_outlined,
                  title: 'Chargement impossible',
                  body: 'Vérifiez votre connexion puis réessayez.',
                ),
                data: (user) => user == null
                    ? const _Notice(
                        icon: Icons.search_off_outlined,
                        title: 'Profil introuvable',
                        body: 'Aucun profil n’est rattaché à ce compte.',
                      )
                    : _ProfileContent(user: user),
              ),
              const SizedBox(height: 24),
              // Toujours accessible, même si le profil ne charge pas.
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
  const _ProfileContent({required this.user});

  final AppUser user;

  void _showSheet(BuildContext context, Widget sheet) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: true,
      isScrollControlled: true,
      // Toute la largeur : sans cela la feuille se réduit à son contenu.
      builder: (_) => SizedBox(width: double.infinity, child: sheet),
    );
  }

  /// Enregistre le profil modifié et annonce le résultat.
  Future<void> _save(
    BuildContext context,
    WidgetRef ref,
    AppUser updated,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    String message;
    try {
      await ref.read(userRepositoryProvider).save(updated);
      message = 'Profil mis à jour.';
    } catch (_) {
      message = 'Modification impossible. Vérifiez votre connexion puis '
          'réessayez.';
    }
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _editBloodType(BuildContext context, WidgetRef ref) async {
    final chosen = await showModalBottomSheet<BloodType>(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: true,
      isScrollControlled: true,
      // Toute la largeur : sans cela la feuille se réduit à son contenu.
      builder: (_) => SizedBox(
        width: double.infinity,
        child: _BloodTypeSheet(initial: user.bloodType),
      ),
    );
    if (chosen == null || chosen == user.bloodType || !context.mounted) return;
    await _save(context, ref, user.copyWith(bloodType: () => chosen));
  }

  Future<void> _editLocation(BuildContext context, WidgetRef ref) async {
    final chosen = await showModalBottomSheet<(String, String)>(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: true,
      isScrollControlled: true,
      // Toute la largeur : sans cela la feuille se réduit à son contenu.
      builder: (_) => SizedBox(
        width: double.infinity,
        child: _LocationSheet(city: user.city, commune: user.commune),
      ),
    );
    if (chosen == null || !context.mounted) return;
    final (city, commune) = chosen;
    if (city == user.city && commune == user.commune) return;
    await _save(
      context,
      ref,
      user.copyWith(city: () => city, commune: () => commune),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final participations =
        ref.watch(upcomingParticipationCountProvider).value ?? 0;
    final pendingMatches = ref.watch(pendingMatchCountProvider).value ?? 0;
    final bloodType = user.bloodType?.label;
    final place = [user.city, user.commune]
        .whereType<String>()
        .where((part) => part.isNotEmpty)
        .join(' · ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HeaderCard(user: user),
        const SizedBox(height: 24),
        ProfileMenuSection(
          title: 'MON COMPTE',
          items: [
            ProfileMenuItem(
              icon: Icons.person_outline,
              title: 'Informations personnelles',
              subtitle: 'Nom, téléphone, email',
              onTap: () => _showSheet(
                context,
                _InfoSheet(
                  title: 'Informations personnelles',
                  fields: [
                    ('Nom', user.fullName),
                    ('Téléphone', user.phone ?? ''),
                    ('Email', user.email),
                  ],
                ),
              ),
            ),
            ProfileMenuItem(
              icon: Icons.water_drop_outlined,
              title: 'Groupe sanguin',
              subtitle: bloodType == null
                  ? 'À renseigner dès que vous le connaissez'
                  : '$bloodType · modifiable si vous le découvrez',
              onTap: () => _editBloodType(context, ref),
            ),
            ProfileMenuItem(
              icon: Icons.location_on_outlined,
              title: 'Ville et commune',
              subtitle: place.isEmpty ? 'À renseigner' : place,
              onTap: () => _editLocation(context, ref),
            ),
          ],
        ),
        const SizedBox(height: 24),
        ProfileMenuSection(
          title: 'MON ACTIVITÉ',
          items: [
            ProfileMenuItem(
              icon: Icons.calendar_today_outlined,
              title: 'Mes collectes',
              subtitle: switch (participations) {
                0 => 'Aucune participation à venir',
                1 => '1 participation à venir',
                final n => '$n participations à venir',
              },
              badge: participations,
              onTap: () => context.go(AppRoutes.citizenDonate),
            ),
            ProfileMenuItem(
              icon: Icons.near_me_outlined,
              title: 'Mes mises en relation',
              subtitle: 'Demandes envoyées et reçues',
              badge: pendingMatches,
              onTap: () => context.go(AppRoutes.citizenMatches),
            ),
          ],
        ),
        const SizedBox(height: 24),
        ProfileMenuSection(
          title: 'PARAMÈTRES',
          items: [
            // « Notifications » et « Aide et contact » : masqués en v1,
            // comme sur les profils des centres.
            ProfileMenuItem(
              icon: Icons.lock_outline,
              title: 'Mot de passe et sécurité',
              onTap: () => confirmPasswordReset(context, ref, user.email),
            ),
            ProfileMenuItem(
              icon: Icons.verified_user_outlined,
              title: 'Confidentialité',
              subtitle: 'Données partagées avec les donneurs et centres',
              onTap: () => _showSheet(context, const _PrivacySheet()),
            ),
          ],
        ),
      ],
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.user});

  final AppUser user;

  // « AK » pour Aya Koné : première lettre des deux premiers mots.
  String get _initials => user.fullName
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty)
      .take(2)
      .map((word) => word[0].toUpperCase())
      .join();

  @override
  Widget build(BuildContext context) {
    final phone = user.phone ?? '';
    final commune = user.commune ?? '';

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
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.bleuSurface,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  _initials,
                  style: const TextStyle(
                    color: AppColors.bleu,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.encre,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),
                    if (phone.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        phone,
                        style: const TextStyle(
                          color: AppColors.gris,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _IdentityTile(
                  label: 'Groupe',
                  value: user.bloodType?.label ?? '—',
                  color: AppColors.rouge,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _IdentityTile(
                  label: 'Commune',
                  value: commune.isEmpty ? 'Non renseignée' : commune,
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

class _IdentityTile extends StatelessWidget {
  const _IdentityTile({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
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
            style: const TextStyle(color: AppColors.gris, fontSize: 13),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

const _sheetTitleStyle = TextStyle(
  color: AppColors.encre,
  fontSize: 19,
  fontWeight: FontWeight.w800,
);

ButtonStyle get _sheetButtonStyle => ElevatedButton.styleFrom(
      backgroundColor: AppColors.bleu,
      minimumSize: const Size(double.infinity, 52),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
    );

/// Rubrique en lecture seule.
class _InfoSheet extends StatelessWidget {
  const _InfoSheet({required this.title, required this.fields});

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
            Text(title, style: _sheetTitleStyle),
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

/// Choix du groupe sanguin. Renvoie le groupe retenu à la fermeture.
class _BloodTypeSheet extends StatefulWidget {
  const _BloodTypeSheet({required this.initial});

  final BloodType? initial;

  @override
  State<_BloodTypeSheet> createState() => _BloodTypeSheetState();
}

class _BloodTypeSheetState extends State<_BloodTypeSheet> {
  late BloodType _value = widget.initial ?? BloodType.oPos;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Groupe sanguin', style: _sheetTitleStyle),
            const SizedBox(height: 6),
            const Text(
              'Indiquez le groupe que vous connaissez. Il sera toujours '
              'vérifié en centre agréé avant un don.',
              style: TextStyle(
                color: AppColors.slate,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            BloodTypeGridSelector(
              value: _value,
              onChanged: (v) => setState(() => _value = v),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(_value),
              style: _sheetButtonStyle,
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Choix de la ville et de la commune. Renvoie le couple retenu.
class _LocationSheet extends StatefulWidget {
  const _LocationSheet({required this.city, required this.commune});

  final String? city;
  final String? commune;

  @override
  State<_LocationSheet> createState() => _LocationSheetState();
}

class _LocationSheetState extends State<_LocationSheet> {
  late final CountryInfo _country = AppLocations.countryOfCity(widget.city);
  late String? _city =
      _country.cities.containsKey(widget.city) ? widget.city : null;
  late String? _commune = widget.commune;

  static const _decoration = InputDecoration(
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
  );

  @override
  Widget build(BuildContext context) {
    final communes = _country.cities[_city] ?? const <String>[];
    final commune = communes.contains(_commune) ? _commune : null;
    final city = _city;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          0,
          24,
          24 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Ville et commune', style: _sheetTitleStyle),
            const SizedBox(height: 16),
            LabeledField(
              label: 'Ville',
              child: DropdownButtonFormField<String>(
                initialValue: city,
                isExpanded: true,
                hint: const Text('Ville'),
                decoration: _decoration,
                items: [
                  for (final c in _country.cities.keys)
                    DropdownMenuItem(value: c, child: Text(c)),
                ],
                onChanged: (v) => setState(() {
                  _city = v;
                  _commune = null;
                }),
              ),
            ),
            const SizedBox(height: 12),
            LabeledField(
              label: 'Commune',
              child: DropdownButtonFormField<String>(
                // Reconstruit la liste quand la ville change.
                key: ValueKey(city),
                initialValue: commune,
                isExpanded: true,
                hint: const Text('Commune'),
                decoration: _decoration,
                items: [
                  for (final c in communes)
                    DropdownMenuItem(value: c, child: Text(c)),
                ],
                onChanged: (v) => setState(() => _commune = v),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: city == null || commune == null
                  ? null
                  : () => Navigator.of(context).pop((city, commune)),
              style: _sheetButtonStyle,
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Ce que les autres voient du citoyen, selon les règles du projet.
class _PrivacySheet extends StatelessWidget {
  const _PrivacySheet();

  static const _points = [
    (
      'Dans une recherche de donneurs',
      'Vous apparaissez de façon anonyme : seuls votre groupe sanguin et '
          'votre commune sont visibles.',
    ),
    (
      'Quand vous recevez une demande',
      'Votre nom et votre numéro ne sont communiqués au demandeur que si '
          'vous acceptez.',
    ),
    (
      'Quand vous envoyez une demande',
      'Vous restez anonyme. Votre numéro n’est transmis au donneur que s’il '
          'accepte et si vous avez choisi de le partager.',
    ),
    (
      'Aucune donnée médicale',
      'L’application ne conserve aucun dossier médical. Votre aptitude au '
          'don est vérifiée uniquement en centre agréé.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Confidentialité', style: _sheetTitleStyle),
            for (final (title, body) in _points)
              Padding(
                padding: const EdgeInsets.only(top: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.encre,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      body,
                      style: const TextStyle(
                        color: AppColors.slate,
                        fontSize: 14,
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
