import 'package:blood_collect/core/constants/app_enums.dart';
import 'package:blood_collect/features/citizen/domain/repositories/blood_center_repository.dart';
import 'package:blood_collect/features/citizen/domain/repositories/campaign_repository.dart';
import 'package:blood_collect/features/citizen/domain/repositories/donor_repository.dart';
import 'package:blood_collect/shared/domain/entities/entities.dart';

import 'citizen_mock_datasource.dart';

/// Implémentations en mémoire des contrats du module citoyen.
///
/// Les tests portent sur les use cases et le domaine, pas sur Firestore : ces
/// fakes rendent les mêmes règles de visibilité que les sources réelles
/// (centres vérifiés, collectes non brouillon et non annulées, inscriptions
/// actives) pour que la logique testée soit celle de production.
class InMemoryBloodCenterRepository implements BloodCenterRepository {
  InMemoryBloodCenterRepository(this._source);

  final CitizenMockDataSource _source;

  @override
  Future<List<BloodCenter>> verifiedCenters() async =>
      _source.centers.where((center) => center.isVerified).toList();

  @override
  Future<BloodCenter?> centerById(String centerId) async {
    for (final center in _source.centers) {
      if (center.id == centerId) return center;
    }
    return null;
  }

  @override
  Future<List<BloodStockLot>> lotsOfCenter(String centerId) async =>
      _source.lots.where((lot) => lot.bloodCenterId == centerId).toList();
}

class InMemoryCampaignRepository implements CampaignRepository {
  InMemoryCampaignRepository(this._source);

  final CitizenMockDataSource _source;

  @override
  Future<List<Campaign>> upcomingCampaigns({String? commune}) async {
    final reference = DateTime.now();
    final visible = _source.campaigns.where((campaign) {
      if (campaign.status == CampaignStatus.draft) return false;
      if (campaign.status == CampaignStatus.cancelled) return false;
      if (!campaign.endDate.isAfter(reference)) return false;
      if (commune != null && !campaign.targetCommunes.contains(commune)) {
        return false;
      }
      return true;
    }).toList()..sort((a, b) => a.startDate.compareTo(b.startDate));

    return visible;
  }

  @override
  Future<List<Campaign>> upcomingCampaignsOfCenter(String centerId) async {
    final reference = DateTime.now();
    final campaigns = _source.campaigns.where((campaign) {
      if (campaign.bloodCenterId != centerId) return false;
      if (campaign.status == CampaignStatus.draft) return false;
      if (campaign.status == CampaignStatus.cancelled) return false;
      return campaign.endDate.isAfter(reference);
    }).toList()..sort((a, b) => a.startDate.compareTo(b.startDate));

    return campaigns;
  }

  @override
  Future<Campaign?> campaignById(String campaignId) async {
    for (final campaign in _source.campaigns) {
      if (campaign.id == campaignId) return campaign;
    }
    return null;
  }
}

class InMemoryDonorRepository implements DonorRepository {
  InMemoryDonorRepository(this._source, {this.origin});

  final CitizenMockDataSource _source;

  /// Position de référence du donneur. Les tests qui vérifient le tri des
  /// centres doivent la fixer : par défaut le centroïde de la commune du
  /// citoyen fictif.
  final GeoLocation? origin;

  @override
  Future<AppUser> currentCitizen() async => _source.citizen;

  @override
  Future<GeoLocation> donorOrigin() async => origin ?? _source.citizenOrigin;

  @override
  Future<List<CampaignRegistration>> registrationsOf(String donorId) async =>
      _source.registrations.where((r) => r.donorId == donorId).toList();

  @override
  Future<List<DonorMatchRequest>> matchesOf(String citizenId) async => _source
      .matches
      .where((m) => m.donorId == citizenId || m.requesterId == citizenId)
      .toList();

  @override
  Future<CampaignRegistration> registerToCampaign({
    required String campaignId,
    required String donorId,
    DateTime? scheduledTime,
  }) async {
    final existing = _activeRegistrationFor(campaignId, donorId);
    if (existing != null) return existing;

    final registration = _source.nextRegistration(
      campaignId: campaignId,
      donorId: donorId,
      scheduledTime: scheduledTime,
    );
    _source.registrations.add(registration);
    return registration;
  }

  @override
  Future<void> cancelRegistration(String registrationId) async {
    final index = _source.registrations.indexWhere(
      (r) => r.id == registrationId,
    );
    if (index < 0) return;

    _source.registrations[index] = _source.registrations[index].copyWith(
      status: RegistrationStatus.cancelled,
    );
  }

  CampaignRegistration? _activeRegistrationFor(
    String campaignId,
    String donorId,
  ) {
    for (final registration in _source.registrations) {
      final sameSlot =
          registration.campaignId == campaignId &&
          registration.donorId == donorId;
      final isCancelled = registration.status == RegistrationStatus.cancelled;
      if (sameSlot && !isCancelled) return registration;
    }
    return null;
  }
}