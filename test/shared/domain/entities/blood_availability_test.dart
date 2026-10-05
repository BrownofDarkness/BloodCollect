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
      updatedAt: reference,
    );
  }

  group('BloodAvailability.fromLots', () {
    test('classe les unités selon les seuils du centre', () {
      final availability = BloodAvailability.fromLots(
        center: centerWith(),
        lots: [
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
        ],
        updatedAt: reference,
        now: reference,
      );

      expect(
        availability.statusOf(BloodType.oPos),
        BloodAvailabilityStatus.available,
      );
      expect(
        availability.statusOf(BloodType.oNeg),
        BloodAvailabilityStatus.limited,
      );
      expect(
        availability.statusOf(BloodType.aNeg),
        BloodAvailabilityStatus.unavailable,
      );
    });

    test('additionne les lots d\'un même groupe', () {
      final availability = BloodAvailability.fromLots(
        center: centerWith(lowStockThreshold: 30),
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
        updatedAt: reference,
        now: reference,
      );

      expect(availability.unitsOf(BloodType.oPos), 35);
      expect(
        availability.statusOf(BloodType.oPos),
        BloodAvailabilityStatus.available,
      );
    });

    test('ignore un lot périmé même s\'il est marqué disponible', () {
      final availability = BloodAvailability.fromLots(
        center: centerWith(),
        lots: [
          lot(
            bloodType: BloodType.oPos,
            quantity: 50,
            centerId: 'center_a',
            expiryDate: reference.subtract(const Duration(days: 1)),
          ),
        ],
        updatedAt: reference,
        now: reference,
      );

      expect(availability.unitsOf(BloodType.oPos), 0);
      expect(
        availability.statusOf(BloodType.oPos),
        BloodAvailabilityStatus.unavailable,
      );
    });

    test('ignore les lots non disponibles', () {
      final availability = BloodAvailability.fromLots(
        center: centerWith(),
        lots: [
          lot(
            bloodType: BloodType.oPos,
            quantity: 50,
            centerId: 'center_a',
            expiryDate: reference.add(const Duration(days: 20)),
            status: StockLotStatus.reserved,
          ),
        ],
        updatedAt: reference,
        now: reference,
      );

      expect(availability.unitsOf(BloodType.oPos), 0);
    });

    test('ignore les lots d\'un autre centre', () {
      final availability = BloodAvailability.fromLots(
        center: centerWith(),
        lots: [
          lot(
            bloodType: BloodType.oPos,
            quantity: 50,
            centerId: 'center_b',
            expiryDate: reference.add(const Duration(days: 20)),
          ),
        ],
        updatedAt: reference,
        now: reference,
      );

      expect(availability.unitsOf(BloodType.oPos), 0);
    });

    test('traite un groupe absent comme indisponible', () {
      final availability = BloodAvailability.fromLots(
        center: centerWith(),
        lots: const [],
        updatedAt: reference,
        now: reference,
      );

      expect(
        availability.statusOf(BloodType.abPos),
        BloodAvailabilityStatus.unavailable,
      );
      expect(availability.unitsOf(BloodType.abPos), 0);
    });
  });
}
