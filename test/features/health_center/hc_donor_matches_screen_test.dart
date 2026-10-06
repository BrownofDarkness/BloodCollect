import 'package:blood_collect/core/constants/app_enums.dart';
import 'package:blood_collect/core/router/app_router.dart';
import 'package:blood_collect/core/theme/app_theme.dart';
import 'package:blood_collect/features/auth/domain/entities/auth_user.dart';
import 'package:blood_collect/features/auth/presentation/providers/auth_providers.dart';
import 'package:blood_collect/features/health_center/presentation/providers/hc_providers.dart';
import 'package:blood_collect/features/health_center/presentation/screens/hc_donor_matches_screen.dart';
import 'package:blood_collect/shared/presentation/widgets/donor_match_card.dart';
import 'package:blood_collect/shared/domain/entities/entities.dart';
import 'package:blood_collect/shared/domain/repositories/donor_match_repository.dart';
import 'package:blood_collect/shared/domain/repositories/donor_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

final _now = DateTime.now();

DonorMatchRequest _match(
  String reference,
  DonorMatchStatus status, {
  Duration age = const Duration(minutes: 30),
  Duration expiresIn = const Duration(hours: 20),
  bool responded = false,
  Priority priority = Priority.normal,
}) =>
    DonorMatchRequest(
      id: reference,
      requesterId: 'u1',
      donorId: 'donor-$reference',
      bloodType: BloodType.oPos,
      priority: priority,
      status: status,
      shareContact: true,
      internalReference: reference,
      notifiedAt: _now.subtract(age),
      respondedAt: responded ? _now : null,
      expiresAt: _now.add(expiresIn),
      createdAt: _now.subtract(age),
    );

class _FakeDonorMatchRepository implements DonorMatchRepository {
  _FakeDonorMatchRepository(this.matches);

  final List<DonorMatchRequest> matches;
  String? watchedRequester;

  @override
  Stream<List<DonorMatchRequest>> watchByRequester(String requesterId) {
    watchedRequester = requesterId;
    return Stream.value(matches);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeDonorRepository implements DonorRepository {
  // Donneurs dont les coordonnées ont été demandées.
  final requested = <String>[];
  bool fail = false;
  bool missing = false;

  @override
  Future<DonorContact?> contactOf(String donorId) async {
    requested.add(donorId);
    if (fail) throw Exception('hors ligne');
    if (missing) return null;
    return DonorContact(
      donorId: donorId,
      fullName: 'Awa Koné',
      phone: '+2250700000000',
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _FakeDonorMatchRepository repository;
  late _FakeDonorRepository donors;

  Future<void> pumpScreen(
    WidgetTester tester,
    List<DonorMatchRequest> matches, {
    bool contactFails = false,
    bool contactMissing = false,
  }) async {
    tester.view.physicalSize = const Size(390, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    repository = _FakeDonorMatchRepository(matches);
    donors = _FakeDonorRepository()
      ..fail = contactFails
      ..missing = contactMissing;

    final router = GoRouter(
      initialLocation: AppRoutes.hcDonorMatches,
      routes: [
        GoRoute(
          path: AppRoutes.hcProfile,
          builder: (_, _) => const Text('écran profil'),
          routes: [
            GoRoute(
              path: 'matches',
              builder: (_, _) => const HcDonorMatchesScreen(),
            ),
          ],
        ),
        GoRoute(
          path: AppRoutes.hcDonors,
          builder: (_, _) => const Text('écran donneurs'),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith(
            (ref) => Stream.value(const AuthUser(id: 'u1', email: 'a@b.ci')),
          ),
          donorMatchRepositoryProvider.overrideWithValue(repository),
          donorRepositoryProvider.overrideWithValue(donors),
        ],
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('liste les réponses, acceptations en tête', (tester) async {
    await pumpScreen(tester, [
      _match('DOS-1', DonorMatchStatus.declined, responded: true),
      _match('DOS-2', DonorMatchStatus.pending, priority: Priority.vital),
      _match('DOS-3', DonorMatchStatus.accepted, responded: true),
      // En attente mais délai dépassé : affichée comme expirée.
      _match(
        'DOS-4',
        DonorMatchStatus.pending,
        expiresIn: const Duration(hours: -1),
      ),
    ]);

    expect(repository.watchedRequester, 'u1');
    expect(find.text('1 acceptée · 1 en attente'), findsOneWidget);
    expect(find.text('Acceptée'), findsOneWidget);
    expect(find.text('En attente'), findsOneWidget);
    expect(find.text('Déclinée'), findsOneWidget);
    expect(find.text('Expirée'), findsOneWidget);
    expect(find.text('Sans réponse dans le délai'), findsOneWidget);
    expect(find.textContaining('A accepté'), findsOneWidget);
    expect(find.text('Urgence vitale · envoyée il y a 30 min'), findsOneWidget);

    final order = tester
        .widgetList<DonorMatchCard>(find.byType(DonorMatchCard))
        .map((card) => card.match.internalReference)
        .toList();
    expect(order, ['DOS-3', 'DOS-2', 'DOS-1', 'DOS-4']);

    // Coordonnées affichées, et lues, pour la seule demande acceptée.
    expect(find.text('Awa Koné'), findsOneWidget);
    expect(find.text('+2250700000000'), findsOneWidget);
    expect(find.text('Appeler'), findsOneWidget);
    expect(donors.requested, ['donor-DOS-3']);
  });

  testWidgets('explique un échec de chargement et permet de réessayer',
      (tester) async {
    await pumpScreen(
      tester,
      [_match('DOS-3', DonorMatchStatus.accepted, responded: true)],
      contactFails: true,
    );

    expect(find.text('Coordonnées non chargées'), findsOneWidget);
    expect(
      find.text('Vérifiez votre connexion, puis réessayez.'),
      findsOneWidget,
    );
    expect(find.text('Appeler'), findsNothing);
    // Le reste de la carte reste lisible.
    expect(find.text('Acceptée'), findsOneWidget);

    donors.fail = false;
    await tester.tap(find.text('Réessayer'));
    await tester.pumpAndSettle();

    expect(find.text('Awa Koné'), findsOneWidget);
    expect(find.text('Réessayer'), findsNothing);
  });

  testWidgets('signale un donneur dont le profil n’existe plus',
      (tester) async {
    await pumpScreen(
      tester,
      [_match('DOS-3', DonorMatchStatus.accepted, responded: true)],
      contactMissing: true,
    );

    expect(find.text('Donneur introuvable'), findsOneWidget);
    expect(find.text('Réessayer'), findsNothing);
    expect(find.text('Appeler'), findsNothing);
  });

  testWidgets('invite à chercher un donneur quand la liste est vide',
      (tester) async {
    await pumpScreen(tester, const []);

    expect(find.text('Aucune mise en relation'), findsOneWidget);
    await tester.tap(find.text('Chercher un donneur'));
    await tester.pumpAndSettle();
    expect(find.text('écran donneurs'), findsOneWidget);
  });

  test('DonorMatchRequest.statusAt lit l’expiration', () {
    final pending = _match('X', DonorMatchStatus.pending);
    expect(pending.statusAt(_now), DonorMatchStatus.pending);
    expect(
      pending.statusAt(_now.add(const Duration(days: 2))),
      DonorMatchStatus.expired,
    );
    // Une réponse donnée n'expire pas.
    expect(
      _match('Y', DonorMatchStatus.accepted)
          .statusAt(_now.add(const Duration(days: 2))),
      DonorMatchStatus.accepted,
    );
  });
}
