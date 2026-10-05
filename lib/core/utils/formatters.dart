// Formatages d'affichage partagés (français).
abstract final class Formatters {
  /// « 3,1 km » — une décimale, virgule française.
  static String distanceKm(double km) =>
      '${km.toStringAsFixed(1).replaceAll('.', ',')} km';

  /// « Mis à jour 09:15 » le jour même, « hier » la veille, sinon la date.
  static String updatedAt(DateTime date, {DateTime? now}) {
    final days = _daysAgo(date, now);
    if (days <= 0) {
      return 'Mis à jour ${_two(date.hour)}:${_two(date.minute)}';
    }
    if (days == 1) return 'Mis à jour hier';
    return 'Mis à jour le ${_two(date.day)}/${_two(date.month)}';
  }

  /// « 10:42 » le jour même, « hier 10:42 » la veille, sinon « 12/09 10:42 ».
  static String timeOrDate(DateTime date, {DateTime? now}) {
    final days = _daysAgo(date, now);
    final time = '${_two(date.hour)}:${_two(date.minute)}';
    if (days <= 0) return time;
    if (days == 1) return 'hier $time';
    return '${_two(date.day)}/${_two(date.month)} $time';
  }

  /// « il y a 22 min », « il y a 3 h », « hier », sinon « le 12/09 ».
  static String relative(DateTime date, {DateTime? now}) {
    final reference = now ?? DateTime.now();
    final days = _daysAgo(date, reference);
    if (days == 1) return 'hier';
    if (days > 1) return 'le ${_two(date.day)}/${_two(date.month)}';
    final minutes = reference.difference(date).inMinutes;
    if (minutes < 1) return 'à l’instant';
    if (minutes < 60) return 'il y a $minutes min';
    return 'il y a ${minutes ~/ 60} h';
  }

  static int _daysAgo(DateTime date, DateTime? now) =>
      _dayOf(now ?? DateTime.now()).difference(_dayOf(date)).inDays;

  static DateTime _dayOf(DateTime d) => DateTime(d.year, d.month, d.day);

  static String _two(int n) => n.toString().padLeft(2, '0');
}
