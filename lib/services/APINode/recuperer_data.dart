import 'dart:convert';
import 'package:http/http.dart' as http;

// Models
import 'package:flutter_application_1/models/genre_model.dart';
import 'package:flutter_application_1/models/film_model.dart';

/// Constante d'URL de base
const String baseUrl = 'https://apinode-foo2.onrender.com';

/// ----------------------------
/// 🔹 GENRES
/// ----------------------------
Future<List<Genre>> fetchGenres() async {
  final response = await http.get(Uri.parse('$baseUrl/genres'));
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data.map<Genre>((json) => Genre.fromJson(json)).toList();
  } else {
    throw Exception('Les genres ne sont pas disponibles');
  }
}

/// ----------------------------
/// 🔹 FILMS
/// ----------------------------

Future<List<Film>> fetchTopMovies() async {
  final response = await http.get(Uri.parse('$baseUrl/movies/top'));
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data.map<Film>((json) => Film.fromJson(json)).toList();
  } else {
    throw Exception('Erreur chargement films les mieux notés');
  }
}

Future<List<Film>> fetchPopularMovies() async {
  final response = await http.get(Uri.parse('$baseUrl/movies/popular'));
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data.map<Film>((json) => Film.fromJson(json)).toList();
  } else {
    throw Exception('Erreur chargement films populaires');
  }
}

Future<List<Film>> fetchUnvotedMovies() async {
  final response = await http.get(Uri.parse('$baseUrl/movies/unvoted'));
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data.map<Film>((json) => Film.fromJson(json)).toList();
  } else {
    throw Exception('Erreur chargement films non notés');
  }
}

Future<List<Film>> fetchWorstMovies() async {
  final response = await http.get(Uri.parse('$baseUrl/movies/worst'));
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data.map<Film>((json) => Film.fromJson(json)).toList();
  } else {
    throw Exception('Erreur chargement des moins bien notés');
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

/// ----------------------------
/// 🔹 SÉRIES
/// ----------------------------

Future<List<Film>> fetchTopSeries() async {
  final response = await http.get(Uri.parse('$baseUrl/series/top-rated'));
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data.map<Film>((json) => Film.fromJson(json)).toList();
  } else {
    throw Exception('Erreur chargement séries les mieux notées');
  }
}

Future<List<Film>> fetchPopularSeries() async {
  final response = await http.get(Uri.parse('$baseUrl/series/popular'));
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data.map<Film>((json) => Film.fromJson(json)).toList();
  } else {
    throw Exception('Erreur chargement séries populaires');
  }
}

Future<List<Film>> fetchUnvotedSeries() async {
  final response = await http.get(Uri.parse('$baseUrl/series/unvoted'));
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data.map<Film>((json) => Film.fromJson(json)).toList();
  } else {
    throw Exception('Erreur chargement séries non notées');
  }
}

Future<List<Film>> fetchWorstSeries() async {
  final response = await http.get(Uri.parse('$baseUrl/series/worst-rated'));
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data.map<Film>((json) => Film.fromJson(json)).toList();
  } else {
    throw Exception('Erreur chargement séries mal notées');
  }
}
