import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/genre_model.dart';
import 'package:flutter_application_1/services/APINode/recuperer_data.dart';

class GenreProvider with ChangeNotifier {
  List<Genre> _genres = [];

  List<Genre> get genres => _genres;

  Future<void> loadGenres() async {
    _genres = await fetchGenres();
    notifyListeners();
  }

  String getGenreNameById(int id) {
    return _genres.firstWhere(
      (g) => g.id == id,
      orElse: () => Genre(mongoId: '', id: id, name: "Inconnu"),
    ).name;
  }
}
