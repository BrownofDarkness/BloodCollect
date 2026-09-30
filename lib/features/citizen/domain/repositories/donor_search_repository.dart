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
  Future<DonorMatchRequest> sendMatchRequest({
    required String donorId,
    required Priority priority,
    String? message,
    required bool shareContact,
  });

  Future<DonorMatchRequest> getIncomingRequest(String requestId);

  Future<RequesterInfo> resolveRequester(String requesterId);

  /// NOTE : DonorMatchStatus n'a pas de valeur "indisponible" — mappé sur
  /// `declined` en attendant une décision d'équipe (cf. message de conversation).
  Future<void> respondToRequest(String requestId, DonorMatchStatus response);
}
