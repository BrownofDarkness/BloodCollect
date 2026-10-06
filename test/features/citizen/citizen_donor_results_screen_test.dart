import 'package:blood_collect/core/constants/app_enums.dart';
import 'package:blood_collect/core/router/app_router.dart';
import 'package:blood_collect/core/theme/app_theme.dart';
import 'package:blood_collect/features/auth/domain/entities/auth_user.dart';
import 'package:blood_collect/features/auth/presentation/providers/auth_providers.dart';
import 'package:blood_collect/features/citizen/presentation/screens/citizen_donor_results_screen.dart';
import 'package:blood_collect/shared/domain/entities/entities.dart';
import 'package:blood_collect/shared/domain/repositories/donor_match_repository.dart';
import 'package:blood_collect/shared/domain/repositories/donor_repository.dart';
import 'package:blood_collect/shared/presentation/providers/repository_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

final _now = DateTime.now();

const _criteria = DonorSearchCriteria(
  bloodType: BloodType.oPos,
  city: 'Abidjan',
  communes: ['Treichville', 'Marcory'],
  priority: Priority.elevated,
);

DonorCandidate _candidate(String id, String commune, [double? km]) =>
    DonorCandidate(
      donorId: id,
      bloodType: BloodType.oPos,
      commune: commune,
      distanceKm: km,
    );

DonorMatchRequest _sent(
  String donorId,
  DonorMatchStatus status, {
  Duration expiresIn = const Duration(hours: 2),
  Duration age = Duration.zero,
}) =>
    DonorMatchRequest(
      id: '$donorId-${status.name}-${age.inMinutes}',
      requesterId: 'me',
      donorId: donorId,
      bloodType: BloodType.oPos,
      priority: Priority.normal,
      status: status,
      shareContact: true,
      notifiedAt: _now.subtract(age),
      expiresAt: _now.add(expiresIn),
      createdAt: _now.subtract(age),
    );

class _FakeDonorRepository implements DonorRepository {
  _FakeDonorRepository(this.result, {this.fail = false});

  final List<DonorCandidate> result;
  final bool fail;

  @override
  Future<List<DonorCandidate>> search(DonorSearchCriteria criteria) async {
    if (fail) throw Exception('hors ligne');
    return result;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeDonorMatchRepository implements DonorMatchRepository {
  _FakeDonorMatchRepository(this.sent);

  final List<DonorMatchRequest> sent;

  @override
  Stream<List<DonorMatchRequest>> watchByRequester(String requesterId) =>
      Stream.value(sent);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  DonorContactSelection? selection;

  Future<void> pumpScreen(
    WidgetTester tester, {
    DonorSearchCriteria? criteria = _criteria,
    List<DonorCandidate> result = const [],
    List<DonorMatchRequest> sent = const [],
    bool fail = false,
  }) async {
    tester.view.physicalSize = const Size(390, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    selection = null;

    final router = GoRouter(
      initialLocation: AppRoutes.citizenDonorResults,
      routes: [
        GoRoute(
          path: AppRoutes.citizenDonors,
          builder: (_, _) => const Text('formulaire donneurs'),
          routes: [
            GoRoute(
              path: 'results',
              builder: (_, _) => CitizenDonorResultsScreen(criteria: criteria),
            ),
            GoRoute(
              path: 'request',
              builder: (_, state) {
                selection = state.extra as DonorContactSelection?;
                return const Text('écran mise en relation');
              },
            ),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith(
            (ref) => Stream.value(const AuthUser(id: 'me', email: 'a@b.ci')),
          ),
          donorRepositoryProvider
              .overrideWithValue(_FakeDonorRepository(result, fail: fail)),
          donorMatchRepositoryProvider
              .overrideWithValue(_FakeDonorMatchRepository(sent)),
        ],
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('rappelle les critères et liste les donneurs anonymisés',
      (tester) async {
    await pumpScreen(
      tester,
      result: [
        _candidate('d1', 'Treichville', 2.5),
        _candidate('d2', 'Marcory'),
        // Le demandeur correspond lui-même aux critères : il est écarté.
        _candidate('me', 'Treichville'),
      ],
    );

    expect(find.text('PERSONNE'), findsOneWidget);
    expect(find.text('Treichville, Marcory'), findsOneWidget);
    expect(find.text('Urgence élevée'), findsOneWidget);
    expect(
      find.text('Un donneur n’est pas du sang disponible.'),
      findsOneWidget,
    );
    expect(
      find.text('2 donneurs correspondent à votre recherche'),
      findsOneWidget,
    );
    expect(find.text('Donneur potentiel'), findsNWidgets(2));
    expect(find.text('Treichville · 2,5 km'), findsOneWidget);
    expect(find.text('Contacter'), findsNWidgets(2));
  });

  testWidgets('remplace le bouton par l’état de la demande déjà envoyée',
      (tester) async {
    await pumpScreen(
      tester,
      result: [
        _candidate('d1', 'Treichville'),
        _candidate('d2', 'Marcory'),
        _candidate('d3', 'Marcory'),
        _candidate('d4', 'Marcory'),
      ],
      sent: [
        _sent('d1', DonorMatchStatus.pending),
        _sent('d2', DonorMatchStatus.accepted),
        // Expirée : le donneur redevient contactable.
        _sent('d3', DonorMatchStatus.pending,
            expiresIn: const Duration(hours: -1)),
      ],
    );

    expect(find.text('Demande envoyée'), findsNWidgets(2));
    expect(find.text('En attente de réponse'), findsOneWidget);
    expect(find.text('Acceptée'), findsOneWidget);
    expect(find.text('Contacter'), findsNWidgets(2));
  });

  testWidgets('la demande la plus récente fait foi', (tester) async {
    await pumpScreen(
      tester,
      result: [_candidate('d1', 'Treichville')],
      // Triées de la plus récente à la plus ancienne, comme le dépôt.
      sent: [
        _sent('d1', DonorMatchStatus.pending),
        _sent('d1', DonorMatchStatus.declined, age: const Duration(days: 3)),
      ],
    );

    expect(find.text('En attente de réponse'), findsOneWidget);
    expect(find.text('Déclinée'), findsNothing);
  });

  testWidgets('contacter transmet le donneur choisi', (tester) async {
    await pumpScreen(
      tester,
      result: [
        _candidate('d1', 'Treichville'),
        _candidate('d2', 'Marcory'),
      ],
    );

    await tester.tap(find.text('Contacter').last);
    await tester.pumpAndSettle();

    expect(find.text('écran mise en relation'), findsOneWidget);
    expect(selection!.criteria, _criteria);
    expect(selection!.candidates.map((c) => c.donorId), ['d2']);
  });

  testWidgets('singulier, liste vide, échec et critères absents',
      (tester) async {
    await pumpScreen(tester, result: [_candidate('d1', 'Treichville')]);
    expect(
      find.text('1 donneur correspond à votre recherche'),
      findsOneWidget,
    );

    await pumpScreen(tester);
    expect(find.text('Aucun donneur ne correspond'), findsOneWidget);

    await pumpScreen(tester, fail: true);
    expect(find.text('Recherche indisponible'), findsOneWidget);
    expect(find.text('Réessayer'), findsOneWidget);

    await pumpScreen(tester, criteria: null);
    expect(find.text('Critères incomplets'), findsOneWidget);
  });
}
