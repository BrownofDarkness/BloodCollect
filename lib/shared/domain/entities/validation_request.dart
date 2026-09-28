import '../../../core/constants/app_enums.dart';

// collection --- validation_requests/{validationId}
class ValidationRequest {
  const ValidationRequest({
    required this.id,
    required this.structureId,
    required this.structureType,
    required this.userId,
    required this.documentUrls,
    required this.status,
    this.reviewedBy,
    this.reviewNotes,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String structureId;
  final StructureType structureType;
  final String userId;
  final List<String> documentUrls;
  final VerificationStatus status;
  final String? reviewedBy;
  final String? reviewNotes;
  final DateTime createdAt;
  final DateTime updatedAt;

  ValidationRequest copyWith({
    String? id,
    String? structureId,
    StructureType? structureType,
    String? userId,
    List<String>? documentUrls,
    VerificationStatus? status,
    String? Function()? reviewedBy,
    String? Function()? reviewNotes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ValidationRequest(
      id: id ?? this.id,
      structureId: structureId ?? this.structureId,
      structureType: structureType ?? this.structureType,
      userId: userId ?? this.userId,
      documentUrls: documentUrls ?? this.documentUrls,
      status: status ?? this.status,
      reviewedBy: reviewedBy != null ? reviewedBy() : this.reviewedBy,
      reviewNotes: reviewNotes != null ? reviewNotes() : this.reviewNotes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
