import '../../../core/constants/app_enums.dart';
import 'geo_location.dart';

// collection --- campaigns/{campaignId}
class Campaign {
  const Campaign({
    required this.id,
    required this.bloodCenterId,
    required this.title,
    required this.description,
    required this.location,
    required this.locationName,
    this.commune,
    required this.startDate,
    required this.endDate,
    required this.targetBloodTypes,
    required this.targetCommunes,
    required this.targetUnits,
    this.collectedUnits = 0,
    this.notifyDonors = true,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String bloodCenterId;
  final String title;
  final String description;
  final GeoLocation location;
  final String locationName;
  final String? commune;
  final DateTime startDate;
  final DateTime endDate;
  final List<BloodType> targetBloodTypes;
  final List<String> targetCommunes;
  final int targetUnits;
  final int collectedUnits;
  final bool notifyDonors;
  final CampaignStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Visible des citoyens : publiée ou en cours, et pas encore terminée.
  bool isOpenAt(DateTime now) =>
      (status == CampaignStatus.published ||
          status == CampaignStatus.active) &&
      endDate.isAfter(now);

  /// La collecte se tient dans [commune] ou la cible explicitement.
  bool concernsCommune(String commune) =>
      this.commune == commune || targetCommunes.contains(commune);

  Campaign copyWith({
    String? id,
    String? bloodCenterId,
    String? title,
    String? description,
    GeoLocation? location,
    String? locationName,
    String? Function()? commune,
    DateTime? startDate,
    DateTime? endDate,
    List<BloodType>? targetBloodTypes,
    List<String>? targetCommunes,
    int? targetUnits,
    int? collectedUnits,
    bool? notifyDonors,
    CampaignStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Campaign(
      id: id ?? this.id,
      bloodCenterId: bloodCenterId ?? this.bloodCenterId,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      locationName: locationName ?? this.locationName,
      commune: commune != null ? commune() : this.commune,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      targetBloodTypes: targetBloodTypes ?? this.targetBloodTypes,
      targetCommunes: targetCommunes ?? this.targetCommunes,
      targetUnits: targetUnits ?? this.targetUnits,
      collectedUnits: collectedUnits ?? this.collectedUnits,
      notifyDonors: notifyDonors ?? this.notifyDonors,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
