import '../../../../../core/constants/app_enums.dart';
import '../../../../../shared/domain/entities/entities.dart';
import '../repositories/donor_repository.dart';

/// Onglet « Profil » : identité du citoyen et résumé de son activité.
class CitizenProfile {
  const CitizenProfile({
    required this.user,
    required this.upcomingCollectCount,
    required this.matchCount,
  });

  final AppUser user;

  /// Collectes à venir auxquelles le citoyen est inscrit.
  final int upcomingCollectCount;

  /// Mises en relation, envoyées comme reçues.
  final int matchCount;

  /// Initiales affichées dans l'avatar : « Aya Koné » -> « AK ».
  String get initials {
    final first = user.firstName.trim();
    final last = user.lastName.trim();
    return '${_initial(first)}${_initial(last)}'.toUpperCase();
  }

  static String _initial(String name) => name.isEmpty ? '' : name[0];
}

class GetCitizenProfileUseCase {
  const GetCitizenProfileUseCase({required this.donors});

  final DonorRepository donors;

  Future<CitizenProfile> call() async {
    final user = await donors.currentCitizen();
    final registrations = await donors.registrationsOf(user.id);
    final matches = await donors.matchesOf(user.id);

    return CitizenProfile(
      user: user,
      upcomingCollectCount: _countActive(registrations),
      matchCount: matches.length,
    );
  }

  /// Une collecte compte tant qu'elle n'est ni annulée ni déjà réalisée.
  int _countActive(List<CampaignRegistration> registrations) {
    var count = 0;
    for (final registration in registrations) {
      final isClosed =
          registration.status == RegistrationStatus.cancelled ||
          registration.status == RegistrationStatus.completed;
      if (!isClosed) count++;
    }
    return count;
  }
}
