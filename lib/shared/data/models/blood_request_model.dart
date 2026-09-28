import '../../../core/constants/app_enums.dart';
import '../../domain/entities/blood_request.dart';
import 'firestore_converters.dart';

// ---- blood_requests
class BloodRequestModel extends BloodRequest {
  const BloodRequestModel({
    required super.id,
    required super.healthCenterId,
    required super.bloodType,
    required super.productType,
    required super.quantityNeeded,
    super.quantityFulfilled = 0,
    super.patientReference,
    required super.priority,
    required super.status,
    required super.bloodRouteStep,
    super.mobilizationRadius,
    super.matchedBloodCenterId,
    super.quantityGranted,
    super.responseMessage,
    super.notes,
    required super.createdAt,
    required super.updatedAt,
    super.receivedAt,
    super.processedAt,
    super.expiresAt,
  });

  factory BloodRequestModel.fromMap(Map<String, dynamic> map, String id) {
    return BloodRequestModel(
      id: id,
      healthCenterId: map['healthCenterId'] as String? ?? '',
      bloodType:
          BloodType.fromString(map['bloodType'] as String?) ?? BloodType.oPos,
      productType: ProductType.fromString(map['productType'] as String?) ??
          ProductType.wholeBlood,
      quantityNeeded: (map['quantityNeeded'] as num?)?.toInt() ?? 0,
      quantityFulfilled: (map['quantityFulfilled'] as num?)?.toInt() ?? 0,
      patientReference: map['patientReference'] as String?,
      priority:
          Priority.fromString(map['priority'] as String?) ?? Priority.normal,
      status: RequestStatus.fromString(map['status'] as String?) ??
          RequestStatus.pending,
      bloodRouteStep: BloodRouteStep.fromString(
              map['bloodRouteStep'] as String?) ??
          BloodRouteStep.searchingStock,
      mobilizationRadius: (map['mobilizationRadius'] as num?)?.toInt(),
      matchedBloodCenterId: map['matchedBloodCenterId'] as String?,
      quantityGranted: (map['quantityGranted'] as num?)?.toInt(),
      responseMessage: map['responseMessage'] as String?,
      notes: map['notes'] as String?,
      createdAt: tsToDate(map['createdAt'], fallback: DateTime.now()),
      updatedAt: tsToDate(map['updatedAt'], fallback: DateTime.now()),
      receivedAt: tsToDateOrNull(map['receivedAt']),
      processedAt: tsToDateOrNull(map['processedAt']),
      expiresAt: tsToDateOrNull(map['expiresAt']),
    );
  }

  Map<String, dynamic> toMap() => {
        'healthCenterId': healthCenterId,
        'bloodType': bloodType.firestoreValue,
        'productType': productType.firestoreValue,
        'quantityNeeded': quantityNeeded,
        'quantityFulfilled': quantityFulfilled,
        'patientReference': patientReference,
        'priority': priority.firestoreValue,
        'status': status.firestoreValue,
        'bloodRouteStep': bloodRouteStep.firestoreValue,
        'mobilizationRadius': mobilizationRadius,
        'matchedBloodCenterId': matchedBloodCenterId,
        'quantityGranted': quantityGranted,
        'responseMessage': responseMessage,
        'notes': notes,
        'createdAt': dateToTs(createdAt),
        'updatedAt': dateToTs(updatedAt),
        'receivedAt': receivedAt == null ? null : dateToTs(receivedAt!),
        'processedAt': processedAt == null ? null : dateToTs(processedAt!),
        'expiresAt': expiresAt == null ? null : dateToTs(expiresAt!),
      };
}
