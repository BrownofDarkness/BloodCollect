import 'package:blood_collect/core/constants/app_enums.dart';
import 'package:blood_collect/core/router/app_router.dart';
import 'package:blood_collect/core/theme/app_theme.dart';
import 'package:blood_collect/features/auth/domain/entities/auth_user.dart';
import 'package:blood_collect/features/auth/presentation/providers/auth_providers.dart';
import 'package:blood_collect/features/health_center/presentation/screens/hc_donor_search_screen.dart';
import 'package:blood_collect/shared/domain/entities/entities.dart';
import 'package:blood_collect/shared/domain/repositories/center_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

final _now = DateTime.now();

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

void main() {
  late Uri? resultsUri;

  Future<void> pumpScreen(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    resultsUri = null;

    final router = GoRouter(
      initialLocation: AppRoutes.hcDonors,
      routes: [
        GoRoute(
          path: AppRoutes.hcDonors,
          builder: (_, _) => const HcDonorSearchScreen(),
          routes: [
            GoRoute(
              path: 'results',
              builder: (_, state) {
                resultsUri = state.uri;
                return const Text('écran résultats');
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
          authStateProvider.overrideWith(
            (ref) => Stream.value(const AuthUser(id: 'u1', email: 'a@b.ci')),
          ),
          centerRepositoryProvider.overrideWithValue(_FakeCenterRepository()),
        ],
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tapText(WidgetTester tester, String text) async {
    await tester.tap(find.text(text));
    await tester.pumpAndSettle();
  }

  testWidgets('préremplit la zone avec celle du centre connecté',
      (tester) async {
    await pumpScreen(tester);

    expect(find.text('Recherche au nom de CSCom de Treichville'), findsOneWidget);
    expect(find.text('COMMUNES D’ABIDJAN'), findsOneWidget);
    expect(find.text('1 commune sélectionnée'), findsOneWidget);
    expect(find.text('3 donneurs'), findsOneWidget);
  });

  testWidgets('transmet les critères choisis à l’écran de résultats',
      (tester) async {
    await pumpScreen(tester);

    await tapText(tester, 'A-');
    await tapText(tester, 'Marcory');
    await tapText(tester, 'Vitale');
    await tester.tap(find.byTooltip('Augmenter'));
    await tester.pumpAndSettle();
    expect(find.text('2 communes sélectionnées'), findsOneWidget);

    await tapText(tester, 'Rechercher des donneurs');

    expect(find.text('écran résultats'), findsOneWidget);
    final uri = resultsUri!;
    expect(uri.queryParameters['bloodType'], 'A-');
    expect(uri.queryParameters['city'], 'Abidjan');
    // Ordre du référentiel, pas celui des clics.
    expect(uri.queryParametersAll['commune'], ['Treichville', 'Marcory']);
    expect(uri.queryParameters['priority'], 'vital');
    expect(uri.queryParameters['count'], '4');
  });

  testWidgets('changer de ville vide les communes et bloque la recherche',
      (tester) async {
    await pumpScreen(tester);

    await tapText(tester, 'Bouaké');

    expect(find.text('COMMUNES DE BOUAKÉ'), findsOneWidget);
    expect(find.text('Aucune commune sélectionnée'), findsOneWidget);
    expect(find.text('Sélectionnez au moins une commune.'), findsOneWidget);

    await tapText(tester, 'Rechercher des donneurs');
    expect(find.text('écran résultats'), findsNothing);

    await tapText(tester, 'Tout sélectionner');
    expect(find.text('4 communes sélectionnées'), findsOneWidget);
    expect(find.text('Tout désélectionner'), findsOneWidget);
  });

  test('AppRoutes.hcDonorResultsPath', () {
    final path = AppRoutes.hcDonorResultsPath(
      const DonorSearchCriteria(
        bloodType: BloodType.oPos,
        city: 'Abidjan',
        communes: ['Plateau', 'Cocody'],
        priority: Priority.elevated,
        donorCount: 3,
      ),
    );
    final uri = Uri.parse(path);
    expect(uri.path, '/hc/donors/results');
    expect(uri.queryParameters['bloodType'], 'O+');
    expect(uri.queryParametersAll['commune'], ['Plateau', 'Cocody']);
    expect(uri.queryParameters['priority'], 'elevated');
  });
}
