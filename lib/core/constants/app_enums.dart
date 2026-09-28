enum UserRole {
  citizen,
  healthCenter,
  bloodCenter,
  admin;

  static UserRole? fromString(String? value) => switch (value) {
        'citizen'       => UserRole.citizen,
        'health_center' => UserRole.healthCenter,
        'blood_center'  => UserRole.bloodCenter,
        'admin'         => UserRole.admin,
        _               => null,
      };

  String get firestoreValue => switch (this) {
        UserRole.citizen       => 'citizen',
        UserRole.healthCenter  => 'health_center',
        UserRole.bloodCenter   => 'blood_center',
        UserRole.admin         => 'admin',
      };
}
