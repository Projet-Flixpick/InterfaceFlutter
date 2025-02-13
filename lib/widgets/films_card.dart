import 'package:flutter/material.dart';
import '../models/film_model.dart';

class FilmsCard extends StatelessWidget {
  final Film film;

  const FilmsCard({Key? key, required this.film}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Affichage de l'affiche du film
        Image.network(
          film.posterPath,
          width: 100, // Largeur spécifique
          height: 150, // Hauteur de l'image
          fit: BoxFit.cover,
        ),
        const SizedBox(height: 5),
        // Titre et année du film
        SizedBox(
          width: 100, // Pour s'aligner avec l'image
          child: Column(
            children: [
              Text(
                film.title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 2, // Limite à 2 lignes le titre
                overflow: TextOverflow.ellipsis, // Ajoute "..." si le texte est trop long
              ),
              Text(
                // Modification de cette ligne pour éviter l'erreur RangeError
                film.releaseDate.length >= 4 ? film.releaseDate.substring(0, 4) : 'Inconnue',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
