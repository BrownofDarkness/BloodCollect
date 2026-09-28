import '../../../core/constants/app_enums.dart';
import '../../domain/entities/validation_request.dart';
import 'firestore_converters.dart';

// ---- validation_requests
class ValidationRequestModel extends ValidationRequest {
  const ValidationRequestModel({
    required super.id,
    required super.structureId,
    required super.structureType,
    required super.userId,
    required super.documentUrls,
    required super.status,
    super.reviewedBy,
    super.reviewNotes,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ValidationRequestModel.fromMap(Map<String, dynamic> map, String id) {
    return ValidationRequestModel(
      id: id,
      structureId: map['structureId'] as String? ?? '',
      structureType:
          StructureType.fromString(map['structureType'] as String?) ??
          StructureType.healthCenter,
      userId: map['userId'] as String? ?? '',
      documentUrls: ((map['documentUrls'] as List?) ?? [])
          .map((e) => '$e')
          .toList(),
      status:
          VerificationStatus.fromString(map['status'] as String?) ??
          VerificationStatus.pending,
      reviewedBy: map['reviewedBy'] as String?,
      reviewNotes: map['reviewNotes'] as String?,
      createdAt: tsToDate(map['createdAt'], fallback: DateTime.now()),
      updatedAt: tsToDate(map['updatedAt'], fallback: DateTime.now()),
    );
  }

  Map<String, dynamic> toMap() => {
    'structureId': structureId,
    'structureType': structureType.firestoreValue,
    'userId': userId,
    'documentUrls': documentUrls,
    'status': status.firestoreValue,
    'reviewedBy': reviewedBy,
    'reviewNotes': reviewNotes,
    'createdAt': dateToTs(createdAt),
    'updatedAt': dateToTs(updatedAt),
  };
}
