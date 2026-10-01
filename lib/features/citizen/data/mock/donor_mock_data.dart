import 'dart:math';

import '../../../../core/constants/app_enums.dart';
import '../../../../shared/domain/entities/entities.dart';
import '../../../../shared/presentation/models/donor_search_candidate.dart';
import 'commune_distances.dart';
import 'mock_records.dart';

final _now = DateTime.now();

/// --- Fixtures fidèles aux maquettes ---

/// --- DonorMatchRequest reçues par le citoyen connecté (écran "Demande reçue") ---

final mockIncomingRequestFromHealthCenter = DonorMatchRequest(
  id: 'req_hc_1',
  requesterId: 'u_hc_treichville', // AppUser.role == healthCenter
  donorId: mockCitizen.id,
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
  donorId: mockCitizen.id,
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
