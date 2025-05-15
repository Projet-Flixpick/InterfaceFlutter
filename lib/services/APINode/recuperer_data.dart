import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/models/genre_model.dart';


Future<List<Genre>> fetchGenres() async {
  final response = await http.get(Uri.parse('http://localhost:8080/genres'));

  if (response.statusCode == 200) {
    List<dynamic> data = jsonDecode(response.body);
    return data.map((genreJson) => Genre.fromJson(genreJson)).toList();
  } else {
    throw Exception('Les genres ne sont pas disponibles');
  }
}
