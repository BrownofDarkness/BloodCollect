import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/app_enums.dart';

part 'auth_providers.g.dart';

@riverpod
Stream<User?> authState(Ref ref) {
  return FirebaseAuth.instance.authStateChanges();
}

// TODO: Migrer vers shared/domain/usecases quand le data layer sera implémenté
@riverpod
Future<UserRole?> currentUserRole(Ref ref) async {
  final user = await ref.watch(authStateProvider.future);
  if (user == null) return null;

  final doc = await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .get();

  return UserRole.fromString(doc.data()?['role'] as String?);
}
