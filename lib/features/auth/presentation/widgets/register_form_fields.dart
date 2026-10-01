import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_locations.dart';
import '../../../../core/utils/validators.dart';

// Champs de formulaire partagés des 3 inscriptions (citoyen, centre de santé, centre de transfusion).
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.gris,
        fontSize: 13,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
    );
  }
}

class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.encre,
        fontSize: 15,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class LabeledField extends StatelessWidget {
  const LabeledField({super.key, required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(label),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

/// Téléphone : sélecteur d'indicatif pays + numéro local.
/// Partage le même pays que [LocationSelector] (sélection synchronisée).
class PhoneField extends StatelessWidget {
  const PhoneField({
    super.key,
    required this.controller,
    required this.country,
    required this.onCountryChanged,
  });

  final TextEditingController controller;
  final CountryInfo country;
  final ValueChanged<CountryInfo> onCountryChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: AppColors.ligne.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.ligne),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: country.dialCode,
              items: AppLocations.countries
                  .map(
                    (c) => DropdownMenuItem(
                      value: c.dialCode,
                      child: Text(
                        c.dialCode,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (d) => onCountryChanged(
                AppLocations.countries.firstWhere(
                  (c) => c.dialCode == d,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextFormField(
            controller: controller,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              hintText: '07 00 00 00 00',
            ),
            validator: Validators.phone,
          ),
        ),
      ],
    );
  }
}

/// Triple Pays / Ville / Commune : la ville impose ses communes.
class LocationSelector extends StatelessWidget {
  const LocationSelector({
    super.key,
    required this.country,
    required this.city,
    required this.commune,
    required this.onCountryChanged,
    required this.onCityChanged,
    required this.onCommuneChanged,
    this.helper,
  });

  final CountryInfo country;
  final String? city;
  final String? commune;
  final ValueChanged<CountryInfo> onCountryChanged;
  final ValueChanged<String?> onCityChanged;
  final ValueChanged<String?> onCommuneChanged;
  final String? helper;

  List<String> get cities => country.cities.keys.toList();
  List<String> get communes =>
      city == null ? [] : country.cities[city] ?? [];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabeledField(
          label: 'Pays',
          child: DropdownButtonFormField<String>(
            initialValue: country.name,
            isExpanded: true,
            decoration: const InputDecoration(
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            ),
            items: AppLocations.countries
                .map(
                  (c) => DropdownMenuItem(
                    value: c.name,
                    child: Text(
                      '${c.name} (${c.dialCode})',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            onChanged: (v) => onCountryChanged(
              AppLocations.countries.firstWhere((c) => c.name == v),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: LabeledField(
                label: 'Ville',
                child: DropdownButtonFormField<String>(
                  initialValue: city,
                  isExpanded: true,
                  hint: const Text('Ville'),
                  decoration: const InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  ),
                  items: cities
                      .map(
                        (c) => DropdownMenuItem(
                          value: c,
                          child: Text(
                            c,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: onCityChanged,
                  validator: (v) =>
                      v == null ? 'Sélectionnez une ville.' : null,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: LabeledField(
                label: 'Commune',
                child: DropdownButtonFormField<String>(
                  initialValue: commune,
                  isExpanded: true,
                  hint: const Text('Commune'),
                  decoration: const InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  ),
                  items: communes
                      .map(
                        (c) => DropdownMenuItem(
                          value: c,
                          child: Text(
                            c,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: onCommuneChanged,
                  validator: (v) =>
                      v == null ? 'Sélectionnez une commune.' : null,
                ),
              ),
            ),
          ],
        ),
        if (helper != null) ...[
          const SizedBox(height: 8),
          Text(
            helper!,
            style: const TextStyle(color: AppColors.gris, fontSize: 14),
          ),
        ],
      ],
    );
  }
}
