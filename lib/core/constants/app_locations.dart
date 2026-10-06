// Référentiel géographique multi-pays (données de démonstration).
// Une ville impose sa liste de sous-zones, appelées « communes »
// dans l'app quel que soit le pays (commune, quartier, arrondissement).
// cette liste est un cas d'exemple et pourra être dynamisé puis étendu selon le besoin future
class CountryInfo {
  const CountryInfo({
    required this.name,
    required this.dialCode,
    required this.cities,
  });

  final String name;
  final String dialCode;
  final Map<String, List<String>> cities;
}

abstract final class AppLocations {
  /// Pays qui contient [city] ; le premier du référentiel si elle est
  /// inconnue ou absente.
  static CountryInfo countryOfCity(String? city) => countries.firstWhere(
        (country) => country.cities.containsKey(city),
        orElse: () => countries.first,
      );

  static const List<CountryInfo> countries = [
    CountryInfo(
      name: "Côte d’Ivoire",
      dialCode: "+225",
      cities: {
        "Abidjan": [
          "Treichville",
          "Marcory",
          "Koumassi",
          "Plateau",
          "Cocody",
          "Yopougon",
          "Abobo",
          "Adjamé",
          "Port-Bouët",
          "Attécoubé",
        ],
        "Bouaké": ["Centre-ville", "Belleville", "Air France", "Koko"],
        "Yamoussoukro": ["Centre-ville", "Habitat", "Morofé", "Dioulakro"],
        "San-Pédro": ["Centre-ville", "Bardot", "Séwéké"],
        "Daloa": ["Centre-ville", "Tazibouo", "Lobia"],
        "Korhogo": ["Centre-ville", "Soba", "Delafosse"],
      },
    ),
    CountryInfo(
      name: "Cameroun",
      dialCode: "+237",
      cities: {
        "Douala": [
          "Akwa",
          "Bonanjo",
          "Bonapriso",
          "Deïdo",
          "Bali",
          "New Bell",
          "Bépanda",
        ],
        "Yaoundé": [
          "Bastos",
          "Mvan",
          "Mendong",
          "Nkolbisson",
          "Centre-ville",
          "Odza",
        ],
        "Bafoussam": ["Centre-ville", "Ndiangdam", "Kamkop"],
        "Garoua": ["Centre-ville", "Plateau", "Kolléré"],
      },
    ),
    CountryInfo(
      name: "Niger",
      dialCode: "+227",
      cities: {
        "Niamey": [
          "Plateau",
          "Terminus",
          "Yantala",
          "Lazaret",
          "Talladjé",
          "Gamkallé",
        ],
        "Zinder": ["Centre-ville", "Birni", "Garin Malam"],
        "Maradi": ["Centre-ville", "Bagalam", "Zaria"],
      },
    ),
    CountryInfo(
      name: "Bénin",
      dialCode: "+229",
      cities: {
        "Cotonou": [
          "Akpakpa",
          "Fidjrossè",
          "Cococodji",
          "Houéyiho",
          "Sainte-Cécile",
        ],
        "Porto-Novo": ["Centre-ville", "Djègan-Kpèvi", "Houinmè", "Ouando"],
        "Parakou": ["Centre-ville", "Banikanni", "Tourou"],
        "Abomey-Calavi": ["Godomey", "Calavi-centre", "Ouèdo"],
      },
    ),
    CountryInfo(
      name: "Sénégal",
      dialCode: "+221",
      cities: {
        "Dakar": [
          "Plateau",
          "Almadies",
          "Mermoz",
          "Ouakam",
          "Yoff",
          "Pikine",
          "Guédiawaye",
        ],
        "Thiès": ["Centre-ville", "Hersent", "Sampathé"],
        "Saint-Louis": ["Centre-ville", "Sor", "Guet Ndar"],
      },
    ),
  ];
}
