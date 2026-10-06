import 'dart:async';

import 'package:blood_collect/core/constants/app_enums.dart';
import 'package:blood_collect/core/router/app_router.dart';
import 'package:blood_collect/core/theme/app_theme.dart';
import 'package:blood_collect/features/auth/domain/entities/auth_user.dart';
import 'package:blood_collect/features/auth/presentation/providers/auth_providers.dart';
import 'package:blood_collect/shared/domain/entities/entities.dart';
import 'package:blood_collect/shared/domain/repositories/campaign_registration_repository.dart';
import 'package:blood_collect/shared/domain/repositories/campaign_repository.dart';
import 'package:blood_collect/shared/domain/repositories/center_repository.dart';
import 'package:blood_collect/shared/domain/repositories/donor_match_repository.dart';
import 'package:blood_collect/shared/domain/repositories/donor_repository.dart';
import 'package:blood_collect/shared/domain/repositories/user_repository.dart';
import 'package:blood_collect/shared/presentation/providers/repository_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// Parcours « Donneurs » d'un citoyen à travers la VRAIE table de routes de
// l'application (appRouterProvider), et non des routes simplifiées : vérifie
// que la recherche, les résultats, l'envoi et le suivi s'enchaînent.

final _now = DateTime.now();

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
          commune: 'Treichville',
          createdAt: _now,
          updatedAt: _now,
        ),
      );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeCenterRepository implements CenterRepository {
  @override
  Stream<VerificationStatus?> watchVerificationStatus({
    required String userId,
    required UserRole role,
  }) =>
      Stream.value(null);

  @override
  Stream<HealthCenter?> watchHealthCenterByUser(String userId) =>
      Stream.value(null);

  @override
  Stream<List<BloodCenter>> watchVerifiedBloodCenters({
    required String city,
    String? commune,
  }) =>
      Stream.value(const []);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeCampaignRepository implements CampaignRepository {
  @override
  Stream<List<Campaign>> watchOpen() => Stream.value(const []);
}

class _FakeRegistrationRepository implements CampaignRegistrationRepository {
  @override
  Stream<List<CampaignRegistration>> watchByDonor(String donorId) =>
      Stream.value(const []);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeDonorRepository implements DonorRepository {
  @override
  Future<List<DonorCandidate>> search(DonorSearchCriteria criteria) async => [
        DonorCandidate(
          donorId: 'd1',
          bloodType: criteria.bloodType,
          commune: 'Treichville',
        ),
      ];

  @override
  Future<DonorContact?> contactOf(String donorId) async => null;
}

/// Dépôt en mémoire : un envoi est rediffusé aux écouteurs, comme Firestore.
class _FakeDonorMatchRepository implements DonorMatchRepository {
  final _sent = <DonorMatchRequest>[];
  final _controller = StreamController<List<DonorMatchRequest>>.broadcast();

  @override
  Future<void> createAll(List<DonorMatchRequest> requests) async {
    _sent.addAll([
      for (final (i, r) in requests.indexed) r.copyWith(id: 'm$i'),
    ]);
    _controller.add([..._sent]);
  }

  @override
  Stream<List<DonorMatchRequest>> watchByRequester(String requesterId) async* {
    yield [..._sent];
    yield* _controller.stream;
  }

  @override
  Stream<List<DonorMatchRequest>> watchByDonor(String donorId) =>
      Stream.value(const []);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('recherche, envoi puis suivi dans la vraie navigation',
      (tester) async {
    tester.view.physicalSize = const Size(390, 2200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final container = ProviderContainer(
      overrides: [
        authStateProvider.overrideWith(
          (ref) => Stream.value(const AuthUser(id: 'me', email: 'a@b.ci')),
        ),
        userRepositoryProvider.overrideWithValue(_FakeUserRepository()),
        centerRepositoryProvider.overrideWithValue(_FakeCenterRepository()),
        campaignRepositoryProvider.overrideWithValue(_FakeCampaignRepository()),
        campaignRegistrationRepositoryProvider
            .overrideWithValue(_FakeRegistrationRepository()),
        donorRepositoryProvider.overrideWithValue(_FakeDonorRepository()),
        donorMatchRepositoryProvider
            .overrideWithValue(_FakeDonorMatchRepository()),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: Consumer(
          builder: (context, ref, _) => MaterialApp.router(
            theme: AppTheme.light,
            routerConfig: ref.watch(appRouterProvider),
          ),
        ),
      ),
    );
    // Le splash s'affiche au moins 2,5 s avant d'aiguiller vers l'accueil.
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.text('Aya Koné'), findsOneWidget);

    // Accueil → Chercher un donneur → résultats.
    await tester.tap(find.text('Chercher un donneur'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Rechercher des donneurs'));
    await tester.pumpAndSettle();
    expect(find.text('Donneurs potentiels'), findsOneWidget);
    expect(
      find.text('1 donneur correspond à votre recherche'),
      findsOneWidget,
    );

    // Contacter → envoyer → retour aux résultats, demande visible.
    await tester.tap(find.text('Contacter'));
    await tester.pumpAndSettle();
    expect(find.text('Demande de mise en relation'), findsOneWidget);
    await tester.tap(find.text('Envoyer la demande'));
    await tester.pumpAndSettle();
    expect(find.text('Donneurs potentiels'), findsOneWidget);
    expect(find.text('En attente de réponse'), findsOneWidget);

    // Profil → Mes mises en relation : la demande envoyée y figure.
    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mes mises en relation'));
    await tester.pumpAndSettle();
    expect(find.text('DEMANDES ENVOYÉES'), findsOneWidget);
    expect(find.text('Donneur potentiel'), findsOneWidget);
    expect(find.text('En attente'), findsOneWidget);
  });
}
