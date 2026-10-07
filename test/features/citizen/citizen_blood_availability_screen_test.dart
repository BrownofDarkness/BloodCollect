import 'package:blood_collect/core/constants/app_enums.dart';
import 'package:blood_collect/core/router/app_router.dart';
import 'package:blood_collect/core/theme/app_theme.dart';
import 'package:blood_collect/features/auth/domain/entities/auth_user.dart';
import 'package:blood_collect/features/auth/presentation/providers/auth_providers.dart';
import 'package:blood_collect/features/citizen/presentation/screens/citizen_blood_availability_screen.dart';
import 'package:blood_collect/shared/domain/entities/entities.dart';
import 'package:blood_collect/shared/domain/repositories/blood_stock_repository.dart';
import 'package:blood_collect/shared/domain/repositories/center_repository.dart';
import 'package:blood_collect/shared/domain/repositories/user_repository.dart';
import 'package:blood_collect/shared/presentation/providers/repository_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

final _now = DateTime.now();

BloodCenter _bloodCenter(String id, String commune, {String phone = '+225'}) =>
    BloodCenter(
      id: id,
      userId: 'owner-$id',
      name: 'Centre de transfusion $id',
      address: '',
      city: 'Abidjan',
      commune: commune,
      location: const GeoLocation(latitude: 5.33, longitude: -4.0),
      phone: phone,
      agreementNumber: '',
      contactFunction: '',
      openingHoursWeekdays: '07h-18h',
      lowStockThreshold: 20,
      unavailableThreshold: 5,
      verificationStatus: VerificationStatus.verified,
      createdAt: _now,
      updatedAt: _now,
    );

BloodStockLot _lot(String centerId, int quantity) => BloodStockLot(
      id: 'lot-$centerId',
      bloodCenterId: centerId,
      bloodType: BloodType.oPos,
      productType: ProductType.wholeBlood,
      lotReference: 'LOT',
      quantity: quantity,
      expiryDate: _now.add(const Duration(days: 10)),
      collectionDate: _now,
      status: StockLotStatus.available,
      createdAt: _now,
      updatedAt: _now,
    );

class _FakeCenterRepository implements CenterRepository {
  final centers = [
    _bloodCenter('A', 'Treichville'),
    _bloodCenter('B', 'Cocody'),
    _bloodCenter('C', 'Yopougon', phone: ''),
  ];

  // Un citoyen ne gère aucun centre de santé : pas de position de départ.
  @override
  Stream<HealthCenter?> watchHealthCenterByUser(String userId) =>
      Stream.value(null);

  @override
  Stream<List<BloodCenter>> watchVerifiedBloodCenters({
    required String city,
    String? commune,
  }) =>
      Stream.value(
        centers
            .where(
              (c) =>
                  c.city == city && (commune == null || c.commune == commune),
            )
            .toList(),
      );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeBloodStockRepository implements BloodStockRepository {
  @override
  Stream<List<BloodStockLot>> watchAvailableLots(BloodType bloodType) =>
      Stream.value(
        bloodType == BloodType.oPos ? [_lot('A', 40), _lot('B', 10)] : [],
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
          commune: 'Treichville',
          createdAt: _now,
          updatedAt: _now,
        ),
      );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  Future<void> pumpScreen(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final router = GoRouter(
      initialLocation: AppRoutes.citizenBlood,
      routes: [
        GoRoute(
          path: AppRoutes.citizenBlood,
          builder: (_, _) => const CitizenBloodAvailabilityScreen(),
          routes: [
            GoRoute(
              path: ':centerId',
              builder: (_, state) =>
                  Text('fiche centre ${state.pathParameters['centerId']}'),
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
          centerRepositoryProvider.overrideWithValue(_FakeCenterRepository()),
          bloodStockRepositoryProvider
              .overrideWithValue(_FakeBloodStockRepository()),
        ],
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('liste les centres en consultation seule', (tester) async {
    await pumpScreen(tester);

    expect(find.text('SANG · CENTRES AGRÉÉS'), findsOneWidget);
    expect(find.text('Consultation uniquement'), findsOneWidget);
    expect(
      find.text('3 centres de transfusion · O+ · Abidjan'),
      findsOneWidget,
    );
    expect(find.text('Disponible'), findsOneWidget);
    expect(find.text('Disponibilité limitée'), findsOneWidget);
    expect(find.text('Indisponible'), findsOneWidget);
    // Lecture seule : aucune demande possible, aucune quantité affichée.
    expect(find.text('Demander'), findsNothing);
    expect(find.text('Autres centres'), findsNothing);
    expect(find.text('40'), findsNothing);
    expect(find.text('Appeler'), findsNWidgets(3));
    // Sans position, seule la commune situe le centre.
    expect(find.text('Treichville'), findsOneWidget);
  });

  testWidgets('désactive « Appeler » sans numéro', (tester) async {
    await pumpScreen(tester);

    final buttons = tester
        .widgetList<OutlinedButton>(
          find.widgetWithText(OutlinedButton, 'Appeler'),
        )
        .toList();
    // Triés par disponibilité : A, B puis C, seul C n'a pas de numéro.
    expect(buttons.map((b) => b.onPressed != null), [true, true, false]);
  });

  testWidgets('filtre par groupe et par commune', (tester) async {
    await pumpScreen(tester);

    await tester.tap(find.text('A+'));
    await tester.pumpAndSettle();
    expect(find.text('Indisponible'), findsNWidgets(3));

    await tester.tap(find.text('Toutes les communes'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cocody').last);
    await tester.pumpAndSettle();
    expect(
      find.text('1 centre de transfusion · A+ · Cocody'),
      findsOneWidget,
    );
  });

  testWidgets('ouvre la fiche du centre', (tester) async {
    await pumpScreen(tester);

    await tester.tap(find.text('Voir le centre').first);
    await tester.pumpAndSettle();

    expect(find.text('fiche centre A'), findsOneWidget);
  });
}
