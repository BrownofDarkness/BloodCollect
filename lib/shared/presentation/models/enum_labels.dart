import '../../../core/constants/app_enums.dart';

/// app_enums.dart expose `firestoreValue` partout mais un `label` FR
/// seulement sur BloodType. Ces extensions comblent le reste côté UI
/// uniquement — elles ne touchent pas au fichier partagé de l'équipe.
extension PriorityLabel on Priority {
  String get label => switch (this) {
    Priority.normal => 'Normale',
    Priority.elevated => 'Élevée',
    Priority.vital => 'Vitale',
  };
}

extension DonorMatchStatusLabel on DonorMatchStatus {
  /// null = pas encore contacté, jamais affiché comme pill.
  String? get label => switch (this) {
    DonorMatchStatus.pending => 'En attente de réponse',
    DonorMatchStatus.accepted => 'Acceptée',
    DonorMatchStatus.declined => 'Refusée',
    DonorMatchStatus.expired => 'Expirée',
    DonorMatchStatus.completed => 'Don réalisé',
  };
}
