// Référentiel géographique : villes, communes et centroïdes.
//
// Ce n'est pas un jeu de test. Ce sont les données géographiques réelles dont
// l'application a besoin tant qu'aucun service d'adresses n'est branché : les
// listes déroulantes « Ville » / « Commune » des filtres, et l'origine du
// calcul de distance tant que le citoyen n'a pas partagé sa position GPS.
//
// Les coordonnées sont des centroïdes de commune, donc la distance calculée
// depuis elles reste une approximation à l'échelle du quartier.

import '../entities/geo_location.dart';

/// Libellé affiché quand aucun filtre de commune n'est actif.
const String allCommunesLabel = 'Toutes les communes';

/// Villes couvertes par les filtres.
const List<String> referenceCities = [
  'Abidjan',
  'Bouaké',
  'Yamoussoukro',
  'San-Pédro',
  'Daloa',
  'Korhogo',
];

const Map<String, List<String>> referenceCommunesByCity = {
  'Abidjan': [
    'Treichville',
    'Marcory',
    'Koumassi',
    'Plateau',
    'Cocody',
    'Yopougon',
    'Abobo',
    'Adjamé',
    'Port-Bouët',
    'Attécoubé',
  ],
  'Bouaké': ['Air France', 'Kouadio', 'Phoenix'],
  'Yamoussoukro': ['Abobo', 'Quartier du Centre', 'Campus 1'],
  'San-Pédro': ['Ville', 'Port'],
  'Daloa': ['Centre-ville', 'Kennedy'],
  'Korhogo': ['Centre-ville', 'Sinema'],
};

/// Communes disponibles pour la ville sélectionnée, liste vide si la ville
/// n'en déclare aucune.
List<String> communesOfCity(String city) =>
    referenceCommunesByCity[city] ?? const <String>[];

/// Centroïdes des communes d'Abidjan.
///
/// Origine du calcul des distances tant que le citoyen n'a pas partagé sa
/// position GPS.
const Map<String, GeoLocation> communeCentroids = {
  'Treichville': GeoLocation(latitude: 5.3600, longitude: -3.7900),
  'Marcory': GeoLocation(latitude: 5.3450, longitude: -3.7850),
  'Koumassi': GeoLocation(latitude: 5.3550, longitude: -3.7700),
  'Plateau': GeoLocation(latitude: 5.3250, longitude: -3.7350),
  'Cocody': GeoLocation(latitude: 5.3720, longitude: -3.8465),
  'Yopougon': GeoLocation(latitude: 5.3942, longitude: -3.8637),
  'Abobo': GeoLocation(latitude: 5.4100, longitude: -3.8850),
  'Adjamé': GeoLocation(latitude: 5.3600, longitude: -3.7450),
  'Port-Bouët': GeoLocation(latitude: 5.3050, longitude: -3.8600),
  'Attécoubé': GeoLocation(latitude: 5.4200, longitude: -3.8300),
};

/// Position de repli : centre d'Abidjan, si la commune du profil est inconnue.
const GeoLocation defaultOrigin = GeoLocation(
  latitude: 5.3600,
  longitude: -3.7900,
);
