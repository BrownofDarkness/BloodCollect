import '../../../../shared/domain/entities/entities.dart';
import '../../domain/repositories/campaign_repository.dart';
import '../datasources/campaign_remote_datasource.dart';

/// Implémentation Firestore de [CampaignRepository].
///
/// Les règles de visibilité des collectes restent dans la source : une collecte
/// `draft` ou `cancelled` n'a pas à revenir au client pour être écartée, et
/// la sécurité des règles s'appuie sur le même filtre.
class CampaignRepositoryImpl implements CampaignRepository {
  const CampaignRepositoryImpl(this._remote);

  final CampaignRemoteDataSource _remote;

  @override
  Future<List<Campaign>> upcomingCampaigns({String? commune}) =>
      _remote.upcomingCampaigns(commune: commune);

  @override
  Future<List<Campaign>> upcomingCampaignsOfCenter(String centerId) =>
      _remote.upcomingCampaignsOfCenter(centerId);

  @override
  Future<Campaign?> campaignById(String campaignId) =>
      _remote.campaignById(campaignId);
}