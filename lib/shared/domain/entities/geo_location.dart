import 'dart:math' as math;

// Value object GPS pur (domaine) — converti en GeoPoint dans le data layer.
class GeoLocation {
  const GeoLocation({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;

  // (0, 0) = position non renseignée (valeur par défaut à l'inscription).
  bool get isSet => latitude != 0 || longitude != 0;

  /// Distance à vol d'oiseau en km (formule de Haversine).
  double distanceKmTo(GeoLocation other) {
    const earthRadiusKm = 6371.0;
    final dLat = _toRadians(other.latitude - latitude);
    final dLng = _toRadians(other.longitude - longitude);
    final a = math.pow(math.sin(dLat / 2), 2) +
        math.cos(_toRadians(latitude)) *
            math.cos(_toRadians(other.latitude)) *
            math.pow(math.sin(dLng / 2), 2);
    return earthRadiusKm * 2 * math.asin(math.min(1, math.sqrt(a)));
  }

  /// Distance en km, ou null si l'une des deux positions est inconnue.
  double? knownDistanceKmTo(GeoLocation? other) {
    if (other == null || !isSet || !other.isSet) return null;
    return distanceKmTo(other);
  }

  static double _toRadians(double degrees) => degrees * math.pi / 180;

  GeoLocation copyWith({double? latitude, double? longitude}) {
    return GeoLocation(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}
