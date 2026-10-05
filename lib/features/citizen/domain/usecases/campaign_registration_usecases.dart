import '../../../../../shared/domain/entities/entities.dart';
import '../repositories/campaign_repository.dart';
import '../repositories/donor_repository.dart';

/// Inscription du citoyen à une collecte.
///
/// L'inscription est volontaire et sans engagement de prélèvement : la
/// participation se fait en centre agréé, après vérification de l'éligibilité.
/// [CampaignRegistrationNotJoinable] si la collecte est inconnue ou déjà
/// terminée — l'UI affiche alors l'état réel au lieu d'échouer en silence.
class JoinCampaignUseCase {
  const JoinCampaignUseCase({required this.campaigns, required this.donors});

  final CampaignRepository campaigns;
  final DonorRepository donors;

  Future<CampaignRegistration> call(String campaignId, {DateTime? now}) async {
    final campaign = await campaigns.campaignById(campaignId);
    final reference = now ?? DateTime.now();

    if (campaign == null) {
      throw const CampaignRegistrationNotJoinable(
        "Cette collecte n'existe plus.",
      );
    }
    if (!campaign.startDate.isAfter(reference)) {
      throw const CampaignRegistrationNotJoinable(
        'Cette collecte a déjà commencé.',
      );
    }

    final citizen = await donors.currentCitizen();
    return donors.registerToCampaign(
      campaignId: campaignId,
      donorId: citizen.id,
    );
  }
}

/// Désinscription d'une collecte à venir.
class CancelRegistrationUseCase {
  const CancelRegistrationUseCase({required this.donors});

  final DonorRepository donors;

  Future<void> call(String registrationId) =>
      donors.cancelRegistration(registrationId);
}

/// La collecte ne peut plus être rejointe : message destiné au citoyen.
class CampaignRegistrationNotJoinable implements Exception {
  const CampaignRegistrationNotJoinable(this.message);

  final String message;

  @override
  String toString() => message;
}
