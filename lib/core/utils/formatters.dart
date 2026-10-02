// Formatages d'affichage partagés (français).
abstract final class Formatters {
  /// « 3,1 km » — une décimale, virgule française.
  static String distanceKm(double km) =>
      '${km.toStringAsFixed(1).replaceAll('.', ',')} km';

  /// « Mis à jour 09:15 » le jour même, « hier » la veille, sinon la date.
  static String updatedAt(DateTime date, {DateTime? now}) {
    final today = _dayOf(now ?? DateTime.now());
    final days = today.difference(_dayOf(date)).inDays;
    if (days <= 0) {
      return 'Mis à jour ${_two(date.hour)}:${_two(date.minute)}';
    }
    if (days == 1) return 'Mis à jour hier';
    return 'Mis à jour le ${_two(date.day)}/${_two(date.month)}';
  }

  static DateTime _dayOf(DateTime d) => DateTime(d.year, d.month, d.day);

  static String _two(int n) => n.toString().padLeft(2, '0');
}
