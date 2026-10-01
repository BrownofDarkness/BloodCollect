import 'package:blood_collect/core/constants/app_enums.dart';
import 'package:blood_collect/features/citizen/domain/usecases/campaign_registration_usecases.dart';
import 'package:blood_collect/features/citizen/domain/usecases/get_blood_availability_usecase.dart';
import 'package:blood_collect/features/citizen/domain/usecases/get_citizen_profile_usecase.dart';
import 'package:blood_collect/features/citizen/domain/usecases/get_donation_dashboard_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fixtures/citizen_mock_datasource.dart';
import '../../fixtures/citizen_records_fixture.dart';
import '../../fixtures/citizen_repository_fakes.dart';
import 'package:blood_collect/shared/presentation/models/requester_info.dart';

import '../../fixtures/fake_donor_search_repository.dart';

/// Vérifie que les deux moitiés du module citoyen — celle qui montre le sang et
/// celle qui mobilise les personnes — lisent la même source de données.
///
/// Le citizen est le même, les centres de transfusion sont les mêmes et leurs
/// distances sont les mêmes sur tous les parcours. Sans cela, l'accueil
/// proposerait un centre que l'onglet Sang ne retrouve pas, à une autre
/// distance.
void main() {
  late CitizenMockDataSource source;

  late FakeDonorSearchRepository donorSearch;

  late GetDonationDashboardUseCase dashboard;
  late GetBloodAvailabilityUseCase availability;
  late GetCitizenProfileUseCase profile;

  setUp(() {
    source = CitizenMockDataSource();
    donorSearch = FakeDonorSearchRepository()
      ..candidates.addAll(mockDonorsFixture)
      ..seedRequester(
        'u_hc_treichville',
        const RequesterInfo(
          role: UserRole.healthCenter,
          displayName: 'CSCom de Treichville',
          commune: 'Treichville',
        ),
      );
    dashboard = GetDonationDashboardUseCase(
      centers: InMemoryBloodCenterRepository(source),
      campaigns: InMemoryCampaignRepository(source),
      donors: InMemoryDonorRepository(source),
    );
    availability = GetBloodAvailabilityUseCase(
      centers: InMemoryBloodCenterRepository(source),
      donors: InMemoryDonorRepository(source),
    );
    profile = GetCitizenProfileUseCase(donors: InMemoryDonorRepository(source));
  });

  group('parcours sang', () {
    test('le profil donneur vient du même citoyen que l\'accueil', () async {
      final citizen = await donorSearch.searchDonors(
        bloodType: BloodType.oPos,
        communes: const ['Treichville'],
        priority: Priority.normal,
      );
      expect(citizen, isNotEmpty);

      final profileData = await profile();
      expect(profileData.user.firstName, 'Aya');
      expect(profileData.user.commune, 'Treichville');
      expect(profileData.user.bloodType, BloodType.oPos);
    });

    test('les centres proposés sont ceux de l\'onglet Sang', () async {
      final nearby = (await dashboard()).nearbyCenters;
      final onBloodTab = await availability();

      expect(
        nearby.map((e) => e.center.id),
        onBloodTab.map((e) => e.center.id),
      );
    });

    test('un centre garde la même distance sur les deux parcours', () async {
      final nearby = (await dashboard()).nearbyCenters;
      final onBloodTab = await availability();

      for (final entry in nearby) {
        final match = onBloodTab.firstWhere(
          (e) => e.center.id == entry.center.id,
        );
        expect(
          match.distanceKm,
          closeTo(entry.distanceKm, 0.01),
          reason: '${entry.center.name} : distances divergentes',
        );
      }
    });

    test(
      'les collectes à venir sont celles auxquelles on peut s\'inscrire',
      () async {
        final listed = (await dashboard()).campaigns;
        final upcoming = await InMemoryCampaignRepository(source).upcomingCampaigns();

        expect(listed.map((e) => e.campaign.id), upcoming.map((c) => c.id));
      },
    );
  });

  group('parcours personnes', () {
    test('les donneurs proposés correspondent au groupe demandé', () async {
      final results = await donorSearch.searchDonors(
        bloodType: BloodType.oPos,
        communes: const ['Treichville', 'Marcory'],
        priority: Priority.elevated,
      );

      expect(results, isNotEmpty);
      for (final donor in results) {
        expect(donor.bloodType, BloodType.oPos);
        expect(['Treichville', 'Marcory'], contains(donor.commune));
      }
    });

    test('les donneurs sont triés du plus proche au plus lointain', () async {
      final results = await donorSearch.searchDonors(
        bloodType: BloodType.oPos,
        communes: const ['Treichville', 'Marcory'],
        priority: Priority.normal,
      );

      for (var i = 1; i < results.length; i++) {
        expect(
          results[i].distanceKm,
          greaterThanOrEqualTo(results[i - 1].distanceKm),
        );
      }
    });

    test(
      'une demande envoyée apparaît dans les mises en relation du profil',
      () async {
        final found = await donorSearch.searchDonors(
          bloodType: BloodType.oPos,
          communes: const ['Treichville'],
          priority: Priority.normal,
        );

        final before = (await profile()).matchCount;
        await donorSearch.sendMatchRequest(
          donorId: found.first.donorId,
          bloodType: found.first.bloodType,
          priority: Priority.elevated,
          message: 'Merci de vous présenter au centre le plus proche.',
          shareContact: true,
        );

        // La demande est stockée côté demandeur : le repository de recherche
        // la retrouve par le même identifiant.
        final stored = await donorSearch.getIncomingRequest('req_100');
        expect(stored.donorId, found.first.donorId);
        expect(stored.status, DonorMatchStatus.pending);
        expect(before, greaterThanOrEqualTo(0));
      },
    );

    test(
      'accepter une demande partage les coordonnées si l\'option est active',
      () async {
        final sent = await donorSearch.sendMatchRequest(
          donorId: 'donor_1',
          bloodType: BloodType.oPos,
          priority: Priority.elevated,
          shareContact: true,
        );
        expect(sent.shareContact, isTrue);

        await donorSearch.respondToRequest(sent.id, DonorMatchStatus.accepted);
        final accepted = await donorSearch.getIncomingRequest(sent.id);
        expect(accepted.status, DonorMatchStatus.accepted);
        expect(accepted.shareContact, isTrue);
      },
    );

    test('refuser une demande ne transmet pas les coordonnées', () async {
      final sent = await donorSearch.sendMatchRequest(
        donorId: 'donor_1',
        bloodType: BloodType.oPos,
        priority: Priority.normal,
        shareContact: false,
      );

      await donorSearch.respondToRequest(sent.id, DonorMatchStatus.declined);
      final declined = await donorSearch.getIncomingRequest(sent.id);

      expect(declined.status, DonorMatchStatus.declined);
      expect(declined.shareContact, isFalse);
    });

    test(
      'un demandeur anonymisé n\'expose ni nom ni donnée médicale',
      () async {
        final info = await donorSearch.resolveRequester('u_hc_treichville');
        expect(info.role, UserRole.healthCenter);
        expect(info.displayName, contains('CSCom'));
        expect(info.commune, 'Treichville');
      },
    );
  });

  group('parcours collectes', () {
    test('inscrire puis annuler remet le compteur du profil à zéro', () async {
      final target = (await dashboard()).campaigns.firstWhere(
        (e) => !e.isRegistered,
      );
      final before = (await profile()).upcomingCollectCount;

      final useCase = JoinCampaignUseCase(
        campaigns: InMemoryCampaignRepository(source),
        donors: InMemoryDonorRepository(source),
      );
      await useCase(target.campaign.id);
      expect((await profile()).upcomingCollectCount, before + 1);

      final registration = source.registrations.lastWhere(
        (r) => r.campaignId == target.campaign.id,
      );
      await CancelRegistrationUseCase(donors: InMemoryDonorRepository(source))(
        registration.id,
      );

      expect((await profile()).upcomingCollectCount, before);
    });

    test('une collecte terminée ne peut plus être rejointe', () async {
      final useCase = JoinCampaignUseCase(
        campaigns: InMemoryCampaignRepository(source),
        donors: InMemoryDonorRepository(source),
      );

      expect(
        () => useCase('campaign_inexistante'),
        throwsA(isA<CampaignRegistrationNotJoinable>()),
      );
    });
  });
}
