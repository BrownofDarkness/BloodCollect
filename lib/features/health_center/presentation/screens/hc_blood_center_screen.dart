import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_enums.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/presentation/widgets/blood_center_sheet.dart';

// Onglet « Sang » — Fiche centre (sans don).
// Fiche d'un centre de transfusion vue par un centre de santé, qui peut lui
// adresser une demande. [bloodType] : groupe recherché en amont, repris
// dans la demande.
class HcBloodCenterScreen extends StatelessWidget {
  const HcBloodCenterScreen({
    super.key,
    required this.centerId,
    this.bloodType,
  });

  final String centerId;
  final BloodType? bloodType;

  @override
  Widget build(BuildContext context) {
    return BloodCenterSheet(
      centerId: centerId,
      onBack: () => context.go(AppRoutes.hcBlood),
      sectionsBuilder: (context, center) => const [_ResponseDelay()],
      primaryActionBuilder: (context, center) => BloodCenterPrimaryButton(
        label: 'Demander du sang à ce centre',
        icon: Icons.near_me_outlined,
        // push : le retour du formulaire ramène à cette fiche.
        onPressed: () => context.push(
          AppRoutes.hcBloodRequestPath(
            bloodCenterId: center.id,
            bloodType: bloodType,
          ),
        ),
      ),
    );
  }
}

class _ResponseDelay extends StatelessWidget {
  const _ResponseDelay();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Délai de réponse', style: BloodCenterSheet.sectionStyle),
        SizedBox(height: 6),
        Text(
          'Les demandes urgentes sont traitées en priorité. Pour une '
          'urgence vitale, appelez aussi le centre.',
          style: TextStyle(color: AppColors.slate, fontSize: 15, height: 1.4),
        ),
      ],
    );
  }
}
