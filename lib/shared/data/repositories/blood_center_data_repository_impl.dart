import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/config/firebase_config.dart';
import '../../../core/constants/firestore_collections.dart';
import '../../domain/entities/blood_center.dart';
import '../../domain/entities/blood_request.dart';
import '../../domain/entities/blood_stock_lot.dart';
import '../../domain/entities/campaign.dart';
import '../../domain/entities/health_center.dart';
import '../../domain/repositories/blood_center_data_repository.dart';
import '../models/blood_center_model.dart';
import '../models/blood_request_model.dart';
import '../models/blood_stock_lot_model.dart';
import '../models/campaign_model.dart';
import '../models/health_center_model.dart';

class BloodCenterDataRepositoryImpl
    implements BloodCenterDataRepository {
  BloodCenterDataRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseConfig.firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _centers =>
      _firestore.collection(FirestoreCollections.bloodCenters);
  CollectionReference<Map<String, dynamic>> get _healthCenters =>
      _firestore.collection(FirestoreCollections.healthCenters);
  CollectionReference<Map<String, dynamic>> get _lots =>
      _firestore.collection(FirestoreCollections.bloodStockLots);
  CollectionReference<Map<String, dynamic>> get _requests =>
      _firestore.collection(FirestoreCollections.bloodRequests);
  CollectionReference<Map<String, dynamic>> get _campaigns =>
      _firestore.collection(FirestoreCollections.campaigns);

  @override
  Stream<BloodCenter?> watchBloodCenterForUser(String userId) {
    return _centers
        .where('userId', isEqualTo: userId)
        .limit(1)
        .snapshots()
        .map((q) {
      if (q.docs.isEmpty) return null;
      final doc = q.docs.first;
      return BloodCenterModel.fromMap(doc.data(), doc.id);
    });
  }

  @override
  Stream<List<HealthCenter>> watchHealthCenters() {
    return _healthCenters.snapshots().map(
          (q) => q.docs
              .map((d) => HealthCenterModel.fromMap(d.data(), d.id))
              .toList(),
        );
  }

  @override
  Stream<List<BloodStockLot>> watchStockLots(String bloodCenterId) {
    return _lots
        .where('bloodCenterId', isEqualTo: bloodCenterId)
        .snapshots()
        .map(
          (q) => q.docs
              .map((d) => BloodStockLotModel.fromMap(d.data(), d.id))
              .toList(),
        );
  }

  @override
  Future<String> saveStockLot(BloodStockLot lot) async {
    final ref =
        lot.id.isEmpty ? _lots.doc() : _lots.doc(lot.id);
    final data = BloodStockLotModel(
      id: ref.id,
      bloodCenterId: lot.bloodCenterId,
      bloodType: lot.bloodType,
      productType: lot.productType,
      lotReference: lot.lotReference,
      quantity: lot.quantity,
      expiryDate: lot.expiryDate,
      collectionDate: lot.collectionDate,
      provenance: lot.provenance,
      internalNote: lot.internalNote,
      status: lot.status,
      createdAt: lot.createdAt,
      updatedAt: lot.updatedAt,
    ).toMap()
      ..['updatedAt'] = FieldValue.serverTimestamp();
    await ref.set(data, SetOptions(merge: true));
    return ref.id;
  }

  @override
  Future<void> deleteStockLot(String id) => _lots.doc(id).delete();

  @override
  Stream<List<BloodRequest>> watchBloodRequests() {
    return _requests.snapshots().map(
          (q) => q.docs
              .map((d) => BloodRequestModel.fromMap(d.data(), d.id))
              .toList(),
        );
  }

  @override
  Future<void> updateBloodRequest(BloodRequest request) async {
    final data = BloodRequestModel(
      id: request.id,
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
      ..['updatedAt'] = FieldValue.serverTimestamp();
    await _requests.doc(request.id).set(data, SetOptions(merge: true));
  }

  @override
  Stream<List<Campaign>> watchCampaigns(String bloodCenterId) {
    return _campaigns
        .where('bloodCenterId', isEqualTo: bloodCenterId)
        .snapshots()
        .map(
          (q) => q.docs
              .map((d) => CampaignModel.fromMap(d.data(), d.id))
              .toList(),
        );
  }

  @override
  Future<String> saveCampaign(Campaign campaign) async {
    final ref = campaign.id.isEmpty
        ? _campaigns.doc()
        : _campaigns.doc(campaign.id);
    final data = CampaignModel(
      id: ref.id,
      bloodCenterId: campaign.bloodCenterId,
      title: campaign.title,
      description: campaign.description,
      location: campaign.location,
      locationName: campaign.locationName,
      commune: campaign.commune,
      startDate: campaign.startDate,
      endDate: campaign.endDate,
      targetBloodTypes: campaign.targetBloodTypes,
      targetCommunes: campaign.targetCommunes,
      targetUnits: campaign.targetUnits,
      collectedUnits: campaign.collectedUnits,
      notifyDonors: campaign.notifyDonors,
      status: campaign.status,
      createdAt: campaign.createdAt,
      updatedAt: campaign.updatedAt,
    ).toMap()
      ..['updatedAt'] = FieldValue.serverTimestamp();
    await ref.set(data, SetOptions(merge: true));
    return ref.id;
  }

  @override
  Future<void> updateCenterThresholds({
    required String centerId,
    required int low,
    required int unavailable,
  }) {
    return _centers.doc(centerId).update({
      'lowStockThreshold': low,
      'unavailableThreshold': unavailable,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
