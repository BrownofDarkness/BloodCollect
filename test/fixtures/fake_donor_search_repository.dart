import 'package:blood_collect/core/constants/app_enums.dart';
import 'package:blood_collect/features/citizen/domain/repositories/donor_search_repository.dart';
import 'package:blood_collect/shared/domain/entities/donor_match_request.dart';
import 'package:blood_collect/shared/presentation/models/donor_search_candidate.dart';
import 'package:blood_collect/shared/presentation/models/requester_info.dart';

/// Faux en mémoire du contrat de recherche de donneurs.
///
/// L'implémentation de production est Firestore : elle dépend des règles de
/// sécurité et d'une base réelle, que `flutter test` ne fournit pas. Ce faux
/// permet de garder les tests sur le comportement du domaine — ce qu'une
/// écriture produit, ce qu'un écran relit — sans collection ni règles.
///
/// `failNextSearch` et `failNextSend` forcent un cas d'erreur depuis les
/// écrans sans toucher au code métier.
class FakeDonorSearchRepository implements DonorRepository {
  bool failNextSearch = false;
  bool failNextSend = false;

  /// Candidats proposés à la recherche, dans l'ordre d'insertion.
  final List<DonorSearchCandidate> candidates = [];

  /// Identité du demandeur telle que la production la lit dans la session.
  String requesterId = 'user_citizen_test';

  final Map<String, DonorMatchRequest> _requests = {};
  final Map<String, RequesterInfo> _requesters = {};
  int _autoId = 100;

  void seedRequester(String id, RequesterInfo info) => _requesters[id] = info;

  @override
  Future<List<DonorSearchCandidate>> searchDonors({
    required BloodType bloodType,
    required List<String> communes,
    required Priority priority,
  }) async {
    if (failNextSearch) {
      failNextSearch = false;
      throw Exception('Impossible de contacter le serveur. Réessayez.');
    }

    final results = candidates
        .where(
          (candidate) =>
              candidate.bloodType == bloodType &&
              (communes.isEmpty ||
                  candidate.commune.isEmpty ||
                  communes.contains(candidate.commune)),
        )
        .toList()
      ..sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    return results;
  }

  @override
  Future<DonorMatchRequest> sendMatchRequest({
    required String donorId,
    required BloodType bloodType,
    required Priority priority,
    String? message,
    required bool shareContact,
  }) async {
    if (failNextSend) {
      failNextSend = false;
      throw Exception("Échec de l'envoi. Vérifiez votre connexion.");
    }

    final now = DateTime.now();
    final request = DonorMatchRequest(
      id: 'req_${_autoId++}',
      requesterId: requesterId,
      donorId: donorId,
      bloodType: bloodType,
      priority: priority,
      status: DonorMatchStatus.pending,
      shareContact: shareContact,
      message: message,
      notifiedAt: now,
      expiresAt: now.add(const Duration(hours: 2)),
      createdAt: now,
    );
    _requests[request.id] = request;
    return request;
  }

  @override
  Future<DonorMatchRequest> getIncomingRequest(String requestId) async {
    final request = _requests[requestId];
    if (request == null) throw Exception('Demande introuvable.');
    return request;
  }

  @override
  Future<RequesterInfo> resolveRequester(String requesterId) async =>
      _requesters[requesterId] ??
      const RequesterInfo(
        role: UserRole.citizen,
        displayName: 'Un particulier',
        commune: '—',
      );

  @override
  Future<void> respondToRequest(
    String requestId,
    DonorMatchStatus response,
  ) async {
    final current = _requests[requestId];
    if (current == null) return;
    _requests[requestId] = current.copyWith(
      status: response,
      respondedAt: () => DateTime.now(),
    );
  }
}