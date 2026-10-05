import '../../../core/constants/app_enums.dart';
import '../../../shared/domain/entities/blood_request.dart';
import '../../../shared/domain/entities/blood_stock_lot.dart';
import '../../../shared/domain/entities/campaign.dart';

// Logique pure du cockpit transfusion — fonctionne à l'identique
// sur les mocks (étape 1) et sur les streams Firestore (étape 2).
enum StockAvailability { available, limited, unavailable }

/// Disponible si total >= seuil bas, limitée si >= seuil critique,
/// sinon indisponible. Ex. : limitée sous 20, indisponible sous 5.
StockAvailability availabilityFor({
  required int units,
  required int low,
  required int unavailable,
}) {
  if (units < unavailable) return StockAvailability.unavailable;
  if (units < low) return StockAvailability.limited;
  return StockAvailability.available;
}

/// Unités disponibles par groupe (lots périmés/réservés exclus).
Map<BloodType, int> unitsByBloodType(List<BloodStockLot> lots) {
  final map = {for (final t in BloodType.values) t: 0};
  for (final lot in lots) {
    if (lot.status != StockLotStatus.available) continue;
    if (lot.isExpiredAt(DateTime.now())) continue;
    map[lot.bloodType] = (map[lot.bloodType] ?? 0) + lot.quantity;
  }
  return map;
}

int totalUnits(Map<BloodType, int> byType) =>
    byType.values.fold(0, (a, b) => a + b);

/// Demandes à traiter : pending/routing, vitales d'abord puis récentes.
List<BloodRequest> pendingSorted(List<BloodRequest> all) {
  final pending = all
      .where(
        (r) =>
            r.status == RequestStatus.pending ||
            r.status == RequestStatus.routing,
      )
      .toList();
  const rank = {
    Priority.vital: 0,
    Priority.elevated: 1,
    Priority.normal: 2,
  };
  pending.sort((a, b) {
    final c = rank[a.priority]!.compareTo(rank[b.priority]!);
    if (c != 0) return c;
    return b.createdAt.compareTo(a.createdAt);
  });
  return pending;
}

int vitalCount(List<BloodRequest> pending) =>
    pending.where((r) => r.priority == Priority.vital).length;

/// Collectes publiées/actives à venir, triées par date.
List<Campaign> upcomingCampaigns(List<Campaign> all, DateTime now) {
  final list = all
      .where(
        (c) =>
            (c.status == CampaignStatus.published ||
                c.status == CampaignStatus.active) &&
            c.startDate.isAfter(now),
      )
      .toList();
  list.sort((a, b) => a.startDate.compareTo(b.startDate));
  return list;
}

/// Collectes en cours (statut actif), triées par date.
List<Campaign> activeCampaigns(List<Campaign> all) {
  final list = all
      .where((c) => c.status == CampaignStatus.active)
      .toList();
  list.sort((a, b) => a.startDate.compareTo(b.startDate));
  return list;
}

/// Collectes terminées (completed/cancelled), récentes d'abord.
List<Campaign> terminatedCampaigns(List<Campaign> all) {
  final list = all
      .where(
        (c) =>
            c.status == CampaignStatus.completed ||
            c.status == CampaignStatus.cancelled,
      )
      .toList();
  list.sort((a, b) => b.startDate.compareTo(a.startDate));
  return list;
}
