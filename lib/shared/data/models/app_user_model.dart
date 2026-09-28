import '../../../core/constants/app_enums.dart';
import '../../domain/entities/app_user.dart';
import 'firestore_converters.dart';

// ---- users
class AppUserModel extends AppUser {
  const AppUserModel({
    required super.id,
    required super.email,
    required super.firstName,
    required super.lastName,
    super.phone,
    required super.role,
    super.bloodType,
    super.city,
    super.commune,
    super.isAvailableToDonate = false,
    super.lastDonationDate,
    super.fcmToken,
    required super.createdAt,
    required super.updatedAt,
  });

  factory AppUserModel.fromMap(Map<String, dynamic> map, String id) {
    return AppUserModel(
      id: id,
      email: map['email'] as String? ?? '',
      firstName: map['firstName'] as String? ?? '',
      lastName: map['lastName'] as String? ?? '',
      phone: map['phone'] as String?,
      role: UserRole.fromString(map['role'] as String?) ?? UserRole.citizen,
      bloodType: BloodType.fromString(map['bloodType'] as String?),
      city: map['city'] as String?,
      commune: map['commune'] as String?,
      isAvailableToDonate: map['isAvailableToDonate'] as bool? ?? false,
      lastDonationDate: tsToDateOrNull(map['lastDonationDate']),
      fcmToken: map['fcmToken'] as String?,
      createdAt: tsToDate(map['createdAt'], fallback: DateTime.now()),
      updatedAt: tsToDate(map['updatedAt'], fallback: DateTime.now()),
    );
  }

  Map<String, dynamic> toMap() => {
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'phone': phone,
        'role': role.firestoreValue,
        'bloodType': bloodType?.firestoreValue,
        'city': city,
        'commune': commune,
        'isAvailableToDonate': isAvailableToDonate,
        'lastDonationDate':
            lastDonationDate == null ? null : dateToTs(lastDonationDate!),
        'fcmToken': fcmToken,
        'createdAt': dateToTs(createdAt),
        'updatedAt': dateToTs(updatedAt),
      };
}
