class Country {
  final String name;
  final String capital;
  final String flagUrl;
  final int population;
  final String region;

  Country({
    required this.name,
    required this.capital,
    required this.flagUrl,
    required this.population,
    required this.region,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      name: json['name'] != null && json['name']['common'] != null
          ? json['name']['common'].toString()
          : 'Sem nome',

      capital: json['capital'] != null && (json['capital'] as List).isNotEmpty
          ? (json['capital'] as List).first.toString()
          : 'Sem capital',

      flagUrl: json['flags'] != null && json['flags']['png'] != null
          ? json['flags']['png'].toString()
          : '',

      population: json['population'] ?? 0,

      region: json['region']?.toString() ?? 'Desconhecida',
    );
  }
}