import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/config/firebase_config.dart';
import '../../../core/constants/app_enums.dart';
import '../../../core/constants/firestore_collections.dart';
import '../../domain/entities/campaign.dart';
import '../../domain/repositories/campaign_repository.dart';
import '../models/campaign_model.dart';

class CampaignRepositoryImpl implements CampaignRepository {
  CampaignRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseConfig.firestore;

  final FirebaseFirestore _firestore;

  @override
  Stream<List<Campaign>> watchOpen() {
    // Un seul filtre : aucun index composite à déclarer. La date de fin
    // et le tri sont appliqués côté client.
    return _firestore
        .collection(FirestoreCollections.campaigns)
        .where(
          'status',
          whereIn: [
            CampaignStatus.published.firestoreValue,
            CampaignStatus.active.firestoreValue,
          ],
        )
        .snapshots()
        .map((snap) {
      final now = DateTime.now();
      return snap.docs
          .map<Campaign>((doc) => CampaignModel.fromMap(doc.data(), doc.id))
          .where((campaign) => campaign.isOpenAt(now))
          .toList()
        ..sort((a, b) => a.startDate.compareTo(b.startDate));
    });
  }
}
