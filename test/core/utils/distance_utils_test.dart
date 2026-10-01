import 'package:blood_collect/core/utils/distance_utils.dart';
import 'package:blood_collect/shared/domain/entities/geo_location.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('distanceInKm', () {
    test('vaut zéro au même point', () {
      const point = GeoLocation(latitude: 5.36, longitude: -3.79);
      expect(distanceInKm(point, point), 0);
    });

    test('mesure la distance orthodromique réelle', () {
      // Abidjan -> Yamoussoukro, environ 235 km à vol d'oiseau.
      const abidjan = GeoLocation(latitude: 5.36, longitude: -3.79);
      const yamoussoukro = GeoLocation(latitude: 6.8276, longitude: -5.2893);
      expect(distanceInKm(abidjan, yamoussoukro), closeTo(236, 6));
    });

    test('est symétrique', () {
      const a = GeoLocation(latitude: 5.36, longitude: -3.79);
      const b = GeoLocation(latitude: 5.37, longitude: -3.84);
      expect(distanceInKm(a, b), distanceInKm(b, a));
    });
  });

  group('formatDistanceKm', () {
    test('utilise la virgule décimale française', () {
      expect(formatDistanceKm(3.1), '3,1 km');
      expect(formatDistanceKm(6.44), '6,4 km');
      expect(formatDistanceKm(9), '9,0 km');
    });
  });
}
