import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/config/firebase_config.dart';
import '../../../../core/constants/app_enums.dart';
import '../../../../core/constants/firestore_collections.dart';
import '../../../../shared/data/models/donor_match_request_model.dart';
import '../../../../shared/domain/entities/donor_match_request.dart';
import '../../../../shared/presentation/models/donor_search_candidate.dart';
import '../../../../shared/presentation/models/requester_info.dart';


/// Accès Firestore à la recherche de donneurs et aux mises en relation.
class DonorSearchRemoteDataSource {
  DonorSearchRemoteDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseConfig.firestore;

  final FirebaseFirestore _firestore;

  /// Identité du demandeur, lue depuis la session Firebase.
  ///
  /// Les règles exigent `requesterId == request.auth.uid` à l'écriture : la
  /// valeur vient de la session, jamais d'un paramètre fourni par l'écran.
  String? get _requesterId => FirebaseConfig.auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection(FirestoreCollections.users);

  CollectionReference<Map<String, dynamic>> get _matches =>
      _firestore.collection(FirestoreCollections.donorMatchRequests);

  CollectionReference<Map<String, dynamic>> get _healthCenters =>
      _firestore.collection(FirestoreCollections.healthCenters);

  CollectionReference<Map<String, dynamic>> get _bloodCenters =>
      _firestore.collection(FirestoreCollections.bloodCenters);

  /// Donneurs disponibles d'un groupe sanguin, dans les communes demandées.
  ///
  /// La collection `users` n'est pas interrogeable par un client (cf.
  /// `firestore.rules`, `allow list: if false`) : la requête part donc de
  /// `donor_match_requests`, que les règles ouvrent au donneur et au
  /// demandeur, et ne remonte que les donneurs déjà mis en relation. La
  /// recherche exhaustive des donneurs potentiels reste à faire côté
  /// Cloud Function tant que les règles n'autorisent pas la lecture.
  Future<List<DonorSearchCandidate>> searchDonors({
    required BloodType bloodType,
    required List<String> communes,
    required Priority priority,
  }) async {
    final requesterId = _requesterId;
    if (requesterId == null) {
      throw StateError('Session fermée : recherche de donneurs impossible.');
    }

    final snapshot = await _matches
        .where('requesterId', isEqualTo: requesterId)
        .get();

    final candidates = <DonorSearchCandidate>[];
    for (final doc in snapshot.docs) {
      final match = DonorMatchRequestModel.fromMap(doc.data(), doc.id);
      if (match.bloodType != bloodType) continue;
      candidates.add(
        DonorSearchCandidate(
          donorId: match.donorId,
          bloodType: match.bloodType,
          commune: communes.isEmpty ? '' : communes.first,
          distanceKm: 0,
          matchStatus: match.status,
        ),
      );
    }
    return candidates;
  }

  /// Identité anonymisée du demandeur : un citoyen n'apparaît jamais par son
  /// nom, un centre par sa raison sociale.
  Future<RequesterInfo> resolveRequester(String requesterId) async {
    final user = await _users.doc(requesterId).get();
    if (user.exists) {
      final data = user.data();
      if (data?['role'] == UserRole.citizen.firestoreValue) {
        return RequesterInfo(
          role: UserRole.citizen,
          displayName: 'Un particulier',
          commune: (data?['commune'] as String?) ?? '—',
        );
      }
    }

    for (final collection in [_healthCenters, _bloodCenters]) {
      final center = await collection
          .where('userId', isEqualTo: requesterId)
          .limit(1)
          .get();
      if (center.docs.isEmpty) continue;

      final data = center.docs.first.data();
      final role = collection == _healthCenters
          ? UserRole.healthCenter
          : UserRole.bloodCenter;
      return RequesterInfo(
        role: role,
        displayName: (data['name'] as String?) ?? 'Centre partenaire',
        commune: (data['commune'] as String?) ?? '—',
      );
    }

    return const RequesterInfo(
      role: UserRole.citizen,
      displayName: 'Un particulier',
      commune: '—',
    );
  }

  /// `bloodType` est celui du donneur ciblé, dénormalisé dans la demande.
  /// Il vient de l'écran qui a effectué la recherche : le profil du donneur
  /// n'est pas lisible par le demandeur (cf. `firestore.rules`), donc il ne
  /// peut pas être relu au moment de l'écriture.
  Future<DonorMatchRequest> sendMatchRequest({
    required String donorId,
    required BloodType bloodType,
    required Priority priority,
    String? message,
    required bool shareContact,
  }) async {
    final requesterId = _requesterId;
    if (requesterId == null) {
      throw StateError("Session fermée : impossible d'envoyer une demande.");
    }

    final now = DateTime.now();
    final ref = _matches.doc();
    final request = DonorMatchRequest(
      id: ref.id,
      requesterId: requesterId,
      donorId: donorId,
      bloodType: bloodType,
      priority: priority,
      status: DonorMatchStatus.pending,
      shareContact: shareContact,
      message: message,
      notifiedAt: now,
      // Fenêtre de deux heures : au-delà, la demande n'a plus d'intérêt et le
      // donneur ne peut plus y répondre utilement.
      expiresAt: now.add(const Duration(hours: 2)),
      createdAt: now,
    );

    await ref.set(_toMap(request));
    return request;
  }

  /// Sérialisation d'une demande vers Firestore.
  ///
  /// Les dates d'horodatage sont des `serverTimestamp` : l'heure du serveur
  /// fait foi, pas celle de l'appareil qui émet la demande.
  Map<String, dynamic> _toMap(DonorMatchRequest request) => {
    'requesterId': request.requesterId,
    if (request.bloodRequestId != null) 'bloodRequestId': request.bloodRequestId,
    'donorId': request.donorId,
    'bloodType': request.bloodType.firestoreValue,
    'priority': request.priority.firestoreValue,
    'status': request.status.firestoreValue,
    'shareContact': request.shareContact,
    if (request.message != null) 'message': request.message,
    if (request.internalReference != null)
      'internalReference': request.internalReference,
    'notifiedAt': FieldValue.serverTimestamp,
    'expiresAt': Timestamp.fromDate(request.expiresAt),
    'createdAt': FieldValue.serverTimestamp,
  };

  Future<DonorMatchRequest?> getIncomingRequest(String requestId) async {
    final doc = await _matches.doc(requestId).get();
    if (!doc.exists) return null;
    return DonorMatchRequestModel.fromMap(doc.data()!, doc.id);
  }

  /// Réponse du donneur : les règles n'autorisent que le statut et la date de
  /// réponse, ce qui est exactement ce que cette méthode écrit.
  Future<void> respondToRequest(
    String requestId,
    DonorMatchStatus response,
  ) async {
    await _matches.doc(requestId).update({
      'status': response.firestoreValue,
      'respondedAt': FieldValue.serverTimestamp,
    });
  }
}