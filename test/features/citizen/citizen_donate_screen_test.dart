import 'dart:async';

import 'package:blood_collect/core/constants/app_enums.dart';
import 'package:blood_collect/core/router/app_router.dart';
import 'package:blood_collect/core/theme/app_theme.dart';
import 'package:blood_collect/features/auth/domain/entities/auth_user.dart';
import 'package:blood_collect/features/auth/presentation/providers/auth_providers.dart';
import 'package:blood_collect/features/citizen/presentation/screens/citizen_donate_screen.dart';
import 'package:blood_collect/shared/domain/entities/entities.dart';
import 'package:blood_collect/shared/domain/repositories/campaign_registration_repository.dart';
import 'package:blood_collect/shared/domain/repositories/campaign_repository.dart';
import 'package:blood_collect/shared/domain/repositories/center_repository.dart';
import 'package:blood_collect/shared/domain/repositories/user_repository.dart';
import 'package:blood_collect/shared/presentation/providers/repository_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

final _now = DateTime.now();

Campaign _campaign(
  String id, {
  String commune = 'Treichville',
  List<BloodType> types = const [BloodType.oNeg, BloodType.bNeg],
  int startsInDays = 3,
}) {
  final day = DateTime(_now.year, _now.month, _now.day)
      .add(Duration(days: startsInDays));
  return Campaign(
    id: id,
    bloodCenterId: 'A',
    title: 'Collecte $id',
    description: 'Venez nombreux.',
    location: const GeoLocation(latitude: 0, longitude: 0),
    locationName: 'Place de la mairie',
    commune: commune,
    startDate: day.add(const Duration(hours: 8)),
    endDate: day.add(const Duration(hours: 14)),
    targetBloodTypes: types,
    targetCommunes: const [],
    targetUnits: 50,
    status: CampaignStatus.published,
    createdAt: _now,
    updatedAt: _now,
  );
}

BloodCenter _center(String id, String commune, {String hours = '0h00 – 23h59'}) =>
    BloodCenter(
      id: id,
      userId: 'owner',
      name: 'Centre de transfusion $id',
      address: '',
      city: 'Abidjan',
      commune: commune,
      location: const GeoLocation(latitude: 0, longitude: 0),
      phone: '',
      agreementNumber: '',
      contactFunction: '',
      openingHoursWeekdays: hours,
      openingHoursSaturday: hours,
      lowStockThreshold: 20,
      unavailableThreshold: 5,
      verificationStatus: VerificationStatus.verified,
      createdAt: _now,
      updatedAt: _now,
    );

/// Dépôt en mémoire qui rediffuse les inscriptions, comme Firestore.
class _FakeRegistrationRepository implements CampaignRegistrationRepository {
  _FakeRegistrationRepository(List<CampaignRegistration> initial)
      : _items = [...initial];

  final List<CampaignRegistration> _items;
  final _controller = StreamController<List<CampaignRegistration>>.broadcast();
  bool fail = false;

  List<CampaignRegistration> get items => List.unmodifiable(_items);

  @override
  Stream<List<CampaignRegistration>> watchByBloodCenter(
    String bloodCenterId,
  ) =>
      Stream.value(
        _items.where((r) => r.bloodCenterId == bloodCenterId).toList(),
      );

  @override
  Stream<List<CampaignRegistration>> watchByDonor(String donorId) async* {
    yield [..._items];
    yield* _controller.stream;
  }

  void _set(String id, CampaignRegistration value) {
    _items
      ..removeWhere((r) => r.id == id)
      ..add(value);
    _controller.add([..._items]);
  }

  @override
  Future<void> register({
    required String campaignId,
    required String bloodCenterId,
    required String donorId,
  }) async {
    if (fail) throw Exception('hors ligne');
    final id =
        CampaignRegistration.idFor(campaignId: campaignId, donorId: donorId);
    _set(
      id,
      CampaignRegistration(
        id: id,
        campaignId: campaignId,
        donorId: donorId,
        bloodCenterId: bloodCenterId,
        status: RegistrationStatus.registered,
        createdAt: _now,
        updatedAt: _now,
      ),
    );
  }

  @override
  Future<void> cancel(String registrationId) async {
    final current = _items.firstWhere((r) => r.id == registrationId);
    _set(
      registrationId,
      current.copyWith(status: RegistrationStatus.cancelled),
    );
  }
}

class _FakeCampaignRepository implements CampaignRepository {
  _FakeCampaignRepository(this.campaigns);

  final List<Campaign> campaigns;

  @override
  Stream<List<Campaign>> watchOpen() => Stream.value(campaigns);
}

class _FakeCenterRepository implements CenterRepository {
  @override
  Stream<List<BloodCenter>> watchVerifiedBloodCenters({
    required String city,
    String? commune,
  }) =>
      Stream.value([
        _center('B', 'Cocody', hours: 'sur rendez-vous'),
        _center('A', 'Treichville'),
      ]);

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
  late _FakeRegistrationRepository registrations;

  Future<void> pumpScreen(
    WidgetTester tester, {
    List<Campaign>? campaigns,
    List<CampaignRegistration> registered = const [],
  }) async {
    tester.view.physicalSize = const Size(390, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    registrations = _FakeRegistrationRepository(registered);

    GoRoute stub(String path, String label) =>
        GoRoute(path: path, builder: (_, _) => Text(label));
    final router = GoRouter(
      initialLocation: AppRoutes.citizenDonate,
      routes: [
        GoRoute(
          path: AppRoutes.citizenDonate,
          builder: (_, _) => const CitizenDonateScreen(),
        ),
        stub(AppRoutes.citizenProfile, 'écran profil'),
        GoRoute(
          path: '${AppRoutes.citizenBlood}/:centerId',
          builder: (_, state) =>
              Text('fiche centre ${state.pathParameters['centerId']}'),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith(
            (ref) => Stream.value(const AuthUser(id: 'me', email: 'a@b.ci')),
          ),
          userRepositoryProvider.overrideWithValue(_FakeUserRepository()),
          centerRepositoryProvider.overrideWithValue(_FakeCenterRepository()),
          campaignRepositoryProvider.overrideWithValue(
            _FakeCampaignRepository(
              campaigns ??
                  [
                    _campaign('Cocody', commune: 'Cocody', startsInDays: 1),
                    _campaign('Treichville', types: const []),
                  ],
            ),
          ),
          campaignRegistrationRepositoryProvider
              .overrideWithValue(registrations),
        ],
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
  }

  CampaignRegistration registration(String campaignId, RegistrationStatus s) =>
      CampaignRegistration(
        id: CampaignRegistration.idFor(campaignId: campaignId, donorId: 'me'),
        campaignId: campaignId,
        donorId: 'me',
        status: s,
        createdAt: _now,
        updatedAt: _now,
      );

  testWidgets('affiche le profil donneur et les collectes, la commune d’abord',
      (tester) async {
    await pumpScreen(tester);

    expect(find.text('DON VOLONTAIRE'), findsOneWidget);
    expect(find.text('O+'), findsOneWidget);
    expect(find.text('Treichville'), findsWidgets);

    // Celle de sa commune passe devant, bien qu'elle soit plus tardive.
    final titles = tester
        .widgetList<Text>(find.textContaining('Collecte '))
        .map((t) => t.data)
        .toList();
    expect(titles, ['Collecte Treichville', 'Collecte Cocody']);
    expect(find.text('Tous groupes'), findsOneWidget);
    expect(find.text('Je participe'), findsNWidgets(2));
    expect(
      find.text('L’éligibilité est vérifiée sur place.'),
      findsOneWidget,
    );
  });

  testWidgets('s’inscrire puis annuler une participation', (tester) async {
    await pumpScreen(tester, campaigns: [_campaign('T')]);

    await tester.tap(find.text('Je participe'));
    await tester.pumpAndSettle();

    expect(registrations.items.single.status, RegistrationStatus.registered);
    expect(registrations.items.single.id, 'T_me');
    // Le centre organisateur est recopié : il lui ouvre la lecture.
    expect(registrations.items.single.bloodCenterId, 'A');
    expect(find.text('Participation confirmée'), findsOneWidget);
    expect(find.text('Je participe'), findsNothing);

    await tester.tap(find.text('Annuler'));
    await tester.pumpAndSettle();

    expect(registrations.items.single.status, RegistrationStatus.cancelled);
    expect(find.text('Je participe'), findsOneWidget);
  });

  testWidgets('reconnaît une inscription existante, pas une annulée',
      (tester) async {
    await pumpScreen(
      tester,
      campaigns: [_campaign('T'), _campaign('C', commune: 'Cocody')],
      registered: [
        registration('T', RegistrationStatus.confirmed),
        registration('C', RegistrationStatus.cancelled),
      ],
    );

    expect(find.text('Participation confirmée'), findsOneWidget);
    expect(find.text('Je participe'), findsOneWidget);
  });

  testWidgets('signale un échec d’inscription', (tester) async {
    await pumpScreen(tester, campaigns: [_campaign('T')]);
    registrations.fail = true;

    await tester.tap(find.text('Je participe'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Action impossible'), findsOneWidget);
    expect(find.text('Je participe'), findsOneWidget);
  });

  testWidgets('détaille une collecte et mène au centre organisateur',
      (tester) async {
    await pumpScreen(tester, campaigns: [_campaign('T')]);

    await tester.tap(find.text('Voir les détails'));
    await tester.pumpAndSettle();
    expect(find.text('Venez nombreux.'), findsOneWidget);
    expect(find.text('50 dons'), findsOneWidget);

    await tester.tap(find.text('Voir le centre organisateur'));
    await tester.pumpAndSettle();
    expect(find.text('fiche centre A'), findsOneWidget);
  });

  testWidgets('liste les centres, celui de la commune en tête',
      (tester) async {
    await pumpScreen(tester);

    final names = tester
        .widgetList<Text>(find.textContaining('Centre de transfusion '))
        .map((t) => t.data)
        .toList();
    expect(names, ['Centre de transfusion A', 'Centre de transfusion B']);
    expect(find.text('Ouvert · jusqu’à 23h59'), findsOneWidget);
    // Horaires illisibles : affichés tels quels.
    expect(find.text('Lun – Ven · sur rendez-vous'), findsOneWidget);

    await tester.tap(find.text('Centre de transfusion A'));
    await tester.pumpAndSettle();
    expect(find.text('fiche centre A'), findsOneWidget);
  });

  testWidgets('« Modifier » ouvre le profil', (tester) async {
    await pumpScreen(tester);

    await tester.tap(find.text('Modifier'));
    await tester.pumpAndSettle();
    expect(find.text('écran profil'), findsOneWidget);
  });

  group('BloodCenter.openingAt', () {
    final center = _center('X', 'Plateau', hours: '7h30 – 16h00').copyWith(
      openingHoursSaturday: () => '8h – 12h',
    );
    // 5 octobre 2026 : lundi.
    DateTime at(int day, int hour, [int minute = 0]) =>
        DateTime(2026, 10, day, hour, minute);

    test('ouvert en semaine dans la plage, fermé en dehors', () {
      expect(center.openingAt(at(5, 9))!.isOpen, isTrue);
      expect(center.openingAt(at(5, 9))!.closesAtMinutes, 16 * 60);
      expect(center.openingAt(at(5, 7, 29))!.isOpen, isFalse);
      expect(center.openingAt(at(5, 16))!.isOpen, isFalse);
    });

    test('samedi selon ses horaires, dimanche fermé', () {
      expect(center.openingAt(at(10, 11))!.isOpen, isTrue);
      expect(center.openingAt(at(10, 13))!.isOpen, isFalse);
      expect(center.openingAt(at(11, 10))!.isOpen, isFalse);
      expect(
        center
            .copyWith(openingHoursSaturday: () => null)
            .openingAt(at(10, 11))!
            .isOpen,
        isFalse,
      );
    });

    test('null si les horaires ne sont pas lisibles', () {
      expect(
        center
            .copyWith(openingHoursWeekdays: 'sur rendez-vous')
            .openingAt(at(5, 9)),
        isNull,
      );
    });
  });
}
