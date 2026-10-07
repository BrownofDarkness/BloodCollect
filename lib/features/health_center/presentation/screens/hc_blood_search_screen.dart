import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../shared/presentation/widgets/blood_availability_card.dart';
import '../../../../shared/presentation/widgets/blood_availability_explorer.dart';
import '../providers/hc_providers.dart';
import '../widgets/hc_role_badge.dart';

// Onglet « Sang » — Trouver du sang disponible.
// Le centre de santé choisit un groupe et une zone : la liste affiche le
// statut déclaré de chaque centre de transfusion vérifié, sans quantités,
// et permet de lui adresser une demande.
class HcBloodSearchScreen extends ConsumerWidget {
  const HcBloodSearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthCenterAsync = ref.watch(currentHealthCenterProvider);

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
                'Trouver du sang\ndisponible',
                style: TextStyle(
                  color: AppColors.encre,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 20),
              BloodAvailabilityExplorer(
                homeCity: healthCenterAsync.value?.city,
                waitingHomeCity: healthCenterAsync.isLoading,
                onViewCenter: (availability) => context.go(
                  AppRoutes.hcBloodCenterPath(
                    availability.center.id,
                    bloodType: availability.bloodType,
                  ),
                ),
                // Indisponible : on oriente vers les autres centres de la
                // ville plutôt que de proposer une demande vouée au refus.
                actionBuilder: (context, availability, showWholeCity) =>
                    availability.canRequest
                        ? AvailabilityActionButton(
                            label: 'Demander',
                            filled: true,
                            // push : le retour du formulaire ramène ici.
                            onPressed: () => context.push(
                              AppRoutes.hcBloodRequestPath(
                                bloodCenterId: availability.center.id,
                                bloodType: availability.bloodType,
                              ),
                            ),
                          )
                        : AvailabilityActionButton(
                            label: 'Autres centres',
                            icon: Icons.turn_right,
                            onPressed: showWholeCity,
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
