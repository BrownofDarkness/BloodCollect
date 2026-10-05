import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/config/firebase_config.dart';
import '../../../../core/constants/app_enums.dart';
import '../../../../core/constants/firestore_collections.dart';
import '../../../../shared/domain/entities/entities.dart';
import '../../../../shared/data/models/blood_center_model.dart';
import '../../../../shared/data/models/blood_stock_lot_model.dart';

/// Accès Firestore aux centres de transfusion et à leurs lots de stock.
class BloodCenterRemoteDataSource {
  BloodCenterRemoteDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseConfig.firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _centers =>
      _firestore.collection(FirestoreCollections.bloodCenters);

  CollectionReference<Map<String, dynamic>> get _lots =>
      _firestore.collection(FirestoreCollections.bloodStockLots);

  /// Centres agréés uniquement : un centre non vérifié n'expose pas de stock.
  Future<List<BloodCenter>> verifiedCenters() async {
    final snapshot = await _centers
        .where('verificationStatus', isEqualTo: 'verified')
        .get();
    return snapshot.docs
        .map((doc) => BloodCenterModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<BloodCenter?> centerById(String centerId) async {
    final doc = await _centers.doc(centerId).get();
    if (!doc.exists) return null;
    return BloodCenterModel.fromMap(doc.data()!, doc.id);
  }

  /// Tous les lots du centre, expiration comprise : c'est le domaine qui
  /// décide lesquels alimentent la disponibilité publique.
  Future<List<BloodStockLot>> lotsOfCenter(String centerId) async {
    final snapshot = await _lots
        .where('bloodCenterId', isEqualTo: centerId)
        .get();
    return snapshot.docs
        .map((doc) => BloodStockLotModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  /// Écriture d'un lot : réserve un lot disponible à une demande.
  Future<void> updateLotStatus(String lotId, StockLotStatus status) async {
    await _lots.doc(lotId).update({
      'status': status.firestoreValue,
      'updatedAt': FieldValue.serverTimestamp,
    });
  }
}