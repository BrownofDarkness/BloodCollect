# Données de test — dossier temporaire

Ce dossier contient **uniquement des données fictives** utilisées pour faire
tourner les écrans du module Citoyen sans backend.

## Règle d'accès aux données

Aucun écran de `lib/features/citizen/` n'importe directement un fichier de ce
dossier. Les écrans passent par les use cases (`domain/usecases/`), qui
dépendent des contrats (`domain/repositories/`). Les implémentations qui lisent
ces mocks sont isolées dans `data/repositories/`.

Deux jeux de données coexistent volontairement, car ils ne décrivent pas la
même chose :

| Fichier | Contenu | Consumé par |
|---|---|---|
| `mock_records.dart` | Citizen, centres, lots de stock, collectes, inscriptions | Onglet Sang, Donner, Profil |
| `donor_mock_data.dart` | Donneurs potentiels, demandes de mise en relation | Accueil, Donneurs, Demande reçue |
| `mock_geography.dart` | Villes, communes, centroïdes | Filtres Ville / Commune |
| `commune_distances.dart` | Distances simulées par commune | Tri des centres sur l'accueil |

## Que faire avant la mise en ligne

Deux options, à décider après les tests sur téléphone et sur Linux :

1. **Supprimer le dossier** et brancher des implémentations Firestore réelles
   sur les mêmes contrats `domain/repositories/`. Aucun écran ni use case à
   modifier.
2. **Le garder** le temps du hackathon pour les démonstrations, en le marquant
   clairement (ce README).

Rien d'autre dans le projet ne dépend de ce dossier.
