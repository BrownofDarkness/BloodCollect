import '../../../core/constants/app_enums.dart';
import 'geo_location.dart';

// collection --- health_centers/{centerId}
class HealthCenter {
  const HealthCenter({
    required this.id,
    required this.userId,
    required this.name,
    required this.address,
    required this.city,
    required this.commune,
    required this.location,
    required this.phone,
    required this.establishmentType,
    required this.authorizationNumber,
    required this.contactFunction,
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
  final String establishmentType;
  final String authorizationNumber;
  final String contactFunction;
  final VerificationStatus verificationStatus;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isVerified => verificationStatus == VerificationStatus.verified;

  HealthCenter copyWith({
    String? id,
    String? userId,
    String? name,
    String? address,
    String? city,
    String? commune,
    GeoLocation? location,
    String? phone,
    String? establishmentType,
    String? authorizationNumber,
    String? contactFunction,
    VerificationStatus? verificationStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HealthCenter(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      address: address ?? this.address,
      city: city ?? this.city,
      commune: commune ?? this.commune,
      location: location ?? this.location,
      phone: phone ?? this.phone,
      establishmentType: establishmentType ?? this.establishmentType,
      authorizationNumber: authorizationNumber ?? this.authorizationNumber,
      contactFunction: contactFunction ?? this.contactFunction,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
