import 'package:blood_collect/core/constants/app_enums.dart';
import 'package:blood_collect/shared/domain/entities/blood_availability.dart';
import 'package:blood_collect/shared/domain/entities/blood_center.dart';
import 'package:blood_collect/features/citizen/domain/usecases/get_blood_availability_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../fixtures/citizen_mock_datasource.dart';
import '../../../../fixtures/citizen_repository_fakes.dart';

void main() {
  late InMemoryBloodCenterRepository centers;
  late InMemoryDonorRepository donors;
  late GetBloodAvailabilityUseCase useCase;

  setUp(() {
    final source = CitizenMockDataSource();
    centers = InMemoryBloodCenterRepository(source);
    donors = InMemoryDonorRepository(source);
    useCase = GetBloodAvailabilityUseCase(centers: centers, donors: donors);
  });

  group('GetBloodAvailabilityUseCase', () {
    test(
      'retourne les centres vérifiés, triés par distance croissante',
      () async {
        final result = await useCase();

        expect(result.map((e) => e.center.name), [
          'Centre de transfusion A',
          'Centre de transfusion B',
          'Centre de transfusion C',
        ]);

        final distances = result.map((e) => e.distanceKm).toList();
        for (var index = 1; index < distances.length; index++) {
          expect(
            distances[index],
            greaterThanOrEqualTo(distances[index - 1]),
            reason:
                'les centres doivent être triés du plus proche au plus lointain',
          );
        }
      },
    );

    test('produit les distances attendues par les maquettes', () async {
      final result = await useCase();

      expect(result[0].distanceKm, closeTo(3.1, 0.2));
      expect(result[1].distanceKm, closeTo(6.4, 0.2));
      expect(result[2].distanceKm, closeTo(9.0, 0.2));
    });

    test('exclut un centre non vérifié', () async {
      final source = CitizenMockDataSource();
      source.centers.add(
        BloodCenter(
          id: 'center_pending',
          userId: 'user_pending',
          name: 'Centre en attente',
          address: 'Adresse',
          city: 'Abidjan',
          commune: 'Cocody',
          location: source.centers.first.location,
          phone: '0700000000',
          agreementNumber: 'AGR-9',
          contactFunction: 'Responsable',
          openingHoursWeekdays: '7h30 – 16h00',
          lowStockThreshold: 20,
          unavailableThreshold: 5,
          verificationStatus: VerificationStatus.pending,
          createdAt: DateTime(2026),
          updatedAt: DateTime(2026),
        ),
      );

      final result = await GetBloodAvailabilityUseCase(
        centers: InMemoryBloodCenterRepository(source),
        donors: InMemoryDonorRepository(source),
      )();

      expect(result.map((e) => e.center.id), isNot(contains('center_pending')));
    });

    test('filtre sur la ville', () async {
      final result = await useCase(
        filter: const BloodAvailabilityFilter(city: 'Abidjan'),
      );
      expect(result, isNotEmpty);

      final other = await useCase(
        filter: const BloodAvailabilityFilter(city: 'Yamoussoukro'),
      );
      expect(other, isEmpty);
    });

    test('filtre sur la commune', () async {
      final result = await useCase(
        filter: const BloodAvailabilityFilter(commune: 'Cocody'),
      );

      expect(result, hasLength(1));
      expect(result.single.center.name, 'Centre de transfusion B');
    });

    test('trie par ordre alphabétique', () async {
      final result = await useCase(sort: BloodAvailabilitySort.name);

      expect(result.map((e) => e.center.name), [
        'Centre de transfusion A',
        'Centre de transfusion B',
        'Centre de transfusion C',
      ]);
    });

    test('trie par nombre de groupes disponibles', () async {
      final result = await useCase(sort: BloodAvailabilitySort.mostAvailable);

      for (var index = 1; index < result.length; index++) {
        final previous = BloodType.values
            .where(
              (t) =>
                  result[index - 1].levelOf(t) ==
                  AvailabilityLevel.available,
            )
            .length;
        final current = BloodType.values
            .where(
              (t) =>
                  result[index].levelOf(t) ==
                  AvailabilityLevel.available,
            )
            .length;
        expect(previous, greaterThanOrEqualTo(current));
      }
    });
  });
}
