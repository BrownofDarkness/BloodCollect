import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

// Point d'accès unique aux instances Firebase, le but est centraliser l'accès
abstract final class FirebaseConfig {
  static FirebaseAuth get auth => FirebaseAuth.instance;
  static FirebaseFirestore get firestore => FirebaseFirestore.instance;
  static FirebaseStorage get storage => FirebaseStorage.instance;

  static String validationDocPath(String uid, String fileName) =>
      'validation_docs/$uid/$fileName';
}
