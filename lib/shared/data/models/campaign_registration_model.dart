import '../../../core/constants/app_enums.dart';
import '../../domain/entities/campaign_registration.dart';
import 'firestore_converters.dart';

// ---- campaign_registrations
class CampaignRegistrationModel extends CampaignRegistration {
  const CampaignRegistrationModel({
    required super.id,
    required super.campaignId,
    required super.donorId,
    super.bloodCenterId,
    super.scheduledTime,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
  });

  factory CampaignRegistrationModel.fromMap(
    Map<String, dynamic> map,
    String id,
  ) {
    return CampaignRegistrationModel(
      id: id,
      campaignId: map['campaignId'] as String? ?? '',
      donorId: map['donorId'] as String? ?? '',
      bloodCenterId: map['bloodCenterId'] as String? ?? '',
      scheduledTime: tsToDateOrNull(map['scheduledTime']),
      status:
          RegistrationStatus.fromString(map['status'] as String?) ??
          RegistrationStatus.registered,
      createdAt: tsToDate(map['createdAt'], fallback: DateTime.now()),
      updatedAt: tsToDate(map['updatedAt'], fallback: DateTime.now()),
    );
  }

  Map<String, dynamic> toMap() => {
    'campaignId': campaignId,
    'donorId': donorId,
    'bloodCenterId': bloodCenterId,
    'scheduledTime': scheduledTime == null ? null : dateToTs(scheduledTime!),
    'status': status.firestoreValue,
    'createdAt': dateToTs(createdAt),
    'updatedAt': dateToTs(updatedAt),
  };
}
