import 'package:flutter/material.dart';
import 'films_card.dart';  // N'oublie pas d'importer FilmsCard
import '../models/film_model.dart';  // Import du modèle Film

class FilmsList extends StatelessWidget {
  final List<Film> films;  // Liste de films à afficher

  const FilmsList({Key? key, required this.films}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220.0, // Hauteur fixe pour la liste horizontale
      child: ListView.builder(
        scrollDirection: Axis.horizontal, // Liste défilante horizontale
        itemCount: films.length,  // Nombre de films dans la liste
        itemBuilder: (context, index) {
          return FilmsCard(film: films[index]);  // Passe chaque film à FilmsCard
        },
      ),
    );
  }
}
