import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/config/firebase_config.dart';
import '../../../core/constants/firestore_collections.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/user_repository.dart';
import '../models/app_user_model.dart';

class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseConfig.firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection(FirestoreCollections.users);

  @override
  Future<AppUser?> getById(String id) async {
    final snap = await _col.doc(id).get();
    if (!snap.exists) return null;
    return AppUserModel.fromMap(snap.data()!, snap.id);
  }

  @override
  Stream<AppUser?> watchById(String id) {
    return _col.doc(id).snapshots().map((snap) {
      if (!snap.exists) return null;
      return AppUserModel.fromMap(snap.data()!, snap.id);
    });
  }

  @override
  Future<void> save(AppUser user) async {
    final data = AppUserModel(
      id: user.id,
      email: user.email,
      firstName: user.firstName,
      lastName: user.lastName,
      phone: user.phone,
      role: user.role,
      bloodType: user.bloodType,
      city: user.city,
      commune: user.commune,
      isAvailableToDonate: user.isAvailableToDonate,
      lastDonationDate: user.lastDonationDate,
      fcmToken: user.fcmToken,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    ).toMap()
      ..['updatedAt'] = FieldValue.serverTimestamp();
    await _col.doc(user.id).set(data, SetOptions(merge: true));
  }
}
