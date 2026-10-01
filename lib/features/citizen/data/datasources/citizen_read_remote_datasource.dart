import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/config/firebase_config.dart';
import '../../../../core/constants/firestore_collections.dart';
import '../../../../shared/data/models/models.dart';
import '../../../../shared/domain/entities/entities.dart';

/// Lectures de l'accueil : profil du citoyen connecté, centres vérifiés,
/// collectes publiées.
class CitizenReadRemoteDataSource {
  CitizenReadRemoteDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseConfig.firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection(FirestoreCollections.users);

  CollectionReference<Map<String, dynamic>> get _centers =>
      _firestore.collection(FirestoreCollections.bloodCenters);

  CollectionReference<Map<String, dynamic>> get _campaigns =>
      _firestore.collection(FirestoreCollections.campaigns);

  /// Profil du connecté. `null` si la session n'est pas ouverte ou si le
  /// document `users` n'existe pas encore.
  Future<AppUser?> currentProfile() async {
    final auth = FirebaseConfig.auth.currentUser;
    if (auth == null) return null;

    final doc = await _users.doc(auth.uid).get();
    if (!doc.exists) return null;
    return AppUserModel.fromMap(doc.data()!, doc.id);
  }

  /// Centres vérifiés, tous villes confondues.
  Future<List<BloodCenter>> verifiedCenters() async {
    final snapshot = await _centers
        .where('verificationStatus', isEqualTo: 'verified')
        .get();
    return snapshot.docs
        .map((doc) => BloodCenterModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  /// Collectes publiées et actives, de la plus proche de commencer à la plus
  /// lointaine.
  ///
  /// Le tri est fait ici et non par `orderBy` : croiser un filtre `status` avec
  /// un tri `startDate` exige un index composite, donc un déploiement des
  /// règles avant que la requête ne fonctionne. L'ensemble tient en quelques
  /// dizaines de documents.
  Future<List<Campaign>> publishedCampaigns() async {
    final snapshot = await _campaigns
        .where(Filter('status', whereIn: const ['published', 'active']))
        .get();
    return snapshot.docs
        .map((doc) => CampaignModel.fromMap(doc.data(), doc.id))
        .toList()
      ..sort((a, b) => a.startDate.compareTo(b.startDate));
  }
}