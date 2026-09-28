# Données de test — dossier temporaire

Ce dossier contient **uniquement des données fictives** utilisées pour faire
tourner les écrans du module Citoyen sans backend.

## Règle d'accès aux données

Aucun écran de `lib/features/citizen/` n'importe directement un fichier de ce
dossier. Les écrans passent par les use cases (`domain/usecases/`), qui
dépendent des contrats (`domain/repositories/`). L'implémentation qui lit ces
mocks est isolée dans `data/repositories/`.

## Que faire avant la mise en ligne

Deux options, à décider après les tests sur téléphone et sur Linux :

1. **Supprimer le dossier** et brancher des implémentations Firestore réelles
   sur les mêmes contrats `domain/repositories/`. Aucun écran ni use case à
   modifier.
2. **Le garder** le temps du hackathon pour les démonstrations, en le marquant
   clairement (ce README).

Rien d'autre dans le projet ne dépend de ce dossier.
