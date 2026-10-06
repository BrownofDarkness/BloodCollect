import 'package:blood_collect/core/constants/app_enums.dart';
import 'package:blood_collect/core/theme/app_theme.dart';
import 'package:blood_collect/features/blood_center/presentation/providers/bc_dashboard_providers.dart';
import 'package:blood_collect/features/blood_center/presentation/screens/bc_request_detail_screen.dart';
import 'package:blood_collect/shared/domain/entities/entities.dart';
import 'package:blood_collect/shared/domain/repositories/blood_center_data_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

final _now = DateTime.now();

final _center = BloodCenter(
  id: 'A',
  userId: 'owner',
  name: 'Centre de transfusion A',
  address: '',
  city: 'Abidjan',
  commune: 'Treichville',
  location: const GeoLocation(latitude: 0, longitude: 0),
  phone: '',
  agreementNumber: 'AG-1',
  contactFunction: '',
  openingHoursWeekdays: '',
  openingHoursSaturday: '',
  lowStockThreshold: 20,
  unavailableThreshold: 5,
  verificationStatus: VerificationStatus.verified,
  createdAt: _now,
  updatedAt: _now,
);

final _lot = BloodStockLot(
  id: 'lot',
  bloodCenterId: 'A',
  bloodType: BloodType.oPos,
  productType: ProductType.wholeBlood,
  lotReference: 'LOT',
  quantity: 10,
  expiryDate: _now.add(const Duration(days: 10)),
  collectionDate: _now,
  status: StockLotStatus.available,
  createdAt: _now,
  updatedAt: _now,
);

BloodRequest _request({
  RequestStatus status = RequestStatus.pending,
  int? quantityGranted,
  String? responseMessage,
  DateTime? processedAt,
}) =>
    BloodRequest(
      id: 'r1',
      healthCenterId: 'hc1',
      bloodType: BloodType.oPos,
      productType: ProductType.wholeBlood,
      quantityNeeded: 3,
      priority: Priority.normal,
      status: status,
      bloodRouteStep: BloodRouteStep.searchingStock,
      quantityGranted: quantityGranted,
      responseMessage: responseMessage,
      createdAt: _now,
      updatedAt: _now,
      processedAt: processedAt,
    );

class _FakeRepository implements BloodCenterDataRepository {
  final saved = <BloodRequest>[];

  @override
  Future<void> updateBloodRequest(BloodRequest request) async =>
      saved.add(request);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _FakeRepository repository;

  Future<void> pumpScreen(WidgetTester tester, BloodRequest request) async {
    tester.view.physicalSize = const Size(390, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    repository = _FakeRepository();
    final router = GoRouter(
      initialLocation: '/bc/requests/r1',
      routes: [
        GoRoute(
          path: '/bc/requests',
          builder: (_, _) => const Text('liste des demandes'),
          routes: [
            GoRoute(
              path: ':id',
              builder: (_, state) => BcRequestDetailScreen(
                requestId: state.pathParameters['id']!,
              ),
            ),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          bloodCenterDataRepositoryProvider.overrideWithValue(repository),
          myBloodCenterProvider.overrideWith((ref) => Stream.value(_center)),
          bcBloodRequestsProvider
              .overrideWith((ref) => Stream.value([request])),
          bcStockLotsProvider.overrideWith((ref) => Stream.value([_lot])),
          bcHealthCenterNamesProvider
              .overrideWith((ref) => Stream.value(const {})),
          bcHealthCenterPhonesProvider
              .overrideWith((ref) => Stream.value(const {})),
        ],
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('une demande traitée n’est plus modifiable', (tester) async {
    await pumpScreen(
      tester,
      _request(
        status: RequestStatus.partiallyFulfilled,
        quantityGranted: 2,
        responseMessage: 'Prêtes au retrait',
        processedAt: _now,
      ),
    );

    expect(find.text('DÉCISION RENDUE'), findsOneWidget);
    expect(find.text('Demande approuvée partiellement'), findsOneWidget);
    expect(find.text('2 poches sur 3'), findsOneWidget);
    expect(find.text('Prêtes au retrait'), findsOneWidget);
    expect(find.textContaining('n’est plus modifiable'), findsOneWidget);

    // Plus aucun moyen de se prononcer à nouveau.
    expect(find.text('Approuver'), findsNothing);
    expect(find.text('Refuser · indisponible'), findsNothing);
    expect(find.text('Valider la décision'), findsNothing);
  });

  testWidgets('la validation demande confirmation : décision irréversible',
      (tester) async {
    await pumpScreen(tester, _request());

    await tester.tap(find.text('Approuver'));
    await tester.pump();
    await tester.tap(find.text('Valider la décision'));
    await tester.pumpAndSettle();

    expect(find.text('Décision irréversible'), findsOneWidget);
    expect(find.textContaining('ne pourra plus être modifiée'), findsOneWidget);
    expect(find.textContaining('Approuver la demande : 3 poches O+'),
        findsOneWidget);

    // « Revenir » n'enregistre rien et laisse le choix ouvert.
    await tester.tap(find.text('Revenir'));
    await tester.pumpAndSettle();
    expect(repository.saved, isEmpty);
    expect(find.text('Valider la décision'), findsOneWidget);

    await tester.tap(find.text('Valider la décision'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirmer'));
    await tester.pumpAndSettle();

    expect(repository.saved.single.status, RequestStatus.fulfilled);
    expect(repository.saved.single.quantityGranted, 3);
    expect(find.text('liste des demandes'), findsOneWidget);
  });
}
