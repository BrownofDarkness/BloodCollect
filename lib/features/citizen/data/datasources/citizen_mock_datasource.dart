import '../../../../core/constants/app_enums.dart';
import '../../../../shared/domain/entities/entities.dart';
import '../mock/mock_data.dart';

/// Source de données de test pour le module Citoyen.
///
/// Implémente l'accès en lecture/écriture attendu des contrats de
/// `domain/repositories/`, sur des enregistrements en mémoire. Le stock est
/// mutable en mémoire pour que « Je participe » et « Annuler » produisent un
/// effet visible sans backend. Voir `data/mock/README.md` pour la stratégie de
/// remplacement par Firestore.
class CitizenMockDataSource {
  CitizenMockDataSource();

  AppUser citizen = mockCitizen;
  final List<BloodCenter> centers = List.of(mockBloodCenters);
  final List<BloodStockLot> lots = List.of(mockStockLots);
  final List<Campaign> campaigns = List.of(mockCampaigns);
  final List<CampaignRegistration> registrations = List.of(
    mockCampaignRegistrations,
  );
  final List<DonorMatchRequest> matches = List.of(mockDonorMatchRequests);

  int _sequence = 0;

  /// Registre qui centralise les écritures pour leur donner un identifiant et
  /// des horodatages cohérents.
  CampaignRegistration nextRegistration({
    required String campaignId,
    required String donorId,
    DateTime? scheduledTime,
  }) {
    final now = DateTime.now();
    return CampaignRegistration(
      id: 'reg_${donorId}_${campaignId}_${++_sequence}',
      campaignId: campaignId,
      donorId: donorId,
      scheduledTime: scheduledTime,
      status: RegistrationStatus.registered,
      createdAt: now,
      updatedAt: now,
    );
  }
}
