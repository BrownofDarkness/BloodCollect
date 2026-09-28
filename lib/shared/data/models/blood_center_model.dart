import '../../../core/constants/app_enums.dart';
import '../../domain/entities/blood_center.dart';
import 'firestore_converters.dart';

// ---- blood_centers
class BloodCenterModel extends BloodCenter {
  const BloodCenterModel({
    required super.id,
    required super.userId,
    required super.name,
    required super.address,
    required super.city,
    required super.commune,
    required super.location,
    required super.phone,
    required super.agreementNumber,
    required super.contactFunction,
    required super.openingHoursWeekdays,
    super.openingHoursSaturday,
    required super.lowStockThreshold,
    required super.unavailableThreshold,
    required super.verificationStatus,
    required super.createdAt,
    required super.updatedAt,
  });

  factory BloodCenterModel.fromMap(Map<String, dynamic> map, String id) {
    return BloodCenterModel(
      id: id,
      userId: map['userId'] as String? ?? '',
      name: map['name'] as String? ?? '',
      address: map['address'] as String? ?? '',
      city: map['city'] as String? ?? '',
      commune: map['commune'] as String? ?? '',
      location: geoToDomain(map['location']),
      phone: map['phone'] as String? ?? '',
      agreementNumber: map['agreementNumber'] as String? ?? '',
      contactFunction: map['contactFunction'] as String? ?? '',
      openingHoursWeekdays:
          map['openingHoursWeekdays'] as String? ?? '07h-18h',
      openingHoursSaturday: map['openingHoursSaturday'] as String?,
      lowStockThreshold: (map['lowStockThreshold'] as num?)?.toInt() ?? 20,
      unavailableThreshold:
          (map['unavailableThreshold'] as num?)?.toInt() ?? 5,
      verificationStatus: VerificationStatus.fromString(
              map['verificationStatus'] as String?) ??
          VerificationStatus.pending,
      createdAt: tsToDate(map['createdAt'], fallback: DateTime.now()),
      updatedAt: tsToDate(map['updatedAt'], fallback: DateTime.now()),
    );
  }

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'name': name,
        'address': address,
        'city': city,
        'commune': commune,
        'location': geoToFirestore(location),
        'phone': phone,
        'agreementNumber': agreementNumber,
        'contactFunction': contactFunction,
        'openingHoursWeekdays': openingHoursWeekdays,
        'openingHoursSaturday': openingHoursSaturday,
        'lowStockThreshold': lowStockThreshold,
        'unavailableThreshold': unavailableThreshold,
        'verificationStatus': verificationStatus.firestoreValue,
        'createdAt': dateToTs(createdAt),
        'updatedAt': dateToTs(updatedAt),
      };
}
