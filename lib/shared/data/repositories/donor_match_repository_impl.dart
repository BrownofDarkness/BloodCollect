import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/config/firebase_config.dart';
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
}
