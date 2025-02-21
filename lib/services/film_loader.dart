import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/film_model.dart';

Future<List<Film>> loadFilms() async {
  try {
    // Charge le fichier JSON à partir des assets
    String jsonString =
        await rootBundle.loadString('lib/services/APINode/films_data.json');
    // print('Fichier JSON chargé : $jsonString'); // Ajouter un log pour afficher le contenu du fichier JSON

    // Convertit la chaîne JSON en une liste dynamique
    List<dynamic> jsonList = json.decode(jsonString);
    // print('JSON décodé avec succès');

    // Mappe chaque élément du JSON pour créer une instance de Film
    List<Film> films = jsonList.map((json) {
      return Film.fromJson(json);
    }).toList();

    return films;
  } catch (e) {
    print('Erreur lors du chargement des films : $e'); // Affiche l'erreur dans la console
    throw Exception('Erreur de chargement des films: $e');
  }
}