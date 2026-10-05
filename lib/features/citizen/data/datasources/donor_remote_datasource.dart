import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/config/firebase_config.dart';
import '../../../../core/constants/firestore_collections.dart';
import '../../../../shared/data/models/models.dart';
import '../../../../shared/domain/entities/entities.dart';

/// Accès Firestore au profil du citoyen connecté et à son activité de donneur.
class DonorRemoteDataSource {
  DonorRemoteDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseConfig.firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection(FirestoreCollections.users);

  CollectionReference<Map<String, dynamic>> get _matches =>
      _firestore.collection(FirestoreCollections.donorMatchRequests);

  /// Profil du connecté, ou `null` si aucun utilisateur Firebase n'est
  /// authentifié. Distinct de `userById` : ici l'identité vient de la session.
  Future<AppUser?> currentUser() async {
    final auth = FirebaseConfig.auth.currentUser;
    if (auth == null) return null;
    return userById(auth.uid);
  }

  Future<AppUser?> userById(String id) async {
    final doc = await _users.doc(id).get();
    if (!doc.exists) return null;
    return AppUserModel.fromMap(doc.data()!, doc.id);
  }

  /// Mises en relation où le citoyen est donneur cible ou demandeur, de
  /// l'ordre de la plus récente : c'est l'ordre d'un fil de discussion.
  ///
  /// Le tri par date est fait côté client. Un `orderBy('createdAt')` couplé à
  /// l'un de ces filtres exige un index composite, donc un déploiement avant
  /// que la requête ne réponde ; or l'onglet Profil ne doit pas dépendre de
  /// cette étape. Un citoyen n'a qu'une poignée de mises en relation.
  Future<List<DonorMatchRequest>> matchesOf(String citizenId) async {
    final donorSide = await _matches
        .where('donorId', isEqualTo: citizenId)
        .get();
    final requesterSide = await _matches
        .where('requesterId', isEqualTo: citizenId)
        .get();

    final docs = <QueryDocumentSnapshot<Map<String, dynamic>>>[
      ...donorSide.docs,
      ...requesterSide.docs.where(
        (doc) => !donorSide.docs.any((d) => d.id == doc.id),
      ),
    ];

    return docs
        .map((doc) => DonorMatchRequestModel.fromMap(doc.data(), doc.id))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<DonorMatchRequest?> matchById(String requestId) async {
    final doc = await _matches.doc(requestId).get();
    if (!doc.exists) return null;
    return DonorMatchRequestModel.fromMap(doc.data()!, doc.id);
  }
}