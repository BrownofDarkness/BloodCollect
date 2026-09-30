import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_enums.dart';
import '../../../../shared/presentation/widgets/blood_type_chip.dart';
import '../../../../shared/presentation/widgets/person_badge.dart';
import '../../../../shared/presentation/widgets/urgency_selector.dart';
import '../providers/donor_providers.dart';
import 'donor_results_screen.dart';

const _villes = ['Abidjan', 'Bouaké', 'Yamoussoukro', 'San-Pédro', 'Daloa', 'Korhogo'];
const _communesAbidjan = [
  'Treichville', 'Marcory', 'Koumassi', 'Plateau', 'Cocody',
  'Yopougon', 'Abobo', 'Adjamé', 'Port-Bouët', 'Attécoubé',
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
        title: const PersonBadge(label: 'Personne'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Chercher un donneur',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            const Text('Trouvez des personnes susceptibles de donner leur sang.',
                style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 24),

            const _SectionLabel('GROUPE SANGUIN RECHERCHÉ'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: BloodType.values
                  .map((t) => BloodTypeChip(
                        type: t,
                        selected: filters.bloodType == t,
                        onTap: () => notifier.setBloodType(t),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 24),

            const _SectionLabel('VILLES'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _villes
                  .map((v) => ChoiceChip(
                        label: Text(v),
                        selected: v == filters.city,
                        onSelected: (_) {}, // Abidjan uniquement pour le MVP démo
                        selectedColor: AppColors.bleuLight,
                        labelStyle: TextStyle(
                          color: v == filters.city ? AppColors.bleu : AppColors.encre,
                          fontWeight: FontWeight.w600,
                        ),
                        side: BorderSide(
                          color: v == filters.city ? AppColors.bleu : AppColors.ligne,
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const _SectionLabel('COMMUNES D\'ABIDJAN'),
                TextButton(
                  onPressed: () => notifier.selectAllCommunes(_communesAbidjan),
                  child: const Text('Tout sélectionner'),
                ),
              ],
            ),
            Text('${filters.communes.length} commune(s) sélectionnée(s)',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _communesAbidjan.map((c) {
                final selected = filters.communes.contains(c);
                return FilterChip(
                  label: Text(c),
                  selected: selected,
                  onSelected: (_) => notifier.toggleCommune(c),
                  showCheckmark: true,
                  selectedColor: AppColors.bleuLight,
                  checkmarkColor: AppColors.bleu,
                  labelStyle: TextStyle(
                    color: selected ? AppColors.bleu : AppColors.encre,
                    fontWeight: FontWeight.w600,
                  ),
                  side: BorderSide(color: selected ? AppColors.bleu : AppColors.ligne),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            const _SectionLabel('NIVEAU D\'URGENCE'),
            const SizedBox(height: 10),
            UrgencySelector(value: filters.priority, onChanged: notifier.setPriority),
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.bleuLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.bleu, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Vous cherchez une personne, pas du sang. Le don se fait toujours dans '
                      'un centre de transfusion agréé, après vérification de l\'éligibilité.',
                      style: TextStyle(fontSize: 13),
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
                    ? () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => DonorResultsScreen(filters: filters),
                          ),
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
