import 'package:blood_collect/core/constants/app_enums.dart';
import 'package:blood_collect/core/router/app_router.dart';
import 'package:blood_collect/core/theme/app_theme.dart';
import 'package:blood_collect/features/health_center/presentation/providers/hc_providers.dart';
import 'package:blood_collect/features/health_center/presentation/screens/hc_donor_contact_screen.dart';
import 'package:blood_collect/features/health_center/presentation/screens/hc_donor_results_screen.dart';
import 'package:blood_collect/shared/domain/entities/entities.dart';
import 'package:blood_collect/shared/domain/repositories/donor_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

const _criteria = DonorSearchCriteria(
  bloodType: BloodType.oPos,
  city: 'Abidjan',
  communes: ['Treichville', 'Marcory'],
  priority: Priority.elevated,
  donorCount: 3,
);

const _candidates = [
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
  DonorCandidate(
    donorId: 'd3',
    bloodType: BloodType.oPos,
    commune: 'Marcory',
    distanceKm: 4.2,
  ),
  DonorCandidate(
    donorId: 'd4',
    bloodType: BloodType.oPos,
    commune: 'Marcory',
  ),
];

class _FakeDonorRepository implements DonorRepository {
  _FakeDonorRepository(this.result, {this.fail = false});

  final List<DonorCandidate> result;
  final bool fail;

  @override
  Future<List<DonorCandidate>> search(DonorSearchCriteria criteria) async {
    if (fail) throw Exception('not-found');
    return result;
  }
}

void main() {
  // Sélection reçue par l'écran de mise en relation.
  DonorContactSelection? sent;

  setUp(() => sent = null);

  Future<void> pumpScreen(
    WidgetTester tester, {
    DonorSearchCriteria? criteria = _criteria,
    List<DonorCandidate> result = _candidates,
    bool fail = false,
  }) async {
    tester.view.physicalSize = const Size(390, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final router = GoRouter(
      initialLocation: '${AppRoutes.hcDonors}/results',
      routes: [
        GoRoute(
          path: AppRoutes.hcDonors,
          builder: (_, _) => const Text('formulaire donneurs'),
          routes: [
            GoRoute(
              path: 'results',
              builder: (_, _) => HcDonorResultsScreen(criteria: criteria),
            ),
            GoRoute(
              path: 'contact',
              builder: (_, state) {
                sent = state.extra as DonorContactSelection?;
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
          donorRepositoryProvider
              .overrideWithValue(_FakeDonorRepository(result, fail: fail)),
        ],
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('affiche les critères et les donneurs anonymisés',
      (tester) async {
    await pumpScreen(tester);

    expect(find.text('O+'), findsWidgets);
    expect(find.text('Treichville, Marcory'), findsOneWidget);
    expect(find.text('Urgence élevée'), findsOneWidget);
    expect(find.text('4 donneurs trouvés'), findsOneWidget);
    expect(find.text('Donneur potentiel'), findsNWidgets(4));
    expect(find.text('Treichville · 1,2 km'), findsOneWidget);
    // Distance inconnue : seule la commune est affichée.
    expect(find.text('Marcory'), findsOneWidget);
    expect(find.text('0 sélectionné sur 3 souhaités'), findsOneWidget);
  });

  testWidgets('transmet les donneurs cochés à la mise en relation',
      (tester) async {
    await pumpScreen(tester);

    await tester.tap(find.text('Treichville · 1,2 km'));
    await tester.tap(find.text('Treichville · 2,5 km'));
    await tester.pumpAndSettle();
    expect(find.text('2 sélectionnés sur 3 souhaités'), findsOneWidget);

    await tester.tap(find.text('Contacter (2)'));
    await tester.pumpAndSettle();

    expect(find.text('écran mise en relation'), findsOneWidget);
    expect(sent!.criteria, _criteria);
    expect(sent!.candidates.map((c) => c.donorId), ['d1', 'd2']);
  });

  testWidgets('tout sélectionner puis tout désélectionner', (tester) async {
    await pumpScreen(tester);

    await tester.tap(find.text('Tout sélectionner'));
    await tester.pumpAndSettle();
    expect(find.text('Contacter (4)'), findsOneWidget);

    await tester.tap(find.text('Tout désélectionner'));
    await tester.pumpAndSettle();
    expect(find.text('Contacter (0)'), findsOneWidget);

    await tester.tap(find.text('Contacter (0)'));
    await tester.pumpAndSettle();
    expect(sent, isNull);
  });

  testWidgets('signale une recherche vide ou en échec', (tester) async {
    await pumpScreen(tester, result: const []);
    expect(find.text('Aucun donneur disponible'), findsOneWidget);
    expect(find.textContaining('Contacter'), findsNothing);

    await pumpScreen(tester, fail: true);
    expect(find.text('Recherche indisponible'), findsOneWidget);
    expect(find.text('Réessayer'), findsOneWidget);
  });

  testWidgets('refuse une URL sans critères valides', (tester) async {
    await pumpScreen(tester, criteria: null);

    expect(find.text('Critères incomplets'), findsOneWidget);
  });

  test('AppRoutes.donorCriteriaFrom relit le chemin de résultats', () {
    final uri = Uri.parse(AppRoutes.hcDonorResultsPath(_criteria));
    expect(AppRoutes.donorCriteriaFrom(uri), _criteria);
    expect(
      AppRoutes.donorCriteriaFrom(Uri.parse('/hc/donors/results?city=X')),
      isNull,
    );
    expect(
      AppRoutes.donorCriteriaFrom(
        Uri.parse(
          '/hc/donors/results?bloodType=O%2B&city=Abidjan&priority=normal'
          '&count=3',
        ),
      ),
      isNull,
      reason: 'au moins une commune est requise',
    );
  });
}
