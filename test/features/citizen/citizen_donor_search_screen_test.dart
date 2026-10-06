import 'package:blood_collect/core/constants/app_enums.dart';
import 'package:blood_collect/core/router/app_router.dart';
import 'package:blood_collect/core/theme/app_theme.dart';
import 'package:blood_collect/features/auth/domain/entities/auth_user.dart';
import 'package:blood_collect/features/auth/presentation/providers/auth_providers.dart';
import 'package:blood_collect/features/citizen/presentation/screens/citizen_donor_search_screen.dart';
import 'package:blood_collect/shared/domain/entities/entities.dart';
import 'package:blood_collect/shared/domain/repositories/user_repository.dart';
import 'package:blood_collect/shared/presentation/widgets/donor_zone_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

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

void main() {
  late Uri? resultsUri;

  Future<void> pumpScreen(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    resultsUri = null;

    final router = GoRouter(
      initialLocation: AppRoutes.citizenDonors,
      routes: [
        GoRoute(
          path: AppRoutes.citizenHome,
          builder: (_, _) => const Text('écran accueil'),
        ),
        GoRoute(
          path: AppRoutes.citizenDonors,
          builder: (_, _) => const CitizenDonorSearchScreen(),
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
          userRepositoryProvider.overrideWithValue(_FakeUserRepository()),
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

  testWidgets('préremplit la zone avec celle du citoyen', (tester) async {
    await pumpScreen(tester);

    expect(find.text('PERSONNE'), findsOneWidget);
    expect(find.text('COMMUNES D’ABIDJAN'), findsOneWidget);
    expect(find.text('1 commune sélectionnée'), findsOneWidget);
    expect(
      find.text('Vous cherchez une personne, pas du sang.'),
      findsOneWidget,
    );
    // Pas de compteur de donneurs : il est réservé aux centres de santé.
    expect(find.textContaining('donneurs souhaités'), findsNothing);
  });

  testWidgets('transmet les critères à l’écran de résultats', (tester) async {
    await pumpScreen(tester);

    await tapText(tester, 'B-');
    await tapText(tester, 'Marcory');
    await tapText(tester, 'Élevée');
    await tapText(tester, 'Rechercher des donneurs');

    expect(find.text('écran résultats'), findsOneWidget);
    final uri = resultsUri!;
    expect(uri.path, AppRoutes.citizenDonorResults);
    expect(
      AppRoutes.donorCriteriaFrom(uri),
      const DonorSearchCriteria(
        bloodType: BloodType.bNeg,
        city: 'Abidjan',
        communes: ['Treichville', 'Marcory'],
        priority: Priority.elevated,
      ),
    );
  });

  testWidgets('changer de ville vide les communes et bloque la recherche',
      (tester) async {
    await pumpScreen(tester);

    await tapText(tester, 'Bouaké');

    expect(find.text('COMMUNES DE BOUAKÉ'), findsOneWidget);
    expect(find.text('Sélectionnez au moins une commune.'), findsOneWidget);
    await tapText(tester, 'Rechercher des donneurs');
    expect(find.text('écran résultats'), findsNothing);

    await tapText(tester, 'Tout sélectionner');
    expect(find.text('4 communes sélectionnées'), findsOneWidget);
    await tapText(tester, 'Rechercher des donneurs');
    expect(find.text('écran résultats'), findsOneWidget);
  });

  group('DonorZone.resolve', () {
    test('part du domicile tant que rien n’est choisi', () {
      final zone = DonorZone.resolve(
        homeCity: 'Abidjan',
        homeCommune: 'Cocody',
      );
      expect(zone.city, 'Abidjan');
      expect(zone.selected, {'Cocody'});
      expect(zone.cities, contains('Bouaké'));
    });

    test('retombe sur la première ville si le domicile est inconnu', () {
      final zone = DonorZone.resolve(homeCity: 'Atlantide');
      expect(zone.city, 'Abidjan');
      expect(zone.selected, isEmpty);
    });

    test('suit le pays de la ville choisie', () {
      final zone = DonorZone.resolve(
        city: 'Douala',
        selected: const {},
        homeCity: 'Abidjan',
        homeCommune: 'Cocody',
      );
      expect(zone.cities, contains('Yaoundé'));
      expect(zone.selected, isEmpty);
    });

    test('rend les communes dans l’ordre du référentiel', () {
      final zone = DonorZone.resolve(
        city: 'Abidjan',
        selected: const {'Cocody', 'Treichville'},
      );
      expect(zone.selectedInOrder, ['Treichville', 'Cocody']);
      expect(zone.allSelected, isFalse);
    });
  });
}
