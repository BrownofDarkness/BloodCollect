import 'package:blood_collect/core/constants/app_enums.dart';
import 'package:blood_collect/core/utils/formatters.dart';
import 'package:blood_collect/shared/domain/entities/entities.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 10, 2, 12);

  BloodCenter center({
    String id = 'bc1',
    GeoLocation location = const GeoLocation(latitude: 0, longitude: 0),
  }) =>
      BloodCenter(
        id: id,
        userId: 'u1',
        name: 'Centre $id',
        address: '',
        city: 'Abidjan',
        commune: 'Treichville',
        location: location,
        phone: '',
        agreementNumber: '',
        contactFunction: '',
        openingHoursWeekdays: '07h-18h',
        lowStockThreshold: 20,
        unavailableThreshold: 5,
        verificationStatus: VerificationStatus.verified,
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      );

  BloodStockLot lot({
    String bloodCenterId = 'bc1',
    BloodType bloodType = BloodType.oPos,
    int quantity = 10,
    StockLotStatus status = StockLotStatus.available,
    DateTime? expiryDate,
    DateTime? updatedAt,
  }) =>
      BloodStockLot(
        id: 'lot',
        bloodCenterId: bloodCenterId,
        bloodType: bloodType,
        productType: ProductType.wholeBlood,
        lotReference: 'LOT-1',
        quantity: quantity,
        expiryDate: expiryDate ?? now.add(const Duration(days: 10)),
        collectionDate: now.subtract(const Duration(days: 2)),
        status: status,
        createdAt: now,
        updatedAt: updatedAt ?? now,
      );

  AvailabilityLevel levelFor(List<BloodStockLot> lots) =>
      BloodAvailability.fromLots(
        center: center(),
        bloodType: BloodType.oPos,
        lots: lots,
        now: now,
      ).level;

  group('BloodAvailability.fromLots', () {
    test('applique les seuils du centre', () {
      expect(levelFor([]), AvailabilityLevel.unavailable);
      expect(levelFor([lot(quantity: 5)]), AvailabilityLevel.unavailable);
      expect(levelFor([lot(quantity: 6)]), AvailabilityLevel.limited);
      expect(levelFor([lot(quantity: 20)]), AvailabilityLevel.limited);
      expect(
        levelFor([lot(quantity: 15), lot(quantity: 6)]),
        AvailabilityLevel.available,
      );
    });

    test('ignore les lots périmés, non disponibles ou étrangers', () {
      expect(
        levelFor([
          lot(quantity: 50, expiryDate: now.subtract(const Duration(days: 1))),
          lot(quantity: 50, status: StockLotStatus.reserved),
          lot(quantity: 50, bloodCenterId: 'autre'),
          lot(quantity: 50, bloodType: BloodType.aPos),
        ]),
        AvailabilityLevel.unavailable,
      );
    });

    test('retient la mise à jour de lot la plus récente', () {
      final latest = now.subtract(const Duration(hours: 1));
      final availability = BloodAvailability.fromLots(
        center: center(),
        bloodType: BloodType.oPos,
        lots: [
          lot(updatedAt: now.subtract(const Duration(days: 3))),
          lot(updatedAt: latest),
        ],
        now: now,
      );
      expect(availability.updatedAt, latest);
    });

    test('masque la distance si une position est absente', () {
      const plateau = GeoLocation(latitude: 5.3197, longitude: -4.0167);
      const cocody = GeoLocation(latitude: 5.3599, longitude: -3.9870);

      final unknown = BloodAvailability.fromLots(
        center: center(),
        bloodType: BloodType.oPos,
        lots: const [],
        now: now,
        origin: plateau,
      );
      expect(unknown.distanceKm, isNull);

      final known = BloodAvailability.fromLots(
        center: center(location: cocody),
        bloodType: BloodType.oPos,
        lots: const [],
        now: now,
        origin: plateau,
      );
      expect(known.distanceKm, closeTo(5.6, 0.3));
    });

    test('trie par disponibilité puis par distance', () {
      BloodAvailability item(String id, AvailabilityLevel level, double? km) =>
          BloodAvailability(
            center: center(id: id),
            bloodType: BloodType.oPos,
            level: level,
            updatedAt: now,
            distanceKm: km,
          );

      final sorted = [
        item('c', AvailabilityLevel.unavailable, 1),
        item('b', AvailabilityLevel.available, 9),
        item('d', AvailabilityLevel.limited, null),
        item('a', AvailabilityLevel.available, 3),
      ]..sort(BloodAvailability.compare);

      expect(sorted.map((e) => e.center.id), ['a', 'b', 'd', 'c']);
    });
  });

  group('Formatters', () {
    test('distanceKm', () {
      expect(Formatters.distanceKm(3.14), '3,1 km');
      expect(Formatters.distanceKm(9), '9,0 km');
    });

    test('updatedAt', () {
      expect(
        Formatters.updatedAt(DateTime(2026, 10, 2, 9, 15), now: now),
        'Mis à jour 09:15',
      );
      expect(
        Formatters.updatedAt(DateTime(2026, 10, 1, 23, 50), now: now),
        'Mis à jour hier',
      );
      expect(
        Formatters.updatedAt(DateTime(2026, 9, 12), now: now),
        'Mis à jour le 12/09',
      );
    });
  });
}
