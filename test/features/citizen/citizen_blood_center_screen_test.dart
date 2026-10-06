import 'package:blood_collect/core/constants/app_enums.dart';
import 'package:blood_collect/core/router/app_router.dart';
import 'package:blood_collect/core/theme/app_theme.dart';
import 'package:blood_collect/features/auth/domain/entities/auth_user.dart';
import 'package:blood_collect/features/auth/presentation/providers/auth_providers.dart';
import 'package:blood_collect/features/citizen/presentation/screens/citizen_blood_center_screen.dart';
import 'package:blood_collect/shared/domain/entities/entities.dart';
import 'package:blood_collect/shared/domain/repositories/blood_stock_repository.dart';
import 'package:blood_collect/shared/domain/repositories/campaign_repository.dart';
import 'package:blood_collect/shared/domain/repositories/center_repository.dart';
import 'package:blood_collect/shared/presentation/providers/repository_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

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

Campaign _campaign(String title, String bloodCenterId) {
  final day = DateTime(_now.year, _now.month, _now.day)
      .add(const Duration(days: 3));
  return Campaign(
    id: title,
    bloodCenterId: bloodCenterId,
    title: title,
    description: '',
    location: const GeoLocation(latitude: 0, longitude: 0),
    locationName: 'Place de la mairie',
    commune: 'Treichville',
    startDate: day.add(const Duration(hours: 8)),
    endDate: day.add(const Duration(hours: 14)),
    targetBloodTypes: const [BloodType.oNeg],
    targetCommunes: const [],
    targetUnits: 50,
    status: CampaignStatus.published,
    createdAt: _now,
    updatedAt: _now,
  );
}

class _FakeCenterRepository implements CenterRepository {
  @override
  Stream<BloodCenter?> watchBloodCenter(String centerId) =>
      Stream.value(centerId == _center.id ? _center : null);

  @override
  Stream<HealthCenter?> watchHealthCenterByUser(String userId) =>
      Stream.value(null);

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

class _FakeCampaignRepository implements CampaignRepository {
  _FakeCampaignRepository(this.campaigns);

  final List<Campaign> campaigns;

  @override
  Stream<List<Campaign>> watchOpen() => Stream.value(campaigns);
}

void main() {
  Future<void> pumpScreen(
    WidgetTester tester, {
    String centerId = 'A',
    List<Campaign> campaigns = const [],
  }) async {
    tester.view.physicalSize = const Size(390, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final router = GoRouter(
      initialLocation: '${AppRoutes.citizenBlood}/$centerId',
      routes: [
        GoRoute(
          path: AppRoutes.citizenBlood,
          builder: (_, _) => const Text('écran disponibilité'),
          routes: [
            GoRoute(
              path: ':centerId',
              builder: (_, state) => CitizenBloodCenterScreen(
                centerId: state.pathParameters['centerId']!,
              ),
            ),
          ],
        ),
        GoRoute(
          path: AppRoutes.citizenDonate,
          builder: (_, _) => const Text('écran donner'),
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
          bloodStockRepositoryProvider
              .overrideWithValue(_FakeBloodStockRepository()),
          campaignRepositoryProvider
              .overrideWithValue(_FakeCampaignRepository(campaigns)),
        ],
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('affiche la fiche, les disponibilités et le déroulé du don',
      (tester) async {
    await pumpScreen(tester);

    expect(find.text('CENTRE DE TRANSFUSION AGRÉÉ'), findsOneWidget);
    expect(find.text('Centre de transfusion A'), findsOneWidget);
    // Un citoyen n'a pas de position : pas de distance.
    expect(find.text('Treichville, Abidjan'), findsOneWidget);
    expect(find.text('Avenue 12, rue 38'), findsOneWidget);
    expect(find.text('Lun – Ven · 7h30 – 16h00'), findsOneWidget);
    expect(find.text('Sam · 8h00 – 12h00'), findsOneWidget);
    expect(find.bySemanticsLabel('O+ : Disponible'), findsOneWidget);
    expect(find.bySemanticsLabel('A+ : Indisponible'), findsOneWidget);
    expect(find.text('40'), findsNothing);

    expect(find.text('Comment se passe votre don'), findsOneWidget);
    expect(find.text('Vérification de l’éligibilité'), findsOneWidget);
    expect(find.text('Enregistrement du don'), findsOneWidget);

    // Lecture seule : pas de demande de sang côté citoyen.
    expect(find.text('Demander du sang à ce centre'), findsNothing);
    expect(find.text('Appeler'), findsOneWidget);
    // « Itinéraire » est masqué en v1 dans tous les espaces.
    expect(find.text('Itinéraire'), findsNothing);
  });

  testWidgets('annonce les seules collectes organisées par ce centre',
      (tester) async {
    await pumpScreen(
      tester,
      campaigns: [
        _campaign('Collecte mobile de Treichville', 'A'),
        _campaign('Collecte d’un autre centre', 'B'),
      ],
    );

    expect(find.text('Collecte mobile de Treichville'), findsOneWidget);
    expect(find.text('Collecte d’un autre centre'), findsNothing);
  });

  testWidgets('« Je souhaite donner mon sang » mène à l’onglet Donner',
      (tester) async {
    await pumpScreen(tester);

    await tester.tap(find.text('Je souhaite donner mon sang'));
    await tester.pumpAndSettle();

    expect(find.text('écran donner'), findsOneWidget);
  });

  testWidgets('signale un centre introuvable', (tester) async {
    await pumpScreen(tester, centerId: 'inconnu');

    expect(find.text('Centre introuvable'), findsOneWidget);
    expect(find.text('Je souhaite donner mon sang'), findsNothing);
  });
}
