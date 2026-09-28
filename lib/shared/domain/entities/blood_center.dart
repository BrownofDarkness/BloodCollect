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
      openingHoursWeekdays:
          openingHoursWeekdays ?? this.openingHoursWeekdays,
      openingHoursSaturday: openingHoursSaturday != null
          ? openingHoursSaturday()
          : this.openingHoursSaturday,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      unavailableThreshold:
          unavailableThreshold ?? this.unavailableThreshold,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
