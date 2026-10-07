import '../../../core/constants/app_enums.dart';

// collection --- campaign_registrations/{registrationId}
class CampaignRegistration {
  const CampaignRegistration({
    required this.id,
    required this.campaignId,
    required this.donorId,
    this.bloodCenterId = '',
    this.scheduledTime,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String campaignId;
  final String donorId;

  /// Centre organisateur de la collecte, recopié à l'inscription : il permet
  /// au centre de lire les inscriptions de ses propres collectes. Vide sur
  /// les inscriptions créées avant l'ajout du champ.
  final String bloodCenterId;

  final DateTime? scheduledTime;
  final RegistrationStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Identifiant d'une inscription : un seul document par couple collecte /
  /// donneur, réactivé plutôt que dupliqué en cas de réinscription.
  static String idFor({required String campaignId, required String donorId}) =>
      '${campaignId}_$donorId';

  /// Le donneur compte participer (inscrit ou confirmé par le centre).
  bool get isActive =>
      status == RegistrationStatus.registered ||
      status == RegistrationStatus.confirmed;

  CampaignRegistration copyWith({
    String? id,
    String? campaignId,
    String? donorId,
    String? bloodCenterId,
    DateTime? Function()? scheduledTime,
    RegistrationStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CampaignRegistration(
      id: id ?? this.id,
      campaignId: campaignId ?? this.campaignId,
      donorId: donorId ?? this.donorId,
      bloodCenterId: bloodCenterId ?? this.bloodCenterId,
      scheduledTime: scheduledTime != null
          ? scheduledTime()
          : this.scheduledTime,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
