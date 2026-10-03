import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/config/firebase_config.dart';
import '../../../core/constants/firestore_collections.dart';
import '../../domain/entities/blood_request.dart';
import '../../domain/repositories/blood_request_repository.dart';
import '../models/blood_request_model.dart';

class BloodRequestRepositoryImpl implements BloodRequestRepository {
  BloodRequestRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseConfig.firestore;

  final FirebaseFirestore _firestore;

  @override
  Future<String> create(BloodRequest request) async {
    final ref = _firestore.collection(FirestoreCollections.bloodRequests).doc();
    final data = BloodRequestModel(
      id: ref.id,
      healthCenterId: request.healthCenterId,
      bloodType: request.bloodType,
      productType: request.productType,
      quantityNeeded: request.quantityNeeded,
      quantityFulfilled: request.quantityFulfilled,
      patientReference: request.patientReference,
      priority: request.priority,
      status: request.status,
      bloodRouteStep: request.bloodRouteStep,
      mobilizationRadius: request.mobilizationRadius,
      matchedBloodCenterId: request.matchedBloodCenterId,
      quantityGranted: request.quantityGranted,
      responseMessage: request.responseMessage,
      notes: request.notes,
      createdAt: request.createdAt,
      updatedAt: request.updatedAt,
      receivedAt: request.receivedAt,
      processedAt: request.processedAt,
      expiresAt: request.expiresAt,
    ).toMap()
      // Heure serveur : l'horloge du téléphone n'est pas fiable.
      ..['createdAt'] = FieldValue.serverTimestamp()
      ..['updatedAt'] = FieldValue.serverTimestamp();
    await ref.set(data);
    return ref.id;
  }

  @override
  Stream<List<BloodRequest>> watchByHealthCenter(String healthCenterId) {
    // Tri côté client : un orderBy imposerait un index composite.
    return _firestore
        .collection(FirestoreCollections.bloodRequests)
        .where('healthCenterId', isEqualTo: healthCenterId)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map<BloodRequest>(
                (doc) => BloodRequestModel.fromMap(doc.data(), doc.id),
              )
              .toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
        );
  }
}
