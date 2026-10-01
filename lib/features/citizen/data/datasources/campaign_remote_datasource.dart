import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/config/firebase_config.dart';
import '../../../../core/constants/app_enums.dart';
import '../../../../core/constants/firestore_collections.dart';
import '../../../../shared/data/models/campaign_model.dart';
import '../../../../shared/data/models/campaign_registration_model.dart';
import '../../../../shared/domain/entities/entities.dart';

/// Accès Firestore aux collectes de sang et aux inscriptions des citoyens.
class CampaignRemoteDataSource {
  CampaignRemoteDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseConfig.firestore;

  final FirebaseFirestore _firestore;

  /// Statuts d'une collecte visibles d'un citoyen. Le brouillon reste interne au
  /// centre organisateur, une collecte annulée ne doit plus apparaître.
  static const _visibleStatuses = [
    'published',
    'active',
    'completed',
  ];

  CollectionReference<Map<String, dynamic>> get _campaigns =>
      _firestore.collection(FirestoreCollections.campaigns);

  CollectionReference<Map<String, dynamic>> get _registrations =>
      _firestore.collection(FirestoreCollections.campaignRegistrations);

  /// Collectes à venir. Les brouillons et les annulées sont invisibles des
  /// citoyens, et la fin de la collecte la retire de la liste.
  Future<List<Campaign>> upcomingCampaigns({String? commune}) async {
    // whereIn est le nom actuel de l'opérateur « in » (isIn a été retiré).
    // Trois statuts visibles des citoyens : ni brouillon, ni annulée.
    final snapshot = await _campaigns
        .where(Filter('status', whereIn: _visibleStatuses))
        .orderBy('startDate')
        .get();

    final now = DateTime.now();
    return snapshot.docs
        .map((doc) => CampaignModel.fromMap(doc.data(), doc.id))
        .where((campaign) => campaign.endDate.isAfter(now))
        .where(
          (campaign) =>
              commune == null || campaign.targetCommunes.contains(commune),
        )
        .toList();
  }

  Future<List<Campaign>> upcomingCampaignsOfCenter(String centerId) async {
    final snapshot = await _campaigns
        .where('bloodCenterId', isEqualTo: centerId)
        .orderBy('startDate')
        .get();

    final now = DateTime.now();
    return snapshot.docs
        .map((doc) => CampaignModel.fromMap(doc.data(), doc.id))
        .where(
          (campaign) =>
              campaign.status != CampaignStatus.draft &&
              campaign.status != CampaignStatus.cancelled &&
              campaign.endDate.isAfter(now),
        )
        .toList();
  }

  Future<Campaign?> campaignById(String campaignId) async {
    final doc = await _campaigns.doc(campaignId).get();
    if (!doc.exists) return null;
    return CampaignModel.fromMap(doc.data()!, campaignId);
  }

  Future<List<CampaignRegistration>> registrationsOf(String donorId) async {
    final snapshot = await _registrations
        .where('donorId', isEqualTo: donorId)
        .get();
    return snapshot.docs
        .map((doc) => CampaignRegistrationModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  /// Inscription du donneur. L'identifiant est dérivé de la paire
  /// collecte/doneur : réinscrire réécrit le même document au lieu d'en créer
  /// un second.
  Future<CampaignRegistration> registerToCampaign({
    required String campaignId,
    required String donorId,
    DateTime? scheduledTime,
  }) async {
    final id = '${campaignId}_$donorId';
    final existing = await _registrations.doc(id).get();

    if (existing.exists) {
      final registration = CampaignRegistrationModel.fromMap(
        existing.data()!,
        existing.id,
      );
      if (registration.status != RegistrationStatus.cancelled) {
        return registration;
      }
    }

    final now = FieldValue.serverTimestamp;
    final data = <String, dynamic>{
      'campaignId': campaignId,
      'donorId': donorId,
      'scheduledTime': ?scheduledTime,
      'status': RegistrationStatus.registered.firestoreValue,
      'createdAt': now,
      'updatedAt': now,
    };
    await _registrations.doc(id).set(data, SetOptions(merge: true));

    final created = await _registrations.doc(id).get();
    return CampaignRegistrationModel.fromMap(created.data()!, id);
  }

  Future<void> cancelRegistration(String registrationId) async {
    await _registrations.doc(registrationId).update({
      'status': RegistrationStatus.cancelled.firestoreValue,
      'updatedAt': FieldValue.serverTimestamp,
    });
  }
}
