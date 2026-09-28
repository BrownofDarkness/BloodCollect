import '../../../core/constants/app_enums.dart';
import '../../domain/entities/donor_match_request.dart';
import 'firestore_converters.dart';

// ---- donor_match_requests
class DonorMatchRequestModel extends DonorMatchRequest {
  const DonorMatchRequestModel({
    required super.id,
    required super.requesterId,
    super.bloodRequestId,
    required super.donorId,
    required super.bloodType,
    required super.priority,
    required super.status,
    required super.shareContact,
    super.message,
    super.internalReference,
    required super.notifiedAt,
    super.respondedAt,
    required super.expiresAt,
    required super.createdAt,
  });

  factory DonorMatchRequestModel.fromMap(Map<String, dynamic> map, String id) {
    return DonorMatchRequestModel(
      id: id,
      requesterId: map['requesterId'] as String? ?? '',
      bloodRequestId: map['bloodRequestId'] as String?,
      donorId: map['donorId'] as String? ?? '',
      bloodType:
          BloodType.fromString(map['bloodType'] as String?) ?? BloodType.oPos,
      priority:
          Priority.fromString(map['priority'] as String?) ?? Priority.normal,
      status:
          DonorMatchStatus.fromString(map['status'] as String?) ??
          DonorMatchStatus.pending,
      shareContact: map['shareContact'] as bool? ?? false,
      message: map['message'] as String?,
      internalReference: map['internalReference'] as String?,
      notifiedAt: tsToDate(map['notifiedAt'], fallback: DateTime.now()),
      respondedAt: tsToDateOrNull(map['respondedAt']),
      expiresAt: tsToDate(map['expiresAt'], fallback: DateTime.now()),
      createdAt: tsToDate(map['createdAt'], fallback: DateTime.now()),
    );
  }

  Map<String, dynamic> toMap() => {
    'requesterId': requesterId,
    'bloodRequestId': bloodRequestId,
    'donorId': donorId,
    'bloodType': bloodType.firestoreValue,
    'priority': priority.firestoreValue,
    'status': status.firestoreValue,
    'shareContact': shareContact,
    'message': message,
    'internalReference': internalReference,
    'notifiedAt': dateToTs(notifiedAt),
    'respondedAt': respondedAt == null ? null : dateToTs(respondedAt!),
    'expiresAt': dateToTs(expiresAt),
    'createdAt': dateToTs(createdAt),
  };
}
