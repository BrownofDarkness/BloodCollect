import '../../../../../core/constants/app_enums.dart';
import '../../../../../core/utils/distance_utils.dart';
import '../../../../../shared/domain/entities/entities.dart';
import '../repositories/blood_center_repository.dart';
import '../repositories/campaign_repository.dart';
import '../repositories/donor_repository.dart';

/// Une collecte à venir, avec l'état de participation du citoyen s'il y en a une.
class RegisteredCampaign {
  const RegisteredCampaign({required this.campaign, this.registration});

  final Campaign campaign;
  final CampaignRegistration? registration;

  bool get isRegistered =>
      registration != null &&
      registration!.status != RegistrationStatus.cancelled;

  bool get isConfirmed => registration?.status == RegistrationStatus.confirmed;

  /// Vise « Tous groupes » quand la collecte ouvre les 8 groupes sanguins.
  bool get targetsEveryBloodType =>
      campaign.targetBloodTypes.length == BloodType.values.length;
}

/// Onglet « Donner » : profil donneur, collectes à venir, centres proches.
class DonationDashboard {
  const DonationDashboard({
    required this.citizen,
    required this.campaigns,
    required this.nearbyCenters,
  });

  final AppUser citizen;
  final List<RegisteredCampaign> campaigns;

  /// Centres de transfusion vérifiés, triés par distance croissante.
  final List<BloodCenterAvailability> nearbyCenters;
}

class GetDonationDashboardUseCase {
  const GetDonationDashboardUseCase({
    required this.centers,
    required this.campaigns,
    required this.donors,
  });

  final BloodCenterRepository centers;
  final CampaignRepository campaigns;
  final DonorRepository donors;

  Future<DonationDashboard> call() async {
    final citizen = await donors.currentCitizen();
    final registrations = await donors.registrationsOf(citizen.id);
    final upcoming = await campaigns.upcomingCampaigns(
      commune: citizen.commune,
    );

    return DonationDashboard(
      citizen: citizen,
      campaigns: [
        for (final campaign in upcoming)
          RegisteredCampaign(
            campaign: campaign,
            registration: _registrationFor(registrations, campaign.id),
          ),
      ],
      nearbyCenters: await _nearbyCenters(),
    );
  }

  Future<List<BloodCenterAvailability>> _nearbyCenters() async {
    final origin = await donors.donorOrigin();
    final verified = await centers.verifiedCenters();

    final entries = <BloodCenterAvailability>[];
    for (final center in verified) {
      final lots = await centers.lotsOfCenter(center.id);
      entries.add(
        BloodCenterAvailability(
          availability: BloodAvailability.fromLots(
            center: center,
            lots: lots,
            updatedAt: center.updatedAt,
          ),
          distanceKm: distanceInKm(origin, center.location),
        ),
      );
    }

    entries.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    return entries;
  }

  CampaignRegistration? _registrationFor(
    List<CampaignRegistration> registrations,
    String campaignId,
  ) {
    for (final registration in registrations) {
      if (registration.campaignId != campaignId) continue;
      if (registration.status == RegistrationStatus.cancelled) continue;
      return registration;
    }
    return null;
  }
}
