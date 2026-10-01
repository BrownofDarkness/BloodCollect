import '../../../../../shared/domain/entities/entities.dart';
import '../../domain/repositories/blood_center_repository.dart';
import '../datasources/blood_center_remote_datasource.dart';

/// Implémentation Firestore de [BloodCenterRepository].
///
/// Le filtrage des centres vérifiés est fait par la source : Firestone rejette
/// l'index composite nécessaire pour croiser `verificationStatus` et un tri
/// sans index déclaré, et la règle de sécurité impose de même que la
/// vérification soit lue depuis le serveur.
class BloodCenterRepositoryImpl implements BloodCenterRepository {
  const BloodCenterRepositoryImpl(this._remote);

  final BloodCenterRemoteDataSource _remote;

  @override
  Future<List<BloodCenter>> verifiedCenters() => _remote.verifiedCenters();

  @override
  Future<BloodCenter?> centerById(String centerId) =>
      _remote.centerById(centerId);

  @override
  Future<List<BloodStockLot>> lotsOfCenter(String centerId) =>
      _remote.lotsOfCenter(centerId);
}