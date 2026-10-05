import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: BloodCollectApp()));
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
