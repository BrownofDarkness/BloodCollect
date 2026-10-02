import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_enums.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/launchers.dart';
import '../../../../shared/domain/entities/blood_availability.dart';
import '../../../../shared/domain/entities/blood_center.dart';
import '../providers/hc_providers.dart';
import '../widgets/blood_group_grid.dart';
import '../widgets/center_map_header.dart';

// Onglet « Sang » — Fiche centre (sans don).
// Coordonnées d'un centre de transfusion et statut déclaré de ses 8 groupes,
// sans quantités. [bloodType] : groupe recherché en amont, repris si le
// centre de santé lance une demande depuis la fiche.
class HcBloodCenterScreen extends ConsumerWidget {
  const HcBloodCenterScreen({
    super.key,
    required this.centerId,
    this.bloodType,
  });

  final String centerId;
  final BloodType? bloodType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final centerAsync = ref.watch(bloodCenterProvider(centerId));
    void back() => context.go(AppRoutes.hcBlood);

    return Scaffold(
      backgroundColor: AppColors.ivoire,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CenterMapHeader(onBack: back),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: centerAsync.when(
                skipLoadingOnReload: true,
                loading: () => const _Loading(),
                error: (_, _) => _Message(
                  icon: Icons.cloud_off_outlined,
                  title: 'Chargement impossible',
                  body: 'Vérifiez votre connexion puis réessayez.',
                  actionLabel: 'Réessayer',
                  onAction: () => ref.invalidate(bloodCenterProvider(centerId)),
                ),
                data: (center) => center == null
                    ? _Message(
                        icon: Icons.search_off_outlined,
                        title: 'Centre introuvable',
                        body: 'Cette fiche n’est plus disponible.',
                        actionLabel: 'Retour à la recherche',
                        onAction: back,
                      )
                    : _CenterDetails(center: center, bloodType: bloodType),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CenterDetails extends ConsumerWidget {
  const _CenterDetails({required this.center, required this.bloodType});

  final BloodCenter center;
  final BloodType? bloodType;

  // Position GPS si connue, sinon adresse en clair.
  String get _destination {
    final location = center.location;
    if (location.isSet) return '${location.latitude},${location.longitude}';
    return [center.name, center.address, center.commune, center.city]
        .where((part) => part.isNotEmpty)
        .join(', ');
  }

  Future<void> _launch(
    BuildContext context,
    Future<bool> Function() action,
    String failureMessage,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    if (await action()) return;
    messenger.showSnackBar(SnackBar(content: Text(failureMessage)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final origin = ref.watch(currentHealthCenterProvider).value?.location;
    final distance = center.location.knownDistanceKmTo(origin);
    final saturday = center.openingHoursSaturday;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (center.isVerified) ...[
          const _AgreedBadge(),
          const SizedBox(height: 12),
        ],
        Text(
          center.name,
          style: const TextStyle(
            color: AppColors.encre,
            fontSize: 28,
            fontWeight: FontWeight.w800,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          [
            '${center.commune}, ${center.city}',
            if (distance != null) Formatters.distanceKm(distance),
          ].join(' · '),
          style: const TextStyle(color: AppColors.gris, fontSize: 15),
        ),
        const SizedBox(height: 16),
        _InfoRow(
          icon: Icons.location_on_outlined,
          label: 'Adresse',
          lines: [
            center.address.isEmpty ? 'Non renseignée' : center.address,
          ],
        ),
        _InfoRow(
          icon: Icons.schedule_outlined,
          label: 'Horaires',
          lines: [
            'Lun – Ven · ${center.openingHoursWeekdays}',
            if (saturday != null && saturday.isNotEmpty) 'Sam · $saturday',
          ],
        ),
        _InfoRow(
          icon: Icons.phone_outlined,
          label: 'Téléphone',
          lines: [center.phone.isEmpty ? 'Non renseigné' : center.phone],
        ),
        const SizedBox(height: 20),
        _Availabilities(centerId: center.id),
        const SizedBox(height: 24),
        const Text('Délai de réponse', style: _sectionStyle),
        const SizedBox(height: 6),
        const Text(
          'Les demandes urgentes sont traitées en priorité. Pour une '
          'urgence vitale, appelez aussi le centre.',
          style: TextStyle(color: AppColors.slate, fontSize: 15, height: 1.4),
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          // push : le retour du formulaire ramène à cette fiche.
          onPressed: () => context.push(
            AppRoutes.hcBloodRequestPath(
              bloodCenterId: center.id,
              bloodType: bloodType,
            ),
          ),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          icon: const Icon(Icons.near_me_outlined, size: 20),
          label: const _ButtonLabel('Demander du sang à ce centre'),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: center.phone.isEmpty
                    ? null
                    : () => _launch(
                          context,
                          () => Launchers.call(center.phone),
                          'Appel impossible depuis cet appareil.',
                        ),
                style: _outlinedStyle,
                icon: const Icon(Icons.phone_outlined, size: 20),
                label: const _ButtonLabel('Appeler'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _launch(
                  context,
                  () => Launchers.directions(_destination),
                  'Impossible d’ouvrir l’itinéraire.',
                ),
                style: _outlinedStyle,
                icon: const Icon(Icons.near_me_outlined, size: 20),
                label: const _ButtonLabel('Itinéraire'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  static final _outlinedStyle = OutlinedButton.styleFrom(
    backgroundColor: Colors.white,
    foregroundColor: AppColors.encre,
    minimumSize: const Size(0, 52),
    padding: const EdgeInsets.symmetric(horizontal: 8),
    side: const BorderSide(color: AppColors.ligne),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
  );
}

const _sectionStyle = TextStyle(
  color: AppColors.encre,
  fontSize: 17,
  fontWeight: FontWeight.w800,
);

class _Availabilities extends ConsumerWidget {
  const _Availabilities({required this.centerId});

  final String centerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final availabilities = ref.watch(
      bloodCenterAvailabilitiesProvider(centerId),
    );
    final items = availabilities.value ?? const <BloodAvailability>[];
    final updatedAt = items.isEmpty
        ? null
        : items
            .map((item) => item.updatedAt)
            .reduce((a, b) => a.isAfter(b) ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: [
              const Text('Disponibilités déclarées', style: _sectionStyle),
              if (updatedAt != null)
                Text(
                  Formatters.updatedAt(updatedAt),
                  style: const TextStyle(color: AppColors.gris, fontSize: 13),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        availabilities.when(
          // Une mise à jour de stock ne doit pas faire clignoter la grille.
          skipLoadingOnReload: true,
          loading: () => const _Loading(),
          error: (_, _) => _Message(
            icon: Icons.cloud_off_outlined,
            title: 'Disponibilités indisponibles',
            body: 'Vérifiez votre connexion puis réessayez.',
            actionLabel: 'Réessayer',
            onAction: () => ref.invalidate(bloodCenterLotsProvider(centerId)),
          ),
          data: (items) => BloodGroupGrid(availabilities: items),
        ),
      ],
    );
  }
}

class _AgreedBadge extends StatelessWidget {
  const _AgreedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.ligne.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        children: [
          Icon(Icons.verified_user_outlined, color: AppColors.encre, size: 16),
          SizedBox(width: 6),
          Flexible(
            child: Text(
              'CENTRE DE TRANSFUSION AGRÉÉ',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.encre,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.lines,
  });

  final IconData icon;
  final String label;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.ligne)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.slate, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: AppColors.gris, fontSize: 13),
                ),
                const SizedBox(height: 2),
                for (final line in lines)
                  Text(
                    line,
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
    );
  }
}

// Réduit le libellé plutôt que de le tronquer sur les petits écrans.
class _ButtonLabel extends StatelessWidget {
  const _ButtonLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return FittedBox(fit: BoxFit.scaleDown, child: Text(text, maxLines: 1));
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
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String body;
  final String actionLabel;
  final VoidCallback onAction;

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
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}
