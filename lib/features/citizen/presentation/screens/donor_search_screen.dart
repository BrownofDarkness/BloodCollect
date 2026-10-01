import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../widgets/back_control.dart';
import '../../../../core/constants/app_enums.dart';
import '../../../../shared/presentation/widgets/blood_type_chip.dart';
import '../../../../shared/presentation/widgets/person_badge.dart';
import '../../../../shared/presentation/widgets/urgency_selector.dart';
import '../providers/donor_providers.dart';

const _villes = [
  'Abidjan',
  'Bouaké',
  'Yamoussoukro',
  'San-Pédro',
  'Daloa',
  'Korhogo',
];
const _communesAbidjan = [
  'Treichville',
  'Marcory',
  'Koumassi',
  'Plateau',
  'Cocody',
  'Yopougon',
  'Abobo',
  'Adjamé',
  'Port-Bouët',
  'Attécoubé',
];

/// Écran 2 — "Chercher un donneur". Formulaire pur, pas d'appel réseau :
/// la recherche ne se déclenche qu'à la soumission (écran suivant).
class DonorSearchScreen extends ConsumerWidget {
  const DonorSearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(donorSearchFiltersProvider);
    final notifier = ref.read(donorSearchFiltersProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.ivoire,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: BackControl(onBack: () => context.go(AppRoutes.citizenHome)),
        title: const PersonBadge(label: 'Personne'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chercher un donneur',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            const Text(
              'Trouvez des personnes susceptibles de donner leur sang.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),

            const _SectionLabel('GROUPE SANGUIN RECHERCHÉ'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: BloodType.values
                  .map(
                    (t) => BloodTypeChip(
                      type: t,
                      selected: filters.bloodType == t,
                      onTap: () => notifier.setBloodType(t),
                      accent: AppColors.bleu,
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 24),

            const _SectionLabel('VILLES'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _villes
                  .map(
                    (v) => _CommuneChip(
                      label: v,
                      selected: v == filters.city,
                      // Les communes listées ne couvrent qu'Abidjan : changer
                      // de ville sans liste associée renverrait une recherche
                      // vide sans explication.
                      onTap: () {},
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const _SectionLabel('COMMUNES D\'ABIDJAN'),
                TextButton(
                  onPressed: () => notifier.selectAllCommunes(_communesAbidjan),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.bleu,
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 32),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Tout sélectionner',
                    style: TextStyle(
                      color: AppColors.bleu,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              _selectionLabel(filters.communes.length),
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _communesAbidjan.map((c) {
                final selected = filters.communes.contains(c);
                return _CommuneChip(
                  label: c,
                  selected: selected,
                  onTap: () => notifier.toggleCommune(c),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            const _SectionLabel('NIVEAU D\'URGENCE'),
            const SizedBox(height: 10),
            UrgencySelector(
              value: filters.priority,
              onChanged: notifier.setPriority,
            ),
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.bleuLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: AppColors.bleu, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Vous cherchez une personne, pas du sang.',
                          style: TextStyle(
                            color: AppColors.bleu,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          "Le don se fait toujours dans un centre de "
                          "transfusion agréé, après vérification de "
                          "l'éligibilité.",
                          style: TextStyle(
                            color: AppColors.bleu,
                            fontSize: 13,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: filters.isValid
                    ? () => context.push(
                        AppRoutes.citizenDonorsResults,
                        extra: filters,
                      )
                    : null,
                icon: const Icon(Icons.search),
                label: const Text('Rechercher des donneurs'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppColors.textSecondary,
        letterSpacing: 0.4,
      ),
    );
  }
}

/// « 0 commune sélectionnée », « 1 commune sélectionnée », « 2 communes
/// sélectionnées ». L'accord en nombre se lit sur un compteur.
String _selectionLabel(int count) => switch (count) {
  0 => 'Aucune commune sélectionnée',
  1 => '1 commune sélectionnée',
  _ => '$count communes sélectionnées',
};

/// Pastille de commune : capsule arrondie, coche quand elle est retenue.
class _CommuneChip extends StatelessWidget {
  const _CommuneChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkResponse(
        onTap: onTap,
        radius: 24,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.bleuLight : AppColors.surface,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? AppColors.bleu : AppColors.ligne,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selected) ...[
                const Icon(Icons.check, size: 15, color: AppColors.bleu),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  color: selected ? AppColors.bleu : AppColors.encre,
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
