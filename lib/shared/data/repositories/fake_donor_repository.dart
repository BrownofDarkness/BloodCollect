import '../../../core/constants/app_enums.dart';
import '../../domain/entities/donor_match_request.dart';
import '../../domain/repositories/donor_repository.dart';
import '../../presentation/models/donor_search_candidate.dart';
import '../../presentation/models/requester_info.dart';
import '../mock/mock_data.dart';

/// Implémentation mock du DonorRepository, alignée sur DonorMatchRequest.
/// `failNextSearch` / `failNextSend` forcent un cas d'erreur depuis les
/// écrans (tests manuels) sans toucher au code métier.
class FakeDonorRepository implements DonorRepository {
  bool failNextSearch = false;
  bool failNextSend = false;

  final Map<String, DonorMatchRequest> _incoming = {
    mockIncomingRequestFromHealthCenter.id: mockIncomingRequestFromHealthCenter,
    mockIncomingRequestFromCitizen.id: mockIncomingRequestFromCitizen,
  };

  int _autoId = 100;

  @override
  Future<List<DonorSearchCandidate>> searchDonors({
    required BloodType bloodType,
    required List<String> communes,
    required Priority priority,
  }) async {
    await Future.delayed(const Duration(milliseconds: 900));

    if (failNextSearch) {
      failNextSearch = false;
      throw Exception('Impossible de contacter le serveur. Réessayez.');
    }

    final pool = [...mockDonorsFixture, ...generateDonorCandidates(15)];
    final results =
        pool
            .where(
              (d) =>
                  d.bloodType == bloodType &&
                  (communes.isEmpty || communes.contains(d.commune)),
            )
            .toList()
          ..sort((a, b) => a.distanceKm.compareTo(b.distanceKm));

    return results;
  }

  @override
  Future<DonorMatchRequest> sendMatchRequest({
    required String donorId,
    required Priority priority,
    String? message,
    required bool shareContact,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));
    if (failNextSend) {
      failNextSend = false;
      throw Exception("Échec de l'envoi. Vérifiez votre connexion.");
    }

    final now = DateTime.now();
    final request = DonorMatchRequest(
      id: 'req_${_autoId++}',
      requesterId: mockCitizenProfile.id,
      donorId: donorId,
      bloodType: mockCitizenProfile.bloodType ?? BloodType.oPos,
      priority: priority,
      status: DonorMatchStatus.pending,
      shareContact: shareContact,
      message: message,
      notifiedAt: now,
      expiresAt: now.add(const Duration(hours: 2)),
      createdAt: now,
    );
    _incoming[request.id] = request;
    return request;
  }

  @override
  Future<DonorMatchRequest> getIncomingRequest(String requestId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final request = _incoming[requestId];
    if (request == null) throw Exception('Demande introuvable.');
    return request;
  }

  @override
  Future<RequesterInfo> resolveRequester(String requesterId) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final match = mockRequesters[requesterId];
    if (match == null) {
      return const RequesterInfo(
        role: UserRole.citizen,
        displayName: 'Un particulier',
        commune: '—',
      );
    }
    return RequesterInfo(
      role: match.role,
      displayName: match.name,
      commune: match.commune,
    );
  }

  @override
  Future<void> respondToRequest(
    String requestId,
    DonorMatchStatus response,
  ) async {
    await Future.delayed(const Duration(milliseconds: 700));
    final current = _incoming[requestId];
    if (current != null) {
      _incoming[requestId] = current.copyWith(
        status: response,
        respondedAt: () => DateTime.now(),
      );
    }
  }
}
