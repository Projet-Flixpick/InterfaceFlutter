import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/film_model.dart';
import '../../models/genre_model.dart';
import '../../models/person_model.dart';

const String baseUrl = 'https://apinode-foo2.onrender.com';

/// ----------------------------
/// 🔹 GENRES
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
/// 🔹 FILMS
/// ----------------------------

Future<List<Film>> fetchTopMovies({int page = 1}) async {
  final response = await http.get(Uri.parse('$baseUrl/movies/top?page=$page'));
  if (response.statusCode == 200) {
    final json = jsonDecode(response.body);
    final data = json['data'] ?? json;
    return (data as List).map((e) => Film.fromJson(e)).toList();
  } else {
    throw Exception('Erreur chargement films les mieux notés');
  }
}

Future<List<Film>> fetchPopularMovies({int page = 1}) async {
  final response = await http.get(Uri.parse('$baseUrl/movies/popular?page=$page'));
  if (response.statusCode == 200) {
    final json = jsonDecode(response.body);
    final data = json['data'] ?? json;
    return (data as List).map((e) => Film.fromJson(e)).toList();
  } else {
    throw Exception('Erreur chargement films populaires');
  }
}

Future<List<Film>> fetchWorstMovies({int page = 1}) async {
  final response = await http.get(Uri.parse('$baseUrl/movies/worst?page=$page'));
  if (response.statusCode == 200) {
    final json = jsonDecode(response.body);
    final data = json['data'] ?? json;
    return (data as List).map((e) => Film.fromJson(e)).toList();
  } else {
    throw Exception('Erreur chargement films mal notés');
  }
}

Future<List<Film>> fetchUnvotedMovies({int page = 1}) async {
  final response = await http.get(Uri.parse('$baseUrl/movies/unvoted?page=$page'));
  if (response.statusCode == 200) {
    final json = jsonDecode(response.body);
    final data = json['data'] ?? json;
    return (data as List).map((e) => Film.fromJson(e)).toList();
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
/// 🔹 SÉRIES
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

Future<List<Film>> fetchWorstSeries({int page = 1}) async {
  final response = await http.get(Uri.parse('$baseUrl/series/worst-rated?page=$page'));
  if (response.statusCode == 200) {
    final json = jsonDecode(response.body);
    final data = json['data'] ?? json;
    return (data as List).map((e) => Film.fromJson(e)).toList();
  } else {
    throw Exception('Erreur chargement séries mal notées');
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

/// ----------------------------
/// 🔹 RECHERCHE
/// ----------------------------

Future<List<Film>> fetchSearchMedia(String query) async {
  final response = await http.get(
    Uri.parse('$baseUrl/search/media?title=${Uri.encodeQueryComponent(query.trim())}'),
  );
  if (response.statusCode == 200) {
    final json = jsonDecode(response.body);
    final data = json['data'] ?? json;
    return (data as List).map((e) => Film.fromJson(e)).toList();
  } else {
    throw Exception('Erreur chargement recherche de films');
  }
}

Future<List<Person>> fetchSearchPeople(String query) async {
  final response = await http.get(
    Uri.parse('$baseUrl/search/people?name=${Uri.encodeQueryComponent(query.trim())}'),
  );
  if (response.statusCode == 200) {
    final json = jsonDecode(response.body);
    final data = json['data'] ?? json;
    return (data as List).map((e) => Person.fromJson(e)).toList();
  } else {
    throw Exception('Erreur chargement recherche de personnes');
  }
}

/// ----------------------------
/// 🔹 ACTEURS
/// ----------------------------

Future<List<Person>> fetchAllPeople() async {
  final response = await http.get(Uri.parse('$baseUrl/people'));
  if (response.statusCode == 200) {
    final json = jsonDecode(response.body);
    final data = json['data'] ?? json;
    return (data as List).map((e) => Person.fromJson(e)).toList();
  } else {
    throw Exception('Erreur chargement des acteurs');
  }
}

Future<Person> fetchPersonById(String id) async {
  final response = await http.get(Uri.parse('$baseUrl/people/$id'));
  if (response.statusCode == 200) {
    final json = jsonDecode(response.body);
    return Person.fromJson(json['data'] ?? json);
  } else {
    throw Exception("Erreur chargement acteur $id");
  }
}

Future<List<Film>> fetchMoviesByPersonId(String id) async {
  final response = await http.get(Uri.parse('$baseUrl/people/$id/movies'));
  if (response.statusCode == 200) {
    final json = jsonDecode(response.body);
    final data = json['data'] ?? json;
    return (data as List).map((e) => Film.fromJson(e)).toList();
  } else {
    throw Exception("Erreur chargement films de l'acteur $id");
  }
}
