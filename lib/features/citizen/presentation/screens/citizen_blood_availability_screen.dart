import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/launchers.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../shared/presentation/widgets/blood_availability_card.dart';
import '../../../../shared/presentation/widgets/blood_availability_explorer.dart';
import '../../../../shared/presentation/widgets/person_badge.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

// Onglet « Sang » — Disponibilité du sang (consultation).
// Le citoyen consulte le statut déclaré des centres de transfusion, sans
// quantités. Il ne peut pas demander de sang : seul un centre de santé
// transmet une demande.
class CitizenBloodAvailabilityScreen extends ConsumerWidget {
  const CitizenBloodAvailabilityScreen({super.key});

  Future<void> _call(BuildContext context, String phone) async {
    final messenger = ScaffoldMessenger.of(context);
    if (await Launchers.call(phone)) return;
    messenger.showSnackBar(
      const SnackBar(content: Text('Appel impossible depuis cet appareil.')),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentAppUserProvider);

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
                    onPressed: () => context.go(AppRoutes.citizenHome),
                  ),
                  const Spacer(),
                  const BloodBadge(
                    label: 'Sang · centres agréés',
                    icon: Icons.water_drop_outlined,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Disponibilité du sang',
                style: TextStyle(
                  color: AppColors.encre,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 20),
              BloodAvailabilityExplorer(
                homeCity: userAsync.value?.city,
                waitingHomeCity: userAsync.isLoading,
                notice: const _ConsultationNotice(),
                onViewCenter: (availability) => context.go(
                  '${AppRoutes.citizenBlood}/${availability.center.id}',
                ),
                actionBuilder: (context, availability, _) {
                  final phone = availability.center.phone;
                  return AvailabilityActionButton(
                    label: 'Appeler',
                    icon: Icons.phone_outlined,
                    onPressed:
                        phone.isEmpty ? null : () => _call(context, phone),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Un citoyen ne commande pas de sang : rappel avant la liste.
class _ConsultationNotice extends StatelessWidget {
  const _ConsultationNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.encart,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.verified_user_outlined,
            color: AppColors.encre,
            size: 22,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Consultation uniquement',
                  style: TextStyle(
                    color: AppColors.encre,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Pour obtenir du sang, rapprochez-vous d’un centre de '
                  'santé : c’est lui qui transmet la demande au centre de '
                  'transfusion.',
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
