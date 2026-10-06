import 'package:blood_collect/core/constants/app_enums.dart';
import 'package:blood_collect/core/router/app_router.dart';
import 'package:blood_collect/core/theme/app_theme.dart';
import 'package:blood_collect/features/auth/domain/entities/auth_user.dart';
import 'package:blood_collect/features/auth/domain/repositories/auth_repository.dart';
import 'package:blood_collect/features/auth/presentation/providers/auth_providers.dart';
import 'package:blood_collect/features/health_center/presentation/providers/hc_providers.dart';
import 'package:blood_collect/features/health_center/presentation/screens/hc_profile_screen.dart';
import 'package:blood_collect/shared/domain/entities/entities.dart';
import 'package:blood_collect/shared/domain/repositories/blood_request_repository.dart';
import 'package:blood_collect/shared/domain/repositories/center_repository.dart';
import 'package:blood_collect/shared/domain/repositories/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

final _now = DateTime.now();

HealthCenter _healthCenter(String userId) => HealthCenter(
      id: 'hc1',
      userId: userId,
      name: 'CSCom de Treichville',
      address: 'Avenue 12',
      city: 'Abidjan',
      commune: 'Treichville',
      location: const GeoLocation(latitude: 0, longitude: 0),
      phone: '+2250700000000',
      establishmentType: 'Centre de santé communautaire',
      authorizationNumber: 'AUT-778',
      contactFunction: 'Médecin-chef',
      verificationStatus: VerificationStatus.verified,
      createdAt: _now,
      updatedAt: _now,
    );

BloodRequest _request(String id, RequestStatus status) => BloodRequest(
      id: id,
      healthCenterId: 'hc1',
      bloodType: BloodType.oPos,
      productType: ProductType.wholeBlood,
      quantityNeeded: 2,
      priority: Priority.normal,
      status: status,
      bloodRouteStep: BloodRouteStep.searchingStock,
      createdAt: _now,
      updatedAt: _now,
    );

class _FakeCenterRepository implements CenterRepository {
  _FakeCenterRepository({this.hasCenter = true});

  final bool hasCenter;

  @override
  Stream<HealthCenter?> watchHealthCenterByUser(String userId) =>
      Stream.value(hasCenter ? _healthCenter(userId) : null);

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
  @override
  Stream<List<BloodRequest>> watchByHealthCenter(String healthCenterId) =>
      Stream.value([
        _request('1', RequestStatus.pending),
        _request('2', RequestStatus.routing),
        _request('3', RequestStatus.oriented),
        _request('4', RequestStatus.fulfilled),
        _request('5', RequestStatus.partiallyFulfilled),
        _request('6', RequestStatus.expired),
      ]);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAuthRepository implements AuthRepository {
  bool signedOut = false;
  final resetEmails = <String>[];

  @override
  Future<void> signOut() async => signedOut = true;

  @override
  Future<void> sendPasswordResetEmail(String email) async =>
      resetEmails.add(email);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _FakeAuthRepository auth;

  setUp(() => auth = _FakeAuthRepository());

  Future<void> pumpScreen(WidgetTester tester, {bool hasCenter = true}) async {
    tester.view.physicalSize = const Size(390, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final router = GoRouter(
      initialLocation: AppRoutes.hcProfile,
      routes: [
        GoRoute(
          path: AppRoutes.hcProfile,
          builder: (_, _) => const HcProfileScreen(),
        ),
        GoRoute(
          path: AppRoutes.hcRequests,
          builder: (_, _) => const Text('écran demandes'),
        ),
        GoRoute(
          path: AppRoutes.welcome,
          builder: (_, _) => const Text('écran accueil'),
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
          authRepositoryProvider.overrideWithValue(auth),
          userRepositoryProvider.overrideWithValue(_FakeUserRepository()),
          centerRepositoryProvider.overrideWithValue(
            _FakeCenterRepository(hasCenter: hasCenter),
          ),
          bloodRequestRepositoryProvider
              .overrideWithValue(_FakeBloodRequestRepository()),
        ],
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('affiche la fiche, les compteurs et le menu', (tester) async {
    await pumpScreen(tester);

    expect(find.text('CSCom de Treichville'), findsOneWidget);
    expect(
      find.text('Centre de santé communautaire · Abidjan'),
      findsOneWidget,
    );
    expect(find.text('Compte vérifié'), findsOneWidget);
    // 3 en cours (attente, traitement, orientée), 2 traitées.
    expect(find.text('3'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('Treichville, Abidjan · Avenue 12'), findsOneWidget);
    expect(find.text('Autorisation validée'), findsOneWidget);
    expect(find.text('Dr Kouadio Yao · Médecin-chef'), findsOneWidget);
    for (final section in ['ÉTABLISSEMENT', 'ÉQUIPE', 'ACTIVITÉ', 'PARAMÈTRES']) {
      expect(find.text(section), findsOneWidget);
    }
    expect(find.text('BloodCollect · version 1.0'), findsOneWidget);
  });

  testWidgets('ouvre le détail d’une rubrique en lecture seule',
      (tester) async {
    await pumpScreen(tester);

    await tester.tap(find.text('Informations de l’établissement'));
    await tester.pumpAndSettle();

    expect(find.text('Numéro d’autorisation'), findsOneWidget);
    expect(find.text('AUT-778'), findsOneWidget);
  });

  testWidgets('masque les rubriques indisponibles en v1', (tester) async {
    await pumpScreen(tester);

    expect(find.text('Membres de l’équipe'), findsNothing);
    expect(find.text('Notifications'), findsNothing);
    expect(find.text('Aide et contact'), findsNothing);
    expect(find.text('Responsable du compte'), findsOneWidget);
  });

  testWidgets('mène à l’historique des demandes', (tester) async {
    await pumpScreen(tester);

    await tester.tap(find.text('Historique des demandes de sang'));
    await tester.pumpAndSettle();

    expect(find.text('écran demandes'), findsOneWidget);
  });

  testWidgets('envoie le lien de réinitialisation après confirmation',
      (tester) async {
    await pumpScreen(tester);

    await tester.tap(find.text('Mot de passe et sécurité'));
    await tester.pumpAndSettle();
    expect(auth.resetEmails, isEmpty);

    await tester.tap(find.text('Envoyer le lien'));
    await tester.pumpAndSettle();

    expect(auth.resetEmails, ['contact@cscom.ci']);
    expect(find.text('Lien envoyé à contact@cscom.ci.'), findsOneWidget);
  });

  testWidgets('déconnecte et revient à l’accueil', (tester) async {
    await pumpScreen(tester);

    await tester.tap(find.text('Se déconnecter'));
    await tester.pumpAndSettle();

    expect(auth.signedOut, isTrue);
    expect(find.text('écran accueil'), findsOneWidget);
  });

  testWidgets('garde la déconnexion accessible sans fiche', (tester) async {
    await pumpScreen(tester, hasCenter: false);

    expect(find.text('Fiche introuvable'), findsOneWidget);
    expect(find.text('Se déconnecter'), findsOneWidget);
  });
}
