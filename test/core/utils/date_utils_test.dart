import 'package:blood_collect/core/utils/date_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatTimeFr', () {
    test('garde un zéro devant les minutes', () {
      expect(formatTimeFr(DateTime(2026, 10, 17, 9, 5)), '09:05');
      expect(formatTimeFr(DateTime(2026, 10, 17, 14, 30)), '14:30');
    });
  });

  group('formatWeekdayDayMonthFr', () {
    test('écrit le jour et le mois en français', () {
      expect(
        formatWeekdayDayMonthFr(DateTime(2026, 10, 17)),
        'samedi 17 octobre',
      );
      expect(
        formatWeekdayDayMonthFr(DateTime(2026, 10, 20)),
        'mardi 20 octobre',
      );
    });
  });

  group('formatHourFr', () {
    test('retire le zéro devant l\'heure mais garde celui des minutes', () {
      expect(formatHourFr(DateTime(2026, 10, 17, 8, 0)), '8h00');
      expect(formatHourFr(DateTime(2026, 10, 20, 15, 30)), '15h30');
    });
  });

  group('formatCampaignPeriodFr', () {
    test('joint le jour, l\'heure de début et l\'heure de fin', () {
      expect(
        formatCampaignPeriodFr(
          DateTime(2026, 10, 17, 8, 0),
          DateTime(2026, 10, 17, 14, 0),
        ),
        'samedi 17 octobre · 8h00 – 14h00',
      );
    });
  });

  group('closingHourFr', () {
    test('extrait la borne haute d\'une plage d\'horaires', () {
      expect(closingHourFr('7h30 – 16h00'), '16h00');
      expect(closingHourFr('7h30 – 15h30'), '15h30');
    });
  });

  group('formatLastUpdateLabel', () {
    final reference = DateTime(2026, 10, 20, 18, 0);

    test('affiche l\'heure si la mise à jour est du jour', () {
      expect(
        formatLastUpdateLabel(DateTime(2026, 10, 20, 9, 15), now: reference),
        'Mis à jour 09:15',
      );
    });

    test('affiche « hier » pour la veille', () {
      expect(
        formatLastUpdateLabel(DateTime(2026, 10, 19, 16, 0), now: reference),
        'Mis à jour hier',
      );
    });

    test('retombe sur la date au-delà de la veille', () {
      expect(
        formatLastUpdateLabel(DateTime(2026, 10, 17, 8, 0), now: reference),
        'Mis à jour 17 octobre',
      );
    });
  });
}
