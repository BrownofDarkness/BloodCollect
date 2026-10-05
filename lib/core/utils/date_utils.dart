// Formatage temporel en français.
// Hand-rolled volontairement : le projet ne déclare pas `intl`, on évite
// d'ajouter une dépendance pour trois listes de mots.

const List<String> _weekdaysFr = [
  'lundi',
  'mardi',
  'mercredi',
  'jeudi',
  'vendredi',
  'samedi',
  'dimanche',
];

const List<String> _monthsFr = [
  'janvier',
  'février',
  'mars',
  'avril',
  'mai',
  'juin',
  'juillet',
  'août',
  'septembre',
  'octobre',
  'novembre',
  'décembre',
];

/// Séparateur typographique « – » (tiret demi-cadratin), utilisé par les maquettes.
const String enDash = '–';
const String middleDot = '·';

/// 9h15 -> « 09:15 » (format 24 h à deux points, utilisé pour « Mis à jour »).
String formatTimeFr(DateTime value) =>
    '${_pad2(value.hour)}:${_pad2(value.minute)}';

/// 17 octobre 2026 -> « samedi 17 octobre ».
String formatWeekdayDayMonthFr(DateTime value) =>
    '${_weekdaysFr[value.weekday - 1]} ${value.day} ${_monthsFr[value.month - 1]}';

/// 17 octobre 2026 -> « 17 octobre ».
String formatDayMonthFr(DateTime value) =>
    '${value.day} ${_monthsFr[value.month - 1]}';

/// « Samedi 17 octobre · 8h00 – 14h00 »
String formatCampaignPeriodFr(DateTime start, DateTime end) =>
    '${formatWeekdayDayMonthFr(start)} $middleDot ${formatHourFr(start)} $enDash ${formatHourFr(end)}';

/// 8h00 -> « 8h00 » (heure sans zéro devant, minutes avec).
String formatHourFr(DateTime value) => '${value.hour}h${_pad2(value.minute)}';

/// Dernière borne d'une plage d'horaires : « 7h30 – 16h00 » -> « 16h00 ».
/// Sert au libellé « Ouvert · jusqu'à 16h00 ».
String closingHourFr(String openingRange) =>
    openingRange.split(enDash).last.trim();

/// « Mis à jour 09:15 » aujourd'hui, « Mis à jour hier » la veille,
/// sinon la date courte.
String formatLastUpdateLabel(DateTime updatedAt, {DateTime? now}) {
  final reference = now ?? DateTime.now();
  final days = DateTime(
    reference.year,
    reference.month,
    reference.day,
  ).difference(DateTime(updatedAt.year, updatedAt.month, updatedAt.day)).inDays;

  return switch (days) {
    0 => 'Mis à jour ${formatTimeFr(updatedAt)}',
    1 => 'Mis à jour hier',
    _ => 'Mis à jour ${formatDayMonthFr(updatedAt)}',
  };
}

String _pad2(int value) => value.toString().padLeft(2, '0');
