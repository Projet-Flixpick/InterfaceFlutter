import 'package:flutter/material.dart';
import 'films_card.dart'; 
import '../models/film_model.dart';

class FilmsList extends StatelessWidget {
  final List<Film> films;

  const FilmsList({Key? key, required this.films}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220.0,  // Hauteur fixe pour l'affichage horizontal
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: films.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 5), // Ajoute un espace entre les films
            child: FilmsCard(film: films[index]),
          );
        },
      ),
    );
  }
}
