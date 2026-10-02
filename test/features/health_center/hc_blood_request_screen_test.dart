import 'package:blood_collect/core/constants/app_enums.dart';
import 'package:blood_collect/core/router/app_router.dart';
import 'package:blood_collect/core/theme/app_theme.dart';
import 'package:blood_collect/core/utils/validators.dart';
import 'package:blood_collect/features/auth/domain/entities/auth_user.dart';
import 'package:blood_collect/features/auth/presentation/providers/auth_providers.dart';
import 'package:blood_collect/features/health_center/presentation/providers/hc_providers.dart';
import 'package:blood_collect/features/health_center/presentation/screens/hc_blood_request_screen.dart';
import 'package:blood_collect/shared/domain/entities/entities.dart';
import 'package:blood_collect/shared/domain/repositories/blood_request_repository.dart';
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
  address: '',
  city: 'Abidjan',
  commune: 'Treichville',
  location: const GeoLocation(latitude: 0, longitude: 0),
  phone: '',
  agreementNumber: '',
  contactFunction: '',
  openingHoursWeekdays: '7h30 – 16h00',
  lowStockThreshold: 20,
  unavailableThreshold: 5,
  verificationStatus: VerificationStatus.verified,
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

class _FakeBloodStockRepository implements BloodStockRepository {
  @override
  Stream<List<BloodStockLot>> watchAvailableLotsByCenter(
    String bloodCenterId,
  ) =>
      Stream.value([
        BloodStockLot(
          id: 'lot',
          bloodCenterId: 'A',
          bloodType: BloodType.oPos,
          productType: ProductType.wholeBlood,
          lotReference: 'LOT',
          quantity: 40,
          expiryDate: _now.add(const Duration(days: 10)),
          collectionDate: _now,
          status: StockLotStatus.available,
          createdAt: _now,
          updatedAt: _now,
        ),
      ]);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeBloodRequestRepository implements BloodRequestRepository {
  final created = <BloodRequest>[];
  bool fail = false;

  @override
  Future<String> create(BloodRequest request) async {
    if (fail) throw Exception('hors ligne');
    created.add(request);
    return 'req1';
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _FakeBloodRequestRepository requests;

  setUp(() => requests = _FakeBloodRequestRepository());

  Future<void> pumpScreen(WidgetTester tester, {String? centerId = 'A'}) async {
    tester.view.physicalSize = const Size(390, 1500);
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
          bloodRequestRepositoryProvider.overrideWithValue(requests),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: HcBloodRequestScreen(
            bloodCenterId: centerId,
            bloodType: BloodType.oPos,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> submit(WidgetTester tester) async {
    await tester.tap(find.text('Transmettre la demande'));
    await tester.pumpAndSettle();
  }

  testWidgets('affiche le centre choisi et le statut du groupe demandé',
      (tester) async {
    await pumpScreen(tester);

    expect(find.text('Centre de transfusion A'), findsOneWidget);
    expect(find.text('O+ · Disponible'), findsOneWidget);
    expect(find.text('Changer'), findsOneWidget);
    expect(find.text('1 poche'), findsOneWidget);

    await tester.tap(find.text('AB-'));
    await tester.pumpAndSettle();
    expect(find.text('AB- · Indisponible'), findsOneWidget);
  });

  testWidgets('refuse l’envoi sans référence patient valide', (tester) async {
    await pumpScreen(tester);

    await submit(tester);
    expect(find.text('La référence du dossier est requise.'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).first, 'Jean Kouassi');
    await submit(tester);
    expect(find.textContaining('Référence invalide'), findsOneWidget);
    expect(requests.created, isEmpty);
  });

  testWidgets('transmet la demande saisie au centre choisi', (tester) async {
    await pumpScreen(tester);

    await tester.enterText(find.byType(TextFormField).first, 'dos-2291');
    await tester.tap(find.text('A+'));
    await tester.tap(find.byTooltip('Augmenter'));
    await tester.tap(find.text('Vitale'));
    await tester.enterText(find.byType(TextFormField).last, ' Sous 2 h ');
    await tester.pumpAndSettle();
    expect(find.text('2 poches'), findsOneWidget);

    await submit(tester);

    final request = requests.created.single;
    expect(request.healthCenterId, 'hc1');
    expect(request.matchedBloodCenterId, 'A');
    expect(request.patientReference, 'DOS-2291');
    expect(request.bloodType, BloodType.aPos);
    expect(request.quantityNeeded, 2);
    expect(request.priority, Priority.vital);
    expect(request.notes, 'Sous 2 h');
    expect(request.status, RequestStatus.pending);
    expect(request.bloodRouteStep, BloodRouteStep.searchingStock);
    expect(find.text('Demande transmise'), findsOneWidget);
  });

  testWidgets('signale un échec d’envoi sans perdre la saisie', (tester) async {
    requests.fail = true;
    await pumpScreen(tester);

    await tester.enterText(find.byType(TextFormField).first, 'DOS-2291');
    await submit(tester);

    expect(find.textContaining('Envoi impossible'), findsOneWidget);
    expect(find.text('Demande transmise'), findsNothing);
    // Le texte d'aide vaut aussi « DOS-2291 » : on lit la valeur du champ.
    final field = tester.widget<EditableText>(find.byType(EditableText).first);
    expect(field.controller.text, 'DOS-2291');
  });

  testWidgets('bloque l’envoi tant qu’aucun centre n’est choisi',
      (tester) async {
    await pumpScreen(tester, centerId: null);

    expect(find.text('Aucun centre choisi'), findsOneWidget);
    expect(find.text('Choisir'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).first, 'DOS-2291');
    await submit(tester);
    expect(requests.created, isEmpty);
  });

  test('Validators.patientReference', () {
    expect(Validators.patientReference('DOS-2291'), isNull);
    expect(Validators.patientReference(' dos/22.91 '), isNull);
    expect(Validators.patientReference(''), isNotNull);
    expect(Validators.patientReference('A'), isNotNull);
    expect(Validators.patientReference('Jean Kouassi'), isNotNull);
  });

  test('le chemin de la demande reste dans l’onglet Sang', () {
    expect(
      AppRoutes.hcBloodRequestPath(
        bloodCenterId: 'A',
        bloodType: BloodType.oPos,
      ),
      '/hc/blood/request?bloodCenterId=A&bloodType=O%2B',
    );
    expect(AppRoutes.hcBloodRequestPath(), '/hc/blood/request');
  });
}
