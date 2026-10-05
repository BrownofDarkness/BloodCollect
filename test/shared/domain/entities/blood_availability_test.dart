import 'package:blood_collect/core/constants/app_enums.dart';
import 'package:blood_collect/shared/domain/entities/blood_availability.dart';
import 'package:blood_collect/shared/domain/entities/blood_center.dart';
import 'package:blood_collect/shared/domain/entities/blood_stock_lot.dart';
import 'package:blood_collect/shared/domain/entities/geo_location.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final reference = DateTime(2026, 10, 20);

  BloodCenter centerWith({
    int lowStockThreshold = 20,
    int unavailableThreshold = 5,
    VerificationStatus status = VerificationStatus.verified,
  }) {
    return BloodCenter(
      id: 'center_a',
      userId: 'user_a',
      name: 'Centre A',
      address: 'Adresse',
      city: 'Abidjan',
      commune: 'Treichville',
      location: const GeoLocation(latitude: 5.36, longitude: -3.79),
      phone: '0700000000',
      agreementNumber: 'AGR-1',
      contactFunction: 'Responsable',
      openingHoursWeekdays: '7h30 – 16h00',
      lowStockThreshold: lowStockThreshold,
      unavailableThreshold: unavailableThreshold,
      verificationStatus: status,
      createdAt: reference,
      updatedAt: reference,
    );
  }

  BloodStockLot lot({
    required BloodType bloodType,
    required int quantity,
    required String centerId,
    required DateTime expiryDate,
    StockLotStatus status = StockLotStatus.available,
    DateTime? updatedAt,
  }) {
    return BloodStockLot(
      id: 'lot_$bloodType$quantity',
      bloodCenterId: centerId,
      bloodType: bloodType,
      productType: ProductType.wholeBlood,
      lotReference: 'LOT-1',
      quantity: quantity,
      expiryDate: expiryDate,
      collectionDate: reference.subtract(const Duration(days: 5)),
      status: status,
      createdAt: reference,
      updatedAt: updatedAt ?? reference,
    );
  }

  /// Niveau d'un groupe dans un centre, calculé depuis les lots.
  ///
  /// L'entité décrit un groupe sanguin à la fois : unlike aggregates, la
  /// lecture passe donc par un `fromLots` par groupe.
  AvailabilityLevel levelOf({
    required BloodCenter center,
    required BloodType bloodType,
    required List<BloodStockLot> lots,
  }) {
    return BloodAvailability.fromLots(
      center: center,
      bloodType: bloodType,
      lots: lots,
      now: reference,
    ).level;
  }

  group('BloodAvailability.fromLots', () {
    test('classe les unités selon les seuils du centre', () {
      final center = centerWith();
      final lots = [
        lot(
          bloodType: BloodType.oPos,
          quantity: 64,
          centerId: 'center_a',
          expiryDate: reference.add(const Duration(days: 20)),
        ),
        lot(
          bloodType: BloodType.oNeg,
          quantity: 12,
          centerId: 'center_a',
          expiryDate: reference.add(const Duration(days: 20)),
        ),
        lot(
          bloodType: BloodType.aNeg,
          quantity: 0,
          centerId: 'center_a',
          expiryDate: reference.add(const Duration(days: 20)),
        ),
      ];

      expect(
        levelOf(center: center, bloodType: BloodType.oPos, lots: lots),
        AvailabilityLevel.available,
        reason: '64 unités dépassent le seuil de 20 : disponible',
      );
      expect(
        levelOf(center: center, bloodType: BloodType.oNeg, lots: lots),
        AvailabilityLevel.limited,
        reason: '12 unités sont entre les seuils 5 et 20 : limitée',
      );
      expect(
        levelOf(center: center, bloodType: BloodType.aNeg, lots: lots),
        AvailabilityLevel.unavailable,
        reason: '0 unité est sous le seuil de 5 : indisponible',
      );
    });

    test('additionne les lots d\'un même groupe', () {
      // Seuil à 30 : 20 + 15 = 35 le dépasse, mais aucun lot seul ne le fait.
      // Le niveau disponible prouve donc que les lots ont été sommés.
      final availability = BloodAvailability.fromLots(
        center: centerWith(lowStockThreshold: 30),
        bloodType: BloodType.oPos,
        lots: [
          lot(
            bloodType: BloodType.oPos,
            quantity: 20,
            centerId: 'center_a',
            expiryDate: reference.add(const Duration(days: 20)),
          ),
          lot(
            bloodType: BloodType.oPos,
            quantity: 15,
            centerId: 'center_a',
            expiryDate: reference.add(const Duration(days: 20)),
          ),
        ],
        now: reference,
      );

      expect(availability.level, AvailabilityLevel.available);
      expect(availability.bloodType, BloodType.oPos);
    });

    test('ignore un lot périmé même s\'il est marqué disponible', () {
      final availability = BloodAvailability.fromLots(
        center: centerWith(),
        bloodType: BloodType.oPos,
        lots: [
          lot(
            bloodType: BloodType.oPos,
            quantity: 50,
            centerId: 'center_a',
            expiryDate: reference.subtract(const Duration(days: 1)),
          ),
        ],
        now: reference,
      );

      expect(availability.level, AvailabilityLevel.unavailable);
      expect(availability.canRequest, isFalse);
    });

    test('ignore les lots non disponibles', () {
      final availability = BloodAvailability.fromLots(
        center: centerWith(),
        bloodType: BloodType.oPos,
        lots: [
          lot(
            bloodType: BloodType.oPos,
            quantity: 50,
            centerId: 'center_a',
            expiryDate: reference.add(const Duration(days: 20)),
            status: StockLotStatus.reserved,
          ),
        ],
        now: reference,
      );

      expect(availability.level, AvailabilityLevel.unavailable);
    });

    test('ignore les lots d\'un autre centre', () {
      final availability = BloodAvailability.fromLots(
        center: centerWith(),
        bloodType: BloodType.oPos,
        lots: [
          lot(
            bloodType: BloodType.oPos,
            quantity: 50,
            centerId: 'center_b',
            expiryDate: reference.add(const Duration(days: 20)),
          ),
        ],
        now: reference,
      );

      expect(availability.level, AvailabilityLevel.unavailable);
    });

    test('traite un groupe sans aucun lot comme indisponible', () {
      final availability = BloodAvailability.fromLots(
        center: centerWith(),
        bloodType: BloodType.abPos,
        lots: const [],
        now: reference,
      );

      expect(availability.level, AvailabilityLevel.unavailable);
      expect(availability.canRequest, isFalse);
    });

    test('reporte la date du lot le plus récent', () {
      final center = centerWith();
      final later = reference.add(const Duration(days: 2));
      final availability = BloodAvailability.fromLots(
        center: center,
        bloodType: BloodType.oPos,
        lots: [
          lot(
            bloodType: BloodType.oPos,
            quantity: 10,
            centerId: 'center_a',
            expiryDate: reference.add(const Duration(days: 20)),
            updatedAt: reference,
          ),
          lot(
            bloodType: BloodType.oPos,
            quantity: 10,
            centerId: 'center_a',
            expiryDate: reference.add(const Duration(days: 20)),
            updatedAt: later,
          ),
        ],
        now: reference,
      );

      expect(availability.updatedAt, later);
    });

    test('sans lot, la date du centre fait foi', () {
      final availability = BloodAvailability.fromLots(
        center: centerWith(),
        bloodType: BloodType.oPos,
        lots: const [],
        now: reference,
      );

      expect(availability.updatedAt, reference);
    });

    test('sans origine connue, la distance reste inconnue', () {
      final availability = BloodAvailability.fromLots(
        center: centerWith(),
        bloodType: BloodType.oPos,
        lots: const [],
        now: reference,
      );

      expect(availability.distanceKm, isNull);
    });

    test('calcule la distance quand l\'origine est fournie', () {
      final availability = BloodAvailability.fromLots(
        center: centerWith(),
        bloodType: BloodType.oPos,
        lots: const [],
        now: reference,
        origin: centerWith().location,
      );

      expect(availability.distanceKm, closeTo(0, 0.001));
    });
  });

  group('BloodAvailability.allGroups', () {
    test('couvre les 8 groupes dans l\'ordre d\'affichage', () {
      final groups = BloodAvailability.allGroups(
        center: centerWith(),
        lots: [
          lot(
            bloodType: BloodType.oPos,
            quantity: 64,
            centerId: 'center_a',
            expiryDate: reference.add(const Duration(days: 20)),
          ),
        ],
        now: reference,
      );

      expect(groups, hasLength(BloodType.values.length));
      expect(
        groups.map((group) => group.bloodType),
        BloodType.displayOrder,
      );
    });

    test('n\'expose que le niveau déclaré, jamais les quantités', () {
      final groups = BloodAvailability.allGroups(
        center: centerWith(),
        lots: [
          lot(
            bloodType: BloodType.oPos,
            quantity: 64,
            centerId: 'center_a',
            expiryDate: reference.add(const Duration(days: 20)),
          ),
        ],
        now: reference,
      );

      expect(
        groups.firstWhere((g) => g.bloodType == BloodType.oPos).level,
        AvailabilityLevel.available,
      );
      expect(
        groups
            .where((g) => g.bloodType != BloodType.oPos)
            .every((g) => g.level == AvailabilityLevel.unavailable),
        isTrue,
        reason: 'un groupe sans lot est indiscernable d\'un groupe épuisé',
      );
    });
  });

  group('BloodAvailability.compare', () {
    BloodAvailability at(AvailabilityLevel level, {double? distanceKm}) {
      return BloodAvailability(
        center: centerWith(),
        bloodType: BloodType.oPos,
        level: level,
        updatedAt: reference,
        distanceKm: distanceKm,
      );
    }

    test('range le plus disponible en premier', () {
      final groups = [
        at(AvailabilityLevel.unavailable),
        at(AvailabilityLevel.available),
        at(AvailabilityLevel.limited),
      ]..sort(BloodAvailability.compare);

      expect(
        groups.map((group) => group.level),
        [
          AvailabilityLevel.available,
          AvailabilityLevel.limited,
          AvailabilityLevel.unavailable,
        ],
      );
    });

    test('à niveau égal, range le plus proche en premier', () {
      final groups = [
        at(AvailabilityLevel.available, distanceKm: 9),
        at(AvailabilityLevel.available, distanceKm: 2),
      ]..sort(BloodAvailability.compare);

      expect(groups.first.distanceKm, 2);
    });

    test('sans distance connue, le groupe passe en dernier', () {
      final groups = [
        at(AvailabilityLevel.available),
        at(AvailabilityLevel.available, distanceKm: 12),
      ]..sort(BloodAvailability.compare);

      expect(groups.first.distanceKm, 12);
    });
  });
}
