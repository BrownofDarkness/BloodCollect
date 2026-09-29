import 'package:blood_collect/core/constants/app_debug.dart';
import 'package:blood_collect/core/constants/app_enums.dart';
import 'package:blood_collect/core/router/app_router.dart';
import 'package:flutter_test/flutter_test.dart';

/// `redirectForRole` est une fonction pure : aucun contexte Flutter, aucun état
/// Firebase. C'est ce qui permet de tester les règles de redirection, y
/// compris celles qui provoquaient auparavant une boucle.
void main() {
  group('redirectForRole', () {
    test('depuis une route publique, renvoie l\'accueil du rôle', () {
      expect(
        redirectForRole(AppRoutes.splash, 'citizen'),
        AppRoutes.citizenHome,
      );
      expect(
        redirectForRole(AppRoutes.login, 'blood_center'),
        AppRoutes.bcHome,
      );
      expect(
        redirectForRole('/register/citizen', 'health_center'),
        AppRoutes.hcHome,
      );
    });

    test('laisse intact une route déjà dans la section du rôle', () {
      // Régression : la version épinglait toutes les routes sur l'accueil, ce
      // qui rendait les onglets inatteignables.
      expect(redirectForRole(AppRoutes.citizenHome, 'citizen'), isNull);
      expect(redirectForRole(AppRoutes.citizenBlood, 'citizen'), isNull);
      expect(redirectForRole(AppRoutes.citizenDonate, 'citizen'), isNull);
      expect(redirectForRole(AppRoutes.citizenProfile, 'citizen'), isNull);
      expect(
        redirectForRole('${AppRoutes.citizenBlood}/center_a', 'citizen'),
        isNull,
      );
    });

    test('renvoie vers l\'accueil depuis la section d\'un autre rôle', () {
      expect(
        redirectForRole(AppRoutes.bcStocks, 'citizen'),
        AppRoutes.citizenHome,
      );
      expect(
        redirectForRole(AppRoutes.hcHome, 'citizen'),
        AppRoutes.citizenHome,
      );
      expect(
        redirectForRole(AppRoutes.citizenHome, 'blood_center'),
        AppRoutes.bcHome,
      );
    });

    test('conserve chaque route d\'un centre dans son onglet', () {
      expect(redirectForRole(AppRoutes.hcRequests, 'health_center'), isNull);
      expect(redirectForRole(AppRoutes.bcCampaigns, 'blood_center'), isNull);
    });

    test('ne redirige pas une route inconnue vers un autre rôle', () {
      // Un rôle inconnu ne doit pas fabriquer une destination.
      expect(redirectForRole('/inconnu', 'inconnu'), isNull);
    });

    test('traite null comme la connexion', () {
      expect(redirectForRole('/citizen/home', null), isNull);
      expect(redirectForRole(AppRoutes.splash, null), AppRoutes.login);
    });

    test('l\'admin est renvoyé vers l\'accueil citoyen', () {
      expect(redirectForRole(AppRoutes.splash, 'admin'), AppRoutes.citizenHome);
    });
  });

  group('homeForRole', () {
    test('fait l\'aller-retour avec chaque rôle', () {
      for (final role in UserRole.values) {
        expect(
          redirectForRole(AppRoutes.splash, role.firestoreValue),
          isNotNull,
        );
      }
    });

    test('retombe sur la connexion pour un rôle inconnu', () {
      expect(homeForRole(UserRole.fromString('inexistant')), AppRoutes.login);
    });
  });

  group('AppRoutes', () {
    test('la sous-route du centre est un segment relatif', () {
      // Une barre oblique ici ferait échouer la correspondance de la sous-route.
      expect(AppRoutes.citizenBloodCenter, ':centerId');
    });

    test('chaque onglet citoyen a une route distincte sous /citizen/', () {
      const tabs = [
        AppRoutes.citizenHome,
        AppRoutes.citizenDonors,
        AppRoutes.citizenBlood,
        AppRoutes.citizenDonate,
        AppRoutes.citizenProfile,
      ];

      expect(tabs.toSet(), hasLength(5));
      for (final path in tabs) {
        expect(path, startsWith('/citizen/'));
      }
    });
  });

  group('AppDebug', () {
    test('les deux options sont désactivées par défaut', () {
      // Une compilation de livraison ne définit pas ces variables : c'est ce qui
      // garantit qu'un utilisateur réel ne passe jamais en contournement.
      expect(AppDebug.skipAuth, isFalse);
      expect(AppDebug.startRole, 'citizen');
    });
  });
}
