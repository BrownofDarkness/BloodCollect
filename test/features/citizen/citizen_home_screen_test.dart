import 'package:blood_collect/core/constants/app_enums.dart';
import 'package:blood_collect/core/router/app_router.dart';
import 'package:blood_collect/core/theme/app_theme.dart';
import 'package:blood_collect/core/utils/formatters.dart';
import 'package:blood_collect/features/auth/domain/entities/auth_user.dart';
import 'package:blood_collect/features/auth/presentation/providers/auth_providers.dart';
import 'package:blood_collect/features/citizen/presentation/screens/citizen_home_screen.dart';
import 'package:blood_collect/shared/domain/entities/entities.dart';
import 'package:blood_collect/shared/domain/repositories/campaign_repository.dart';
import 'package:blood_collect/shared/domain/repositories/donor_match_repository.dart';
import 'package:blood_collect/shared/domain/repositories/user_repository.dart';
import 'package:blood_collect/shared/presentation/providers/repository_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

final _now = DateTime.now();

Campaign _campaign(
  String title, {
  String? commune,
  List<String> targetCommunes = const [],
  int startsInDays = 3,
}) {
  final day = DateTime(_now.year, _now.month, _now.day)
      .add(Duration(days: startsInDays));
  return Campaign(
    id: title,
    bloodCenterId: 'bc1',
    title: title,
    description: '',
    location: const GeoLocation(latitude: 0, longitude: 0),
    locationName: 'Place de la mairie',
    commune: commune,
    startDate: day.add(const Duration(hours: 8)),
    endDate: day.add(const Duration(hours: 14)),
    targetBloodTypes: const [BloodType.oNeg, BloodType.bNeg],
    targetCommunes: targetCommunes,
    targetUnits: 50,
    status: CampaignStatus.published,
    createdAt: _now,
    updatedAt: _now,
  );
}

DonorMatchRequest _request(
  String id, {
  DonorMatchStatus status = DonorMatchStatus.pending,
  Duration expiresIn = const Duration(hours: 2),
}) =>
    DonorMatchRequest(
      id: id,
      requesterId: 'hc-user',
      donorId: 'u1',
      bloodType: BloodType.oPos,
      priority: Priority.normal,
      status: status,
      shareContact: true,
      notifiedAt: _now,
      expiresAt: _now.add(expiresIn),
      createdAt: _now,
    );

class _FakeUserRepository implements UserRepository {
  _FakeUserRepository({this.commune = 'Treichville'});

  final String? commune;

  @override
  Stream<AppUser?> watchById(String id) => Stream.value(
        AppUser(
          id: id,
          email: 'aya@mail.ci',
          firstName: 'Aya',
          lastName: 'Koné',
          role: UserRole.citizen,
          bloodType: BloodType.oPos,
          city: commune == null ? null : 'Abidjan',
          commune: commune,
          createdAt: _now,
          updatedAt: _now,
        ),
      );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeCampaignRepository implements CampaignRepository {
  _FakeCampaignRepository(this.campaigns);

  final List<Campaign> campaigns;

  @override
  Stream<List<Campaign>> watchOpen() => Stream.value(campaigns);
}

class _FakeDonorMatchRepository implements DonorMatchRepository {
  _FakeDonorMatchRepository(this.requests, this.sent);

  final List<DonorMatchRequest> requests;
  final List<DonorMatchRequest> sent;
  String? watchedDonor;

  @override
  Stream<List<DonorMatchRequest>> watchByRequester(String requesterId) =>
      Stream.value(sent);

  @override
  Stream<List<DonorMatchRequest>> watchByDonor(String donorId) {
    watchedDonor = donorId;
    return Stream.value(requests);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _FakeDonorMatchRepository matches;

  Future<void> pumpScreen(
    WidgetTester tester, {
    List<Campaign> campaigns = const [],
    List<DonorMatchRequest> requests = const [],
    List<DonorMatchRequest> sent = const [],
    String? commune = 'Treichville',
  }) async {
    tester.view.physicalSize = const Size(390, 2200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    matches = _FakeDonorMatchRepository(requests, sent);

    GoRoute stub(String path, String label) =>
        GoRoute(path: path, builder: (_, _) => Text(label));
    final router = GoRouter(
      initialLocation: AppRoutes.citizenHome,
      routes: [
        GoRoute(
          path: AppRoutes.citizenHome,
          builder: (_, _) => const CitizenHomeScreen(),
        ),
        stub(AppRoutes.citizenDonors, 'écran donneurs'),
        stub(AppRoutes.citizenBlood, 'écran sang'),
        stub(AppRoutes.citizenDonate, 'écran donner'),
        stub(AppRoutes.citizenMatches, 'écran mises en relation'),
        GoRoute(
          path: '${AppRoutes.citizenIncoming}/:requestId',
          builder: (_, state) =>
              Text('demande ${state.pathParameters['requestId']}'),
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
          userRepositoryProvider
              .overrideWithValue(_FakeUserRepository(commune: commune)),
          campaignRepositoryProvider
              .overrideWithValue(_FakeCampaignRepository(campaigns)),
          donorMatchRepositoryProvider.overrideWithValue(matches),
        ],
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('affiche l’identité du donneur et les trois actions',
      (tester) async {
    await pumpScreen(tester);

    expect(find.text('CITOYEN'), findsOneWidget);
    expect(find.text('Aya Koné'), findsOneWidget);
    expect(find.text('O+'), findsOneWidget);
    expect(find.text('Treichville, Abidjan'), findsOneWidget);
    expect(find.text('Chercher un donneur'), findsOneWidget);
    expect(find.text('Voir la disponibilité de sang'), findsOneWidget);
    expect(find.text('Je veux donner mon sang'), findsOneWidget);
  });

  testWidgets('mène aux trois parcours', (tester) async {
    for (final (action, destination) in [
      ('Chercher un donneur', 'écran donneurs'),
      ('Voir la disponibilité de sang', 'écran sang'),
      ('Je veux donner mon sang', 'écran donner'),
      ('Tout voir', 'écran donner'),
    ]) {
      await pumpScreen(tester);
      await tester.tap(find.text(action));
      await tester.pumpAndSettle();
      expect(find.text(destination), findsOneWidget, reason: action);
    }
  });

  testWidgets('ne liste que les collectes de la commune, deux au plus',
      (tester) async {
    await pumpScreen(
      tester,
      campaigns: [
        _campaign('Collecte de Treichville', commune: 'Treichville'),
        _campaign('Collecte de Cocody', commune: 'Cocody'),
        _campaign(
          'Collecte du Plateau',
          commune: 'Plateau',
          targetCommunes: ['Treichville'],
        ),
        _campaign('Collecte bis', commune: 'Treichville', startsInDays: 9),
      ],
    );

    expect(find.text('Collecte de Treichville'), findsOneWidget);
    // Cible la commune du citoyen bien qu'elle se tienne ailleurs.
    expect(find.text('Collecte du Plateau'), findsOneWidget);
    expect(find.text('Collecte de Cocody'), findsNothing);
    expect(find.text('Collecte bis'), findsNothing);
    expect(find.text('Place de la mairie, Treichville'), findsOneWidget);
    expect(find.text('O-'), findsNWidgets(2));
    expect(find.textContaining('8h00 – 14h00'), findsNWidgets(2));
  });

  testWidgets('explique l’absence de collecte, commune connue ou non',
      (tester) async {
    await pumpScreen(
      tester,
      campaigns: [_campaign('Collecte de Cocody', commune: 'Cocody')],
    );
    expect(find.textContaining('Aucune collecte prévue'), findsOneWidget);

    await pumpScreen(
      tester,
      commune: null,
      campaigns: [_campaign('Collecte de Cocody', commune: 'Cocody')],
    );
    expect(find.text('Non renseignée'), findsOneWidget);
    expect(find.textContaining('Aucune collecte prévue'), findsOneWidget);
  });

  testWidgets('la cloche de notifications est masquée en v1', (tester) async {
    await pumpScreen(tester, requests: [_request('r-attente')]);

    expect(matches.watchedDonor, 'u1');
    expect(find.byIcon(Icons.notifications_outlined), findsNothing);
  });

  group('demandes reçues', () {
    testWidgets('aucune carte quand rien n’attend', (tester) async {
      await pumpScreen(
        tester,
        requests: [
          _request('r-acceptee', status: DonorMatchStatus.accepted),
          _request('r-expiree', expiresIn: const Duration(hours: -1)),
        ],
      );

      expect(find.textContaining('vous attend'), findsNothing);
      expect(find.text('Répondre'), findsNothing);
    });

    testWidgets('une demande en attente : « Répondre » l’ouvre',
        (tester) async {
      await pumpScreen(
        tester,
        requests: [
          _request('r-attente'),
          _request('r-acceptee', status: DonorMatchStatus.accepted),
        ],
      );

      expect(find.text('Une demande de don vous attend'), findsOneWidget);
      expect(
        find.textContaining('Donneur O+ recherché · Urgence normale'),
        findsOneWidget,
      );

      await tester.tap(find.text('Répondre'));
      await tester.pumpAndSettle();
      expect(find.text('demande r-attente'), findsOneWidget);
    });

    testWidgets('plusieurs demandes en attente : ouvre la liste',
        (tester) async {
      await pumpScreen(
        tester,
        requests: [_request('r1'), _request('r2')],
      );

      expect(find.text('2 demandes de don vous attendent'), findsOneWidget);

      await tester.tap(find.text('Voir les demandes'));
      await tester.pumpAndSettle();
      expect(find.text('écran mises en relation'), findsOneWidget);
    });
  });

  group('demandes envoyées', () {
    testWidgets('aucune carte tant que rien n’a été envoyé', (tester) async {
      await pumpScreen(tester);

      expect(find.text('Mes demandes envoyées'), findsNothing);
    });

    testWidgets('résume les réponses et ouvre le suivi', (tester) async {
      await pumpScreen(
        tester,
        sent: [
          _request('s1', status: DonorMatchStatus.accepted),
          _request('s2'),
          _request('s3'),
          // En attente mais délai dépassé : comptée comme expirée.
          _request('s4', expiresIn: const Duration(hours: -1)),
          _request('s5', status: DonorMatchStatus.declined),
        ],
      );

      expect(find.text('1 acceptée · 2 en attente'), findsOneWidget);

      await tester.tap(find.text('Mes demandes envoyées'));
      await tester.pumpAndSettle();
      expect(find.text('écran mises en relation'), findsOneWidget);
    });
  });

  test('Campaign : ouverture et commune concernée', () {
    final open = _campaign('A', commune: 'Treichville');
    expect(open.isOpenAt(_now), isTrue);
    expect(open.isOpenAt(_now.add(const Duration(days: 30))), isFalse);
    expect(
      open.copyWith(status: CampaignStatus.draft).isOpenAt(_now),
      isFalse,
    );
    expect(open.concernsCommune('Treichville'), isTrue);
    expect(open.concernsCommune('Cocody'), isFalse);
  });

  test('Formatters.schedule', () {
    expect(
      Formatters.schedule(
        DateTime(2026, 10, 17, 8),
        DateTime(2026, 10, 17, 14),
      ),
      'Samedi 17 octobre · 8h00 – 14h00',
    );
    expect(
      Formatters.schedule(
        DateTime(2026, 10, 17, 8, 30),
        DateTime(2026, 10, 18, 14),
      ),
      'Samedi 17 octobre 8h30 → Dimanche 18 octobre 14h00',
    );
  });
}
