import '../../../core/constants/app_enums.dart';
import '../../domain/entities/donation.dart';
import 'firestore_converters.dart';

// ---- donations
class DonationModel extends Donation {
  const DonationModel({
    required super.id,
    required super.donorId,
    required super.structureId,
    super.campaignId,
    super.bloodRequestId,
    required super.bloodType,
    super.quantity,
    required super.donationDate,
    required super.status,
    super.validatedBy,
    super.notes,
    required super.createdAt,
    required super.updatedAt,
  });

  factory DonationModel.fromMap(Map<String, dynamic> map, String id) {
    return DonationModel(
      id: id,
      donorId: map['donorId'] as String? ?? '',
      structureId: map['structureId'] as String? ?? '',
      campaignId: map['campaignId'] as String?,
      bloodRequestId: map['bloodRequestId'] as String?,
      bloodType:
          BloodType.fromString(map['bloodType'] as String?) ?? BloodType.oPos,
      quantity: (map['quantity'] as num?)?.toInt(),
      donationDate: tsToDate(map['donationDate'], fallback: DateTime.now()),
      status:
          DonationStatus.fromString(map['status'] as String?) ??
          DonationStatus.pendingValidation,
      validatedBy: map['validatedBy'] as String?,
      notes: map['notes'] as String?,
      createdAt: tsToDate(map['createdAt'], fallback: DateTime.now()),
      updatedAt: tsToDate(map['updatedAt'], fallback: DateTime.now()),
    );
  }

  Map<String, dynamic> toMap() => {
    'donorId': donorId,
    'structureId': structureId,
    'campaignId': campaignId,
    'bloodRequestId': bloodRequestId,
    'bloodType': bloodType.firestoreValue,
    'quantity': quantity,
    'donationDate': dateToTs(donationDate),
    'status': status.firestoreValue,
    'validatedBy': validatedBy,
    'notes': notes,
    'createdAt': dateToTs(createdAt),
    'updatedAt': dateToTs(updatedAt),
  };
}
