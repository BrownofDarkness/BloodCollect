import '../../../../core/constants/app_enums.dart';
import '../../../../shared/presentation/models/donor_search_candidate.dart';
import '../../../../shared/presentation/models/requester_info.dart';
import '../../../../shared/domain/entities/donor_match_request.dart';

/// Contrat d'accès aux donneurs / mises en relation, aligné sur la
/// collection réelle `donor_match_requests` (cf. donor_match_request.dart).
abstract class DonorRepository {
  Future<List<DonorSearchCandidate>> searchDonors({
    required BloodType bloodType,
    required List<String> communes,
    required Priority priority,
  });

  /// Crée une DonorMatchRequest (recherche directe, bloodRequestId = null).
  ///
  /// `bloodType` est celui du donneur ciblé. Il est dénormalisé dans la
  /// demande parce que le profil du donneur n'est pas lisible par le
  /// demandeur : seul l'écran qui a fait la recherche le connaît.
  Future<DonorMatchRequest> sendMatchRequest({
    required String donorId,
    required BloodType bloodType,
    required Priority priority,
    String? message,
    required bool shareContact,
  });

  Future<DonorMatchRequest> getIncomingRequest(String requestId);

  /// Demandes de mobilisation adressées au citoyen connecté, la plus récente
  /// d'abord. Alimente le compteur de l'accueil et la liste des demandes reçues.
  Future<List<DonorMatchRequest>> incomingRequests();

  Future<RequesterInfo> resolveRequester(String requesterId);

  /// NOTE : DonorMatchStatus n'a pas de valeur "indisponible" — mappé sur
  /// `declined` en attendant une décision d'équipe (cf. message de conversation).
  Future<void> respondToRequest(String requestId, DonorMatchStatus response);
}
