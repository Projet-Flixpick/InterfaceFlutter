import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/film_model.dart';
import '../../models/genre_model.dart';

const String baseUrl = 'https://apinode-75sw.onrender.com';

/// ----------------------------
/// GENRES
/// ----------------------------

Future<List<Genre>> fetchGenres() async {
  final response = await http.get(Uri.parse('$baseUrl/genres'));
  if (response.statusCode == 200) {
    final json = jsonDecode(response.body);
    final data = json is List ? json : json['data'];
    return (data as List).map((e) => Genre.fromJson(e)).toList();
  } else {
    throw Exception('Erreur chargement des genres');
  }
}

/// ----------------------------
/// FILMS
/// ----------------------------

Future<List<Film>> fetchTopMovies({int page = 1}) async {
  final response = await http.get(Uri.parse('$baseUrl/movies/top?page=$page'));
  if (response.statusCode == 200) {
    final json = jsonDecode(response.body);
    final list = json['data'] ?? json;
    return (list as List).map((e) => Film.fromJson(e)).toList();
  } else {
    throw Exception('Erreur chargement films les mieux notés');
  }
}

Future<List<Film>> fetchPopularMovies({int page = 1}) async {
  final response = await http.get(Uri.parse('$baseUrl/movies/popular?page=$page'));
  if (response.statusCode == 200) {
    final json = jsonDecode(response.body);
    final list = json['data'] ?? json;
    return (list as List).map((e) => Film.fromJson(e)).toList();
  } else {
    throw Exception('Erreur chargement films populaires');
  }
}

/*
Future<List<Film>> fetchWorstMovies({int page = 1}) async {
  final response = await http.get(Uri.parse('$baseUrl/movies/worst?page=$page'));
  if (response.statusCode == 200) {
    final json = jsonDecode(response.body);
    final list = json['data'] ?? json;
    return (list as List).map((e) => Film.fromJson(e)).toList();
  } else {
    throw Exception('Erreur chargement films mal notés');
  }
}
*/

Future<List<Film>> fetchUnvotedMovies({int page = 1}) async {
  final response = await http.get(Uri.parse('$baseUrl/movies/unvoted?page=$page'));
  if (response.statusCode == 200) {
    final json = jsonDecode(response.body);
    final list = json['data'] ?? json;
    return (list as List).map((e) => Film.fromJson(e)).toList();
  } else {
    throw Exception('Erreur chargement films non notés');
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
/// SERIES
/// ----------------------------

Future<List<Film>> fetchTopSeries({int page = 1}) async {
  final response = await http.get(Uri.parse('$baseUrl/series/top?page=$page'));
  if (response.statusCode == 200) {
    final json = jsonDecode(response.body);
    final data = json['data'] ?? json;
    return (data as List).map((e) => Film.fromJson(e)).toList();
  } else {
    throw Exception('Erreur chargement séries les mieux notées');
  }
}

Future<List<Film>> fetchPopularSeries({int page = 1}) async {
  final response = await http.get(Uri.parse('$baseUrl/series/popular?page=$page'));
  if (response.statusCode == 200) {
    final json = jsonDecode(response.body);
    final data = json['data'] ?? json;
    return (data as List).map((e) => Film.fromJson(e)).toList();
  } else {
    throw Exception('Erreur chargement séries populaires');
  }
}

Future<List<Film>> fetchUnvotedSeries({int page = 1}) async {
  final response = await http.get(Uri.parse('$baseUrl/series/unvoted?page=$page'));
  if (response.statusCode == 200) {
    final json = jsonDecode(response.body);
    final data = json['data'] ?? json;
    return (data as List).map((e) => Film.fromJson(e)).toList();
  } else {
    throw Exception('Erreur chargement séries non notées');
  }
}