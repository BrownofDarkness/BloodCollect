import 'dart:async';

import 'package:blood_collect/core/constants/app_enums.dart';
import 'package:blood_collect/core/router/app_router.dart';
import 'package:blood_collect/core/theme/app_theme.dart';
import 'package:blood_collect/features/auth/domain/entities/auth_user.dart';
import 'package:blood_collect/features/auth/presentation/providers/auth_providers.dart';
import 'package:blood_collect/features/citizen/presentation/screens/citizen_incoming_request_screen.dart';
import 'package:blood_collect/shared/domain/entities/entities.dart';
import 'package:blood_collect/shared/domain/repositories/center_repository.dart';
import 'package:blood_collect/shared/domain/repositories/donor_match_repository.dart';
import 'package:blood_collect/shared/domain/repositories/donor_repository.dart';
import 'package:blood_collect/shared/domain/repositories/user_repository.dart';
import 'package:blood_collect/shared/presentation/providers/repository_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

final _now = DateTime.now();

DonorMatchRequest _request({
  String requesterId = 'hc-user',
  DonorMatchStatus status = DonorMatchStatus.pending,
  bool shareContact = true,
  Duration expiresIn = const Duration(hours: 20),
  String? message = 'Merci de vous présenter au centre.',
}) =>
    DonorMatchRequest(
      id: 'r1',
      requesterId: requesterId,
      donorId: 'me',
      bloodType: BloodType.oPos,
      priority: Priority.elevated,
      status: status,
      shareContact: shareContact,
      message: message,
      internalReference: 'DOS-2291',
      notifiedAt: _now.subtract(const Duration(minutes: 5)),
      expiresAt: _now.add(expiresIn),
      createdAt: _now.subtract(const Duration(minutes: 5)),
    );

/// Dépôt en mémoire : la réponse du donneur est rediffusée aux écouteurs,
/// comme le ferait Firestore.
class _FakeDonorMatchRepository implements DonorMatchRepository {
  _FakeDonorMatchRepository(this._current);

  DonorMatchRequest? _current;
  final _controller = StreamController<DonorMatchRequest?>.broadcast();
  final responses = <DonorMatchStatus>[];
  bool fail = false;

  @override
  Stream<DonorMatchRequest?> watchById(String id) async* {
    yield _current;
    yield* _controller.stream;
  }

  @override
  Future<void> respond(String id, DonorMatchStatus status) async {
    if (fail) throw Exception('hors ligne');
    responses.add(status);
    _current = _current!.copyWith(status: status, respondedAt: () => _now);
    _controller.add(_current);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeCenterRepository implements CenterRepository {
  @override
  Stream<HealthCenter?> watchHealthCenterByUser(String userId) => Stream.value(
        userId != 'hc-user'
            ? null
            : HealthCenter(
                id: 'hc1',
                userId: userId,
                name: 'CSCom de Treichville',
                address: '',
                city: 'Abidjan',
                commune: 'Treichville',
                location: const GeoLocation(latitude: 0, longitude: 0),
                phone: '+2250700000001',
                establishmentType: 'Clinique',
                authorizationNumber: '',
                contactFunction: '',
                verificationStatus: VerificationStatus.verified,
                createdAt: _now,
                updatedAt: _now,
              ),
      );

  @override
  Stream<List<BloodCenter>> watchVerifiedBloodCenters({
    required String city,
    String? commune,
  }) =>
      Stream.value([
        for (final (id, c) in [('B', 'Cocody'), ('A', 'Marcory')])
          BloodCenter(
            id: id,
            userId: 'owner',
            name: 'Centre de transfusion $id',
            address: '',
            city: city,
            commune: c,
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
      ]);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeDonorRepository implements DonorRepository {
  @override
  Future<DonorContact?> contactOf(String donorId) async => DonorContact(
        donorId: donorId,
        fullName: 'Awa Koné',
        phone: '+2250700000002',
        commune: 'Cocody',
      );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeUserRepository implements UserRepository {
  @override
  Stream<AppUser?> watchById(String id) => Stream.value(
        AppUser(
          id: id,
          email: 'aya@mail.ci',
          firstName: 'Aya',
          lastName: 'Koné',
          role: UserRole.citizen,
          bloodType: BloodType.oPos,
          city: 'Abidjan',
          commune: 'Marcory',
          createdAt: _now,
          updatedAt: _now,
        ),
      );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _FakeDonorMatchRepository matches;

  Future<void> pumpScreen(
    WidgetTester tester,
    DonorMatchRequest? request,
  ) async {
    tester.view.physicalSize = const Size(390, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    matches = _FakeDonorMatchRepository(request);

    final router = GoRouter(
      initialLocation: '${AppRoutes.citizenIncoming}/r1',
      routes: [
        GoRoute(
          path: '${AppRoutes.citizenIncoming}/:requestId',
          builder: (_, state) => CitizenIncomingRequestScreen(
            requestId: state.pathParameters['requestId']!,
          ),
        ),
        GoRoute(
          path: '${AppRoutes.citizenBlood}/:centerId',
          builder: (_, state) =>
              Text('fiche centre ${state.pathParameters['centerId']}'),
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
          centerRepositoryProvider.overrideWithValue(_FakeCenterRepository()),
          donorRepositoryProvider.overrideWithValue(_FakeDonorRepository()),
          donorMatchRepositoryProvider.overrideWithValue(matches),
        ],
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('présente une demande d’un centre de santé', (tester) async {
    await pumpScreen(tester, _request());

    expect(find.text('VOUS ÊTES DONNEUR'), findsOneWidget);
    expect(
      find.text('DEMANDE SOUMISE PAR UN CENTRE DE SANTÉ'),
      findsOneWidget,
    );
    expect(find.text('CSCom de Treichville'), findsOneWidget);
    expect(
      find.text('Un centre de santé recherche un donneur O+ pour un patient.'),
      findsOneWidget,
    );
    expect(find.text('Treichville'), findsOneWidget);
    expect(find.text('Urgence élevée'), findsOneWidget);
    expect(find.text('Reçue il y a 5 min'), findsOneWidget);
    expect(find.text('« Merci de vous présenter au centre. »'), findsOneWidget);
    expect(
      find.text('Accepter ne veut pas dire donner tout de suite.'),
      findsOneWidget,
    );
    // La référence interne du centre et son numéro restent cachés.
    expect(find.textContaining('DOS-2291'), findsNothing);
    expect(find.textContaining('+225'), findsNothing);
  });

  testWidgets('garde anonyme un demandeur particulier', (tester) async {
    await pumpScreen(tester, _request(requesterId: 'citizen-2'));

    expect(find.text('DEMANDE SOUMISE PAR UN PARTICULIER'), findsOneWidget);
    expect(find.text('Identité non communiquée'), findsOneWidget);
    expect(
      find.text('Une personne recherche un donneur O+, votre groupe sanguin.'),
      findsOneWidget,
    );
    expect(find.text('Cocody'), findsOneWidget);
    expect(find.textContaining('Awa'), findsNothing);
  });

  testWidgets('propose le centre de transfusion de sa commune',
      (tester) async {
    await pumpScreen(tester, _request());

    // Le citoyen habite Marcory : le centre A passe devant le B.
    await tester.tap(find.text('Centre de transfusion A · Marcory'));
    await tester.pumpAndSettle();
    expect(find.text('fiche centre A'), findsOneWidget);
  });

  testWidgets('accepter enregistre la réponse et montre le contact partagé',
      (tester) async {
    await pumpScreen(tester, _request());

    await tester.tap(find.text('Accepter'));
    await tester.pumpAndSettle();

    expect(matches.responses, [DonorMatchStatus.accepted]);
    expect(find.text('Vous avez accepté cette demande'), findsOneWidget);
    expect(find.text('Accepter'), findsNothing);
    expect(
      find.text('Appeler le demandeur · +2250700000001'),
      findsOneWidget,
    );
  });

  testWidgets('n’affiche pas le contact si le demandeur ne le partage pas',
      (tester) async {
    await pumpScreen(tester, _request(shareContact: false));

    await tester.tap(find.text('Accepter'));
    await tester.pumpAndSettle();

    expect(find.text('Vous avez accepté cette demande'), findsOneWidget);
    expect(find.textContaining('Appeler le demandeur'), findsNothing);
  });

  testWidgets('indisponible et refuser déclinent tous deux la demande',
      (tester) async {
    await pumpScreen(tester, _request());
    await tester.tap(find.text('Je suis indisponible pour le moment'));
    await tester.pumpAndSettle();
    expect(matches.responses, [DonorMatchStatus.declined]);
    expect(find.text('Vous avez décliné cette demande'), findsOneWidget);

    await pumpScreen(tester, _request());
    await tester.tap(find.text('Refuser'));
    await tester.pumpAndSettle();
    expect(matches.responses, [DonorMatchStatus.declined]);
    expect(find.textContaining('Appeler le demandeur'), findsNothing);
  });

  testWidgets('garde les boutons si la réponse n’est pas enregistrée',
      (tester) async {
    await pumpScreen(tester, _request());
    matches.fail = true;

    await tester.tap(find.text('Accepter'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Réponse non enregistrée'), findsOneWidget);
    expect(find.text('Accepter'), findsOneWidget);
  });

  testWidgets('une demande expirée ou introuvable n’attend plus de réponse',
      (tester) async {
    await pumpScreen(
      tester,
      _request(expiresIn: const Duration(hours: -1)),
    );
    expect(find.text('Cette demande a expiré'), findsOneWidget);
    expect(find.text('Accepter'), findsNothing);

    await pumpScreen(tester, null);
    expect(find.text('Demande introuvable'), findsOneWidget);
  });
}
