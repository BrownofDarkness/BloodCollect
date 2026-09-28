import '../../../core/constants/app_enums.dart';

// collection --- users/{uid} (id = UID Firebase Auth)
class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phone,
    required this.role,
    this.bloodType,
    this.city,
    this.commune,
    this.isAvailableToDonate = false,
    this.lastDonationDate,
    this.fcmToken,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? phone;
  final UserRole role;
  // Pertinents uniquement pour role == citizen
  final BloodType? bloodType;
  final String? city;
  final String? commune;
  final bool isAvailableToDonate;
  final DateTime? lastDonationDate;
  final String? fcmToken;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isCitizen => role == UserRole.citizen;

  AppUser copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? Function()? phone,
    UserRole? role,
    BloodType? Function()? bloodType,
    String? Function()? city,
    String? Function()? commune,
    bool? isAvailableToDonate,
    DateTime? Function()? lastDonationDate,
    String? Function()? fcmToken,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone != null ? phone() : this.phone,
      role: role ?? this.role,
      bloodType: bloodType != null ? bloodType() : this.bloodType,
      city: city != null ? city() : this.city,
      commune: commune != null ? commune() : this.commune,
      isAvailableToDonate: isAvailableToDonate ?? this.isAvailableToDonate,
      lastDonationDate:
          lastDonationDate != null ? lastDonationDate() : this.lastDonationDate,
      fcmToken: fcmToken != null ? fcmToken() : this.fcmToken,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
