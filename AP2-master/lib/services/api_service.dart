import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/country_model.dart';

class ApiService {
  static const String _url =
      'https://restcountries.com/v3.1/all?fields=name,capital,flags,population,region';

  Future<List<Country>> fetchCountries() async {
    try {
      final response = await http.get(Uri.parse(_url));

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);

        return body.map((dynamic item) => Country.fromJson(item)).toList()
          ..sort((a, b) => a.name.compareTo(b.name));
      } else {
        throw Exception('Erro no servidor: Código de status ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Falha na conexão: $e');
    }
  }
}