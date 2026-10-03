import '../../../core/constants/app_enums.dart';

// Avancement d'une demande vu par le centre de santé, déduit du statut
// et des horodatages. Non persisté : pas de valeur Firestore.
enum RequestProgress {
  waiting,
  received,
  processing,
  approved,
  partial,
  refused,
  oriented,
  cancelled,
  expired;

  /// Encore à suivre : aucune décision finale n'a clos la demande.
  bool get isOngoing => switch (this) {
        waiting || received || processing || oriented => true,
        _ => false,
      };

  /// Décision rendue et demande close (approuvée, partielle ou refusée).
  bool get isProcessed => isDecision && !isOngoing;

  /// Le centre de transfusion a rendu sa décision.
  bool get isDecision => switch (this) {
        approved || partial || refused || oriented => true,
        _ => false,
      };
}

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

  RequestProgress get progress => switch (status) {
        RequestStatus.pending => receivedAt == null
            ? RequestProgress.waiting
            : RequestProgress.received,
        RequestStatus.routing => RequestProgress.processing,
        RequestStatus.fulfilled => RequestProgress.approved,
        RequestStatus.partiallyFulfilled => RequestProgress.partial,
        RequestStatus.oriented => RequestProgress.oriented,
        // Pas de statut « refusée » : une annulation traitée par le centre
        // de transfusion (processedAt renseigné) est lue comme un refus.
        RequestStatus.cancelled => processedAt == null
            ? RequestProgress.cancelled
            : RequestProgress.refused,
        RequestStatus.expired => RequestProgress.expired,
      };

  /// Le centre de transfusion a pris connaissance de la demande.
  bool get isReceived =>
      receivedAt != null ||
      progress == RequestProgress.processing ||
      progress.isDecision;

  /// Heure de la décision, null tant qu'elle n'est pas rendue.
  DateTime? get decidedAt =>
      progress.isDecision ? (processedAt ?? updatedAt) : null;

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
