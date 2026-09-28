import '../../../core/constants/app_enums.dart';
import '../../domain/entities/health_center.dart';
import 'firestore_converters.dart';

// PDF p.5 — health_centers
class HealthCenterModel extends HealthCenter {
  const HealthCenterModel({
    required super.id,
    required super.userId,
    required super.name,
    required super.address,
    required super.city,
    required super.commune,
    required super.location,
    required super.phone,
    required super.establishmentType,
    required super.authorizationNumber,
    required super.contactFunction,
    required super.verificationStatus,
    required super.createdAt,
    required super.updatedAt,
  });

  factory HealthCenterModel.fromMap(Map<String, dynamic> map, String id) {
    return HealthCenterModel(
      id: id,
      userId: map['userId'] as String? ?? '',
      name: map['name'] as String? ?? '',
      address: map['address'] as String? ?? '',
      city: map['city'] as String? ?? '',
      commune: map['commune'] as String? ?? '',
      location: geoToDomain(map['location']),
      phone: map['phone'] as String? ?? '',
      establishmentType: map['establishmentType'] as String? ?? '',
      authorizationNumber: map['authorizationNumber'] as String? ?? '',
      contactFunction: map['contactFunction'] as String? ?? '',
      verificationStatus:
          VerificationStatus.fromString(map['verificationStatus'] as String?) ??
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
    'establishmentType': establishmentType,
    'authorizationNumber': authorizationNumber,
    'contactFunction': contactFunction,
    'verificationStatus': verificationStatus.firestoreValue,
    'createdAt': dateToTs(createdAt),
    'updatedAt': dateToTs(updatedAt),
  };
}
