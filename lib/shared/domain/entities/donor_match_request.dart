import '../../../core/constants/app_enums.dart';

// collection --- donor_match_requests/{id}
// Double flux : (1) recherche directe sans bloodRequestId,
// (2) Blood Route auto avec bloodRequestId.
class DonorMatchRequest {
  const DonorMatchRequest({
    required this.id,
    required this.requesterId,
    this.bloodRequestId,
    required this.donorId,
    required this.bloodType,
    required this.priority,
    required this.status,
    required this.shareContact,
    this.message,
    this.internalReference,
    required this.notifiedAt,
    this.respondedAt,
    required this.expiresAt,
    required this.createdAt,
  });

  final String id;
  final String requesterId;
  final String? bloodRequestId;
  final String donorId;
  // Dénormalisé depuis le profil donneur (PDF p.8)
  final BloodType bloodType;
  final Priority priority;
  final DonorMatchStatus status;
  final bool shareContact;
  final String? message;
  final String? internalReference;
  final DateTime notifiedAt;
  final DateTime? respondedAt;
  final DateTime expiresAt;
  final DateTime createdAt;

  bool get isAutoRouting => bloodRequestId != null;

  DonorMatchRequest copyWith({
    String? id,
    String? requesterId,
    String? Function()? bloodRequestId,
    String? donorId,
    BloodType? bloodType,
    Priority? priority,
    DonorMatchStatus? status,
    bool? shareContact,
    String? Function()? message,
    String? Function()? internalReference,
    DateTime? notifiedAt,
    DateTime? Function()? respondedAt,
    DateTime? expiresAt,
    DateTime? createdAt,
  }) {
    return DonorMatchRequest(
      id: id ?? this.id,
      requesterId: requesterId ?? this.requesterId,
      bloodRequestId:
          bloodRequestId != null ? bloodRequestId() : this.bloodRequestId,
      donorId: donorId ?? this.donorId,
      bloodType: bloodType ?? this.bloodType,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      shareContact: shareContact ?? this.shareContact,
      message: message != null ? message() : this.message,
      internalReference: internalReference != null
          ? internalReference()
          : this.internalReference,
      notifiedAt: notifiedAt ?? this.notifiedAt,
      respondedAt: respondedAt != null ? respondedAt() : this.respondedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
