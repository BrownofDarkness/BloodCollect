import 'package:blood_collect/core/constants/app_enums.dart';
import 'package:blood_collect/core/router/app_router.dart';
import 'package:blood_collect/core/theme/app_theme.dart';
import 'package:blood_collect/features/auth/domain/entities/auth_user.dart';
import 'package:blood_collect/features/auth/presentation/providers/auth_providers.dart';
import 'package:blood_collect/features/health_center/presentation/providers/hc_providers.dart';
import 'package:blood_collect/features/health_center/presentation/screens/hc_blood_center_screen.dart';
import 'package:blood_collect/shared/domain/entities/entities.dart';
import 'package:blood_collect/shared/domain/repositories/blood_stock_repository.dart';
import 'package:blood_collect/shared/domain/repositories/center_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

final _now = DateTime.now();

final _center = BloodCenter(
  id: 'A',
  userId: 'owner',
  name: 'Centre de transfusion A',
  address: 'Avenue 12, rue 38',
  city: 'Abidjan',
  commune: 'Treichville',
  location: const GeoLocation(latitude: 5.33, longitude: -4.0),
  phone: '+2250700000000',
  agreementNumber: 'AG-1',
  contactFunction: '',
  openingHoursWeekdays: '7h30 – 16h00',
  openingHoursSaturday: '8h00 – 12h00',
  lowStockThreshold: 20,
  unavailableThreshold: 5,
  verificationStatus: VerificationStatus.verified,
  createdAt: _now,
  updatedAt: _now,
);

BloodStockLot _lot(BloodType bloodType, int quantity) => BloodStockLot(
      id: 'lot-${bloodType.name}',
      bloodCenterId: 'A',
      bloodType: bloodType,
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
  @override
  Stream<BloodCenter?> watchBloodCenter(String centerId) =>
      Stream.value(centerId == _center.id ? _center : null);

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
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeBloodStockRepository implements BloodStockRepository {
  @override
  Stream<List<BloodStockLot>> watchAvailableLotsByCenter(
    String bloodCenterId,
  ) =>
      Stream.value([_lot(BloodType.oPos, 40), _lot(BloodType.oNeg, 10)]);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  Future<void> pumpScreen(WidgetTester tester, String centerId) async {
    tester.view.physicalSize = const Size(390, 1400);
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
          home: HcBloodCenterScreen(
            centerId: centerId,
            bloodType: BloodType.oPos,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('affiche la fiche et le statut des 8 groupes, sans quantités',
      (tester) async {
    await pumpScreen(tester, 'A');

    expect(find.text('CENTRE DE TRANSFUSION AGRÉÉ'), findsOneWidget);
    expect(find.text('Centre de transfusion A'), findsOneWidget);
    expect(find.text('Treichville, Abidjan · 1,1 km'), findsOneWidget);
    expect(find.text('Avenue 12, rue 38'), findsOneWidget);
    expect(find.text('Lun – Ven · 7h30 – 16h00'), findsOneWidget);
    expect(find.text('Sam · 8h00 – 12h00'), findsOneWidget);
    expect(find.text('+2250700000000'), findsOneWidget);

    for (final type in BloodType.values) {
      expect(find.text(type.label), findsOneWidget);
    }
    expect(find.bySemanticsLabel('O+ : Disponible'), findsOneWidget);
    expect(find.bySemanticsLabel('O- : Disponibilité limitée'), findsOneWidget);
    expect(find.bySemanticsLabel('A+ : Indisponible'), findsOneWidget);
    expect(find.text('40'), findsNothing);

    expect(find.text('Demander du sang à ce centre'), findsOneWidget);
    expect(find.text('Appeler'), findsOneWidget);
    expect(find.text('Itinéraire'), findsOneWidget);
  });

  testWidgets('signale un centre introuvable', (tester) async {
    await pumpScreen(tester, 'inconnu');

    expect(find.text('Centre introuvable'), findsOneWidget);
    expect(find.text('Demander du sang à ce centre'), findsNothing);
  });

  test('les chemins transmettent le groupe et le centre', () {
    expect(
      AppRoutes.hcBloodCenterPath('A', bloodType: BloodType.oPos),
      '/hc/blood/center/A?bloodType=O%2B',
    );
    expect(AppRoutes.hcBloodCenterPath('A'), '/hc/blood/center/A');
    expect(
      Uri.parse(
        AppRoutes.hcBloodRequestPath(
          bloodCenterId: 'A',
          bloodType: BloodType.abNeg,
        ),
      ).queryParameters,
      {'bloodCenterId': 'A', 'bloodType': 'AB-'},
    );
  });
}
