import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_enums.dart';
import '../../../../core/constants/app_locations.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../shared/domain/entities/donor_search_criteria.dart';
import '../../../auth/presentation/widgets/register_form_fields.dart';
import '../providers/hc_providers.dart';
import '../widgets/blood_request_form_fields.dart';
import '../widgets/hc_role_badge.dart';
import '../widgets/selectable_pill.dart';

// Onglet « Donneurs » — Chercher un donneur.
// Le centre de santé définit groupe, zone, urgence et nombre de donneurs.
// Code couleur bleu : on cherche des personnes, pas du sang disponible.
class HcDonorSearchScreen extends ConsumerStatefulWidget {
  const HcDonorSearchScreen({super.key});

  @override
  ConsumerState<HcDonorSearchScreen> createState() =>
      _HcDonorSearchScreenState();
}

class _HcDonorSearchScreenState extends ConsumerState<HcDonorSearchScreen> {
  static const _defaultDonorCount = 3;
  static const _maxDonorCount = 10;

  BloodType _bloodType = BloodType.oPos;
  // null = ville du centre connecté (par défaut).
  String? _city;
  // null = commune du centre connecté (par défaut).
  Set<String>? _communes;
  Priority _priority = Priority.normal;
  int _donorCount = _defaultDonorCount;

  CountryInfo _countryOf(String? city) => AppLocations.countries.firstWhere(
        (c) => c.cities.containsKey(city),
        orElse: () => AppLocations.countries.first,
      );

  // « D’ABIDJAN », « DE BOUAKÉ ».
  static String _communesTitle(String city) {
    final elided = RegExp(r'^[AEIOUÉÈÊH]', caseSensitive: false).hasMatch(city);
    return 'COMMUNES ${elided ? 'D’' : 'DE '}${city.toUpperCase()}';
  }

  @override
  Widget build(BuildContext context) {
    final healthCenter = ref.watch(currentHealthCenterProvider).value;
    final country = _countryOf(_city ?? healthCenter?.city);
    final homeCity = healthCenter?.city;
    final city = _city ??
        (country.cities.containsKey(homeCity)
            ? homeCity!
            : country.cities.keys.first);
    final communes = country.cities[city] ?? const <String>[];
    final selected = _communes ??
        {
          if (healthCenter != null &&
              healthCenter.city == city &&
              communes.contains(healthCenter.commune))
            healthCenter.commune,
        };
    final allSelected =
        communes.isNotEmpty && selected.containsAll(communes);

    final criteria = DonorSearchCriteria(
      bloodType: _bloodType,
      city: city,
      // Ordre du référentiel, indépendant de l'ordre des clics.
      communes: communes.where(selected.contains).toList(),
      priority: _priority,
      donorCount: _donorCount,
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
                    onPressed: () => context.go(AppRoutes.hcHome),
                  ),
                  const Spacer(),
                  const HcRoleBadge(),
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
              const SizedBox(height: 16),
              _RequesterNotice(
                centerName: healthCenter?.name ?? 'votre centre de santé',
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
              const SectionTitle('VILLES'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final c in country.cities.keys)
                    SelectablePill(
                      label: c,
                      selected: c == city,
                      onTap: () => setState(() {
                        if (c == city) return;
                        _city = c;
                        _communes = {};
                      }),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              SectionTitle(_communesTitle(city)),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      switch (selected.length) {
                        0 => 'Aucune commune sélectionnée',
                        1 => '1 commune sélectionnée',
                        final n => '$n communes sélectionnées',
                      },
                      style: const TextStyle(
                        color: AppColors.slate,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => setState(
                      () => _communes = allSelected ? {} : communes.toSet(),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.bleu,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      textStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    child: Text(
                      allSelected ? 'Tout désélectionner' : 'Tout sélectionner',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final c in communes)
                    SelectablePill(
                      label: c,
                      selected: selected.contains(c),
                      onTap: () => setState(() {
                        final next = Set.of(selected);
                        if (!next.remove(c)) next.add(c);
                        _communes = next;
                      }),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              const SectionTitle('NIVEAU D’URGENCE'),
              const SizedBox(height: 12),
              PrioritySelector(
                value: _priority,
                accent: AppColors.bleu,
                onChanged: (v) => setState(() => _priority = v),
              ),
              const SizedBox(height: 24),
              const SectionTitle('NOMBRE DE DONNEURS SOUHAITÉS'),
              const SizedBox(height: 12),
              LabeledField(
                label: 'Donneurs à contacter',
                child: QuantityStepper(
                  value: _donorCount,
                  max: _maxDonorCount,
                  unit: 'donneur',
                  onChanged: (v) => setState(() => _donorCount = v),
                ),
              ),
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
                          AppRoutes.hcDonorResultsPath(criteria),
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

// Transparence envers les donneurs : ils voient qui les sollicite.
class _RequesterNotice extends StatelessWidget {
  const _RequesterNotice({required this.centerName});

  final String centerName;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.ligne.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.verified_user_outlined,
            color: AppColors.encre,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recherche au nom de $centerName',
                  style: const TextStyle(
                    color: AppColors.encre,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Les donneurs verront que la demande provient d’un centre '
                  'de santé.',
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
