import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/app_enums.dart';
import '../../../../core/utils/date_utils.dart';
import '../../domain/usecases/get_blood_availability_usecase.dart';

part 'citizen_filters_providers.g.dart';

/// Filtres de l'onglet « Sang ».
///
/// Amorçage sur la ville du profil : la première consultation doit porter sur
/// les centres proches du citoyen, pas sur tout le pays.
@riverpod
class BloodAvailabilityFilterNotifier
    extends _$BloodAvailabilityFilterNotifier {
  @override
  Future<BloodAvailabilityFilter> build() async {
    // Par defaut les deux selecteurs montrent « Tout » : ville et commune
    // valent null, ce qui est la seule facon de connaitre la liste des
    // communes. Les amorcer sur la ville du profil restreindait la liste et
    // cachait les autres villes derriere une selection invisible.
    return const BloodAvailabilityFilter(bloodType: BloodType.oPos);
  }

  /// Recliquer sur le groupe déjà sélectionné le désactive.
  void selectBloodType(BloodType bloodType) {
    final current = state.asData?.value ?? BloodAvailabilityFilter.none;
    state = AsyncData(
      current.copyWith(
        bloodType: () => current.bloodType == bloodType ? null : bloodType,
      ),
    );
  }

  void selectCity(String? city) {
    final current = state.asData?.value ?? BloodAvailabilityFilter.none;
    // Changer de ville invalide la commune : celle-ci n'a de sens que dans
    // une ville donnée.
    state = AsyncData(current.copyWith(city: () => city, commune: () => null));
  }

  void selectCommune(String? commune) {
    final current = state.asData?.value ?? BloodAvailabilityFilter.none;
    state = AsyncData(current.copyWith(commune: () => commune));
  }
}

/// Libellé du compteur de résultats : « 3 centres de transfusion · O+ · Abidjan ».
String bloodResultCountLabel(
  int count, {
  required BloodAvailabilityFilter filter,
}) {
  final noun = count > 1 ? 'centres de transfusion' : 'centre de transfusion';
  final parts = <String>['$count $noun'];

  final bloodType = filter.bloodType;
  if (bloodType != null) parts.add(bloodType.label);

  final commune = filter.commune;
  final city = filter.city;
  if (commune != null) {
    parts.add(commune);
  } else if (city != null) {
    parts.add(city);
  }

  return parts.join(' $middleDot ');
}
