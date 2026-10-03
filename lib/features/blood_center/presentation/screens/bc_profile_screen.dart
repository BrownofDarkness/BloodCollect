import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../auth/data/repositories/auth_repository_impl.dart';
import '../../domain/blood_center_stats.dart';
import '../providers/bc_dashboard_providers.dart';

// Profil transfusion : fiche + pilotage, lecture seule.
// Remplace le ProfileScreen temporaire sur /bc/profile uniquement.
class BcProfileScreen extends ConsumerWidget {
  const BcProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final center = ref.watch(bcCenterProvider);
    final lots = ref.watch(bcStockLotsProvider);
    final campaigns = ref.watch(bcCampaignsProvider);
    final low = ref.watch(bcLowThresholdProvider);
    final unavailable = ref.watch(bcUnavailableThresholdProvider);

    final total = totalUnits(unitsByBloodType(lots));
    final upcoming =
        upcomingCampaigns(campaigns, DateTime.now()).length;

    return Scaffold(
      backgroundColor: AppColors.ivoire,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Profil',
                style: TextStyle(
                  color: AppColors.encre,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.ligne),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: const BoxDecoration(
                            color: AppColors.rougeLight,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.water_drop_outlined,
                            color: AppColors.rouge,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                center.name,
                                style: const TextStyle(
                                  color: AppColors.encre,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  height: 1.2,
                                ),
                              ),
                              Text(
                                'Centre de transfusion sanguine · '
                                '${center.commune}',
                                style: const TextStyle(
                                  color: AppColors.gris,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDCFCE7),
                                  borderRadius:
                                      BorderRadius.circular(20),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.verified_user_outlined,
                                      color: AppColors.disponible,
                                      size: 14,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Compte vérifié',
                                      style: TextStyle(
                                        color: AppColors.disponible,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _MiniStat(
                            label: 'Poches',
                            value: '$total',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _MiniStat(
                            label: 'Collectes',
                            value: '$upcoming',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const _SectionTitle('ÉTABLISSEMENT'),
              const SizedBox(height: 8),
              _Group(
                rows: [
                  _Row(
                    icon: Icons.business_outlined,
                    title: 'Informations du centre',
                    subtitle:
                        '${center.name} · ${center.agreementNumber}',
                  ),
                  _Row(
                    icon: Icons.place_outlined,
                    title: 'Localisation',
                    subtitle:
                        '${center.commune}, ${center.city} · ${center.address}',
                  ),
                  _Row(
                    icon: Icons.schedule_outlined,
                    title: 'Horaires de collecte',
                    subtitle:
                        'Lun – Ven ${center.openingHoursWeekdays}'
                        '${center.openingHoursSaturday == null ? '' : ' · Sam ${center.openingHoursSaturday}'}',
                  ),
                  _Row(
                    icon: Icons.phone_outlined,
                    title: 'Coordonnées',
                    subtitle: center.phone,
                  ),
                  _Row(
                    icon: Icons.description_outlined,
                    title: 'Justificatifs',
                    subtitle: 'Agrément validé',
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const _SectionTitle('GESTION'),
              const SizedBox(height: 8),
              _Group(
                rows: [
                  _Row(
                    icon: Icons.tune_outlined,
                    title: 'Seuils d’alerte des stocks',
                    subtitle:
                        'Limitée sous $low · indisponible sous $unavailable',
                  ),
                  _Row(
                    icon: Icons.redo_outlined,
                    title: 'Centres partenaires',
                    subtitle: 'Pour orienter les demandes',
                    badge: '2',
                  ),
                  _Row(
                    icon: Icons.group_outlined,
                    title: 'Membres de l’équipe',
                    subtitle: 'Accès stocks, demandes, collectes',
                    badge: '5',
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const _SectionTitle('PARAMÈTRES'),
              const SizedBox(height: 8),
              _Group(
                rows: const [
                  _Row(
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    subtitle: 'Nouvelles demandes, péremptions',
                  ),
                  _Row(
                    icon: Icons.lock_outlined,
                    title: 'Mot de passe et sécurité',
                    subtitle: null,
                  ),
                  _Row(
                    icon: Icons.help_outlined,
                    title: 'Aide et contact',
                    subtitle: null,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.ligne),
                ),
                child: InkWell(
                  onTap: () async {
                    await AuthRepositoryImpl().signOut();
                    if (context.mounted) {
                      context.go(AppRoutes.welcome);
                    }
                  },
                  borderRadius: BorderRadius.circular(18),
                  child: const Padding(
                    padding: EdgeInsets.all(18),
                    child: Row(
                      children: [
                        Icon(
                          Icons.logout_outlined,
                          color: AppColors.rouge,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Se déconnecter',
                          style: TextStyle(
                            color: AppColors.rouge,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'BloodCollect · version 1.0',
                  style: TextStyle(
                    color: AppColors.gris,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

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

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.ligne.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.gris, fontSize: 13),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.encre,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.rows});

  final List<_Row> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.ligne),
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            _RowTile(row: rows[i]),
            if (i < rows.length - 1)
              const Divider(
                height: 1,
                color: AppColors.ligne,
                indent: 58,
              ),
          ],
        ],
      ),
    );
  }
}

class _Row {
  const _Row({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.badge,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? badge;
}

class _RowTile extends StatelessWidget {
  const _RowTile({required this.row});

  final _Row row;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Édition à venir.')),
        ),
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          child: Row(
            children: [
              Icon(row.icon, color: AppColors.gris, size: 24),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      row.title,
                      style: const TextStyle(
                        color: AppColors.encre,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (row.subtitle != null)
                      Text(
                        row.subtitle!,
                        style: const TextStyle(
                          color: AppColors.gris,
                          fontSize: 13,
                        ),
                      ),
                  ],
                ),
              ),
              if (row.badge != null)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.rougeLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    row.badge!,
                    style: const TextStyle(
                      color: AppColors.rouge,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              const Icon(
                Icons.chevron_right_outlined,
                color: AppColors.gris,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
