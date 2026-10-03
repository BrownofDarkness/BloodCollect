import 'package:cloud_functions/cloud_functions.dart';

import '../../../core/config/firebase_config.dart';
import '../../../core/constants/app_enums.dart';
import '../../domain/entities/donor_candidate.dart';
import '../../domain/entities/donor_search_criteria.dart';
import '../../domain/repositories/donor_repository.dart';

// Appelle la Cloud Function `searchDonors` (à déployer, forfait Blaze).
// Contrat attendu :
//   entrée  { bloodType, city, communes[], priority, donorCount }
//   sortie  { donors: [{ donorId, bloodType, commune, distanceKm? }] }
// La fonction ne retient que les citoyens disponibles au don et ne renvoie
// aucune donnée d'identité.
class DonorRepositoryImpl implements DonorRepository {
  DonorRepositoryImpl({FirebaseFunctions? functions})
      : _functions = functions ?? FirebaseConfig.functions;

  final FirebaseFunctions _functions;

  @override
  Future<List<DonorCandidate>> search(DonorSearchCriteria criteria) async {
    final result = await _functions.httpsCallable('searchDonors').call({
      'bloodType': criteria.bloodType.firestoreValue,
      'city': criteria.city,
      'communes': criteria.communes,
      'priority': criteria.priority.firestoreValue,
      'donorCount': criteria.donorCount,
    });
    final data = result.data;
    final donors = data is Map ? data['donors'] : null;
    if (donors is! List) return const [];

    return [
      for (final donor in donors)
        if (donor is Map && donor['donorId'] is String)
          DonorCandidate(
            donorId: donor['donorId'] as String,
            bloodType: BloodType.fromString(donor['bloodType'] as String?) ??
                criteria.bloodType,
            commune: donor['commune'] as String? ?? '',
            distanceKm: (donor['distanceKm'] as num?)?.toDouble(),
          ),
    ];
  }
}
