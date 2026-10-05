import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_enums.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/date_utils.dart';
import '../../domain/models/center_blood_availability.dart';
import '../../domain/usecases/get_blood_availability_usecase.dart';
import '../providers/citizen_filters_providers.dart';
import '../providers/citizen_providers.dart';
import '../widgets/blood_center_card.dart';
import '../widgets/blood_status_widgets.dart';
import '../widgets/citizen_scaffold_parts.dart';

/// Onglet « Sang » — lecture seule de la disponibilité déclarée par les
/// centres de transfusion agréés.
///
/// Un citoyen ne demande pas de sang : seul un centre de santé le peut. Cet
/// écran se contente d'afficher ce qui est réellement disponible, et où.
class BloodAvailabilityScreen extends ConsumerWidget {
  const BloodAvailabilityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterAsync = ref.watch(bloodAvailabilityFilterProvider);

    return Scaffold(
      backgroundColor: AppColors.ivoire,
      body: SafeArea(
        bottom: false,
        child: filterAsync.when(
          loading: () => const _ScreenSkeleton(),
          error: (error, _) => _FilterError(
            onRetry: () => ref.invalidate(bloodAvailabilityFilterProvider),
          ),
          data: (filter) => _BloodAvailabilityBody(filter: filter),
        ),
      ),
    );
  }
}

class _BloodAvailabilityBody extends ConsumerWidget {
  const _BloodAvailabilityBody({required this.filter});

  final BloodAvailabilityFilter filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(
      bloodAvailabilityListProvider(filter, BloodAvailabilitySort.distance),
    );

    return RefreshIndicator(
      color: AppColors.rouge,
      onRefresh: () async => ref.invalidate(
        bloodAvailabilityListProvider(filter, BloodAvailabilitySort.distance),
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          CitizenScreenHeader(
            contextLabel: 'Sang $middleDot Centres agréés',
            contextIcon: Icons.water_drop_outlined,
            tone: ContextTone.blood,
            onBack: () => context.go(AppRoutes.citizenHome),
          ),
          const SizedBox(height: 18),
          const CitizenPageTitle('Disponibilité du sang'),
          const SizedBox(height: 24),

          const CitizenLabelCaps('Groupe sanguin'),
          const SizedBox(height: 10),
          BloodTypeFilterRow(
            selected: filter.bloodType,
            onSelected: ref
                .read(bloodAvailabilityFilterProvider.notifier)
                .selectBloodType,
          ),
          const SizedBox(height: 18),

          const _LocationFilters(),
          const SizedBox(height: 20),

          const CitizenInfoBanner(
            title: 'Consultation uniquement',
            message:
                "Pour obtenir du sang, rapprochez-vous d'un centre de santé : "
                "c'est lui qui transmet la demande au centre de transfusion.",
          ),
          const SizedBox(height: 20),

          entriesAsync.when(
            loading: () => const _ResultsPlaceholder(),
            error: (error, _) => const _ResultsError(),
            data: (entries) => _Results(entries: entries, filter: filter),
          ),
        ],
      ),
    );
  }
}

class _Results extends StatelessWidget {
  const _Results({required this.entries, required this.filter});

  final List<CenterBloodAvailability> entries;
  final BloodAvailabilityFilter filter;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CitizenSectionTitle(
            bloodResultCountLabel(entries.length, filter: filter),
          ),
          const SizedBox(height: 16),
          const _EmptyResults(),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CitizenSectionTitle(
          bloodResultCountLabel(entries.length, filter: filter),
        ),
        const SizedBox(height: 16),
        for (final entry in entries) ...[
          _CenterCard(entry: entry, bloodType: filter.bloodType),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _CenterCard extends StatelessWidget {
  const _CenterCard({required this.entry, required this.bloodType});

  final CenterBloodAvailability entry;
  final BloodType? bloodType;

  @override
  Widget build(BuildContext context) {
    return BloodCenterAvailabilityCard(
      entry: entry,
      bloodType: bloodType,
      onOpen: () => context.go('${AppRoutes.citizenBlood}/${entry.center.id}'),
      // Ouverture du carnet d'appels : pas de dépendance à ce stade.
      onCall: () {},
    );
  }
}

/// Sélecteurs Ville et Commune, côte à côte.
class _LocationFilters extends ConsumerWidget {
  const _LocationFilters();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(bloodAvailabilityFilterProvider).asData?.value;
    if (filter == null) return const SizedBox.shrink();

    final notifier = ref.read(bloodAvailabilityFilterProvider.notifier);
    final cities = ref.watch(bloodFilterCitiesProvider);
    // Un provider futur expose un AsyncValue : on n'extrait la liste que si
    // elle est arrivée, sinon le filtre_commune reste simplement vide.
    final AsyncValue<List<String>> communesAsync = filter.city == null
        ? const AsyncData(<String>[])
        : ref.watch(bloodFilterCommunesProvider(filter.city!));
    final List<String> communes =
        communesAsync.asData?.value ?? const <String>[];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _FilterDropdown<String?>(
            label: 'Ville',
            value: cities.contains(filter.city) ? filter.city : null,
            hint: 'Toutes les villes',
            items: [
              for (final city in cities)
                DropdownMenuItem(value: city, child: Text(city)),
            ],
            onChanged: notifier.selectCity,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _FilterDropdown<String?>(
            label: 'Commune',
            value: communes.contains(filter.commune) ? filter.commune : null,
            hint: 'Toutes les communes',
            items: [
              for (final commune in communes.take(100))  // ✅ Max 100 communes
                DropdownMenuItem(
                  value: commune,
                  child: Text(
                    commune,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,  // ✅ Pas de débordement
                  ),
                ),
              if (communes.length > 100)
                DropdownMenuItem(
                  enabled: false,
                  child: Text('... et ${communes.length - 100} autres'),
                ),
            ],
            onChanged: communes.isEmpty ? null : notifier.selectCommune,
          ),
        ),
      ],
    );
  }
}

class _FilterDropdown<T> extends StatelessWidget {
  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final T? value;
  final String hint;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.encre,
            fontSize: 14.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.ligne, width: 1.5),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              isDense: true,
              borderRadius: BorderRadius.circular(12),
              hint: Text(
                hint,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.gris, fontSize: 14),
              ),
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.slate,
              ),
              style: const TextStyle(
                color: AppColors.encre,
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
              ),
              items: items,
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyResults extends StatelessWidget {
  const _EmptyResults();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(Icons.search_off, size: 32, color: AppColors.gris),
          const SizedBox(height: 12),
          Text(
            'Aucun centre ne correspond à cette recherche.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.slate,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Élargissez vos filtres pour voir les centres voisins.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.gris, fontSize: 13.5),
          ),
        ],
      ),
    );
  }
}

class _ResultsPlaceholder extends StatelessWidget {
  const _ResultsPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SkeletonBar(width: 220, height: 20),
        const SizedBox(height: 16),
        for (var index = 0; index < 3; index++) ...[
          const _SkeletonCard(),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _ResultsError extends StatelessWidget {
  const _ResultsError();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.indisponibleLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Text(
        "La disponibilité n'a pas pu être chargée. Vérifiez votre connexion.",
        style: TextStyle(color: AppColors.indisponible, fontSize: 14),
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 156,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}

class _SkeletonBar extends StatelessWidget {
  const _SkeletonBar({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

class _ScreenSkeleton extends StatelessWidget {
  const _ScreenSkeleton();

  @override
  Widget build(BuildContext context) {
    return const _ResultsPlaceholder();
  }
}

class _FilterError extends StatelessWidget {
  const _FilterError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 36, color: AppColors.gris),
            const SizedBox(height: 12),
            const Text(
              'Impossible de charger les filtres.',
              style: TextStyle(color: AppColors.slate),
            ),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: onRetry, child: const Text('Réessayer')),
          ],
        ),
      ),
    );
  }
}
