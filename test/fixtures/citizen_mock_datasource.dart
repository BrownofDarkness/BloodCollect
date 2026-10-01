import 'package:blood_collect/core/constants/app_enums.dart';
import 'package:blood_collect/shared/domain/entities/entities.dart';
import 'package:blood_collect/shared/domain/value_objects/city_reference.dart';

import 'citizen_records_fixture.dart';

/// Source de données de test pour le module Citoyen.
///
/// Implémente l'accès en lecture/écriture attendu des contrats de
/// `domain/repositories/`, sur des enregistrements en mémoire. Le stock est
/// mutable pour que « Je participe » et « Annuler » produisent un effet visible
/// sans backend.
///
/// Cette classe ne sert qu'aux tests. En production, les mêmes contrats sont
/// implémentés par les datasources Firestore du module `data/datasources/`.
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

  /// Position de référence du donneur : le centroïde de la commune déclarée au
  /// profil. Les tests qui vérifient des distances la fixent explicitement.
  GeoLocation get citizenOrigin =>
      communeCentroids[citizen.commune] ?? defaultOrigin;

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
