import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_enums.dart';
import '../../../core/constants/app_locations.dart';
import '../../../features/auth/presentation/widgets/register_form_fields.dart';
import '../../domain/entities/blood_availability.dart';
import '../providers/blood_availability_providers.dart';
import 'blood_availability_card.dart';

/// Construit l'action propre à l'espace pour un centre. [showWholeCity]
/// élargit la recherche à toute la ville et remonte en haut de la liste.
typedef AvailabilityActionBuilder = Widget Function(
  BuildContext context,
  BloodAvailability availability,
  VoidCallback showWholeCity,
);

/// Consultation de la disponibilité du sang : filtres (groupe, ville,
/// commune) et liste temps réel des centres de transfusion vérifiés.
/// Partagé par le citoyen (lecture seule) et le centre de santé (demande).
class BloodAvailabilityExplorer extends ConsumerStatefulWidget {
  const BloodAvailabilityExplorer({
    super.key,
    required this.homeCity,
    required this.waitingHomeCity,
    required this.onViewCenter,
    required this.actionBuilder,
    this.notice,
  });

  /// Ville par défaut : celle du compte connecté.
  final String? homeCity;

  /// true tant que [homeCity] charge : la recherche attend pour ne pas
  /// partir sur une ville provisoire.
  final bool waitingHomeCity;

  /// Reçoit le centre et le groupe recherché.
  final void Function(BloodAvailability availability) onViewCenter;
  final AvailabilityActionBuilder actionBuilder;

  /// Encart affiché entre les filtres et les résultats.
  final Widget? notice;

  @override
  ConsumerState<BloodAvailabilityExplorer> createState() =>
      _BloodAvailabilityExplorerState();
}

class _BloodAvailabilityExplorerState
    extends ConsumerState<BloodAvailabilityExplorer> {
  BloodType _bloodType = BloodType.oPos;
  // null = ville du compte connecté (par défaut).
  String? _city;
  // null = toutes les communes.
  String? _commune;

  void _showWholeCity() {
    setState(() => _commune = null);
    Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final homeCity = widget.homeCity;
    final country = AppLocations.countryOfCity(_city ?? homeCity);
    final city = _city ??
        (country.cities.containsKey(homeCity)
            ? homeCity!
            : country.cities.keys.first);
    final communes = country.cities[city] ?? const <String>[];
    final notice = widget.notice;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle('GROUPE SANGUIN'),
        const SizedBox(height: 12),
        Row(
          children: [
            for (final type in BloodType.displayOrder)
              Expanded(
                child: _BloodTypeChip(
                  bloodType: type,
                  selected: type == _bloodType,
                  onTap: () => setState(() => _bloodType = type),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: LabeledField(
                label: 'Ville',
                child: DropdownButtonFormField<String>(
                  // La valeur par défaut arrive après le 1er build.
                  key: ValueKey(city),
                  initialValue: city,
                  isExpanded: true,
                  decoration: _dropdownDecoration,
                  items: [
                    for (final c in country.cities.keys)
                      DropdownMenuItem(
                        value: c,
                        child: Text(c, overflow: TextOverflow.ellipsis),
                      ),
                  ],
                  onChanged: (v) => setState(() {
                    _city = v;
                    _commune = null;
                  }),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: LabeledField(
                label: 'Commune',
                child: DropdownButtonFormField<String?>(
                  key: ValueKey('$city/$_commune'),
                  initialValue: _commune,
                  isExpanded: true,
                  decoration: _dropdownDecoration,
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text(
                        'Toutes les communes',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    for (final c in communes)
                      DropdownMenuItem<String?>(
                        value: c,
                        child: Text(c, overflow: TextOverflow.ellipsis),
                      ),
                  ],
                  onChanged: (v) => setState(() => _commune = v),
                ),
              ),
            ),
          ],
        ),
        if (notice != null) ...[
          const SizedBox(height: 16),
          notice,
        ],
        const SizedBox(height: 20),
        if (_city == null && widget.waitingHomeCity)
          const _Loading()
        else
          _Results(
            bloodType: _bloodType,
            city: city,
            commune: _commune,
            onViewCenter: widget.onViewCenter,
            actionBuilder: widget.actionBuilder,
            onShowWholeCity: _showWholeCity,
          ),
      ],
    );
  }

  static const _dropdownDecoration = InputDecoration(
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
  );
}

class _BloodTypeChip extends StatelessWidget {
  const _BloodTypeChip({
    required this.bloodType,
    required this.selected,
    required this.onTap,
  });

  final BloodType bloodType;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 52),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: AspectRatio(
            aspectRatio: 1,
            child: Material(
              color: selected ? AppColors.rouge : Colors.white,
              shape: CircleBorder(
                side: BorderSide(
                  color: selected ? AppColors.rouge : AppColors.ligne,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onTap,
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        bloodType.label,
                        style: TextStyle(
                          color: selected ? Colors.white : AppColors.encre,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Results extends ConsumerWidget {
  const _Results({
    required this.bloodType,
    required this.city,
    required this.commune,
    required this.onViewCenter,
    required this.actionBuilder,
    required this.onShowWholeCity,
  });

  final BloodType bloodType;
  final String city;
  final String? commune;
  final void Function(BloodAvailability availability) onViewCenter;
  final AvailabilityActionBuilder actionBuilder;
  final VoidCallback onShowWholeCity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final availabilities = ref.watch(
      bloodAvailabilitiesProvider(
        bloodType: bloodType,
        city: city,
        commune: commune,
      ),
    );

    return availabilities.when(
      // Une mise à jour de stock ne doit pas faire clignoter la liste.
      skipLoadingOnReload: true,
      loading: () => const _Loading(),
      error: (_, _) => _Message(
        icon: Icons.cloud_off_outlined,
        title: 'Chargement impossible',
        body: 'Vérifiez votre connexion puis réessayez.',
        actionLabel: 'Réessayer',
        onAction: () {
          ref.invalidate(verifiedBloodCentersProvider);
          ref.invalidate(availableBloodLotsProvider);
        },
      ),
      data: (items) {
        final zone = commune ?? city;
        if (items.isEmpty) {
          return _Message(
            icon: Icons.search_off_outlined,
            title: 'Aucun centre de transfusion',
            body: 'Aucun centre vérifié n’est référencé à $zone.',
            actionLabel: commune == null ? null : 'Voir toute la ville',
            onAction: commune == null ? null : onShowWholeCity,
          );
        }
        final count = items.length;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$count centre${count > 1 ? 's' : ''} de transfusion'
              ' · ${bloodType.label} · $zone',
              style: const TextStyle(
                color: AppColors.encre,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            for (final item in items) ...[
              BloodAvailabilityCard(
                availability: item,
                onViewCenter: () => onViewCenter(item),
                action: actionBuilder(context, item, onShowWholeCity),
              ),
              const SizedBox(height: 12),
            ],
          ],
        );
      },
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: CircularProgressIndicator(color: AppColors.rouge),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({
    required this.icon,
    required this.title,
    required this.body,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String body;
  final String? actionLabel;
  final VoidCallback? onAction;

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
          if (actionLabel != null) ...[
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: onAction,
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.encre,
                minimumSize: const Size(0, 44),
                side: const BorderSide(color: AppColors.ligne),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}
