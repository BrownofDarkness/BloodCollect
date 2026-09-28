import '../../../../shared/domain/entities/entities.dart';
import '../../domain/repositories/blood_center_repository.dart';
import '../datasources/citizen_mock_datasource.dart';

/// Implémentation de test de [BloodCenterRepository].
/// Brancher une source Firestore réel ne demandera qu'une autre classe
/// respectant le même contrat.
class BloodCenterRepositoryImpl implements BloodCenterRepository {
  const BloodCenterRepositoryImpl(this._source);

  final CitizenMockDataSource _source;

  @override
  Future<List<BloodCenter>> verifiedCenters() async =>
      _source.centers.where((center) => center.isVerified).toList();

  @override
  Future<BloodCenter?> centerById(String centerId) async {
    for (final center in _source.centers) {
      if (center.id == centerId) return center;
    }
    return null;
  }

  @override
  Future<List<BloodStockLot>> lotsOfCenter(String centerId) async =>
      _source.lots.where((lot) => lot.bloodCenterId == centerId).toList();
}
