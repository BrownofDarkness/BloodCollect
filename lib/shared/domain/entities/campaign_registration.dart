import '../../../core/constants/app_enums.dart';

// collection --- campaign_registrations/{registrationId}
class CampaignRegistration {
  const CampaignRegistration({
    required this.id,
    required this.campaignId,
    required this.donorId,
    this.scheduledTime,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String campaignId;
  final String donorId;
  final DateTime? scheduledTime;
  final RegistrationStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  CampaignRegistration copyWith({
    String? id,
    String? campaignId,
    String? donorId,
    DateTime? Function()? scheduledTime,
    RegistrationStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CampaignRegistration(
      id: id ?? this.id,
      campaignId: campaignId ?? this.campaignId,
      donorId: donorId ?? this.donorId,
      scheduledTime:
          scheduledTime != null ? scheduledTime() : this.scheduledTime,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
