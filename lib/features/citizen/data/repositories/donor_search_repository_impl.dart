import '../../../../core/constants/app_enums.dart';
import '../../../../shared/domain/entities/donor_match_request.dart';
import '../../../../shared/presentation/models/donor_search_candidate.dart';
import '../../../../shared/presentation/models/requester_info.dart';
import '../../domain/repositories/donor_search_repository.dart';
import '../datasources/donor_search_remote_datasource.dart';

/// Implémentation Firestore de la recherche de donneurs et des mises en
/// relation.
///
/// La distance d'un donneur n'est pas calculable : `AppUser` ne porte pas de
/// coordonnées et un citoyen ne partage pas sa position. La projection
/// renvoie donc une distance nulle et l'écran s'appuie sur la commune, seule
/// information réellement disponible.
class DonorSearchRepositoryImpl implements DonorRepository {
  const DonorSearchRepositoryImpl(this._remote);

  final DonorSearchRemoteDataSource _remote;

  @override
  Future<List<DonorSearchCandidate>> searchDonors({
    required BloodType bloodType,
    required List<String> communes,
    required Priority priority,
  }) => _remote.searchDonors(
    bloodType: bloodType,
    communes: communes,
    priority: priority,
  );

  @override
  Future<DonorMatchRequest> sendMatchRequest({
    required String donorId,
    required BloodType bloodType,
    required Priority priority,
    String? message,
    required bool shareContact,
  }) => _remote.sendMatchRequest(
    donorId: donorId,
    bloodType: bloodType,
    priority: priority,
    message: message,
    shareContact: shareContact,
  );

  @override
  Future<DonorMatchRequest> getIncomingRequest(String requestId) async {
    final request = await _remote.getIncomingRequest(requestId);
    if (request == null) {
      throw StateError('Demande introuvable.');
    }
    return request;
  }

  @override
  Future<RequesterInfo> resolveRequester(String requesterId) =>
      _remote.resolveRequester(requesterId);

  @override
  Future<void> respondToRequest(
    String requestId,
    DonorMatchStatus response,
  ) => _remote.respondToRequest(requestId, response);
}