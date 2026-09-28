// Helpers Firestore <-> domaine (Timestamp, GeoPoint, enums).
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/geo_location.dart';

DateTime tsToDate(dynamic v, {required DateTime fallback}) {
  if (v is Timestamp) return v.toDate();
  if (v is DateTime) return v;
  return fallback;
}

DateTime? tsToDateOrNull(dynamic v) {
  if (v == null) return null;
  if (v is Timestamp) return v.toDate();
  if (v is DateTime) return v;
  return null;
}

Timestamp dateToTs(DateTime d) => Timestamp.fromDate(d);

GeoLocation geoToDomain(dynamic v) {
  if (v is GeoPoint) {
    return GeoLocation(latitude: v.latitude, longitude: v.longitude);
  }
  return const GeoLocation(latitude: 0, longitude: 0);
}

GeoPoint geoToFirestore(GeoLocation g) => GeoPoint(g.latitude, g.longitude);
