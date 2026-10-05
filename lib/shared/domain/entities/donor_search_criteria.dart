import '../../../core/constants/app_enums.dart';

// Critères d'une recherche de donneurs par un centre de santé.
// Non persisté : la sélection des donneurs se fait côté serveur, qui ne
// renvoie que des profils anonymisés (groupe + commune + distance).
class DonorSearchCriteria {
  const DonorSearchCriteria({
    required this.bloodType,
    required this.city,
    required this.communes,
    required this.priority,
    required this.donorCount,
  });

  final BloodType bloodType;
  final String city;
  // Au moins une commune de [city].
  final List<String> communes;
  final Priority priority;
  final int donorCount;

  bool get isValid => city.isNotEmpty && communes.isNotEmpty && donorCount > 0;

  // Égalité de valeur : sert de clé de cache aux providers.
  @override
  bool operator ==(Object other) =>
      other is DonorSearchCriteria &&
      other.bloodType == bloodType &&
      other.city == city &&
      other.priority == priority &&
      other.donorCount == donorCount &&
      other.communes.length == communes.length &&
      Iterable<int>.generate(communes.length)
          .every((i) => other.communes[i] == communes[i]);

  @override
  int get hashCode => Object.hash(
        bloodType,
        city,
        Object.hashAll(communes),
        priority,
        donorCount,
      );
}
