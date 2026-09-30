import 'dart:math';

import '../../../../core/constants/app_enums.dart';
import '../../../../shared/domain/entities/entities.dart';
import '../../../../shared/presentation/models/donor_search_candidate.dart';
import 'commune_distances.dart';

final _now = DateTime.now();

/// --- Fixtures fidèles aux maquettes ---

final mockCitizenProfile = AppUser(
  id: 'u_aya',
  email: 'aya.kone@example.com',
  firstName: 'Aya',
  lastName: 'Koné',
  phone: '+225 07 00 00 00 00',
  role: UserRole.citizen,
  bloodType: BloodType.oPos,
  city: 'Abidjan',
  commune: 'Treichville',
  createdAt: _now.subtract(const Duration(days: 40)),
  updatedAt: _now,
);

/// GeoLocation factices (non utilisées pour le calcul, juste pour remplir
/// le champ requis par BloodCenter — cf. note Option A).
const _dummyLocation = GeoLocation(latitude: 5.301, longitude: -4.012);

final mockCenters = <BloodCenter>[
  BloodCenter(
    id: 'bc_a',
    userId: 'u_bc_a',
    name: 'Centre de transfusion A',
    address: '[Adresse du centre]',
    city: 'Abidjan',
    commune: 'Treichville',
    location: _dummyLocation,
    phone: '[Numéro du centre]',
    agreementNumber: 'MSHP-0001',
    contactFunction: 'Directeur',
    openingHoursWeekdays: 'Lun – Ven · 7h30 – 16h00',
    openingHoursSaturday: 'Sam · 8h00 – 12h00',
    lowStockThreshold: 10,
    unavailableThreshold: 2,
    verificationStatus: VerificationStatus.verified,
    createdAt: _now.subtract(const Duration(days: 200)),
    updatedAt: _now.subtract(const Duration(hours: 1, minutes: 45)),
  ),
  BloodCenter(
    id: 'bc_b',
    userId: 'u_bc_b',
    name: 'Centre de transfusion B',
    address: '[Adresse du centre]',
    city: 'Abidjan',
    commune: 'Cocody',
    location: _dummyLocation,
    phone: '[Numéro du centre]',
    agreementNumber: 'MSHP-0002',
    contactFunction: 'Directeur',
    openingHoursWeekdays: 'Lun – Ven · 8h00 – 15h30',
    lowStockThreshold: 10,
    unavailableThreshold: 2,
    verificationStatus: VerificationStatus.verified,
    createdAt: _now.subtract(const Duration(days: 180)),
    updatedAt: _now.subtract(const Duration(hours: 2, minutes: 20)),
  ),
  BloodCenter(
    id: 'bc_c',
    userId: 'u_bc_c',
    name: 'Centre de transfusion C',
    address: '[Adresse du centre]',
    city: 'Abidjan',
    commune: 'Yopougon',
    location: _dummyLocation,
    phone: '[Numéro du centre]',
    agreementNumber: 'MSHP-0003',
    contactFunction: 'Directeur',
    openingHoursWeekdays: 'Lun – Ven · 7h30 – 16h00',
    lowStockThreshold: 10,
    unavailableThreshold: 2,
    verificationStatus: VerificationStatus.verified,
    createdAt: _now.subtract(const Duration(days: 220)),
    updatedAt: _now.subtract(const Duration(days: 1)),
  ),
];

final mockCampaigns = <Campaign>[
  Campaign(
    id: 'camp_1',
    bloodCenterId: 'bc_a',
    title: 'Collecte mobile de Treichville',
    description: 'Collecte organisée place de la mairie.',
    location: _dummyLocation,
    locationName: 'Place de la mairie, Treichville',
    commune: 'Treichville',
    startDate: DateTime(_now.year, _now.month, _now.day + 3, 8),
    endDate: DateTime(_now.year, _now.month, _now.day + 3, 14),
    targetBloodTypes: const [BloodType.oNeg, BloodType.bNeg],
    targetCommunes: const ['Treichville', 'Marcory'],
    targetUnits: 40,
    status: CampaignStatus.published,
    createdAt: _now.subtract(const Duration(days: 5)),
    updatedAt: _now.subtract(const Duration(days: 1)),
  ),
  Campaign(
    id: 'camp_2',
    bloodCenterId: 'bc_b',
    title: 'Journée du don · Université',
    description: 'Collecte sur le campus de Cocody.',
    location: _dummyLocation,
    locationName: 'Campus de Cocody',
    commune: 'Cocody',
    startDate: DateTime(_now.year, _now.month, _now.day + 6, 9),
    endDate: DateTime(_now.year, _now.month, _now.day + 6, 15),
    targetBloodTypes: const [], // "Tous groupes"
    targetCommunes: const ['Cocody', 'Plateau'],
    targetUnits: 60,
    status: CampaignStatus.published,
    createdAt: _now.subtract(const Duration(days: 8)),
    updatedAt: _now.subtract(const Duration(days: 2)),
  ),
];

/// --- DonorMatchRequest reçues par le citoyen connecté (écran "Demande reçue") ---

final mockIncomingRequestFromHealthCenter = DonorMatchRequest(
  id: 'req_hc_1',
  requesterId: 'u_hc_treichville', // AppUser.role == healthCenter
  donorId: mockCitizenProfile.id,
  bloodType: BloodType.oPos,
  priority: Priority.elevated,
  status: DonorMatchStatus.pending,
  shareContact: true,
  message: 'Merci de vous présenter au centre de transfusion le plus proche.',
  notifiedAt: _now.subtract(const Duration(minutes: 5)),
  expiresAt: _now.add(const Duration(hours: 2)),
  createdAt: _now.subtract(const Duration(minutes: 5)),
);

final mockIncomingRequestFromCitizen = DonorMatchRequest(
  id: 'req_cz_1',
  requesterId: 'u_citizen_other', // AppUser.role == citizen
  donorId: mockCitizenProfile.id,
  bloodType: BloodType.oPos,
  priority: Priority.normal,
  status: DonorMatchStatus.pending,
  shareContact: false,
  notifiedAt: _now.subtract(const Duration(minutes: 20)),
  expiresAt: _now.add(const Duration(hours: 2)),
  createdAt: _now.subtract(const Duration(minutes: 20)),
);

/// Résolution mock requesterId -> (rôle, nom affiché, commune).
/// En Partie 2 : lookup Firestore sur `users` (+ `health_centers` si role
/// == healthCenter pour le nom officiel de la structure).
final Map<String, ({UserRole role, String name, String commune})>
mockRequesters = {
  'u_hc_treichville': (
    role: UserRole.healthCenter,
    name: 'CSCom de Treichville',
    commune: 'Treichville',
  ),
  'u_citizen_other': (
    role: UserRole.citizen,
    name: 'Un particulier',
    commune: 'Marcory',
  ),
};

/// --- Générateur seedé pour le volume de donneurs ---

const _communes = [
  'Treichville',
  'Marcory',
  'Cocody',
  'Plateau',
  'Yopougon',
  'Abobo',
  'Adjamé',
  'Koumassi',
  'Port-Bouët',
  'Attécoubé',
];

List<DonorSearchCandidate> generateDonorCandidates(int count, {int seed = 42}) {
  final random = Random(seed);
  final list = List.generate(count, (i) {
    final id = 'gen_$i';
    final commune = _communes[random.nextInt(_communes.length)];
    return DonorSearchCandidate(
      donorId: id,
      bloodType: BloodType.values[random.nextInt(BloodType.values.length)],
      commune: commune,
      distanceKm: CommuneDistances.forCommune(commune, seedKey: id),
      matchStatus: random.nextInt(6) == 0 ? DonorMatchStatus.pending : null,
    );
  });
  list.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
  return list;
}

/// Trois donneurs fixes correspondant exactement à la maquette
/// "Donneurs potentiels" (O+, Treichville 2,5km / Marcory 4,2km / 5,1km).
final mockDonorsFixture = <DonorSearchCandidate>[
  const DonorSearchCandidate(
    donorId: 'd1',
    bloodType: BloodType.oPos,
    commune: 'Treichville',
    distanceKm: 2.5,
    matchStatus: DonorMatchStatus.pending,
  ),
  const DonorSearchCandidate(
    donorId: 'd2',
    bloodType: BloodType.oPos,
    commune: 'Marcory',
    distanceKm: 4.2,
  ),
  const DonorSearchCandidate(
    donorId: 'd3',
    bloodType: BloodType.oPos,
    commune: 'Marcory',
    distanceKm: 5.1,
  ),
];
