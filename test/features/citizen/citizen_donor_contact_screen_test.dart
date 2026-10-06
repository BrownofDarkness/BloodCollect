import 'package:blood_collect/core/constants/app_enums.dart';
import 'package:blood_collect/core/router/app_router.dart';
import 'package:blood_collect/core/theme/app_theme.dart';
import 'package:blood_collect/features/auth/domain/entities/auth_user.dart';
import 'package:blood_collect/features/auth/presentation/providers/auth_providers.dart';
import 'package:blood_collect/features/citizen/presentation/screens/citizen_donor_contact_screen.dart';
import 'package:blood_collect/shared/domain/entities/entities.dart';
import 'package:blood_collect/shared/domain/repositories/donor_match_repository.dart';
import 'package:blood_collect/shared/domain/repositories/user_repository.dart';
import 'package:blood_collect/shared/presentation/providers/repository_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

final _now = DateTime.now();

const _selection = DonorContactSelection(
  criteria: DonorSearchCriteria(
    bloodType: BloodType.oPos,
    city: 'Abidjan',
    communes: ['Treichville', 'Marcory'],
    priority: Priority.elevated,
  ),
  candidates: [
    DonorCandidate(
      donorId: 'd2',
      bloodType: BloodType.oPos,
      commune: 'Marcory',
      distanceKm: 4.2,
    ),
  ],
);

class _FakeUserRepository implements UserRepository {
  @override
  Stream<AppUser?> watchById(String id) => Stream.value(
        AppUser(
          id: id,
          email: 'aya@mail.ci',
          firstName: 'Aya',
          lastName: 'Koné',
          role: UserRole.citizen,
          bloodType: BloodType.aPos,
          city: 'Abidjan',
          commune: 'Treichville',
          createdAt: _now,
          updatedAt: _now,
        ),
      );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeDonorMatchRepository implements DonorMatchRepository {
  final created = <DonorMatchRequest>[];
  bool fail = false;

  @override
  Future<void> createAll(List<DonorMatchRequest> requests) async {
    if (fail) throw Exception('hors ligne');
    created.addAll(requests);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _FakeDonorMatchRepository matches;

  setUp(() => matches = _FakeDonorMatchRepository());

  Future<void> pumpScreen(
    WidgetTester tester, {
    DonorContactSelection? selection = _selection,
  }) async {
    tester.view.physicalSize = const Size(390, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final router = GoRouter(
      initialLocation: AppRoutes.citizenDonorResults,
      routes: [
        GoRoute(
          path: AppRoutes.citizenDonors,
          builder: (_, _) => const Text('formulaire donneurs'),
          routes: [
            GoRoute(
              path: 'results',
              builder: (context, _) => Scaffold(
                body: TextButton(
                  onPressed: () =>
                      context.push(AppRoutes.citizenDonorContact),
                  child: const Text('écran résultats'),
                ),
              ),
            ),
            GoRoute(
              path: 'request',
              builder: (_, _) => CitizenDonorContactScreen(selection: selection),
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
          userRepositoryProvider.overrideWithValue(_FakeUserRepository()),
          donorMatchRepositoryProvider.overrideWithValue(matches),
        ],
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
    // Ouvre la mise en relation par-dessus les résultats, comme dans l'app.
    await tester.tap(find.text('écran résultats'));
    await tester.pumpAndSettle();
  }

  testWidgets('présente le donneur et l’aperçu de la demande', (tester) async {
    await pumpScreen(tester);

    expect(find.text('PERSONNE'), findsOneWidget);
    expect(find.text('Donneur potentiel'), findsOneWidget);
    expect(find.text('Marcory · 4,2 km'), findsOneWidget);
    expect(
      find.text(
        'Une personne recherche un donneur O+, votre groupe sanguin.',
      ),
      findsOneWidget,
    );
    // Commune du demandeur et urgence reprise de la recherche.
    expect(
      find.text(
        'Treichville · Urgence élevée · Don dans un centre agréé uniquement',
      ),
      findsOneWidget,
    );
    // Pas de référence interne : elle est réservée aux centres de santé.
    expect(find.textContaining('Référence interne'), findsNothing);

    await tester.enterText(find.byType(TextFormField), 'Merci');
    await tester.tap(find.text('Vitale'));
    await tester.pumpAndSettle();
    expect(find.text('« Merci »'), findsOneWidget);
    expect(find.textContaining('Urgence vitale'), findsOneWidget);
  });

  testWidgets('envoie la demande puis revient aux résultats', (tester) async {
    await pumpScreen(tester);

    await tester.enterText(find.byType(TextFormField), '  Merci d’avance  ');
    await tester.tap(find.byType(Switch));
    await tester.tap(find.text('Envoyer la demande'));
    await tester.pumpAndSettle();

    final request = matches.created.single;
    expect(request.requesterId, 'me');
    expect(request.donorId, 'd2');
    expect(request.bloodType, BloodType.oPos);
    expect(request.priority, Priority.elevated);
    expect(request.status, DonorMatchStatus.pending);
    expect(request.shareContact, isFalse);
    expect(request.message, 'Merci d’avance');
    expect(request.internalReference, isNull);
    expect(request.bloodRequestId, isNull);
    expect(
      request.expiresAt.difference(request.notifiedAt),
      DonorMatchRequest.responseWindow,
    );

    expect(find.text('écran résultats'), findsOneWidget);
    expect(find.text('Demande envoyée au donneur.'), findsOneWidget);
  });

  testWidgets('reste sur l’écran si l’envoi échoue', (tester) async {
    matches.fail = true;
    await pumpScreen(tester);

    await tester.enterText(find.byType(TextFormField), 'Merci');
    await tester.tap(find.text('Envoyer la demande'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Envoi impossible'), findsOneWidget);
    expect(find.text('Demande de mise en relation'), findsOneWidget);
    expect(find.text('Merci'), findsOneWidget);
  });

  testWidgets('signale une sélection perdue', (tester) async {
    await pumpScreen(tester, selection: null);

    expect(find.text('Aucun donneur sélectionné'), findsOneWidget);
    expect(find.text('Envoyer la demande'), findsNothing);
  });
}
