import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/config/firebase_config.dart';
import '../../../core/constants/app_enums.dart';
import '../../../core/constants/firestore_collections.dart';
import '../../domain/entities/blood_stock_lot.dart';
import '../../domain/repositories/blood_stock_repository.dart';
import '../models/blood_stock_lot_model.dart';

class BloodStockRepositoryImpl implements BloodStockRepository {
  BloodStockRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseConfig.firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection(FirestoreCollections.bloodStockLots);

  @override
  Stream<List<BloodStockLot>> watchAvailableLots(BloodType bloodType) {
    // Égalités uniquement : aucun index composite à déclarer.
    return _watch(
      _col.where('bloodType', isEqualTo: bloodType.firestoreValue),
    );
  }

  @override
  Stream<List<BloodStockLot>> watchAvailableLotsByCenter(
    String bloodCenterId,
  ) {
    return _watch(_col.where('bloodCenterId', isEqualTo: bloodCenterId));
  }

  Stream<List<BloodStockLot>> _watch(Query<Map<String, dynamic>> query) {
    return query
        .where('status', isEqualTo: StockLotStatus.available.firestoreValue)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => BloodStockLotModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }
}
