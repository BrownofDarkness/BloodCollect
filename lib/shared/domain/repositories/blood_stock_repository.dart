import '../../../core/constants/app_enums.dart';
import '../entities/blood_stock_lot.dart';

// Contrat d'accès aux lots de stock déclarés par les centres de transfusion.
abstract class BloodStockRepository {
  /// Lots `available` d'un groupe sanguin, tous centres confondus, en temps réel.
  Stream<List<BloodStockLot>> watchAvailableLots(BloodType bloodType);

  /// Lots `available` d'un centre, tous groupes confondus, en temps réel.
  Stream<List<BloodStockLot>> watchAvailableLotsByCenter(String bloodCenterId);
}
