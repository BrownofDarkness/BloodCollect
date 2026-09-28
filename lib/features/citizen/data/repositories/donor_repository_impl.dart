import '../../../../core/constants/app_enums.dart';
import '../../../../shared/domain/entities/entities.dart';
import '../../domain/repositories/donor_repository.dart';
import '../datasources/citizen_mock_datasource.dart';
import '../mock/mock_data.dart';

/// Implémentation de test de [DonorRepository].
///
/// L'écriture est réelle côté mémoire : inscrire puis annuler une collecte fait
/// changer l'onglet « Donner » sans redémarrer l'application.
class DonorRepositoryImpl implements DonorRepository {
  const DonorRepositoryImpl(this._source);

  final CitizenMockDataSource _source;

  @override
  Future<AppUser> currentCitizen() async => _source.citizen;

  @override
  Future<GeoLocation> donorOrigin() async {
    final commune = _source.citizen.commune;
    return mockCommuneCentroids[commune] ?? mockDefaultOrigin;
  }

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
