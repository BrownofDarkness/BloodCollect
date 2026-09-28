import '../../../../core/constants/app_enums.dart';
import '../../../../shared/domain/entities/entities.dart';

// Enregistrements de test alignés sur les maquettes du PDF Citoyen (p. 6 à 9).
//
// Toutes les dates sont relatives à l'instant courant : la démo reste cohérente
// quelle que soit la date de lancement (« Collectes à venir », « Mis à jour
// hier », distances inchangées).

/// Instant de référence des données de test.
final DateTime mockNow = DateTime.now();

/// Le citoyen de la maquette : Aya Koné, O+, Treichville (Abidjan).
final AppUser mockCitizen = AppUser(
  id: 'user_citizen_aya',
  email: 'aya.kone@exemple.ci',
  firstName: 'Aya',
  lastName: 'Koné',
  phone: '+225 07 00 00 00 00',
  role: UserRole.citizen,
  bloodType: BloodType.oPos,
  city: 'Abidjan',
  commune: 'Treichville',
  isAvailableToDonate: true,
  lastDonationDate: mockNow.subtract(const Duration(days: 97)),
  createdAt: mockNow.subtract(const Duration(days: 210)),
  updatedAt: mockNow,
);

/// 3 centres agréés d'Abidjan, aux distances 3,1 / 6,4 / 9,0 km de Treichville.
final List<BloodCenter> mockBloodCenters = [
  BloodCenter(
    id: 'center_a',
    userId: 'user_center_a',
    name: 'Centre de transfusion A',
    address: '[Adresse du centre]',
    city: 'Abidjan',
    commune: 'Treichville',
    location: const GeoLocation(latitude: 5.3760, longitude: -3.7671),
    phone: '[Numéro du centre]',
    agreementNumber: 'AGR-ABJ-001',
    contactFunction: 'Responsable',
    openingHoursWeekdays: '7h30 – 16h00',
    openingHoursSaturday: '8h00 – 12h00',
    lowStockThreshold: 20,
    unavailableThreshold: 5,
    verificationStatus: VerificationStatus.verified,
    createdAt: mockNow.subtract(const Duration(days: 400)),
    updatedAt: _todayAt(9, 15),
  ),
  BloodCenter(
    id: 'center_b',
    userId: 'user_center_b',
    name: 'Centre de transfusion B',
    address: '[Adresse du centre]',
    city: 'Abidjan',
    commune: 'Cocody',
    location: const GeoLocation(latitude: 5.3720, longitude: -3.8465),
    phone: '[Numéro du centre]',
    agreementNumber: 'AGR-ABJ-002',
    contactFunction: 'Responsable',
    openingHoursWeekdays: '7h30 – 15h30',
    openingHoursSaturday: '8h00 – 12h00',
    lowStockThreshold: 20,
    unavailableThreshold: 5,
    verificationStatus: VerificationStatus.verified,
    createdAt: mockNow.subtract(const Duration(days: 380)),
    updatedAt: _todayAt(8, 40),
  ),
  BloodCenter(
    id: 'center_c',
    userId: 'user_center_c',
    name: 'Centre de transfusion C',
    address: '[Adresse du centre]',
    city: 'Abidjan',
    commune: 'Yopougon',
    location: const GeoLocation(latitude: 5.3942, longitude: -3.8637),
    phone: '[Numéro du centre]',
    agreementNumber: 'AGR-ABJ-003',
    contactFunction: 'Responsable',
    openingHoursWeekdays: '7h30 – 16h00',
    lowStockThreshold: 20,
    unavailableThreshold: 5,
    verificationStatus: VerificationStatus.verified,
    createdAt: mockNow.subtract(const Duration(days: 350)),
    updatedAt: _yesterdayAt(16, 0),
  ),
];

/// Unités déclarées par centre et par groupe. L'abondance est calibrée sur les
/// seuils des centres (bas 20, indisponible 5) pour retrouver exactement les
/// statuts des maquettes : A disponible, B limitée, C indisponible sur O+.
final Map<String, Map<BloodType, int>> _unitsByCenter = {
  'center_a': {
    BloodType.oPos: 64,
    BloodType.oNeg: 12,
    BloodType.aPos: 41,
    BloodType.aNeg: 0,
    BloodType.bPos: 37,
    BloodType.bNeg: 6,
    BloodType.abPos: 22,
    BloodType.abNeg: 0,
  },
  'center_b': {BloodType.oPos: 12, BloodType.aPos: 26, BloodType.bPos: 9},
  'center_c': {BloodType.abPos: 3},
};

final List<BloodStockLot> mockStockLots = [
  for (final entry in _unitsByCenter.entries)
    ..._lotsFor(
      centerId: entry.key,
      quantities: entry.value,
      collectedAt: _todayAt(8, 0),
    ),
  // Lot périmé volontairement présent : BloodAvailability doit l'ignorer.
  BloodStockLot(
    id: 'lot_center_a_expired',
    bloodCenterId: 'center_a',
    bloodType: BloodType.oPos,
    productType: ProductType.wholeBlood,
    lotReference: 'LOT-2025-0007',
    quantity: 40,
    expiryDate: mockNow.subtract(const Duration(days: 2)),
    collectionDate: mockNow.subtract(const Duration(days: 37)),
    provenance: 'Campagne',
    status: StockLotStatus.available,
    createdAt: mockNow.subtract(const Duration(days: 37)),
    updatedAt: mockNow.subtract(const Duration(days: 37)),
  ),
];

final List<Campaign> mockCampaigns = [
  Campaign(
    id: 'campaign_treichville',
    bloodCenterId: 'center_a',
    title: 'Collecte mobile de Treichville',
    description:
        "Collecte de sang organisée par le centre de transfusion A, place de la mairie.",
    location: const GeoLocation(latitude: 5.3760, longitude: -3.7671),
    locationName: 'Place de la mairie, Treichville',
    commune: 'Treichville',
    startDate: _nextWeekday(DateTime.saturday, hour: 8, minute: 0),
    endDate: _nextWeekday(DateTime.saturday, hour: 14, minute: 0),
    targetBloodTypes: const [BloodType.oNeg, BloodType.bNeg],
    targetCommunes: const ['Treichville', 'Marcory'],
    targetUnits: 60,
    collectedUnits: 24,
    notifyDonors: true,
    status: CampaignStatus.published,
    createdAt: mockNow.subtract(const Duration(days: 12)),
    updatedAt: mockNow,
  ),
  Campaign(
    id: 'campaign_universite',
    bloodCenterId: 'center_b',
    title: 'Journée du don · Université',
    description:
        "Journée du don ouverte à tous les groupes sanguins, campus de Cocody.",
    location: const GeoLocation(latitude: 5.3720, longitude: -3.8465),
    locationName: 'Campus de Cocody',
    commune: 'Cocody',
    startDate: _nextWeekday(DateTime.tuesday, hour: 9, minute: 0),
    endDate: _nextWeekday(DateTime.tuesday, hour: 15, minute: 0),
    targetBloodTypes: BloodType.values,
    targetCommunes: const ['Cocody', 'Treichville'],
    targetUnits: 100,
    collectedUnits: 51,
    notifyDonors: true,
    status: CampaignStatus.published,
    createdAt: mockNow.subtract(const Duration(days: 5)),
    updatedAt: mockNow,
  ),
];

/// Aya est inscrite à la journée du don de Cocody (participation confirmée).
final List<CampaignRegistration> mockCampaignRegistrations = [
  CampaignRegistration(
    id: 'reg_aya_universite',
    campaignId: 'campaign_universite',
    donorId: mockCitizen.id,
    status: RegistrationStatus.confirmed,
    createdAt: mockNow.subtract(const Duration(days: 3)),
    updatedAt: mockNow.subtract(const Duration(days: 3)),
  ),
];

/// 2 mises en relation : une reçue (CSCom de Treichville), une envoyée.
final List<DonorMatchRequest> mockDonorMatchRequests = [
  DonorMatchRequest(
    id: 'match_received',
    requesterId: 'user_center_health_treichville',
    donorId: mockCitizen.id,
    bloodType: BloodType.oPos,
    priority: Priority.elevated,
    status: DonorMatchStatus.accepted,
    shareContact: true,
    message: 'Merci de vous présenter au centre de transfusion le plus proche.',
    notifiedAt: mockNow.subtract(const Duration(minutes: 5)),
    respondedAt: mockNow.subtract(const Duration(minutes: 3)),
    expiresAt: mockNow.add(const Duration(hours: 2)),
    createdAt: mockNow.subtract(const Duration(minutes: 5)),
  ),
  DonorMatchRequest(
    id: 'match_sent',
    requesterId: mockCitizen.id,
    donorId: 'user_citizen_donated',
    bloodType: BloodType.oPos,
    priority: Priority.normal,
    status: DonorMatchStatus.pending,
    shareContact: false,
    createdAt: mockNow.subtract(const Duration(days: 2)),
    notifiedAt: mockNow.subtract(const Duration(days: 2)),
    expiresAt: mockNow.add(const Duration(hours: 1, minutes: 58)),
  ),
];

// ── Constructeurs internes ───────────────────────────────────────────────

DateTime _todayAt(int hour, int minute) =>
    DateTime(mockNow.year, mockNow.month, mockNow.day, hour, minute);

DateTime _yesterdayAt(int hour, int minute) =>
    _todayAt(hour, minute).subtract(const Duration(days: 1));

DateTime _nextWeekday(int weekday, {required int hour, required int minute}) {
  var daysAhead = (weekday - mockNow.weekday) % 7;
  if (daysAhead == 0) daysAhead = 7;
  final day = DateTime(mockNow.year, mockNow.month, mockNow.day + daysAhead);
  return DateTime(day.year, day.month, day.day, hour, minute);
}

List<BloodStockLot> _lotsFor({
  required String centerId,
  required Map<BloodType, int> quantities,
  required DateTime collectedAt,
}) {
  var sequence = 0;
  return [
    for (final entry in quantities.entries)
      if (entry.value > 0)
        BloodStockLot(
          id: 'lot_${centerId}_${entry.key.name}',
          bloodCenterId: centerId,
          bloodType: entry.key,
          productType: ProductType.wholeBlood,
          lotReference: 'LOT-2026-${(++sequence).toString().padLeft(4, '0')}',
          quantity: entry.value,
          expiryDate: collectedAt.add(const Duration(days: 35)),
          collectionDate: collectedAt,
          provenance: 'Don spontané',
          status: StockLotStatus.available,
          createdAt: collectedAt,
          updatedAt: collectedAt,
        ),
  ];
}
