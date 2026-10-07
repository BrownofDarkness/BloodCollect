import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/config/firebase_config.dart';
import '../../../core/constants/app_enums.dart';
import '../../../core/constants/firestore_collections.dart';
import '../../domain/entities/donor_candidate.dart';
import '../../domain/entities/donor_contact.dart';
import '../../domain/entities/donor_search_criteria.dart';
import '../../domain/repositories/donor_repository.dart';
import '../models/app_user_model.dart';

// MVP sans Cloud Functions : lit directement les profils citoyens de users
// (cf. firestore.rules, `allow list` restreint à role == 'citizen').
// La recherche ne laisse sortir que groupe et commune ; nom et téléphone ne
// sont lus que par [contactOf], après acceptation. Tout citoyen inscrit est considéré comme
// donneur potentiel tant que l'espace Citoyen ne gère pas la disponibilité.
class DonorRepositoryImpl implements DonorRepository {
  DonorRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseConfig.firestore;

  // Plafond de `whereIn` imposé par Firestore.
  static const _maxCommunes = 30;
  static const _maxResults = 50;

  final FirebaseFirestore _firestore;

  @override
  Future<List<DonorCandidate>> search(DonorSearchCriteria criteria) async {
    final communes = criteria.communes.take(_maxCommunes).toList();
    if (communes.isEmpty) return const [];

    // Égalités uniquement : aucun index composite à déclarer.
    final snapshot = await _firestore
        .collection(FirestoreCollections.users)
        .where('role', isEqualTo: UserRole.citizen.firestoreValue)
        .where('bloodType', isEqualTo: criteria.bloodType.firestoreValue)
        .where('city', isEqualTo: criteria.city)
        .where('commune', whereIn: communes)
        .limit(_maxResults)
        .get();

    final candidates = [
      for (final doc in snapshot.docs)
        DonorCandidate(
          donorId: doc.id,
          bloodType: criteria.bloodType,
          commune: doc.data()['commune'] as String? ?? '',
        ),
    ];
    // Faute de position GPS, on regroupe par commune dans l'ordre demandé.
    int rank(DonorCandidate c) => communes.indexOf(c.commune);
    return candidates..sort((a, b) => rank(a).compareTo(rank(b)));
  }

  @override
  Future<DonorContact?> contactOf(String donorId) async {
    // `get` sur users est réservé au propriétaire : on passe par une requête,
    // que la règle `list` accepte tant qu'elle filtre role == 'citizen'.
    final snapshot = await _firestore
        .collection(FirestoreCollections.users)
        .where(FieldPath.documentId, isEqualTo: donorId)
        .where('role', isEqualTo: UserRole.citizen.firestoreValue)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;

    final user = AppUserModel.fromMap(snapshot.docs.first.data(), donorId);
    return DonorContact(
      donorId: donorId,
      fullName: user.fullName,
      phone: user.phone,
      commune: user.commune,
    );
  }
}
