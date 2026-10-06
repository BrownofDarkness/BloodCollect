import '../../../core/constants/app_enums.dart';
import 'geo_location.dart';

// collection --- blood_centers/{centerId}
class BloodCenter {
  const BloodCenter({
    required this.id,
    required this.userId,
    required this.name,
    required this.address,
    required this.city,
    required this.commune,
    required this.location,
    required this.phone,
    required this.agreementNumber,
    required this.contactFunction,
    required this.openingHoursWeekdays,
    this.openingHoursSaturday,
    required this.lowStockThreshold,
    required this.unavailableThreshold,
    required this.verificationStatus,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final String name;
  final String address;
  final String city;
  final String commune;
  final GeoLocation location;
  final String phone;
  final String agreementNumber;
  final String contactFunction;
  final String openingHoursWeekdays;
  final String? openingHoursSaturday;
  final int lowStockThreshold;
  final int unavailableThreshold;
  final VerificationStatus verificationStatus;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isVerified => verificationStatus == VerificationStatus.verified;

  /// Ouverture à l'instant [now], d'après les horaires déclarés : semaine du
  /// lundi au vendredi, samedi si renseigné, fermé le dimanche. Null si les
  /// horaires du jour ne sont pas lisibles (saisie libre).
  OpeningStatus? openingAt(DateTime now) {
    final String? hours;
    if (now.weekday == DateTime.sunday) {
      return const OpeningStatus(isOpen: false);
    } else if (now.weekday == DateTime.saturday) {
      hours = openingHoursSaturday;
      if (hours == null || hours.isEmpty) {
        return const OpeningStatus(isOpen: false);
      }
    } else {
      hours = openingHoursWeekdays;
    }

    // « 7h30 – 16h00 », « 07h-18h » : deux heures, minutes facultatives.
    final times = RegExp(r'(\d{1,2})\s*h\s*(\d{2})?').allMatches(hours);
    if (times.length != 2) return null;
    int minutesOf(RegExpMatch m) =>
        int.parse(m.group(1)!) * 60 + int.parse(m.group(2) ?? '0');
    final opens = minutesOf(times.first);
    final closes = minutesOf(times.last);
    final current = now.hour * 60 + now.minute;

    return OpeningStatus(
      isOpen: current >= opens && current < closes,
      closesAtMinutes: closes,
    );
  }

  BloodCenter copyWith({
    String? id,
    String? userId,
    String? name,
    String? address,
    String? city,
    String? commune,
    GeoLocation? location,
    String? phone,
    String? agreementNumber,
    String? contactFunction,
    String? openingHoursWeekdays,
    String? Function()? openingHoursSaturday,
    int? lowStockThreshold,
    int? unavailableThreshold,
    VerificationStatus? verificationStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BloodCenter(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      address: address ?? this.address,
      city: city ?? this.city,
      commune: commune ?? this.commune,
      location: location ?? this.location,
      phone: phone ?? this.phone,
      agreementNumber: agreementNumber ?? this.agreementNumber,
      contactFunction: contactFunction ?? this.contactFunction,
      openingHoursWeekdays: openingHoursWeekdays ?? this.openingHoursWeekdays,
      openingHoursSaturday: openingHoursSaturday != null
          ? openingHoursSaturday()
          : this.openingHoursSaturday,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      unavailableThreshold: unavailableThreshold ?? this.unavailableThreshold,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// État d'ouverture d'un centre à un instant donné. Non persisté.
class OpeningStatus {
  const OpeningStatus({required this.isOpen, this.closesAtMinutes});

  final bool isOpen;

  /// Heure de fermeture du jour, en minutes depuis minuit ; null si le
  /// centre est fermé toute la journée.
  final int? closesAtMinutes;
}
