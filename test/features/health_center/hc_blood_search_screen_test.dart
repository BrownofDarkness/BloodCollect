import 'package:blood_collect/core/constants/app_enums.dart';
import 'package:blood_collect/core/theme/app_theme.dart';
import 'package:blood_collect/features/auth/domain/entities/auth_user.dart';
import 'package:blood_collect/features/auth/presentation/providers/auth_providers.dart';
import 'package:blood_collect/features/health_center/presentation/providers/hc_providers.dart';
import 'package:blood_collect/features/health_center/presentation/screens/hc_blood_search_screen.dart';
import 'package:blood_collect/shared/domain/entities/entities.dart';
import 'package:blood_collect/shared/domain/repositories/blood_stock_repository.dart';
import 'package:blood_collect/shared/domain/repositories/center_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

final _now = DateTime.now();

BloodCenter _bloodCenter(String id, String commune, double lat) => BloodCenter(
      id: id,
      userId: 'owner-$id',
      name: 'Centre de transfusion $id',
      address: '',
      city: 'Abidjan',
      commune: commune,
      location: GeoLocation(latitude: lat, longitude: -4.0),
      phone: '',
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
    _bloodCenter('A', 'Treichville', 5.33),
    _bloodCenter('B', 'Cocody', 5.36),
    _bloodCenter('C', 'Yopougon', 5.40),
  ];

  @override
  Stream<HealthCenter?> watchHealthCenterByUser(String userId) => Stream.value(
        HealthCenter(
          id: 'hc1',
          userId: userId,
          name: 'CSCom',
          address: '',
          city: 'Abidjan',
          commune: 'Plateau',
          location: const GeoLocation(latitude: 5.32, longitude: -4.0),
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

void main() {
  Future<void> pumpScreen(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith(
            (ref) => Stream.value(const AuthUser(id: 'u1', email: 'a@b.ci')),
          ),
          centerRepositoryProvider.overrideWithValue(_FakeCenterRepository()),
          bloodStockRepositoryProvider
              .overrideWithValue(_FakeBloodStockRepository()),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const HcBloodSearchScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('liste les centres avec leur statut, sans quantités',
      (tester) async {
    await pumpScreen(tester);

    expect(
      find.text('3 centres de transfusion · O+ · Abidjan'),
      findsOneWidget,
    );
    expect(find.text('Disponible'), findsOneWidget);
    expect(find.text('Disponibilité limitée'), findsOneWidget);
    expect(find.text('Indisponible'), findsOneWidget);
    expect(find.text('Demander'), findsNWidgets(2));
    expect(find.text('Autres centres'), findsOneWidget);
    expect(find.textContaining('Treichville · 1,1 km'), findsOneWidget);
    expect(find.text('40'), findsNothing);
  });

  testWidgets('change de groupe sanguin', (tester) async {
    await pumpScreen(tester);

    await tester.tap(find.text('A+'));
    await tester.pumpAndSettle();

    expect(
      find.text('3 centres de transfusion · A+ · Abidjan'),
      findsOneWidget,
    );
    expect(find.text('Indisponible'), findsNWidgets(3));
  });

  testWidgets('filtre par commune', (tester) async {
    await pumpScreen(tester);

    await tester.tap(find.text('Toutes les communes'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cocody').last);
    await tester.pumpAndSettle();

    expect(
      find.text('1 centre de transfusion · O+ · Cocody'),
      findsOneWidget,
    );
  });
}
