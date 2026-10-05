import 'dart:io';
import 'dart:ui' as ui;

import 'package:blood_collect/core/constants/app_colors.dart';
import 'package:blood_collect/core/constants/app_enums.dart';
import 'package:blood_collect/features/citizen/presentation/screens/blood_availability_screen.dart';
import 'package:blood_collect/features/citizen/presentation/screens/citizen_home_screen.dart';
import 'package:blood_collect/features/citizen/presentation/screens/donate_screen.dart';
import 'package:blood_collect/features/citizen/presentation/screens/donor_results_screen.dart';
import 'package:blood_collect/features/citizen/presentation/screens/donor_search_screen.dart';
import 'package:blood_collect/features/citizen/presentation/screens/match_request_received_screen.dart';
import 'package:blood_collect/features/citizen/presentation/screens/match_request_screen.dart';
import 'package:blood_collect/features/citizen/presentation/screens/profile_screen.dart';
import 'package:blood_collect/features/citizen/presentation/providers/donor_providers.dart';
import 'package:blood_collect/shared/presentation/models/donor_search_candidate.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Rend chaque écran du module Citoyen dans un fichier PNG, afin de les
/// comparer aux maquettes sans dépendre d'un appareil.
///
/// Le runner de test substitue une police de substitution qui rend le texte en
/// rectangles ; les polices réelles du système sont donc chargées à la main
/// avant tout rendu.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(_loadFonts);

  final outputDir = Directory('build/citizen_screens');
  if (outputDir.existsSync()) outputDir.deleteSync(recursive: true);
  outputDir.createSync(recursive: true);

  Future<void> capture(
    WidgetTester tester,
    String name,
    Widget child, {
    Size size = const Size(390, 1200),
  }) async {
    tester.view.physicalSize = size * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final boundaryKey = GlobalKey();
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: _theme(),
          home: RepaintBoundary(
            key: boundaryKey,
            child: MediaQuery(
              data: MediaQueryData(size: size),
              child: child,
            ),
          ),
        ),
      ),
    );
    // Laisse les repositories de test résoudre leurs délais simulés. On
    // n'utilise pas pumpAndSettle : un indicateur de chargement tourne
    // indéfiniment et la boucle ne se terminerait jamais.
    await tester.pump();
    for (final step in [200, 400, 600, 800, 1000, 1200, 1500, 2000, 2500]) {
      await tester.pump(Duration(milliseconds: step));
    }

    // toImage fait de l'asynchrone hors de la boucle de rendu : sans
    // runAsync le test se bloque sur la capture.
    final boundary =
        boundaryKey.currentContext!.findRenderObject()!
            as RenderRepaintBoundary;
    await tester.runAsync(() async {
      final image = await boundary.toImage(pixelRatio: 3);
      // ignore: avoid_print
      print('capture $name');
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      File(
        '${outputDir.path}/$name.png',
      ).writeAsBytesSync(data!.buffer.asUint8List());
    });
  }

  testWidgets(
    'accueil',
    (t) => capture(t, '1_accueil', const CitizenHomeScreen()),
  );

  testWidgets(
    'donneurs recherche',
    (t) => capture(t, '2_donneurs', const DonorSearchScreen()),
  );

  testWidgets('donneurs resultats', (t) async {
    final filters = DonorSearchFilters(
      bloodType: BloodType.oPos,
      communes: const {'Treichville', 'Marcory'},
    );
    await capture(
      t,
      '3_donneurs_resultats',
      DonorResultsScreen(filters: filters),
    );
  });

  testWidgets('demande envoyee', (t) async {
    final candidate = _candidate();
    await capture(
      t,
      '4_demande_envoi',
      MatchRequestScreen(candidate: candidate),
    );
  });

  testWidgets('demande recue', (t) async {
    await capture(
      t,
      '5_demande_recue',
      const MatchRequestReceivedScreen(requestId: 'req_hc_1'),
    );
    // ignore: avoid_print
    print(
      'TEXTE = '
      '${find.text('Demande reçue', skipOffstage: false).evaluate().length}',
    );
  });

  testWidgets(
    'sang',
    (t) => capture(t, '6_sang', const BloodAvailabilityScreen()),
  );

  testWidgets('donner', (t) => capture(t, '8_donner', const DonateScreen()));

  testWidgets('profil', (t) => capture(t, '9_profil', const ProfileScreen()));
}

/// Raccourci pour éviter d'importer les enums dans chaque appel.
typedef BloodTypeForTest = _BloodTypeAlias;

/// Alias_local : la valeur est lue depuis les enums du coeur applicatif.
class _BloodTypeAlias {}

ThemeData _theme() => ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: AppColors.ivoire,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.rouge,
    primary: AppColors.rouge,
    secondary: AppColors.bleu,
    surface: AppColors.ivoire,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.rouge,
    foregroundColor: Colors.white,
    elevation: 0,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.ligne),
    ),
  ),
);

/// Charge les polices disponibles sur la machine pour que le texte rendu soit
/// lisible. Sans cela, `flutter test` dessine des rectangles à la place des
/// glyphes et la comparaison avec les maquettes n'a aucun sens.
Future<void> _loadFonts() async {
  const iconFonts = <String>[
    '/snap/prompting-client/228/bin/data/flutter_assets/fonts/MaterialIcons-Regular.otf',
    '/snap/snap-store/1427/bin/data/flutter_assets/fonts/MaterialIcons-Regular.otf',
  ];
  final iconFontPaths = iconFonts;

  const candidates = [
    '/usr/share/fonts/truetype/lato/Lato-Regular.ttf',
    '/usr/share/fonts/truetype/lato/Lato-Bold.ttf',
    '/usr/share/fonts/truetype/liberation/LiberationSans-Regular.ttf',
    '/usr/share/fonts/truetype/liberation/LiberationSans-Bold.ttf',
  ];

  var loaded = 0;
  final text = FontLoader('Roboto');
  for (final path in candidates) {
    final file = File(path);
    if (!file.existsSync()) continue;
    final bytes = file.readAsBytesSync();
    if (bytes.length < 1000) continue;
    text.addFont(Future.value(bytes.buffer.asByteData()));
    loaded++;
  }
  if (loaded > 0) await text.load();

  // Sans cette police, les icônes Material sont dessinées comme des carrés.
  for (final path in iconFontPaths) {
    final file = File(path);
    if (!file.existsSync()) continue;
    final icons = FontLoader('MaterialIcons')
      ..addFont(Future.value(file.readAsBytesSync().buffer.asByteData()));
    await icons.load();
    loaded++;
    break;
  }
  // ignore: avoid_print
  print('polices chargees: $loaded');
}

/// Donneur servant à rendre l'écran de demande.
///
/// La recherche réelle lit Firestore, hors de portée d'un test de rendu : le
/// candidat est donc construit ici, et l'écran est rendu exactement comme en
/// production à partir des mêmes champs de `DonorSearchCandidate`.
DonorSearchCandidate _candidate() => const DonorSearchCandidate(
  donorId: 'donor_1',
  bloodType: BloodType.oPos,
  commune: 'Treichville',
  distanceKm: 2.5,
);
