import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

import '../../../core/config/firebase_config.dart';
import '../../../core/constants/app_enums.dart';
import '../../../core/constants/firestore_collections.dart';
import '../../domain/entities/blood_center.dart';
import '../../domain/entities/health_center.dart';
import '../../domain/entities/validation_request.dart';
import '../../domain/repositories/center_repository.dart';
import '../models/blood_center_model.dart';
import '../models/health_center_model.dart';
import '../models/validation_request_model.dart';

class CenterRepositoryImpl implements CenterRepository {
  CenterRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseConfig.firestore,
        _storage = storage ?? FirebaseConfig.storage;

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  @override
  Future<String> createHealthCenter(HealthCenter center) async {
    final ref = _firestore.collection(FirestoreCollections.healthCenters).doc();
    final data = HealthCenterModel(
      id: ref.id,
      userId: center.userId,
      name: center.name,
      address: center.address,
      city: center.city,
      commune: center.commune,
      location: center.location,
      phone: center.phone,
      establishmentType: center.establishmentType,
      authorizationNumber: center.authorizationNumber,
      contactFunction: center.contactFunction,
      verificationStatus: center.verificationStatus,
      createdAt: center.createdAt,
      updatedAt: center.updatedAt,
    ).toMap()
      ..['updatedAt'] = FieldValue.serverTimestamp();
    await ref.set(data);
    return ref.id;
  }

  @override
  Future<String> createBloodCenter(BloodCenter center) async {
    final ref = _firestore.collection(FirestoreCollections.bloodCenters).doc();
    final data = BloodCenterModel(
      id: ref.id,
      userId: center.userId,
      name: center.name,
      address: center.address,
      city: center.city,
      commune: center.commune,
      location: center.location,
      phone: center.phone,
      agreementNumber: center.agreementNumber,
      contactFunction: center.contactFunction,
      openingHoursWeekdays: center.openingHoursWeekdays,
      openingHoursSaturday: center.openingHoursSaturday,
      lowStockThreshold: center.lowStockThreshold,
      unavailableThreshold: center.unavailableThreshold,
      verificationStatus: center.verificationStatus,
      createdAt: center.createdAt,
      updatedAt: center.updatedAt,
    ).toMap()
      ..['updatedAt'] = FieldValue.serverTimestamp();
    await ref.set(data);
    return ref.id;
  }

  @override
  Future<void> createValidationRequest(ValidationRequest request) async {
    final ref = _firestore
        .collection(FirestoreCollections.validationRequests)
        .doc();
    final data = ValidationRequestModel(
      id: ref.id,
      structureId: request.structureId,
      structureType: request.structureType,
      userId: request.userId,
      documentUrls: request.documentUrls,
      status: request.status,
      reviewedBy: request.reviewedBy,
      reviewNotes: request.reviewNotes,
      createdAt: request.createdAt,
      updatedAt: request.updatedAt,
    ).toMap()
      ..['updatedAt'] = FieldValue.serverTimestamp();
    await ref.set(data);
  }

  @override
  Future<String> uploadValidationDoc({
    required String uid,
    required String fileName,
    required List<int> bytes,
  }) async {
    final ref = _storage
        .ref()
        .child(FirebaseConfig.validationDocPath(uid, fileName));
    await ref.putData(Uint8List.fromList(bytes));
    return ref.getDownloadURL();
  }

  @override
  Stream<VerificationStatus?> watchVerificationStatus({
    required String userId,
    required UserRole role,
  }) {
    final collection = role == UserRole.healthCenter
        ? FirestoreCollections.healthCenters
        : FirestoreCollections.bloodCenters;
    return _firestore
        .collection(collection)
        .where('userId', isEqualTo: userId)
        .limit(1)
        .snapshots()
        .map((query) {
      if (query.docs.isEmpty) return null;
      return VerificationStatus.fromString(
        query.docs.first.data()['verificationStatus'] as String?,
      );
    });
  }

  @override
  Stream<HealthCenter?> watchHealthCenterByUser(String userId) {
    return _firestore
        .collection(FirestoreCollections.healthCenters)
        .where('userId', isEqualTo: userId)
        .limit(1)
        .snapshots()
        .map((query) {
      if (query.docs.isEmpty) return null;
      final doc = query.docs.first;
      return HealthCenterModel.fromMap(doc.data(), doc.id);
    });
  }

  @override
  Stream<BloodCenter?> watchBloodCenter(String centerId) {
    return _firestore
        .collection(FirestoreCollections.bloodCenters)
        .doc(centerId)
        .snapshots()
        .map((snap) {
      if (!snap.exists) return null;
      return BloodCenterModel.fromMap(snap.data()!, snap.id);
    });
  }

  @override
  Stream<List<BloodCenter>> watchVerifiedBloodCenters({
    required String city,
    String? commune,
  }) {
    // Égalités uniquement : aucun index composite à déclarer.
    var query = _firestore
        .collection(FirestoreCollections.bloodCenters)
        .where('city', isEqualTo: city)
        .where(
          'verificationStatus',
          isEqualTo: VerificationStatus.verified.firestoreValue,
        );
    if (commune != null) {
      query = query.where('commune', isEqualTo: commune);
    }
    return query.snapshots().map(
          (snap) => snap.docs
              .map((doc) => BloodCenterModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }
}
