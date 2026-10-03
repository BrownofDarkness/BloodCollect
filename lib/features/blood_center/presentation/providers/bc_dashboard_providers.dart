import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_enums.dart';
import '../../../../shared/domain/entities/blood_center.dart';
import '../../../../shared/domain/entities/blood_request.dart';
import '../../../../shared/domain/entities/blood_stock_lot.dart';
import '../../../../shared/domain/entities/campaign.dart';
import '../../../../shared/domain/entities/geo_location.dart';

// Porte de simulation : retarde la première lecture pour visualiser
// les shimmers comme avec un vrai réseau. Étape 2 Firestore : supprimer
// ce provider, les streams portent leur propre AsyncValue (loading/error).
final bcMockReadyProvider = FutureProvider<bool>((ref) async {
  await Future.delayed(const Duration(seconds: 2));
  return true;
});

/// Recharge les données : ré-émet le mock (étape 1), invalidera les
/// streams Firestore à l'étape 2. Appelé par les RefreshIndicator.
Future<void> refreshBcData(WidgetRef ref) async {
  await Future.delayed(const Duration(seconds: 1));
  ref.invalidate(bcMockReadyProvider);
}

final bcCenterProvider = Provider<BloodCenter>((ref) {
  final now = DateTime.now();
  return BloodCenter(
    id: 'bc-a',
    userId: 'user-bc-a',
    name: 'Centre de transfusion A',
    address: 'Rue des Jardins, Treichville',
    city: 'Abidjan',
    commune: 'Treichville',
    location: const GeoLocation(latitude: 5.2945, longitude: -4.0257),
    phone: '+2252721000000',
    agreementNumber: 'MSHP-2024-001',
    contactFunction: 'Directeur',
    openingHoursWeekdays: '07h30 – 16h00',
    openingHoursSaturday: '08h00 – 12h00',
    lowStockThreshold: 20,
    unavailableThreshold: 5,
    verificationStatus: VerificationStatus.verified,
    createdAt: now,
    updatedAt: now,
  );
});

/// Seuils d'alerte modifiables (dialog seuils) — lus par dashboard + stocks.
/// Étape 2 : initialisés depuis le doc blood_centers, écriture via repository.
final bcLowThresholdProvider =
    NotifierProvider<ThresholdNotifier, int>(() => ThresholdNotifier(20));
final bcUnavailableThresholdProvider =
    NotifierProvider<ThresholdNotifier, int>(() => ThresholdNotifier(5));

class ThresholdNotifier extends Notifier<int> {
  ThresholdNotifier(this._initial);

  final int _initial;

  @override
  int build() => _initial;

  void set(int value) => state = value;
}

BloodStockLot _lot({
  required String id,
  required BloodType type,
  required int qty,
  required String ref,
  required DateTime collected,
  required DateTime expires,
  ProductType product = ProductType.wholeBlood,
}) {
  final now = DateTime.now();
  return BloodStockLot(
    id: id,
    bloodCenterId: 'bc-a',
    bloodType: type,
    productType: product,
    lotReference: ref,
    quantity: qty,
    expiryDate: expires,
    collectionDate: collected,
    createdAt: now,
    updatedAt: now,
    status: StockLotStatus.available,
  );
}

/// Lots mutables en mock (delete/edit UI 2-3) — même provider lu partout.
/// Étape 2 : devient le stream Firestore, les écrans ne changent pas.
final bcStockLotsProvider =
    NotifierProvider<LotsNotifier, List<BloodStockLot>>(LotsNotifier.new);

class LotsNotifier extends Notifier<List<BloodStockLot>> {
  @override
  List<BloodStockLot> build() {
    // Totaux : O+ 64 · O- 8 · A+ 41 · A- 2 · B+ 37 · B- 6 · AB+ 22 · AB- 0.
    return [
    _lot(
      id: 'lot-op-1',
      type: BloodType.oPos,
      qty: 40,
      ref: 'LOT-2026-0101',
      collected: DateTime(2026, 9, 10),
      expires: DateTime(2026, 10, 22),
    ),
    _lot(
      id: 'lot-op-2',
      type: BloodType.oPos,
      qty: 24,
      ref: 'LOT-2026-0118',
      collected: DateTime(2026, 9, 24),
      expires: DateTime(2026, 11, 5),
    ),
    _lot(
      id: 'lot-om-1',
      type: BloodType.oNeg,
      qty: 5,
      ref: 'L-2291',
      collected: DateTime(2026, 9, 20),
      expires: DateTime(2026, 10, 25),
    ),
    _lot(
      id: 'lot-om-2',
      type: BloodType.oNeg,
      qty: 3,
      ref: 'L-2304',
      collected: DateTime(2026, 9, 24),
      expires: DateTime(2026, 10, 29),
      product: ProductType.redCells,
    ),
    _lot(
      id: 'lot-ap-1',
      type: BloodType.aPos,
      qty: 25,
      ref: 'LOT-2026-0098',
      collected: DateTime(2026, 9, 8),
      expires: DateTime(2026, 10, 20),
    ),
    _lot(
      id: 'lot-ap-2',
      type: BloodType.aPos,
      qty: 16,
      ref: 'LOT-2026-0122',
      collected: DateTime(2026, 9, 26),
      expires: DateTime(2026, 11, 7),
    ),
    _lot(
      id: 'lot-am-1',
      type: BloodType.aNeg,
      qty: 2,
      ref: 'LOT-2026-0110',
      collected: DateTime(2026, 9, 18),
      expires: DateTime(2026, 10, 30),
    ),
    _lot(
      id: 'lot-bp-1',
      type: BloodType.bPos,
      qty: 20,
      ref: 'LOT-2026-0105',
      collected: DateTime(2026, 9, 12),
      expires: DateTime(2026, 10, 24),
    ),
    _lot(
      id: 'lot-bp-2',
      type: BloodType.bPos,
      qty: 17,
      ref: 'LOT-2026-0120',
      collected: DateTime(2026, 9, 25),
      expires: DateTime(2026, 11, 6),
    ),
    _lot(
      id: 'lot-bm-1',
      type: BloodType.bNeg,
      qty: 6,
      ref: 'LOT-2026-0115',
      collected: DateTime(2026, 9, 21),
      expires: DateTime(2026, 11, 2),
    ),
    _lot(
      id: 'lot-abp-1',
      type: BloodType.abPos,
      qty: 22,
      ref: 'LOT-2026-0108',
      collected: DateTime(2026, 9, 15),
      expires: DateTime(2026, 10, 27),
    ),
  ];
  }

  void remove(String id) {
    state = state.where((l) => l.id != id).toList();
  }

  void upsert(BloodStockLot lot) {
    final i = state.indexWhere((l) => l.id == lot.id);
    if (i < 0) {
      state = [...state, lot];
    } else {
      state = [...state.sublist(0, i), lot, ...state.sublist(i + 1)];
    }
  }
}

BloodRequest _request({
  required String id,
  required String hcId,
  required BloodType type,
  required int qty,
  required Priority priority,
  required Duration ago,
  required String patientRef,
  String? notes,
}) {
  final now = DateTime.now();
  return BloodRequest(
    id: id,
    healthCenterId: hcId,
    bloodType: type,
    productType: ProductType.wholeBlood,
    quantityNeeded: qty,
    patientReference: patientRef,
    priority: priority,
    status: RequestStatus.pending,
    bloodRouteStep: BloodRouteStep.waiting,
    notes: notes,
    createdAt: now.subtract(ago),
    updatedAt: now.subtract(ago),
  );
}

/// Demandes mutables en mock (décisions UI 5) — même provider lu partout.
/// Étape 2 : devient le stream Firestore, les écrans ne changent pas.
final bcBloodRequestsProvider =
    NotifierProvider<RequestsNotifier, List<BloodRequest>>(
        RequestsNotifier.new);

class RequestsNotifier extends Notifier<List<BloodRequest>> {
  @override
  List<BloodRequest> build() {
    return [
    _request(
      id: 'DEM-0147',
      hcId: 'hc-treichville',
      type: BloodType.oNeg,
      qty: 2,
      priority: Priority.vital,
      ago: const Duration(minutes: 6),
      patientRef: 'DOS-2291',
      notes: 'Transfusion à prévoir rapidement. Le centre de santé '
          'assure la prise en charge du patient.',
    ),
    _request(
      id: 'DEM-0148',
      hcId: 'hc-treichville',
      type: BloodType.oPos,
      qty: 2,
      priority: Priority.elevated,
      ago: const Duration(minutes: 22),
      patientRef: 'DOS-2285',
    ),
    _request(
      id: 'DEM-0149',
      hcId: 'hc-marcory',
      type: BloodType.bPos,
      qty: 3,
      priority: Priority.elevated,
      ago: const Duration(minutes: 41),
      patientRef: 'DOS-2280',
    ),
    _request(
      id: 'DEM-0150',
      hcId: 'hc-koumassi',
      type: BloodType.aNeg,
      qty: 1,
      priority: Priority.normal,
      ago: const Duration(hours: 1),
      patientRef: 'DOS-2274',
    ),
    ];
  }

  /// Applique une décision (UI 5) : statut + quantités + message.
  void decide({
    required String id,
    required RequestStatus status,
    int? quantityGranted,
    int? quantityFulfilled,
    String? Function()? responseMessage,
  }) {
    state = [
      for (final r in state)
        if (r.id == id)
          r.copyWith(
            status: status,
            bloodRouteStep: BloodRouteStep.completed,
            quantityGranted: () => quantityGranted,
            quantityFulfilled:
                quantityFulfilled ?? r.quantityFulfilled,
            responseMessage: responseMessage ?? () => r.responseMessage,
            processedAt: () => DateTime.now(),
            updatedAt: DateTime.now(),
          )
        else
          r,
    ];
  }
}

/// Noms d'affichage des centres demandeurs (étape 2 : jointure Firestore).
final bcHealthCenterNamesProvider = Provider<Map<String, String>>((ref) {
  return const {
    'hc-treichville': 'CSCom de Treichville',
    'hc-marcory': 'CSCom de Marcory',
    'hc-koumassi': 'Centre de santé de Koumassi',
  };
});

/// Contacts demandeurs (étape 2 : jointure Firestore).
final bcRequestContactsProvider = Provider<Map<String, String>>((ref) {
  return const {
    'DEM-0147': 'Dr Kouadio',
    'DEM-0148': 'Dr Kouadio',
    'DEM-0149': 'Dr Awa',
    'DEM-0150': 'Dr Yao',
  };
});

/// Campagnes mutables en mock (UI 7) — même provider lu partout.
/// Étape 2 : devient le stream Firestore, les écrans ne changent pas.
final bcCampaignsProvider =
    NotifierProvider<CampaignsNotifier, List<Campaign>>(
        CampaignsNotifier.new);

class CampaignsNotifier extends Notifier<List<Campaign>> {
  @override
  List<Campaign> build() {
    final now = DateTime.now();
    return [
    Campaign(
      id: 'camp-1',
      bloodCenterId: 'bc-a',
      title: 'Collecte mobile de Treichville',
      description: 'Place de la mairie, Treichville',
      location: const GeoLocation(latitude: 5.2945, longitude: -4.0257),
      locationName: 'Place de la mairie, Treichville',
      commune: 'Treichville',
      startDate: now.add(const Duration(days: 12)),
      endDate: now.add(const Duration(days: 12, hours: 6)),
      targetBloodTypes: const [BloodType.oNeg, BloodType.bNeg],
      targetCommunes: const ['Treichville', 'Marcory'],
      targetUnits: 80,
      collectedUnits: 32,
      status: CampaignStatus.published,
      createdAt: now,
      updatedAt: now,
    ),
    Campaign(
      id: 'camp-2',
      bloodCenterId: 'bc-a',
      title: 'Journée du don · Université',
      description: 'Campus de Cocody',
      location: const GeoLocation(latitude: 5.3453, longitude: -3.9824),
      locationName: 'Campus de Cocody',
      commune: 'Cocody',
      startDate: now.add(const Duration(days: 15)),
      endDate: now.add(const Duration(days: 15, hours: 6)),
      targetBloodTypes: BloodType.values,
      targetCommunes: const ['Cocody'],
      targetUnits: 150,
      collectedUnits: 12,
      status: CampaignStatus.published,
      createdAt: now,
      updatedAt: now,
    ),
    ];
  }

  void upsert(Campaign campaign) {
    final i = state.indexWhere((c) => c.id == campaign.id);
    if (i < 0) {
      state = [...state, campaign];
    } else {
      state = [...state.sublist(0, i), campaign, ...state.sublist(i + 1)];
    }
  }
}
