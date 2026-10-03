import 'package:blood_collect/core/constants/app_enums.dart';
import 'package:blood_collect/core/router/app_router.dart';
import 'package:blood_collect/core/theme/app_theme.dart';
import 'package:blood_collect/features/auth/domain/entities/auth_user.dart';
import 'package:blood_collect/features/auth/presentation/providers/auth_providers.dart';
import 'package:blood_collect/features/health_center/presentation/providers/hc_providers.dart';
import 'package:blood_collect/features/health_center/presentation/screens/hc_donor_contact_screen.dart';
import 'package:blood_collect/shared/domain/entities/entities.dart';
import 'package:blood_collect/shared/domain/repositories/center_repository.dart';
import 'package:blood_collect/shared/domain/repositories/donor_match_repository.dart';
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
    donorCount: 3,
  ),
  candidates: [
    DonorCandidate(
      donorId: 'd1',
      bloodType: BloodType.oPos,
      commune: 'Treichville',
      distanceKm: 1.2,
    ),
    DonorCandidate(
      donorId: 'd2',
      bloodType: BloodType.oPos,
      commune: 'Treichville',
      distanceKm: 2.5,
    ),
  ],
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
          contactFunction: '',
          verificationStatus: VerificationStatus.verified,
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
}

void main() {
  late _FakeDonorMatchRepository matches;

  setUp(() => matches = _FakeDonorMatchRepository());

  Future<void> pumpScreen(
    WidgetTester tester, {
    DonorContactSelection? selection = _selection,
  }) async {
    tester.view.physicalSize = const Size(390, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final router = GoRouter(
      initialLocation: AppRoutes.hcDonorContact,
      routes: [
        GoRoute(
          path: AppRoutes.hcDonors,
          builder: (_, _) => const Text('formulaire donneurs'),
          routes: [
            GoRoute(
              path: 'contact',
              builder: (_, _) => HcDonorContactScreen(selection: selection),
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
            (ref) => Stream.value(const AuthUser(id: 'u1', email: 'a@b.ci')),
          ),
          centerRepositoryProvider.overrideWithValue(_FakeCenterRepository()),
          donorMatchRepositoryProvider.overrideWithValue(matches),
        ],
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder field(String label) => find.descendant(
        of: find.ancestor(
          of: find.text(label),
          matching: find.byType(Column),
        ).first,
        matching: find.byType(TextFormField),
      );

  testWidgets('résume la sélection et prévisualise la demande',
      (tester) async {
    await pumpScreen(tester);

    expect(find.text('2 donneurs O+'), findsOneWidget);
    expect(find.text('Treichville · 1,2 km et 2,5 km'), findsOneWidget);
    expect(find.text('CSCom de Treichville'), findsOneWidget);
    expect(
      find.text('Un centre de santé recherche un donneur O+ pour un patient.'),
      findsOneWidget,
    );
    expect(
      find.text(
        'Treichville · Urgence élevée · Don dans un centre agréé uniquement',
      ),
      findsOneWidget,
    );
    // La référence interne ne doit jamais apparaître dans l'aperçu.
    await tester.enterText(
      field('Référence interne (non visible par le donneur)'),
      'DOS-2291',
    );
    await tester.enterText(field('Message au donneur (facultatif)'), 'Merci');
    await tester.tap(find.text('Vitale'));
    await tester.pumpAndSettle();
    expect(find.text('« Merci »'), findsOneWidget);
    expect(find.textContaining('Urgence vitale'), findsOneWidget);
    expect(find.text('DOS-2291'), findsWidgets);
    expect(
      find.descendant(
        of: find.ancestor(
          of: find.text('CE QUE VERRA LE DONNEUR'),
          matching: find.byType(Container),
        ).first,
        matching: find.textContaining('DOS-2291'),
      ),
      findsNothing,
    );
  });

  testWidgets('exige la référence interne', (tester) async {
    await pumpScreen(tester);

    await tester.tap(find.text('Envoyer les demandes'));
    await tester.pumpAndSettle();

    expect(find.text('La référence du dossier est requise.'), findsOneWidget);
    expect(matches.created, isEmpty);
  });

  testWidgets('envoie une sollicitation par donneur', (tester) async {
    await pumpScreen(tester);

    await tester.enterText(
      field('Référence interne (non visible par le donneur)'),
      'dos-2291',
    );
    await tester.enterText(
      field('Message au donneur (facultatif)'),
      '  Présentez-vous au CNTS  ',
    );
    await tester.tap(find.byType(Switch));
    await tester.tap(find.text('Envoyer les demandes'));
    await tester.pumpAndSettle();

    expect(matches.created.map((m) => m.donorId), ['d1', 'd2']);
    final match = matches.created.first;
    expect(match.requesterId, 'u1');
    expect(match.internalReference, 'DOS-2291');
    expect(match.message, 'Présentez-vous au CNTS');
    expect(match.priority, Priority.elevated);
    expect(match.shareContact, isFalse);
    expect(match.status, DonorMatchStatus.pending);
    expect(match.bloodRequestId, isNull);
    expect(match.expiresAt.difference(match.notifiedAt).inHours, 24);
    expect(find.text('Demandes envoyées'), findsOneWidget);

    await tester.tap(find.text('Terminer'));
    await tester.pumpAndSettle();
    expect(find.text('formulaire donneurs'), findsOneWidget);
  });

  testWidgets('garde la saisie si l’envoi échoue', (tester) async {
    matches.fail = true;
    await pumpScreen(tester);

    await tester.enterText(
      field('Référence interne (non visible par le donneur)'),
      'DOS-2291',
    );
    await tester.tap(find.text('Envoyer les demandes'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Envoi impossible'), findsOneWidget);
    expect(find.text('Demandes envoyées'), findsNothing);
  });

  testWidgets('signale une sélection perdue', (tester) async {
    await pumpScreen(tester, selection: null);

    expect(find.text('Aucun donneur sélectionné'), findsOneWidget);
    expect(find.text('Envoyer les demandes'), findsNothing);
  });
}
