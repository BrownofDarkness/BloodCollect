import '../../../core/constants/app_enums.dart';
import '../../domain/entities/blood_stock_lot.dart';
import 'firestore_converters.dart';

// ---- blood_stock_lots
class BloodStockLotModel extends BloodStockLot {
  const BloodStockLotModel({
    required super.id,
    required super.bloodCenterId,
    required super.bloodType,
    required super.productType,
    required super.lotReference,
    required super.quantity,
    required super.expiryDate,
    required super.collectionDate,
    super.provenance,
    super.internalNote,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
  });

  factory BloodStockLotModel.fromMap(Map<String, dynamic> map, String id) {
    return BloodStockLotModel(
      id: id,
      bloodCenterId: map['bloodCenterId'] as String? ?? '',
      bloodType:
          BloodType.fromString(map['bloodType'] as String?) ?? BloodType.oPos,
      productType: ProductType.fromString(map['productType'] as String?) ??
          ProductType.wholeBlood,
      lotReference: map['lotReference'] as String? ?? '',
      quantity: (map['quantity'] as num?)?.toInt() ?? 0,
      expiryDate: tsToDate(map['expiryDate'], fallback: DateTime.now()),
      collectionDate:
          tsToDate(map['collectionDate'], fallback: DateTime.now()),
      provenance: map['provenance'] as String?,
      internalNote: map['internalNote'] as String?,
      status: StockLotStatus.fromString(map['status'] as String?) ??
          StockLotStatus.available,
      createdAt: tsToDate(map['createdAt'], fallback: DateTime.now()),
      updatedAt: tsToDate(map['updatedAt'], fallback: DateTime.now()),
    );
  }

  Map<String, dynamic> toMap() => {
        'bloodCenterId': bloodCenterId,
        'bloodType': bloodType.firestoreValue,
        'productType': productType.firestoreValue,
        'lotReference': lotReference,
        'quantity': quantity,
        'expiryDate': dateToTs(expiryDate),
        'collectionDate': dateToTs(collectionDate),
        'provenance': provenance,
        'internalNote': internalNote,
        'status': status.firestoreValue,
        'createdAt': dateToTs(createdAt),
        'updatedAt': dateToTs(updatedAt),
      };
}
