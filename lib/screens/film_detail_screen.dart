import 'package:flutter/material.dart';
import '../models/film_model.dart';

class FilmDetailScreen extends StatelessWidget {
  final Film film;  // On passe l'objet film à cette page

  const FilmDetailScreen({Key? key, required this.film}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(film.title),  // Affiche le titre du film dans la barre d'app
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Affiche l'affiche du film
            Image.network(
              film.posterPath,
              width: double.infinity,
              height: 600,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 50),
            Text(
              film.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Date de sortie: ${film.releaseDate}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              film.overview,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
