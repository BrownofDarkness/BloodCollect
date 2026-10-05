import 'package:blood_collect/core/constants/app_enums.dart';
import 'package:blood_collect/core/router/app_router.dart';
import 'package:blood_collect/features/citizen/domain/repositories/donor_search_repository.dart';
import 'package:blood_collect/features/citizen/presentation/providers/donor_providers.dart';
import 'package:blood_collect/features/citizen/presentation/screens/donor_results_screen.dart';
import 'package:blood_collect/features/citizen/presentation/screens/donor_search_screen.dart';
import 'package:blood_collect/shared/domain/entities/donor_match_request.dart';
import 'package:blood_collect/shared/presentation/models/donor_search_candidate.dart';
import 'package:blood_collect/shared/presentation/models/requester_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  late ProviderContainer container;

  GoRouter makeRouter() => GoRouter(
    initialLocation: AppRoutes.citizenDonors,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => shell,
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.citizenDonors,
                builder: (context, state) => const DonorSearchScreen(),
                routes: [
                  GoRoute(
                    path: AppRoutes.citizenDonorsResults,
                    builder: (context, state) => DonorResultsScreen(
                      filters: state.extra! as DonorSearchFilters,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );

  Future<void> open(WidgetTester tester, {String? commune}) async {
    tester.view.physicalSize = const Size(1080, 4200);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    container = ProviderContainer(
      overrides: [
        donorSearchRepositoryProvider.overrideWithValue(_EmptyDonorRepository()),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: makeRouter()),
      ),
    );
    await tester.pumpAndSettle();

    if (commune != null) {
      container
          .read(donorSearchFiltersProvider.notifier)
          .toggleCommune(commune);
      await tester.pump();
    }
  }

  ElevatedButton searchButton(WidgetTester tester) {
    final label = find.text('Rechercher des donneurs');
    expect(label, findsOneWidget, reason: 'le bouton doit etre present');
    return tester.widget<ElevatedButton>(
      find.ancestor(of: label, matching: find.byType(ElevatedButton)),
    );
  }

  testWidgets('bouton inactif sans commune choisie', (tester) async {
    await open(tester);
    expect(searchButton(tester).onPressed, isNull);
  });

  testWidgets('le bouton devient actif avec un groupe et une commune', (tester) async {
    await open(tester, commune: 'Treichville');
    expect(searchButton(tester).onPressed, isNotNull);
  });

  testWidgets('appuyer ouvre l ecran Donneurs potentiels', (tester) async {
    await open(tester, commune: 'Treichville');
    await tester.ensureVisible(find.text('Rechercher des donneurs'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Rechercher des donneurs'));
    await tester.pumpAndSettle();
    expect(find.text('Donneurs potentiels'), findsOneWidget);
  });

  testWidgets('choisir une ville vide les communes deja cochees', (tester) async {
    await open(tester, commune: 'Treichville');
    expect(searchButton(tester).onPressed, isNotNull);
    await tester.tap(find.text('Bouaké'));
    await tester.pumpAndSettle();
    expect(searchButton(tester).onPressed, isNull);
    expect(find.textContaining('Aucune commune disponible pour Bouaké'), findsOneWidget);
  });
}

class _EmptyDonorRepository implements DonorRepository {
  @override
  Future<List<DonorSearchCandidate>> searchDonors({required bloodType, required communes, required priority}) async => [];
  @override
  Future<DonorMatchRequest> sendMatchRequest({required donorId, required bloodType, required priority, String? message, required shareContact}) => throw UnimplementedError();
  @override
  Future<DonorMatchRequest> getIncomingRequest(String requestId) => throw UnimplementedError();
  @override
  Future<List<DonorMatchRequest>> incomingRequests() async => [];
  @override
  Future<RequesterInfo> resolveRequester(String requesterId) => throw UnimplementedError();
  @override
  Future<void> respondToRequest(String requestId, DonorMatchStatus response) => throw UnimplementedError();
}
