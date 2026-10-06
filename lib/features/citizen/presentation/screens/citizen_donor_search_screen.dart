import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_enums.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../shared/domain/entities/donor_search_criteria.dart';
import '../../../../shared/presentation/widgets/donor_zone_selector.dart';
import '../../../../shared/presentation/widgets/person_badge.dart';
import '../../../../shared/presentation/widgets/request_form_fields.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../auth/presentation/widgets/register_form_fields.dart';

// Onglet « Donneurs » — Chercher un donneur.
// Le citoyen choisit un groupe, une zone et un niveau d'urgence.
// Code couleur bleu : on cherche une personne, pas du sang disponible.
class CitizenDonorSearchScreen extends ConsumerStatefulWidget {
  const CitizenDonorSearchScreen({super.key});

  @override
  ConsumerState<CitizenDonorSearchScreen> createState() =>
      _CitizenDonorSearchScreenState();
}

class _CitizenDonorSearchScreenState
    extends ConsumerState<CitizenDonorSearchScreen> {
  BloodType _bloodType = BloodType.oPos;
  // null = ville du citoyen connecté (par défaut).
  String? _city;
  // null = commune du citoyen connecté (par défaut).
  Set<String>? _communes;
  Priority _priority = Priority.normal;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentAppUserProvider).value;
    final zone = DonorZone.resolve(
      city: _city,
      selected: _communes,
      homeCity: user?.city,
      homeCommune: user?.commune,
    );

    final criteria = DonorSearchCriteria(
      bloodType: _bloodType,
      city: zone.city,
      communes: zone.selectedInOrder,
      priority: _priority,
    );

    return Scaffold(
      backgroundColor: AppColors.ivoire,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AppBackButton(
                    onPressed: () => context.go(AppRoutes.citizenHome),
                  ),
                  const Spacer(),
                  const PersonBadge(
                    label: 'Personne',
                    icon: Icons.person_outline,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Chercher un donneur',
                style: TextStyle(
                  color: AppColors.encre,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Trouvez des personnes susceptibles de donner leur sang.',
                style: TextStyle(color: AppColors.gris, fontSize: 15),
              ),
              const SizedBox(height: 24),
              const SectionTitle('GROUPE SANGUIN RECHERCHÉ'),
              const SizedBox(height: 12),
              BloodTypeGridSelector(
                value: _bloodType,
                accent: AppColors.bleu,
                onChanged: (v) => setState(() => _bloodType = v),
              ),
              const SizedBox(height: 24),
              DonorZoneSelector(
                zone: zone,
                onCityChanged: (city) => setState(() {
                  _city = city;
                  _communes = {};
                }),
                onCommunesChanged: (communes) =>
                    setState(() => _communes = communes),
              ),
              const SizedBox(height: 24),
              const SectionTitle('NIVEAU D’URGENCE'),
              const SizedBox(height: 12),
              PrioritySelector(
                value: _priority,
                accent: AppColors.bleu,
                onChanged: (v) => setState(() => _priority = v),
              ),
              const SizedBox(height: 20),
              const _PersonNotBloodNotice(),
              if (!criteria.isValid) ...[
                const SizedBox(height: 12),
                const Text(
                  'Sélectionnez au moins une commune.',
                  style: TextStyle(color: AppColors.rouge, fontSize: 13),
                ),
              ],
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: criteria.isValid
                    ? () => context.push(
                          AppRoutes.citizenDonorResultsPath(criteria),
                        )
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.bleu,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                icon: const Icon(Icons.search, size: 22),
                label: const Text('Rechercher des donneurs'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Règle fondamentale du projet : un donneur n'est pas du sang disponible.
class _PersonNotBloodNotice extends StatelessWidget {
  const _PersonNotBloodNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bleuSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: AppColors.bleu, size: 22),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vous cherchez une personne, pas du sang.',
                  style: TextStyle(
                    color: AppColors.bleu,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Le don se fait toujours dans un centre de transfusion '
                  'agréé, après vérification de l’éligibilité.',
                  style: TextStyle(
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
    );
  }
}
