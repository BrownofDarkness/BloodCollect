import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_locations.dart';
import '../../../features/auth/presentation/widgets/register_form_fields.dart';
import 'selectable_pill.dart';

/// Zone de recherche de donneurs : une ville et une ou plusieurs de ses
/// communes. Tant que l'utilisateur n'a rien choisi, la zone est celle de
/// son domicile (ou de son établissement).
class DonorZone {
  const DonorZone._({
    required this.cities,
    required this.city,
    required this.communes,
    required this.selected,
  });

  /// [city] et [selected] : choix explicites, null tant qu'ils valent le
  /// domicile. [homeCity] / [homeCommune] : valeurs par défaut.
  factory DonorZone.resolve({
    String? city,
    Set<String>? selected,
    String? homeCity,
    String? homeCommune,
  }) {
    final country = AppLocations.countryOfCity(city ?? homeCity);
    final resolvedCity = city ??
        (country.cities.containsKey(homeCity)
            ? homeCity!
            : country.cities.keys.first);
    final communes = country.cities[resolvedCity] ?? const <String>[];

    return DonorZone._(
      cities: country.cities.keys.toList(),
      city: resolvedCity,
      communes: communes,
      selected: selected ??
          {
            if (homeCity == resolvedCity && communes.contains(homeCommune))
              homeCommune!,
          },
    );
  }

  /// Villes du pays de la zone.
  final List<String> cities;
  final String city;

  /// Communes de [city], dans l'ordre du référentiel.
  final List<String> communes;
  final Set<String> selected;

  bool get allSelected =>
      communes.isNotEmpty && selected.containsAll(communes);

  /// Communes choisies, dans l'ordre du référentiel et non celui des clics.
  List<String> get selectedInOrder =>
      communes.where(selected.contains).toList();
}

/// Sections « VILLES » et « COMMUNES DE … » d'un formulaire de recherche.
class DonorZoneSelector extends StatelessWidget {
  const DonorZoneSelector({
    super.key,
    required this.zone,
    required this.onCityChanged,
    required this.onCommunesChanged,
  });

  final DonorZone zone;

  /// Appelé avec une ville différente de la ville courante.
  final ValueChanged<String> onCityChanged;
  final ValueChanged<Set<String>> onCommunesChanged;

  // « D’ABIDJAN », « DE BOUAKÉ ».
  static String _communesTitle(String city) {
    final elided = RegExp(r'^[AEIOUÉÈÊH]', caseSensitive: false).hasMatch(city);
    return 'COMMUNES ${elided ? 'D’' : 'DE '}${city.toUpperCase()}';
  }

  @override
  Widget build(BuildContext context) {
    final selected = zone.selected;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle('VILLES'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final city in zone.cities)
              SelectablePill(
                label: city,
                selected: city == zone.city,
                onTap: () {
                  if (city != zone.city) onCityChanged(city);
                },
              ),
          ],
        ),
        const SizedBox(height: 24),
        SectionTitle(_communesTitle(zone.city)),
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
                style: const TextStyle(color: AppColors.slate, fontSize: 14),
              ),
            ),
            TextButton(
              onPressed: () => onCommunesChanged(
                zone.allSelected ? {} : zone.communes.toSet(),
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
                zone.allSelected ? 'Tout désélectionner' : 'Tout sélectionner',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final commune in zone.communes)
              SelectablePill(
                label: commune,
                selected: selected.contains(commune),
                onTap: () {
                  final next = Set.of(selected);
                  if (!next.remove(commune)) next.add(commune);
                  onCommunesChanged(next);
                },
              ),
          ],
        ),
      ],
    );
  }
}
