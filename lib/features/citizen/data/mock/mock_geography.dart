// Référentiel géographique de test : villes, communes et centroïdes.
// Sert aux listes déroulantes « Ville » / « Commune » des filtres.

import '../../../../../shared/domain/entities/geo_location.dart';

/// Libellé affiché quand aucun filtre de commune n'est actif.
const String allCommunesLabel = 'Toutes les communes';

/// Villes couvertes par les filtres (PDF Citoyen, écran « Chercher un donneur »).
const List<String> mockCities = [
  'Abidjan',
  'Bouaké',
  'Yamoussoukro',
  'San-Pédro',
  'Daloa',
  'Korhogo',
];

const Map<String, List<String>> mockCommunesByCity = {
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
List<String> mockCommunesOf(String city) =>
    mockCommunesByCity[city] ?? const <String>[];

/// Centroïdes des communes d'Abidjan.
///
/// Sert d'origine au calcul des distances tant que le citoyen n'a pas
/// partagé sa position GPS. Treichville est calibrée pour que les centres de
/// test s'affichent à 3,1 / 6,4 / 9,0 km, comme sur les maquettes.
const Map<String, GeoLocation> mockCommuneCentroids = {
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
const GeoLocation mockDefaultOrigin = GeoLocation(
  latitude: 5.3600,
  longitude: -3.7900,
);
