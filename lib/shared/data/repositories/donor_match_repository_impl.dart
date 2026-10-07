import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/config/firebase_config.dart';
import '../../../core/constants/app_enums.dart';
import '../../../core/constants/firestore_collections.dart';
import '../../domain/entities/donor_match_request.dart';
import '../../domain/repositories/donor_match_repository.dart';
import '../models/donor_match_request_model.dart';

class DonorMatchRepositoryImpl implements DonorMatchRepository {
  DonorMatchRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseConfig.firestore;

  final FirebaseFirestore _firestore;

  @override
  Future<void> createAll(List<DonorMatchRequest> requests) async {
    final col = _firestore.collection(FirestoreCollections.donorMatchRequests);
    final batch = _firestore.batch();
    for (final request in requests) {
      final ref = col.doc();
      batch.set(
        ref,
        DonorMatchRequestModel(
          id: ref.id,
          requesterId: request.requesterId,
          bloodRequestId: request.bloodRequestId,
          donorId: request.donorId,
          bloodType: request.bloodType,
          priority: request.priority,
          status: request.status,
          shareContact: request.shareContact,
          message: request.message,
          internalReference: request.internalReference,
          notifiedAt: request.notifiedAt,
          respondedAt: request.respondedAt,
          expiresAt: request.expiresAt,
          createdAt: request.createdAt,
        ).toMap()
          // Heure serveur : l'horloge du téléphone n'est pas fiable.
          ..['createdAt'] = FieldValue.serverTimestamp(),
      );
    }
    await batch.commit();
  }

  @override
  Stream<List<DonorMatchRequest>> watchByRequester(String requesterId) =>
      _watchWhere('requesterId', requesterId);

  @override
  Stream<List<DonorMatchRequest>> watchByDonor(String donorId) =>
      _watchWhere('donorId', donorId);

  @override
  Stream<DonorMatchRequest?> watchById(String id) {
    return _firestore
        .collection(FirestoreCollections.donorMatchRequests)
        .doc(id)
        .snapshots()
        .map((snap) {
      if (!snap.exists) return null;
      return DonorMatchRequestModel.fromMap(snap.data()!, snap.id);
    });
  }

  @override
  Future<void> respond(String id, DonorMatchStatus status) {
    // Les règles n'autorisent le donneur à modifier que ces deux champs.
    return _firestore
        .collection(FirestoreCollections.donorMatchRequests)
        .doc(id)
        .update({
      'status': status.firestoreValue,
      'respondedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<DonorMatchRequest>> _watchWhere(String field, String uid) {
    // Les règles n'ouvrent la lecture qu'au demandeur et au donneur : le
    // filtre est obligatoire. Tri côté client pour éviter un index composite.
    return _firestore
        .collection(FirestoreCollections.donorMatchRequests)
        .where(field, isEqualTo: uid)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map<DonorMatchRequest>(
                (doc) => DonorMatchRequestModel.fromMap(doc.data(), doc.id),
              )
              .toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
        );
  }
}
