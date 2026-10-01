import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/config/platform_firebase_options.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initFirebase();
  runApp(const ProviderScope(child: BloodCollectApp()));
}

/// Démarre Firebase quand la plateforme le permet.
///
/// L'échec n'interrompt pas le démarrage : les écrans du module citoyen se
/// rendent sur leurs données de test, et seules les fonctions qui demandent
/// réellement le backend ont besoin de cette étape.
Future<void> _initFirebase() async {
  final options = PlatformFirebaseOptions.currentPlatform();
  if (options == null) return;
  try {
    await Firebase.initializeApp(options: options);
  } on FirebaseException {
    // Réseau coupé, projet introuvable, quotas : l'application démarre quand
    // même et l'écran concerné explique l'indisponibilité.
  }
}


class BloodCollectApp extends ConsumerStatefulWidget {
  const BloodCollectApp({super.key});

  @override
  ConsumerState<BloodCollectApp> createState() => _BloodCollectAppState();
}

class _BloodCollectAppState extends ConsumerState<BloodCollectApp> {
  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    return GestureDetector(
      onTap: hideKeyboard,
      child: MaterialApp.router(
        title: 'BloodCollect',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: router,
      ),
    );
  }

  void hideKeyboard() {
    FocusScope.of(context).requestFocus(FocusNode());
  }
}
