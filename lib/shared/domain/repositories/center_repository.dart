import '../../../core/constants/app_enums.dart';
import '../entities/blood_center.dart';
import '../entities/health_center.dart';
import '../entities/validation_request.dart';

// Contrats d'accès aux structures + dossiers de vérification + Storage.
abstract class CenterRepository {
  Future<String> createHealthCenter(HealthCenter center);
  Future<String> createBloodCenter(BloodCenter center);
  Future<void> createValidationRequest(ValidationRequest request);
  Future<String> uploadValidationDoc({
    required String uid,
    required String fileName,
    required List<int> bytes,
  });

  /// Même chose en temps réel : émet à chaque changement console/admin.
  Stream<VerificationStatus?> watchVerificationStatus({
    required String userId,
    required UserRole role,
  });

  /// Fiche du centre de santé rattaché à un compte (null si absente).
  Stream<HealthCenter?> watchHealthCenterByUser(String userId);

  /// Fiche d'un centre de transfusion (null si introuvable).
  Stream<BloodCenter?> watchBloodCenter(String centerId);

  /// Centres de transfusion vérifiés d'une ville, commune facultative.
  Stream<List<BloodCenter>> watchVerifiedBloodCenters({
    required String city,
    String? commune,
  });
}
