import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/blood_stock_repository_impl.dart';
import '../../data/repositories/campaign_registration_repository_impl.dart';
import '../../data/repositories/campaign_repository_impl.dart';
import '../../data/repositories/donor_match_repository_impl.dart';
import '../../data/repositories/donor_repository_impl.dart';
import '../../domain/repositories/blood_stock_repository.dart';
import '../../domain/repositories/campaign_registration_repository.dart';
import '../../domain/repositories/campaign_repository.dart';
import '../../domain/repositories/donor_match_repository.dart';
import '../../domain/repositories/donor_repository.dart';

part 'repository_providers.g.dart';

// Dépôts partagés par plusieurs espaces (citoyen, centre de santé…).
// Un dépôt propre à un seul espace reste dans les providers de cet espace.

@riverpod
BloodStockRepository bloodStockRepository(Ref ref) =>
    BloodStockRepositoryImpl();

@riverpod
CampaignRepository campaignRepository(Ref ref) => CampaignRepositoryImpl();

@riverpod
CampaignRegistrationRepository campaignRegistrationRepository(Ref ref) =>
    CampaignRegistrationRepositoryImpl();

@riverpod
DonorRepository donorRepository(Ref ref) => DonorRepositoryImpl();

@riverpod
DonorMatchRepository donorMatchRepository(Ref ref) =>
    DonorMatchRepositoryImpl();
