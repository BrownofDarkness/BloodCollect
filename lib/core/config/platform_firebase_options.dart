import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

import '../../firebase_options.dart';

/// Options Firebase de la plateforme courante.
///
/// `lib/firebase_options.dart` est produit par FlutterFire et ne couvre que les
/// cibles mobiles et le web. Sans une entrée pour le bureau, la lecture de
/// `DefaultFirebaseOptions.currentPlatform` lève une exception et
/// l'application ne démarre pas du tout sur Linux.
///
/// Le module citoyen fonctionne entièrement sur ses données de test : il doit
/// pouvoir s'afficher sans Firebase, et c'est l'initialisation qui décide si le
/// backend est disponible, pas l'affichage.
abstract final class PlatformFirebaseOptions {
  const PlatformFirebaseOptions._();

  /// Options de la plateforme courante, ou `null` si aucune application
  /// Firebase n'y est déclarée. Un `null` n'est pas une erreur : l'application
  /// démarre alors en mode sans backend.
  static FirebaseOptions? currentPlatform() {
    if (kIsWeb) return DefaultFirebaseOptions.web;

    return switch (defaultTargetPlatform) {
      TargetPlatform.android => DefaultFirebaseOptions.android,
      TargetPlatform.iOS => DefaultFirebaseOptions.ios,
      TargetPlatform.macOS => DefaultFirebaseOptions.macos,
      TargetPlatform.windows => DefaultFirebaseOptions.windows,
      TargetPlatform.linux => linux,

      // Fuchsia n'a pas d'application Firebase déclarée.
      _ => null,
    };
  }
}

/// Configuration déclarée pour le bureau Linux, alignée sur l'application web
/// du même projet Firebase.
const FirebaseOptions linux = FirebaseOptions(
  apiKey: 'AIzaSyBXbKmyZP_qT6U5E4Jk41OGS2DpaJkiGJ0',
  appId: '1:71835287248:web:3b4ebeab04476e3af768d5',
  messagingSenderId: '71835287248',
  projectId: 'bloodcollect-be2ac',
  authDomain: 'bloodcollect-be2ac.firebaseapp.com',
  storageBucket: 'bloodcollect-be2ac.firebasestorage.app',
  measurementId: 'G-L3TJDC5H7K',
);
