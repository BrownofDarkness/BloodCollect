import 'package:blood_collect/core/constants/app_enums.dart';
import 'package:blood_collect/shared/domain/entities/donor_match_request.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fixtures/fake_donor_search_repository.dart';

/// Le bouton de notification de l'accueil doit refléter les demandes réelles :
/// une pastille quand il y a quelque chose à traiter, et l'ouverture de la
/// bonne demande au tap.
void main() {
  late FakeDonorSearchRepository repo;

  DonorMatchRequest request({
    required String id,
    required DonorMatchStatus status,
    required DateTime createdAt,
  }) => DonorMatchRequest(
    id: id,
    requesterId: 'centre_1',
    donorId: 'user_citizen_test',
    bloodType: BloodType.oPos,
    priority: Priority.elevated,
    status: status,
    shareContact: false,
    message: 'Don de sang urgent',
    notifiedAt: createdAt,
    expiresAt: createdAt.add(const Duration(days: 7)),
    createdAt: createdAt,
  );

  setUp(() => repo = FakeDonorSearchRepository());

  test('sans demande reçue, la liste est vide', () async {
    expect(await repo.incomingRequests(), isEmpty);
  });

  test('les demandes reçues sont triées de la plus récente à la plus ancienne', () async {
    final ancient = DateTime(2026, 1, 10);
    final recent = DateTime(2026, 2, 20);
    repo.incoming
      ..add(request(id: 'a', status: DonorMatchStatus.accepted, createdAt: ancient))
      ..add(request(id: 'b', status: DonorMatchStatus.pending, createdAt: recent));

    final received = await repo.incomingRequests();

    expect(received.map((r) => r.id), ['b', 'a']);
  });

  test('la demande en attente est identifiée même si une autre est répondue', () async {
    repo.incoming
      ..add(
        request(
          id: 'old',
          status: DonorMatchStatus.declined,
          createdAt: DateTime(2026, 1, 10),
        ),
      )
      ..add(
        request(
          id: 'live',
          status: DonorMatchStatus.pending,
          createdAt: DateTime(2026, 1, 11),
        ),
      );

    final pending = repo.incoming.where(
      (r) => r.status == DonorMatchStatus.pending,
    );
    expect(pending.single.id, 'live');
  });

  test('une demande répondue ne reste plus en attente', () async {
    repo.incoming.add(
      request(
        id: 'done',
        status: DonorMatchStatus.accepted,
        createdAt: DateTime(2026, 1, 10),
      ),
    );

    final pending = repo.incoming.where(
      (r) => r.status == DonorMatchStatus.pending,
    );
    expect(pending, isEmpty);
  });
}