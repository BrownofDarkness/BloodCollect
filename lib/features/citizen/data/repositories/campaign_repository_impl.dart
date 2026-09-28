import '../../../../core/constants/app_enums.dart';
import '../../../../shared/domain/entities/entities.dart';
import '../../domain/repositories/campaign_repository.dart';
import '../datasources/citizen_mock_datasource.dart';

/// Implémentation de test de [CampaignRepository].
class CampaignRepositoryImpl implements CampaignRepository {
  const CampaignRepositoryImpl(this._source);

  final CitizenMockDataSource _source;

  /// Seules les collectes publiées ou en cours sont visibles des citoyens :
  /// un brouillon (`draft`) reste interne au centre organisateur.
  @override
  Future<List<Campaign>> upcomingCampaigns({
    String? commune,
    DateTime? now,
  }) async {
    final reference = now ?? DateTime.now();

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
  Future<List<Campaign>> upcomingCampaignsOfCenter(
    String centerId, {
    DateTime? now,
  }) async {
    final reference = now ?? DateTime.now();

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
