import '../../../core/constants/app_enums.dart';
import '../../domain/entities/campaign.dart';
import 'firestore_converters.dart';

// ---- campaigns
class CampaignModel extends Campaign {
  const CampaignModel({
    required super.id,
    required super.bloodCenterId,
    required super.title,
    required super.description,
    required super.location,
    required super.locationName,
    super.commune,
    required super.startDate,
    required super.endDate,
    required super.targetBloodTypes,
    required super.targetCommunes,
    required super.targetUnits,
    super.collectedUnits = 0,
    super.notifyDonors = true,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
  });

  factory CampaignModel.fromMap(Map<String, dynamic> map, String id) {
    final rawTypes = (map['targetBloodTypes'] as List?) ?? [];
    return CampaignModel(
      id: id,
      bloodCenterId: map['bloodCenterId'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      location: geoToDomain(map['location']),
      locationName: map['locationName'] as String? ?? '',
      commune: map['commune'] as String?,
      startDate: tsToDate(map['startDate'], fallback: DateTime.now()),
      endDate: tsToDate(map['endDate'], fallback: DateTime.now()),
      targetBloodTypes: rawTypes
          .map((e) => BloodType.fromString(e as String?))
          .whereType<BloodType>()
          .toList(),
      targetCommunes:
          ((map['targetCommunes'] as List?) ?? []).map((e) => '$e').toList(),
      targetUnits: (map['targetUnits'] as num?)?.toInt() ?? 0,
      collectedUnits: (map['collectedUnits'] as num?)?.toInt() ?? 0,
      notifyDonors: map['notifyDonors'] as bool? ?? true,
      status: CampaignStatus.fromString(map['status'] as String?) ??
          CampaignStatus.draft,
      createdAt: tsToDate(map['createdAt'], fallback: DateTime.now()),
      updatedAt: tsToDate(map['updatedAt'], fallback: DateTime.now()),
    );
  }

  Map<String, dynamic> toMap() => {
        'bloodCenterId': bloodCenterId,
        'title': title,
        'description': description,
        'location': geoToFirestore(location),
        'locationName': locationName,
        'commune': commune,
        'startDate': dateToTs(startDate),
        'endDate': dateToTs(endDate),
        'targetBloodTypes': targetBloodTypes.map((e) => e.firestoreValue).toList(),
        'targetCommunes': targetCommunes,
        'targetUnits': targetUnits,
        'collectedUnits': collectedUnits,
        'notifyDonors': notifyDonors,
        'status': status.firestoreValue,
        'createdAt': dateToTs(createdAt),
        'updatedAt': dateToTs(updatedAt),
      };
}
