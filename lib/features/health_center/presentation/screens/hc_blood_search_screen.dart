import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_enums.dart';
import '../../../../core/constants/app_locations.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../shared/domain/entities/blood_availability.dart';
import '../../../auth/presentation/widgets/register_form_fields.dart';
import '../providers/hc_providers.dart';
import '../widgets/blood_availability_card.dart';
import '../widgets/hc_role_badge.dart';

// Onglet « Sang » — Trouver du sang disponible.
// Le centre de santé choisit un groupe et une zone : la liste affiche le
// statut déclaré de chaque centre de transfusion vérifié, sans quantités.
class HcBloodSearchScreen extends ConsumerStatefulWidget {
  const HcBloodSearchScreen({super.key});

  @override
  ConsumerState<HcBloodSearchScreen> createState() =>
      _HcBloodSearchScreenState();
}

class _HcBloodSearchScreenState extends ConsumerState<HcBloodSearchScreen> {
  final _scrollController = ScrollController();

  BloodType _bloodType = BloodType.oPos;
  // null = ville du centre connecté (par défaut).
  String? _city;
  // null = toutes les communes.
  String? _commune;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  CountryInfo _countryOf(String? city) => AppLocations.countries.firstWhere(
        (c) => c.cities.containsKey(city),
        orElse: () => AppLocations.countries.first,
      );

  void _showOtherCenters() {
    setState(() => _commune = null);
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _requestFrom(BloodAvailability availability) {
    context.go(
      AppRoutes.hcRequestNewPath(
        bloodCenterId: availability.center.id,
        bloodType: availability.bloodType,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final healthCenterAsync = ref.watch(currentHealthCenterProvider);
    final homeCity = healthCenterAsync.value?.city;
    final country = _countryOf(_city ?? homeCity);
    final city = _city ??
        (country.cities.containsKey(homeCity)
            ? homeCity!
            : country.cities.keys.first);
    final communes = country.cities[city] ?? const <String>[];
    // Tant que la fiche du centre charge, la ville par défaut est inconnue.
    final waitingHomeCity = _city == null && healthCenterAsync.isLoading;

    return Scaffold(
      backgroundColor: AppColors.ivoire,
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
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
                'Trouver du sang\ndisponible',
                style: TextStyle(
                  color: AppColors.encre,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 20),
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
                        items: country.cities.keys
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
                              child: Text(
                                c,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                        onChanged: (v) => setState(() => _commune = v),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (waitingHomeCity)
                const _Loading()
              else
                _Results(
                  bloodType: _bloodType,
                  city: city,
                  commune: _commune,
                  onRequest: _requestFrom,
                  onOtherCenters: _showOtherCenters,
                ),
            ],
          ),
        ),
      ),
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
    required this.onRequest,
    required this.onOtherCenters,
  });

  final BloodType bloodType;
  final String city;
  final String? commune;
  final ValueChanged<BloodAvailability> onRequest;
  final VoidCallback onOtherCenters;

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
            onAction: commune == null ? null : onOtherCenters,
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
                onViewCenter: () => context.go(
                  AppRoutes.hcBloodCenterPath(
                    item.center.id,
                    bloodType: bloodType,
                  ),
                ),
                onRequest: () => onRequest(item),
                onOtherCenters: onOtherCenters,
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
