import 'package:blood_collect/core/constants/app_enums.dart';
import 'package:blood_collect/features/blood_center/presentation/providers/bc_dashboard_providers.dart';
import 'package:blood_collect/shared/domain/entities/entities.dart';
import 'package:blood_collect/shared/domain/repositories/campaign_registration_repository.dart';
import 'package:blood_collect/shared/presentation/providers/repository_providers.dart';
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

CampaignRegistration _registration(
  String campaignId,
  String donorId,
  RegistrationStatus status, {
  String bloodCenterId = 'A',
}) =>
    CampaignRegistration(
      id: CampaignRegistration.idFor(campaignId: campaignId, donorId: donorId),
      campaignId: campaignId,
      donorId: donorId,
      bloodCenterId: bloodCenterId,
      status: status,
      createdAt: _now,
      updatedAt: _now,
    );

class _FakeRegistrationRepository implements CampaignRegistrationRepository {
  _FakeRegistrationRepository(this.items);

  final List<CampaignRegistration> items;

  @override
  Stream<List<CampaignRegistration>> watchByBloodCenter(
    String bloodCenterId,
  ) =>
      Stream.value(
        items.where((r) => r.bloodCenterId == bloodCenterId).toList(),
      );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  Future<Map<String, int>> counts(
    List<CampaignRegistration> items, {
    BloodCenter? center,
  }) {
    final container = ProviderContainer(
      overrides: [
        myBloodCenterProvider.overrideWith((ref) => Stream.value(center)),
        campaignRegistrationRepositoryProvider
            .overrideWithValue(_FakeRegistrationRepository(items)),
      ],
    );
    addTearDown(container.dispose);
    // Écoute maintenue : le provider n'est pas détruit pendant la lecture.
    container.listen(bcCampaignRegisteredCountsProvider, (_, _) {});
    return container.read(bcCampaignRegisteredCountsProvider.future);
  }

  test('compte les inscriptions actives de chaque collecte du centre',
      () async {
    final result = await counts(
      center: _center,
      [
        _registration('c1', 'd1', RegistrationStatus.registered),
        _registration('c1', 'd2', RegistrationStatus.confirmed),
        // Une participation annulée n'est plus un inscrit.
        _registration('c1', 'd3', RegistrationStatus.cancelled),
        _registration('c2', 'd1', RegistrationStatus.registered),
        // Collecte d'un autre centre.
        _registration('c9', 'd1', RegistrationStatus.registered,
            bloodCenterId: 'B'),
      ],
    );

    expect(result, {'c1': 2, 'c2': 1});
  });

  test('reste vide sans centre rattaché au compte', () async {
    final result = await counts(
      [_registration('c1', 'd1', RegistrationStatus.registered)],
    );

    expect(result, isEmpty);
  });
}
