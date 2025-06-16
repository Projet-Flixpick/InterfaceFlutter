import 'dart:convert';
import 'package:http/http.dart' as http;

// Models
import 'package:flutter_application_1/models/genre_model.dart';
import 'package:flutter_application_1/models/film_model.dart';

// Constantes
const String baseUrl = 'https://apinode-75sw.onrender.com';

/// Récupération des genres depuis l'API Node.js
Future<List<Genre>> fetchGenres() async {
  final response = await http.get(Uri.parse('$baseUrl/genres'));

  if (response.statusCode == 200) {
    List<dynamic> data = jsonDecode(response.body);
    return data.map((genreJson) => Genre.fromJson(genreJson)).toList();
  } else {
    throw Exception('Les genres ne sont pas disponibles');
  }
}

Future<String?> fetchFilmTitleById(String filmId) async {
  final url = Uri.parse('$baseUrl/movies/$filmId');

  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['title'];
    } else {
      print('Erreur récupération film: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    print('Erreur réseau film: $e');
    return null;
  }
}
