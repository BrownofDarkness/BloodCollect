import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/config/firebase_config.dart';
import '../../../core/constants/app_enums.dart';
import '../../../core/constants/firestore_collections.dart';
import '../../domain/entities/campaign_registration.dart';
import '../../domain/repositories/campaign_registration_repository.dart';
import '../models/campaign_registration_model.dart';

class CampaignRegistrationRepositoryImpl
    implements CampaignRegistrationRepository {
  CampaignRegistrationRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseConfig.firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection(FirestoreCollections.campaignRegistrations);

  @override
  Stream<List<CampaignRegistration>> watchByDonor(String donorId) {
    // Les règles n'ouvrent la lecture qu'au donneur : le filtre est
    // obligatoire.
    return _col.where('donorId', isEqualTo: donorId).snapshots().map(
          (snap) => snap.docs
              .map<CampaignRegistration>(
                (doc) => CampaignRegistrationModel.fromMap(doc.data(), doc.id),
              )
              .toList(),
        );
  }

  @override
  Stream<List<CampaignRegistration>> watchByBloodCenter(String bloodCenterId) {
    // Les règles n'ouvrent au centre que les inscriptions de ses collectes :
    // le filtre est obligatoire.
    return _col.where('bloodCenterId', isEqualTo: bloodCenterId).snapshots().map(
          (snap) => snap.docs
              .map<CampaignRegistration>(
                (doc) => CampaignRegistrationModel.fromMap(doc.data(), doc.id),
              )
              .toList(),
        );
  }

  @override
  Future<void> register({
    required String campaignId,
    required String bloodCenterId,
    required String donorId,
  }) async {
    final ref = _col.doc(
      CampaignRegistration.idFor(campaignId: campaignId, donorId: donorId),
    );
    // Recherche par requête et non par `ref.get()` : les règles lisent
    // `resource.data.donorId`, donc la lecture directe d'un document qui
    // n'existe pas encore est refusée (permission-denied).
    final existing = await _col
        .where('donorId', isEqualTo: donorId)
        .where('campaignId', isEqualTo: campaignId)
        .limit(1)
        .get();
    if (existing.docs.isNotEmpty) {
      // Réinscription : les règles ne laissent modifier que le statut.
      await ref.update({
        'status': RegistrationStatus.registered.firestoreValue,
      });
      return;
    }
    await ref.set({
      'campaignId': campaignId,
      'donorId': donorId,
      'bloodCenterId': bloodCenterId,
      'scheduledTime': null,
      'status': RegistrationStatus.registered.firestoreValue,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> cancel(String registrationId) {
    // Les règles ne laissent modifier que le statut (pas updatedAt).
    return _col.doc(registrationId).update({
      'status': RegistrationStatus.cancelled.firestoreValue,
    });
  }
}
