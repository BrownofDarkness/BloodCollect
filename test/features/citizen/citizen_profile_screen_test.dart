import 'dart:async';

import 'package:blood_collect/core/constants/app_enums.dart';
import 'package:blood_collect/core/router/app_router.dart';
import 'package:blood_collect/core/theme/app_theme.dart';
import 'package:blood_collect/features/auth/domain/entities/auth_user.dart';
import 'package:blood_collect/features/auth/domain/repositories/auth_repository.dart';
import 'package:blood_collect/features/auth/presentation/providers/auth_providers.dart';
import 'package:blood_collect/features/citizen/presentation/screens/citizen_matches_screen.dart';
import 'package:blood_collect/features/citizen/presentation/screens/citizen_profile_screen.dart';
import 'package:blood_collect/shared/domain/entities/entities.dart';
import 'package:blood_collect/shared/domain/repositories/campaign_registration_repository.dart';
import 'package:blood_collect/shared/domain/repositories/campaign_repository.dart';
import 'package:blood_collect/shared/domain/repositories/donor_match_repository.dart';
import 'package:blood_collect/shared/domain/repositories/donor_repository.dart';
import 'package:blood_collect/shared/domain/repositories/user_repository.dart';
import 'package:blood_collect/shared/presentation/providers/repository_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

final _now = DateTime.now();

AppUser _user({BloodType? bloodType = BloodType.oPos}) => AppUser(
      id: 'me',
      email: 'aya@mail.ci',
      firstName: 'Aya',
      lastName: 'Koné',
      phone: '+2250700000000',
      role: UserRole.citizen,
      bloodType: bloodType,
      city: 'Abidjan',
      commune: 'Treichville',
      createdAt: _now,
      updatedAt: _now,
    );

/// Dépôt en mémoire : une sauvegarde est rediffusée, comme Firestore.
class _FakeUserRepository implements UserRepository {
  _FakeUserRepository(this._current);

  AppUser _current;
  final _controller = StreamController<AppUser?>.broadcast();
  final saved = <AppUser>[];
  bool fail = false;

  @override
  Stream<AppUser?> watchById(String id) async* {
    yield _current;
    yield* _controller.stream;
  }

  @override
  Future<void> save(AppUser user) async {
    if (fail) throw Exception('hors ligne');
    saved.add(user);
    _current = user;
    _controller.add(user);
  }

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

class _FakeCampaignRepository implements CampaignRepository {
  @override
  Stream<List<Campaign>> watchOpen() {
    final day = DateTime(_now.year, _now.month, _now.day)
        .add(const Duration(days: 3));
    return Stream.value([
      Campaign(
        id: 'open',
        bloodCenterId: 'A',
        title: 'Collecte',
        description: '',
        location: const GeoLocation(latitude: 0, longitude: 0),
        locationName: '',
        startDate: day,
        endDate: day.add(const Duration(hours: 6)),
        targetBloodTypes: const [],
        targetCommunes: const [],
        targetUnits: 10,
        status: CampaignStatus.published,
        createdAt: _now,
        updatedAt: _now,
      ),
    ]);
  }
}

class _FakeRegistrationRepository implements CampaignRegistrationRepository {
  CampaignRegistration _registration(String campaignId, RegistrationStatus s) =>
      CampaignRegistration(
        id: '${campaignId}_me',
        campaignId: campaignId,
        donorId: 'me',
        status: s,
        createdAt: _now,
        updatedAt: _now,
      );

  @override
  Stream<List<CampaignRegistration>> watchByDonor(String donorId) =>
      Stream.value([
        _registration('open', RegistrationStatus.registered),
        // Collecte terminée, et inscription annulée : non comptées.
        _registration('closed', RegistrationStatus.registered),
        _registration('other', RegistrationStatus.cancelled),
      ]);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

DonorMatchRequest _match(
  String id, {
  required String requesterId,
  required String donorId,
  DonorMatchStatus status = DonorMatchStatus.pending,
}) =>
    DonorMatchRequest(
      id: id,
      requesterId: requesterId,
      donorId: donorId,
      bloodType: BloodType.oPos,
      priority: Priority.elevated,
      status: status,
      shareContact: true,
      notifiedAt: _now.subtract(const Duration(minutes: 10)),
      expiresAt: _now.add(const Duration(hours: 20)),
      createdAt: _now.subtract(const Duration(minutes: 10)),
    );

class _FakeDonorMatchRepository implements DonorMatchRepository {
  @override
  Stream<List<DonorMatchRequest>> watchByDonor(String donorId) => Stream.value([
        _match('r1', requesterId: 'hc', donorId: 'me'),
        _match(
          'r2',
          requesterId: 'hc',
          donorId: 'me',
          status: DonorMatchStatus.declined,
        ),
      ]);

  @override
  Stream<List<DonorMatchRequest>> watchByRequester(String requesterId) =>
      Stream.value([
        _match('s1', requesterId: 'me', donorId: 'd1'),
        _match(
          's2',
          requesterId: 'me',
          donorId: 'd2',
          status: DonorMatchStatus.accepted,
        ),
      ]);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeDonorRepository implements DonorRepository {
  @override
  Future<DonorContact?> contactOf(String donorId) async => DonorContact(
        donorId: donorId,
        fullName: 'Awa Diallo',
        phone: '+2250700000009',
      );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _FakeUserRepository users;
  late _FakeAuthRepository auth;

  Future<void> pumpAt(
    WidgetTester tester,
    String location, {
    AppUser? user,
  }) async {
    tester.view.physicalSize = const Size(390, 2200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    users = _FakeUserRepository(user ?? _user());
    auth = _FakeAuthRepository();

    GoRoute stub(String path, String label) =>
        GoRoute(path: path, builder: (_, _) => Text(label));
    final router = GoRouter(
      initialLocation: location,
      routes: [
        GoRoute(
          path: AppRoutes.citizenProfile,
          builder: (_, _) => const CitizenProfileScreen(),
          routes: [
            GoRoute(
              path: 'matches',
              builder: (_, _) => const CitizenMatchesScreen(),
            ),
          ],
        ),
        stub(AppRoutes.citizenDonate, 'écran donner'),
        stub(AppRoutes.citizenDonors, 'écran donneurs'),
        stub(AppRoutes.welcome, 'écran accueil'),
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
            (ref) => Stream.value(const AuthUser(id: 'me', email: 'a@b.ci')),
          ),
          authRepositoryProvider.overrideWithValue(auth),
          userRepositoryProvider.overrideWithValue(users),
          campaignRepositoryProvider
              .overrideWithValue(_FakeCampaignRepository()),
          campaignRegistrationRepositoryProvider
              .overrideWithValue(_FakeRegistrationRepository()),
          donorMatchRepositoryProvider
              .overrideWithValue(_FakeDonorMatchRepository()),
          donorRepositoryProvider.overrideWithValue(_FakeDonorRepository()),
        ],
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> pumpProfile(WidgetTester tester, {AppUser? user}) =>
      pumpAt(tester, AppRoutes.citizenProfile, user: user);

  testWidgets('affiche l’identité, l’activité et le menu', (tester) async {
    await pumpProfile(tester);

    expect(find.text('CITOYEN'), findsOneWidget);
    expect(find.text('AK'), findsOneWidget);
    expect(find.text('Aya Koné'), findsOneWidget);
    expect(find.text('+2250700000000'), findsOneWidget);
    expect(find.text('O+ · modifiable si vous le découvrez'), findsOneWidget);
    expect(find.text('Abidjan · Treichville'), findsOneWidget);
    // 1 inscription active à une collecte encore ouverte.
    expect(find.text('1 participation à venir'), findsOneWidget);
    // 2 demandes en attente : 1 reçue + 1 envoyée.
    expect(find.text('2'), findsOneWidget);
    // Rubriques masquées en v1, comme sur les profils des centres.
    expect(find.text('Notifications'), findsNothing);
    expect(find.text('Aide et contact'), findsNothing);
    expect(find.text('BloodCollect · version 1.0'), findsOneWidget);
  });

  testWidgets('modifie le groupe sanguin', (tester) async {
    await pumpProfile(tester);

    await tester.tap(find.text('Groupe sanguin'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('AB-'));
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();

    expect(users.saved.single.bloodType, BloodType.abNeg);
    expect(users.saved.single.commune, 'Treichville');
    expect(find.text('Profil mis à jour.'), findsOneWidget);
    expect(find.text('AB- · modifiable si vous le découvrez'), findsOneWidget);
  });

  testWidgets('modifie la ville et la commune', (tester) async {
    await pumpProfile(tester);

    await tester.tap(find.text('Ville et commune'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Abidjan').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bouaké').last);
    await tester.pumpAndSettle();

    // Changer de ville vide la commune : on ne peut pas enregistrer.
    final save = find.widgetWithText(ElevatedButton, 'Enregistrer');
    expect(tester.widget<ElevatedButton>(save).onPressed, isNull);

    // Second menu déroulant du panneau : celui des communes.
    await tester.tap(find.byType(DropdownButtonFormField<String>).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Koko').last);
    await tester.pumpAndSettle();
    await tester.tap(save);
    await tester.pumpAndSettle();

    expect(users.saved.single.city, 'Bouaké');
    expect(users.saved.single.commune, 'Koko');
    expect(users.saved.single.bloodType, BloodType.oPos);
    expect(find.text('Bouaké · Koko'), findsOneWidget);
  });

  testWidgets('signale un échec de modification sans rien changer',
      (tester) async {
    await pumpProfile(tester);
    users.fail = true;

    await tester.tap(find.text('Groupe sanguin'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('AB-'));
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Modification impossible'), findsOneWidget);
    expect(find.text('O+ · modifiable si vous le découvrez'), findsOneWidget);
  });

  testWidgets('ouvre les informations et la confidentialité', (tester) async {
    await pumpProfile(tester);

    await tester.tap(find.text('Informations personnelles'));
    await tester.pumpAndSettle();
    expect(find.text('aya@mail.ci'), findsOneWidget);
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Confidentialité'));
    await tester.pumpAndSettle();
    expect(find.text('Dans une recherche de donneurs'), findsOneWidget);
    expect(find.text('Aucune donnée médicale'), findsOneWidget);
  });

  testWidgets('envoie le lien de réinitialisation après confirmation',
      (tester) async {
    await pumpProfile(tester);

    await tester.tap(find.text('Mot de passe et sécurité'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Envoyer le lien'));
    await tester.pumpAndSettle();

    expect(auth.resetEmails, ['aya@mail.ci']);
  });

  testWidgets('mène aux collectes et déconnecte', (tester) async {
    await pumpProfile(tester);
    await tester.tap(find.text('Mes collectes'));
    await tester.pumpAndSettle();
    expect(find.text('écran donner'), findsOneWidget);

    await pumpProfile(tester);
    await tester.tap(find.text('Se déconnecter'));
    await tester.pumpAndSettle();
    expect(auth.signedOut, isTrue);
    expect(find.text('écran accueil'), findsOneWidget);
  });

  testWidgets('invite à renseigner un groupe inconnu', (tester) async {
    await pumpProfile(tester, user: _user(bloodType: null));

    expect(
      find.text('À renseigner dès que vous le connaissez'),
      findsOneWidget,
    );
    expect(find.text('—'), findsOneWidget);
  });

  group('Mes mises en relation', () {
    testWidgets('réunit les demandes reçues et envoyées', (tester) async {
      await pumpProfile(tester);
      await tester.tap(find.text('Mes mises en relation'));
      await tester.pumpAndSettle();

      expect(find.text('DEMANDES REÇUES'), findsOneWidget);
      expect(find.text('Demande de don'), findsNWidgets(2));
      expect(find.text('À traiter'), findsOneWidget);
      expect(find.text('DEMANDES ENVOYÉES'), findsOneWidget);
      expect(find.text('Donneur potentiel'), findsNWidgets(2));
      // Coordonnées du seul donneur qui a accepté.
      expect(find.text('Awa Diallo'), findsOneWidget);
      expect(find.text('Appeler'), findsOneWidget);
    });

    testWidgets('ouvre une demande reçue pour y répondre', (tester) async {
      await pumpAt(tester, AppRoutes.citizenMatches);

      await tester.tap(find.text('À traiter'));
      await tester.pumpAndSettle();

      expect(find.text('demande r1'), findsOneWidget);
    });
  });
}
