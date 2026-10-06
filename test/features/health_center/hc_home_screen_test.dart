import 'package:blood_collect/core/constants/app_enums.dart';
import 'package:blood_collect/core/router/app_router.dart';
import 'package:blood_collect/core/theme/app_theme.dart';
import 'package:blood_collect/features/auth/domain/entities/auth_user.dart';
import 'package:blood_collect/features/auth/presentation/providers/auth_providers.dart';
import 'package:blood_collect/features/health_center/presentation/providers/hc_providers.dart';
import 'package:blood_collect/features/health_center/presentation/screens/hc_home_screen.dart';
import 'package:blood_collect/shared/domain/entities/entities.dart';
import 'package:blood_collect/shared/domain/repositories/blood_request_repository.dart';
import 'package:blood_collect/shared/domain/repositories/center_repository.dart';
import 'package:blood_collect/shared/domain/repositories/donor_match_repository.dart';
import 'package:blood_collect/shared/domain/repositories/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

final _now = DateTime.now();

BloodRequest _request(
  String id, {
  BloodType bloodType = BloodType.oPos,
  Priority priority = Priority.normal,
  RequestStatus status = RequestStatus.pending,
  Duration age = const Duration(minutes: 22),
  DateTime? processedAt,
}) =>
    BloodRequest(
      id: id,
      healthCenterId: 'hc1',
      bloodType: bloodType,
      productType: ProductType.wholeBlood,
      quantityNeeded: 2,
      priority: priority,
      status: status,
      bloodRouteStep: BloodRouteStep.searchingStock,
      matchedBloodCenterId: 'A',
      createdAt: _now.subtract(age),
      updatedAt: processedAt ?? _now,
      processedAt: processedAt,
    );

class _FakeCenterRepository implements CenterRepository {
  @override
  Stream<HealthCenter?> watchHealthCenterByUser(String userId) => Stream.value(
        HealthCenter(
          id: 'hc1',
          userId: userId,
          name: 'CSCom de Treichville',
          address: '',
          city: 'Abidjan',
          commune: 'Treichville',
          location: const GeoLocation(latitude: 0, longitude: 0),
          phone: '',
          establishmentType: 'Clinique',
          authorizationNumber: '',
          contactFunction: 'Médecin-chef',
          verificationStatus: VerificationStatus.verified,
          createdAt: _now,
          updatedAt: _now,
        ),
      );

  @override
  Stream<BloodCenter?> watchBloodCenter(String centerId) => Stream.value(
        BloodCenter(
          id: centerId,
          userId: 'owner',
          name: 'Centre de transfusion $centerId',
          address: '',
          city: 'Abidjan',
          commune: 'Treichville',
          location: const GeoLocation(latitude: 0, longitude: 0),
          phone: '',
          agreementNumber: '',
          contactFunction: '',
          openingHoursWeekdays: '',
          lowStockThreshold: 20,
          unavailableThreshold: 5,
          verificationStatus: VerificationStatus.verified,
          createdAt: _now,
          updatedAt: _now,
        ),
      );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeUserRepository implements UserRepository {
  @override
  Stream<AppUser?> watchById(String id) => Stream.value(
        AppUser(
          id: id,
          email: 'contact@cscom.ci',
          firstName: 'Dr Kouadio Yao',
          lastName: 'Dr Kouadio Yao',
          role: UserRole.healthCenter,
          createdAt: _now,
          updatedAt: _now,
        ),
      );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeBloodRequestRepository implements BloodRequestRepository {
  _FakeBloodRequestRepository(this.requests);

  final List<BloodRequest> requests;

  @override
  Stream<List<BloodRequest>> watchByHealthCenter(String healthCenterId) =>
      Stream.value(requests);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeDonorMatchRepository implements DonorMatchRepository {
  _FakeDonorMatchRepository(this.matches);

  final List<DonorMatchRequest> matches;

  @override
  Stream<List<DonorMatchRequest>> watchByRequester(String requesterId) =>
      Stream.value(matches);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

DonorMatchRequest _match(
  String id,
  DonorMatchStatus status, {
  Duration expiresIn = const Duration(hours: 20),
}) =>
    DonorMatchRequest(
      id: id,
      requesterId: 'u1',
      donorId: 'donor-$id',
      bloodType: BloodType.oPos,
      priority: Priority.normal,
      status: status,
      shareContact: true,
      notifiedAt: _now,
      expiresAt: _now.add(expiresIn),
      createdAt: _now,
    );

void main() {
  Future<void> pumpScreen(
    WidgetTester tester,
    List<BloodRequest> requests, {
    List<DonorMatchRequest> matches = const [],
  }) async {
    tester.view.physicalSize = const Size(390, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    GoRoute stub(String path, String label) =>
        GoRoute(path: path, builder: (_, _) => Text(label));
    final router = GoRouter(
      initialLocation: AppRoutes.hcHome,
      routes: [
        GoRoute(
          path: AppRoutes.hcHome,
          builder: (_, _) => const HcHomeScreen(),
        ),
        stub(AppRoutes.hcDonors, 'écran donneurs'),
        stub(AppRoutes.hcBlood, 'écran sang'),
        stub(AppRoutes.hcRequests, 'écran demandes'),
        stub(AppRoutes.hcDonorMatches, 'écran mises en relation'),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith(
            (ref) => Stream.value(const AuthUser(id: 'u1', email: 'a@b.ci')),
          ),
          userRepositoryProvider.overrideWithValue(_FakeUserRepository()),
          centerRepositoryProvider.overrideWithValue(_FakeCenterRepository()),
          bloodRequestRepositoryProvider
              .overrideWithValue(_FakeBloodRequestRepository(requests)),
          donorMatchRepositoryProvider
              .overrideWithValue(_FakeDonorMatchRepository(matches)),
        ],
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
  }

  final sample = [
    _request(
      '1',
      bloodType: BloodType.oNeg,
      priority: Priority.vital,
      age: const Duration(minutes: 6),
    ),
    _request(
      '2',
      priority: Priority.elevated,
      status: RequestStatus.routing,
    ),
    _request('3', age: const Duration(minutes: 40)),
    _request('4', status: RequestStatus.oriented, age: const Duration(hours: 2)),
    _request('5', status: RequestStatus.fulfilled, processedAt: _now),
    _request(
      '6',
      status: RequestStatus.fulfilled,
      processedAt: _now.subtract(const Duration(days: 45)),
    ),
    _request('7', status: RequestStatus.expired),
  ];

  // Lit la valeur affichée au-dessus du libellé d'une tuile de compteur.
  String statValue(WidgetTester tester, String label) {
    final column = tester.widget<Column>(
      find.ancestor(of: find.text(label), matching: find.byType(Column)).first,
    );
    return (column.children.first as Text).data!;
  }

  testWidgets('salue le responsable et résume les demandes', (tester) async {
    await pumpScreen(tester, sample);

    expect(find.text('Bonjour Dr Kouadio Yao,'), findsOneWidget);
    expect(find.text('CSCom de Treichville'), findsOneWidget);
    expect(find.text('Chercher un donneur'), findsOneWidget);
    expect(find.text('Trouver du sang disponible'), findsOneWidget);

    // 2 en attente dont 1 vitale, 1 en traitement, 1 traitée sur 30 jours.
    expect(statValue(tester, 'dont 1 vitale'), '2');
    expect(statValue(tester, 'traitement'), '1');
    expect(statValue(tester, '30 derniers jours'), '1');
  });

  testWidgets('liste les 3 demandes en cours les plus récentes',
      (tester) async {
    await pumpScreen(tester, sample);

    expect(find.text('Centre de transfusion A · il y a 6 min'), findsOneWidget);
    expect(find.text('Vitale'), findsOneWidget);
    expect(find.text('Élevée'), findsOneWidget);
    // Pastilles : 2 « En attente » + le libellé de la tuile de compteur.
    expect(find.text('En attente'), findsNWidgets(3));
    // La 4e demande en cours (orientée) et les demandes closes sont omises.
    expect(find.text('Orientée'), findsNothing);
    expect(find.text('Approuvée'), findsNothing);
  });

  testWidgets('mène aux trois destinations', (tester) async {
    await pumpScreen(tester, sample);
    await tester.tap(find.text('Trouver du sang disponible'));
    await tester.pumpAndSettle();
    expect(find.text('écran sang'), findsOneWidget);

    await pumpScreen(tester, sample);
    await tester.tap(find.text('Chercher un donneur'));
    await tester.pumpAndSettle();
    expect(find.text('écran donneurs'), findsOneWidget);

    await pumpScreen(tester, sample);
    await tester.tap(find.text('Tout voir'));
    await tester.pumpAndSettle();
    expect(find.text('écran demandes'), findsOneWidget);
  });

  testWidgets('résume les réponses des donneurs et y mène', (tester) async {
    await pumpScreen(tester, const []);
    expect(find.text('Réponses des donneurs'), findsNothing);

    await pumpScreen(
      tester,
      const [],
      matches: [
        _match('1', DonorMatchStatus.accepted),
        _match('2', DonorMatchStatus.accepted),
        _match('3', DonorMatchStatus.pending),
        // En attente mais délai dépassé : comptée comme expirée.
        _match(
          '4',
          DonorMatchStatus.pending,
          expiresIn: const Duration(hours: -1),
        ),
      ],
    );
    expect(find.text('2 acceptées · 1 en attente'), findsOneWidget);

    await tester.tap(find.text('Réponses des donneurs'));
    await tester.pumpAndSettle();
    expect(find.text('écran mises en relation'), findsOneWidget);
  });

  testWidgets('affiche des compteurs à zéro sans demande', (tester) async {
    await pumpScreen(tester, const []);

    expect(statValue(tester, 'aucune vitale'), '0');
    expect(find.text('Aucune demande en cours.'), findsOneWidget);
  });
}
