import '../../../core/constants/app_enums.dart';

// collection --- blood_requests/{requestId} (collection centrale du Blood Route)
class BloodRequest {
  const BloodRequest({
    required this.id,
    required this.healthCenterId,
    required this.bloodType,
    required this.productType,
    required this.quantityNeeded,
    this.quantityFulfilled = 0,
    this.patientReference,
    required this.priority,
    required this.status,
    required this.bloodRouteStep,
    this.mobilizationRadius,
    this.matchedBloodCenterId,
    this.quantityGranted,
    this.responseMessage,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.receivedAt,
    this.processedAt,
    this.expiresAt,
  });

  final String id;
  final String healthCenterId;
  final BloodType bloodType;
  final ProductType productType;
  final int quantityNeeded;
  final int quantityFulfilled;
  final String? patientReference;
  final Priority priority;
  final RequestStatus status;
  final BloodRouteStep bloodRouteStep;
  // 5, 10 ou 20 km
  final int? mobilizationRadius;
  final String? matchedBloodCenterId;
  final int? quantityGranted;
  final String? responseMessage;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? receivedAt;
  final DateTime? processedAt;
  final DateTime? expiresAt;

  int get remainingUnits => quantityNeeded - quantityFulfilled;

  BloodRequest copyWith({
    String? id,
    String? healthCenterId,
    BloodType? bloodType,
    ProductType? productType,
    int? quantityNeeded,
    int? quantityFulfilled,
    String? Function()? patientReference,
    Priority? priority,
    RequestStatus? status,
    BloodRouteStep? bloodRouteStep,
    int? Function()? mobilizationRadius,
    String? Function()? matchedBloodCenterId,
    int? Function()? quantityGranted,
    String? Function()? responseMessage,
    String? Function()? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? Function()? receivedAt,
    DateTime? Function()? processedAt,
    DateTime? Function()? expiresAt,
  }) {
    return BloodRequest(
      id: id ?? this.id,
      healthCenterId: healthCenterId ?? this.healthCenterId,
      bloodType: bloodType ?? this.bloodType,
      productType: productType ?? this.productType,
      quantityNeeded: quantityNeeded ?? this.quantityNeeded,
      quantityFulfilled: quantityFulfilled ?? this.quantityFulfilled,
      patientReference: patientReference != null
          ? patientReference()
          : this.patientReference,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      bloodRouteStep: bloodRouteStep ?? this.bloodRouteStep,
      mobilizationRadius: mobilizationRadius != null
          ? mobilizationRadius()
          : this.mobilizationRadius,
      matchedBloodCenterId: matchedBloodCenterId != null
          ? matchedBloodCenterId()
          : this.matchedBloodCenterId,
      quantityGranted:
          quantityGranted != null ? quantityGranted() : this.quantityGranted,
      responseMessage:
          responseMessage != null ? responseMessage() : this.responseMessage,
      notes: notes != null ? notes() : this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      receivedAt: receivedAt != null ? receivedAt() : this.receivedAt,
      processedAt: processedAt != null ? processedAt() : this.processedAt,
      expiresAt: expiresAt != null ? expiresAt() : this.expiresAt,
    );
  }
}
