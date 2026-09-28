// BloodCollect — Énumérations partagées
// Valeurs Firestore en snake_case / symboles groupes sanguins.

enum UserRole {
  citizen,
  healthCenter,
  bloodCenter,
  admin;

  static UserRole? fromString(String? value) => switch (value) {
        'citizen' => UserRole.citizen,
        'health_center' => UserRole.healthCenter,
        'blood_center' => UserRole.bloodCenter,
        'admin' => UserRole.admin,
        _ => null,
      };

  String get firestoreValue => switch (this) {
        UserRole.citizen => 'citizen',
        UserRole.healthCenter => 'health_center',
        UserRole.bloodCenter => 'blood_center',
        UserRole.admin => 'admin',
      };
}

enum BloodType {
  aPos,
  aNeg,
  bPos,
  bNeg,
  abPos,
  abNeg,
  oPos,
  oNeg;

  static BloodType? fromString(String? value) => switch (value) {
        'A+' => BloodType.aPos,
        'A-' => BloodType.aNeg,
        'B+' => BloodType.bPos,
        'B-' => BloodType.bNeg,
        'AB+' => BloodType.abPos,
        'AB-' => BloodType.abNeg,
        'O+' => BloodType.oPos,
        'O-' => BloodType.oNeg,
        _ => null,
      };

  String get firestoreValue => switch (this) {
        BloodType.aPos => 'A+',
        BloodType.aNeg => 'A-',
        BloodType.bPos => 'B+',
        BloodType.bNeg => 'B-',
        BloodType.abPos => 'AB+',
        BloodType.abNeg => 'AB-',
        BloodType.oPos => 'O+',
        BloodType.oNeg => 'O-',
      };

  String get label => firestoreValue;
}

enum ProductType {
  wholeBlood,
  plasma,
  platelets,
  redCells;

  static ProductType? fromString(String? value) => switch (value) {
        'whole_blood' => ProductType.wholeBlood,
        'plasma' => ProductType.plasma,
        'platelets' => ProductType.platelets,
        'red_cells' => ProductType.redCells,
        _ => null,
      };

  String get firestoreValue => switch (this) {
        ProductType.wholeBlood => 'whole_blood',
        ProductType.plasma => 'plasma',
        ProductType.platelets => 'platelets',
        ProductType.redCells => 'red_cells',
      };
}

enum Priority {
  normal,
  elevated,
  vital;

  static Priority? fromString(String? value) => switch (value) {
        'normal' => Priority.normal,
        'elevated' => Priority.elevated,
        'vital' => Priority.vital,
        _ => null,
      };

  String get firestoreValue => switch (this) {
        Priority.normal => 'normal',
        Priority.elevated => 'elevated',
        Priority.vital => 'vital',
      };
}

enum VerificationStatus {
  pending,
  verified,
  rejected;

  static VerificationStatus? fromString(String? value) =>
      switch (value) {
        'pending' => VerificationStatus.pending,
        'verified' => VerificationStatus.verified,
        'rejected' => VerificationStatus.rejected,
        _ => null,
      };

  String get firestoreValue => switch (this) {
        VerificationStatus.pending => 'pending',
        VerificationStatus.verified => 'verified',
        VerificationStatus.rejected => 'rejected',
      };
}

enum StockLotStatus {
  available,
  reserved,
  used,
  expired,
  discarded;

  static StockLotStatus? fromString(String? value) => switch (value) {
        'available' => StockLotStatus.available,
        'reserved' => StockLotStatus.reserved,
        'used' => StockLotStatus.used,
        'expired' => StockLotStatus.expired,
        'discarded' => StockLotStatus.discarded,
        _ => null,
      };

  String get firestoreValue => switch (this) {
        StockLotStatus.available => 'available',
        StockLotStatus.reserved => 'reserved',
        StockLotStatus.used => 'used',
        StockLotStatus.expired => 'expired',
        StockLotStatus.discarded => 'discarded',
      };
}

enum RequestStatus {
  pending,
  routing,
  partiallyFulfilled,
  fulfilled,
  oriented,
  cancelled,
  expired;

  static RequestStatus? fromString(String? value) => switch (value) {
        'pending' => RequestStatus.pending,
        'routing' => RequestStatus.routing,
        'partially_fulfilled' => RequestStatus.partiallyFulfilled,
        'fulfilled' => RequestStatus.fulfilled,
        'oriented' => RequestStatus.oriented,
        'cancelled' => RequestStatus.cancelled,
        'expired' => RequestStatus.expired,
        _ => null,
      };

  String get firestoreValue => switch (this) {
        RequestStatus.pending => 'pending',
        RequestStatus.routing => 'routing',
        RequestStatus.partiallyFulfilled => 'partially_fulfilled',
        RequestStatus.fulfilled => 'fulfilled',
        RequestStatus.oriented => 'oriented',
        RequestStatus.cancelled => 'cancelled',
        RequestStatus.expired => 'expired',
      };
}

enum BloodRouteStep {
  searchingStock,
  mobilizingDonors,
  waiting,
  completed;

  static BloodRouteStep? fromString(String? value) => switch (value) {
        'searching_stock' => BloodRouteStep.searchingStock,
        'mobilizing_donors' => BloodRouteStep.mobilizingDonors,
        'waiting' => BloodRouteStep.waiting,
        'completed' => BloodRouteStep.completed,
        _ => null,
      };

  String get firestoreValue => switch (this) {
        BloodRouteStep.searchingStock => 'searching_stock',
        BloodRouteStep.mobilizingDonors => 'mobilizing_donors',
        BloodRouteStep.waiting => 'waiting',
        BloodRouteStep.completed => 'completed',
      };
}

enum DonorMatchStatus {
  pending,
  accepted,
  declined,
  expired,
  completed;

  static DonorMatchStatus? fromString(String? value) => switch (value) {
        'pending' => DonorMatchStatus.pending,
        'accepted' => DonorMatchStatus.accepted,
        'declined' => DonorMatchStatus.declined,
        'expired' => DonorMatchStatus.expired,
        'completed' => DonorMatchStatus.completed,
        _ => null,
      };

  String get firestoreValue => switch (this) {
        DonorMatchStatus.pending => 'pending',
        DonorMatchStatus.accepted => 'accepted',
        DonorMatchStatus.declined => 'declined',
        DonorMatchStatus.expired => 'expired',
        DonorMatchStatus.completed => 'completed',
      };
}

enum CampaignStatus {
  draft,
  published,
  active,
  completed,
  cancelled;

  static CampaignStatus? fromString(String? value) => switch (value) {
        'draft' => CampaignStatus.draft,
        'published' => CampaignStatus.published,
        'active' => CampaignStatus.active,
        'completed' => CampaignStatus.completed,
        'cancelled' => CampaignStatus.cancelled,
        _ => null,
      };

  String get firestoreValue => switch (this) {
        CampaignStatus.draft => 'draft',
        CampaignStatus.published => 'published',
        CampaignStatus.active => 'active',
        CampaignStatus.completed => 'completed',
        CampaignStatus.cancelled => 'cancelled',
      };
}

enum RegistrationStatus {
  registered,
  confirmed,
  completed,
  absent,
  cancelled;

  static RegistrationStatus? fromString(String? value) => switch (value) {
        'registered' => RegistrationStatus.registered,
        'confirmed' => RegistrationStatus.confirmed,
        'completed' => RegistrationStatus.completed,
        'absent' => RegistrationStatus.absent,
        'cancelled' => RegistrationStatus.cancelled,
        _ => null,
      };

  String get firestoreValue => switch (this) {
        RegistrationStatus.registered => 'registered',
        RegistrationStatus.confirmed => 'confirmed',
        RegistrationStatus.completed => 'completed',
        RegistrationStatus.absent => 'absent',
        RegistrationStatus.cancelled => 'cancelled',
      };
}

enum DonationStatus {
  pendingValidation,
  validated,
  rejected;

  static DonationStatus? fromString(String? value) => switch (value) {
        'pending_validation' => DonationStatus.pendingValidation,
        'validated' => DonationStatus.validated,
        'rejected' => DonationStatus.rejected,
        _ => null,
      };

  String get firestoreValue => switch (this) {
        DonationStatus.pendingValidation => 'pending_validation',
        DonationStatus.validated => 'validated',
        DonationStatus.rejected => 'rejected',
      };
}

enum NotificationType {
  bloodRequest,
  donorMobilization,
  campaign,
  stockAlert,
  validation,
  donationConfirmed;

  static NotificationType? fromString(String? value) => switch (value) {
        'blood_request' => NotificationType.bloodRequest,
        'donor_mobilization' => NotificationType.donorMobilization,
        'campaign' => NotificationType.campaign,
        'stock_alert' => NotificationType.stockAlert,
        'validation' => NotificationType.validation,
        'donation_confirmed' => NotificationType.donationConfirmed,
        _ => null,
      };

  String get firestoreValue => switch (this) {
        NotificationType.bloodRequest => 'blood_request',
        NotificationType.donorMobilization => 'donor_mobilization',
        NotificationType.campaign => 'campaign',
        NotificationType.stockAlert => 'stock_alert',
        NotificationType.validation => 'validation',
        NotificationType.donationConfirmed => 'donation_confirmed',
      };
}

enum StructureType {
  healthCenter,
  bloodCenter;

  static StructureType? fromString(String? value) => switch (value) {
        'health_center' => StructureType.healthCenter,
        'blood_center' => StructureType.bloodCenter,
        _ => null,
      };

  String get firestoreValue => switch (this) {
        StructureType.healthCenter => 'health_center',
        StructureType.bloodCenter => 'blood_center',
      };
}
