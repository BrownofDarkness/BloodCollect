import 'dart:math' as math;

import '../../shared/domain/entities/geo_location.dart';

/// Distance orthodromique (formule de haversine) en kilomètres.
const double _earthRadiusKm = 6371.0088;

double distanceInKm(GeoLocation from, GeoLocation to) {
  final dLat = _toRadians(to.latitude - from.latitude);
  final dLon = _toRadians(to.longitude - from.longitude);

  final a =
      math.pow(math.sin(dLat / 2), 2) +
      math.cos(_toRadians(from.latitude)) *
          math.cos(_toRadians(to.latitude)) *
          math.pow(math.sin(dLon / 2), 2);

  return 2 * _earthRadiusKm * math.asin(math.min(1, math.sqrt(a)));
}

/// Décimale française : 3.1 km -> « 3,1 km ».
String formatDistanceKm(double km) =>
    '${km.toStringAsFixed(1).replaceAll('.', ',')} km';

/// Variante approximative utilisée quand la distance reste approximative :
/// 1.2 km -> « à environ 1,2 km ».
String formatApproximateDistanceKm(double km) =>
    'à environ ${km.toStringAsFixed(1).replaceAll('.', ',')} km';

double _toRadians(double degrees) => degrees * math.pi / 180;
