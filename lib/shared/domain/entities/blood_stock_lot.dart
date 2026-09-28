import '../../../core/constants/app_enums.dart';

// collection --- blood_stock_lots/{lotId}
class BloodStockLot {
  const BloodStockLot({
    required this.id,
    required this.bloodCenterId,
    required this.bloodType,
    required this.productType,
    required this.lotReference,
    required this.quantity,
    required this.expiryDate,
    required this.collectionDate,
    this.provenance,
    this.internalNote,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String bloodCenterId;
  final BloodType bloodType;
  final ProductType productType;
  final String lotReference;
  final int quantity;
  final DateTime expiryDate;
  final DateTime collectionDate;
  final String? provenance;
  final String? internalNote;
  final StockLotStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isAvailable => status == StockLotStatus.available;
  bool isExpiredAt(DateTime now) => expiryDate.isBefore(now);

  BloodStockLot copyWith({
    String? id,
    String? bloodCenterId,
    BloodType? bloodType,
    ProductType? productType,
    String? lotReference,
    int? quantity,
    DateTime? expiryDate,
    DateTime? collectionDate,
    String? Function()? provenance,
    String? Function()? internalNote,
    StockLotStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BloodStockLot(
      id: id ?? this.id,
      bloodCenterId: bloodCenterId ?? this.bloodCenterId,
      bloodType: bloodType ?? this.bloodType,
      productType: productType ?? this.productType,
      lotReference: lotReference ?? this.lotReference,
      quantity: quantity ?? this.quantity,
      expiryDate: expiryDate ?? this.expiryDate,
      collectionDate: collectionDate ?? this.collectionDate,
      provenance: provenance != null ? provenance() : this.provenance,
      internalNote: internalNote != null ? internalNote() : this.internalNote,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
