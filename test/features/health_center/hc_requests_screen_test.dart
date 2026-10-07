import 'package:blood_collect/core/constants/app_enums.dart';
import 'package:blood_collect/core/theme/app_theme.dart';
import 'package:blood_collect/core/utils/formatters.dart';
import 'package:blood_collect/features/auth/domain/entities/auth_user.dart';
import 'package:blood_collect/features/auth/presentation/providers/auth_providers.dart';
import 'package:blood_collect/features/health_center/presentation/providers/hc_providers.dart';
import 'package:blood_collect/features/health_center/presentation/screens/hc_requests_screen.dart';
import 'package:blood_collect/shared/domain/entities/entities.dart';
import 'package:blood_collect/shared/domain/repositories/blood_request_repository.dart';
import 'package:blood_collect/shared/domain/repositories/center_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

final _now = DateTime.now();

BloodRequest _request(
  String id, {
  BloodType bloodType = BloodType.oPos,
  int quantity = 2,
  Priority priority = Priority.normal,
  RequestStatus status = RequestStatus.pending,
  String centerId = 'A',
  Duration age = const Duration(minutes: 22),
  DateTime? receivedAt,
  DateTime? processedAt,
  String? responseMessage,
  int? quantityGranted,
}) =>
    BloodRequest(
      id: id,
      healthCenterId: 'hc1',
      bloodType: bloodType,
      productType: ProductType.wholeBlood,
      quantityNeeded: quantity,
      patientReference: 'DOS-$id',
      priority: priority,
      status: status,
      bloodRouteStep: BloodRouteStep.searchingStock,
      matchedBloodCenterId: centerId,
      responseMessage: responseMessage,
      quantityGranted: quantityGranted,
      createdAt: _now.subtract(age),
      updatedAt: _now,
      receivedAt: receivedAt,
      processedAt: processedAt,
    );

class _FakeCenterRepository implements CenterRepository {
  @override
  Stream<BloodCenter?> watchBloodCenter(String centerId) => Stream.value(
        BloodCenter(
          id: centerId,
          userId: 'owner',
          name: 'Centre de transfusion $centerId',
          address: '',
          city: 'Abidjan',
          commune: 'Treichville',
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
      );

  @override
  Stream<HealthCenter?> watchHealthCenterByUser(String userId) => Stream.value(
        HealthCenter(
          id: 'hc1',
          userId: userId,
          name: 'CSCom',
          address: '',
          city: 'Abidjan',
          commune: 'Plateau',
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

class _FakeBloodRequestRepository implements BloodRequestRepository {
  _FakeBloodRequestRepository(this.requests);

  final List<BloodRequest> requests;

  @override
  Stream<List<BloodRequest>> watchByHealthCenter(String healthCenterId) =>
      Stream.value(requests);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  Future<void> pumpScreen(
    WidgetTester tester,
    List<BloodRequest> requests,
  ) async {
    tester.view.physicalSize = const Size(390, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith(
            (ref) => Stream.value(const AuthUser(id: 'u1', email: 'a@b.ci')),
          ),
          centerRepositoryProvider.overrideWithValue(_FakeCenterRepository()),
          bloodRequestRepositoryProvider
              .overrideWithValue(_FakeBloodRequestRepository(requests)),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const HcRequestsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  final sample = [
    _request(
      '2291',
      bloodType: BloodType.oNeg,
      priority: Priority.vital,
      status: RequestStatus.routing,
      receivedAt: _now,
    ),
    _request('2285'),
    _request(
      '2266',
      bloodType: BloodType.bPos,
      quantity: 3,
      status: RequestStatus.oriented,
      centerId: 'C',
      processedAt: _now,
      responseMessage: 'Orientée vers le Centre de transfusion B',
    ),
    _request(
      '2200',
      status: RequestStatus.partiallyFulfilled,
      processedAt: _now,
      quantityGranted: 1,
    ),
    _request('2100', status: RequestStatus.cancelled, processedAt: _now),
    _request('2000', status: RequestStatus.cancelled),
    _request('1900', status: RequestStatus.expired),
  ];

  testWidgets('liste les demandes en cours et déplie la première',
      (tester) async {
    await pumpScreen(tester, sample);

    expect(find.text('En cours · 3'), findsOneWidget);
    expect(find.text('2 poches · DOS-2291'), findsOneWidget);
    expect(find.text('Centre de transfusion A · Urgence vitale'), findsOneWidget);
    expect(find.text('Centre de transfusion A · il y a 22 min'), findsOneWidget);
    expect(find.text('En attente'), findsOneWidget);
    expect(find.text('Orientée'), findsOneWidget);
    expect(find.text('Orientée vers le Centre de transfusion B'), findsOneWidget);

    // Frise de la 1re carte uniquement (pastille + étape courante). Ses
    // étapes intermédiaires sont affichées car réellement enregistrées.
    expect(find.text('En cours de traitement'), findsNWidgets(2));
    expect(find.text('Reçue par le centre'), findsOneWidget);
    expect(find.text('Transmise'), findsOneWidget);
    expect(find.text('Décision du centre'), findsOneWidget);
    expect(find.text('3 poches · DOS-2200'), findsNothing);
  });

  testWidgets('déplie une autre carte au toucher', (tester) async {
    await pumpScreen(tester, sample);

    await tester.tap(find.text('2 poches · DOS-2285'));
    await tester.pumpAndSettle();

    // Seule la demande en attente est dépliée : frise à deux étapes, sans
    // étape intermédiaire non constatée (il ne reste que la pastille de la
    // 1re carte).
    expect(find.text('Transmise'), findsOneWidget);
    expect(find.text('Décision du centre'), findsOneWidget);
    expect(find.text('Reçue par le centre'), findsNothing);
    expect(find.text('En cours de traitement'), findsOneWidget);
    expect(find.textContaining('Depuis'), findsNothing);
  });

  testWidgets('n’invente pas d’étapes intermédiaires après une décision',
      (tester) async {
    await pumpScreen(tester, sample);

    // 1re carte de « Traitées » : décision rendue sans réception enregistrée.
    await tester.tap(find.text('Traitées'));
    await tester.pumpAndSettle();

    expect(find.text('Transmise'), findsOneWidget);
    expect(
      find.text('Décision : partiellement approuvée'),
      findsOneWidget,
    );
    expect(find.text('Reçue par le centre'), findsNothing);
    expect(find.text('En cours de traitement'), findsNothing);
  });

  testWidgets('range les décisions et les demandes closes par onglet',
      (tester) async {
    await pumpScreen(tester, sample);

    await tester.tap(find.text('Traitées'));
    await tester.pumpAndSettle();
    expect(find.text('Partiellement approuvée'), findsOneWidget);
    expect(find.text('Refusée'), findsOneWidget);
    expect(find.textContaining('1 sur 2 poches accordées'), findsOneWidget);
    expect(find.text('En attente'), findsNothing);

    await tester.tap(find.text('Historique'));
    await tester.pumpAndSettle();
    expect(find.text('Annulée'), findsOneWidget);
    expect(find.text('Expirée'), findsOneWidget);
    expect(find.text('Refusée'), findsNothing);
  });

  testWidgets('invite à chercher du sang quand rien n’est en cours',
      (tester) async {
    await pumpScreen(tester, const []);

    expect(find.text('En cours'), findsOneWidget);
    expect(find.text('Aucune demande en cours'), findsOneWidget);
    expect(find.text('Trouver du sang'), findsOneWidget);
  });

  test('BloodRequest.progress lit le statut et les horodatages', () {
    expect(_request('1').progress, RequestProgress.waiting);
    expect(_request('1', receivedAt: _now).progress, RequestProgress.received);
    expect(
      _request('1', status: RequestStatus.routing).progress,
      RequestProgress.processing,
    );
    expect(
      _request('1', status: RequestStatus.fulfilled).progress,
      RequestProgress.approved,
    );
    expect(
      _request('1', status: RequestStatus.cancelled, processedAt: _now)
          .progress,
      RequestProgress.refused,
    );
    expect(
      _request('1', status: RequestStatus.cancelled).progress,
      RequestProgress.cancelled,
    );
    expect(_request('1').decidedAt, isNull);
    expect(
      _request('1', status: RequestStatus.oriented, processedAt: _now)
          .decidedAt,
      _now,
    );
  });

  test('Formatters.relative et timeOrDate', () {
    final now = DateTime(2026, 10, 2, 12);
    expect(Formatters.relative(DateTime(2026, 10, 2, 11, 38), now: now),
        'il y a 22 min');
    expect(Formatters.relative(DateTime(2026, 10, 2, 9), now: now), 'il y a 3 h');
    expect(Formatters.relative(DateTime(2026, 10, 1, 23), now: now), 'hier');
    expect(Formatters.relative(DateTime(2026, 9, 12), now: now), 'le 12/09');
    expect(Formatters.relative(now, now: now), 'à l’instant');
    expect(Formatters.timeOrDate(DateTime(2026, 10, 2, 10, 42), now: now),
        '10:42');
    expect(Formatters.timeOrDate(DateTime(2026, 10, 1, 8, 5), now: now),
        'hier 08:05');
    expect(Formatters.timeOrDate(DateTime(2026, 9, 12, 8, 5), now: now),
        '12/09 08:05');
  });
}
