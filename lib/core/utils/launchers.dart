import 'package:url_launcher/url_launcher.dart';

// Ouverture des apps externes (téléphone, cartes).
// Renvoie false si aucune app ne peut traiter la demande.
abstract final class Launchers {
  static Future<bool> call(String phone) =>
      _launch(Uri(scheme: 'tel', path: phone.replaceAll(' ', '')));

  /// Itinéraire vers [destination] : « lat,lng » ou adresse en clair.
  static Future<bool> directions(String destination) => _launch(
        Uri.https('www.google.com', '/maps/dir/', {
          'api': '1',
          'destination': destination,
        }),
      );

  static Future<bool> _launch(Uri uri) async {
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }
}
