import '../../../core/constants/app_enums.dart';

// collection --- donations/{donationId}
// campaignId ET bloodRequestId optionnels : don spontané possible.
class Donation {
  const Donation({
    required this.id,
    required this.donorId,
    required this.structureId,
    this.campaignId,
    this.bloodRequestId,
    required this.bloodType,
    this.quantity,
    required this.donationDate,
    required this.status,
    this.validatedBy,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String donorId;
  final String structureId;
  final String? campaignId;
  final String? bloodRequestId;
  final BloodType bloodType;
  final int? quantity;
  final DateTime donationDate;
  final DonationStatus status;
  final String? validatedBy;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Donation copyWith({
    String? id,
    String? donorId,
    String? structureId,
    String? Function()? campaignId,
    String? Function()? bloodRequestId,
    BloodType? bloodType,
    int? Function()? quantity,
    DateTime? donationDate,
    DonationStatus? status,
    String? Function()? validatedBy,
    String? Function()? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Donation(
      id: id ?? this.id,
      donorId: donorId ?? this.donorId,
      structureId: structureId ?? this.structureId,
      campaignId: campaignId != null ? campaignId() : this.campaignId,
      bloodRequestId:
          bloodRequestId != null ? bloodRequestId() : this.bloodRequestId,
      bloodType: bloodType ?? this.bloodType,
      quantity: quantity != null ? quantity() : this.quantity,
      donationDate: donationDate ?? this.donationDate,
      status: status ?? this.status,
      validatedBy: validatedBy != null ? validatedBy() : this.validatedBy,
      notes: notes != null ? notes() : this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
