  import 'package:flutter/material.dart';
  import 'package:provider/provider.dart';
  import '../../providers/film_statut_provider.dart';
  import '../../providers/genre_provider.dart';
  import '../../models/genre_model.dart';
  import '../4.autre/choisir_genres_screen.dart';

  class UserGenresScreen extends StatelessWidget {
    const UserGenresScreen({super.key});

    @override
    Widget build(BuildContext context) {
      final filmProvider = Provider.of<FilmStatutProvider>(context);
      final genreProvider = Provider.of<GenreProvider>(context);
      final mongoIds = filmProvider.preferredGenres;

      // On récupère les noms à partir des mongoIds
      final matchedGenres = genreProvider.genres
          .where((genre) => mongoIds.contains(genre.mongoId))
          .toList();

      return Scaffold(
        appBar: AppBar(title: const Text("My Favorite Genres")),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ChoisirGenresScreen()),
                  );
                },
                icon: const Icon(Icons.edit),
                label: const Text("Edit My Genres"),
              ),
              const SizedBox(height: 24),
              const Text(
                " Genres you love 🎬",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              matchedGenres.isEmpty
                  ? const Text("No favorite genres selected.")
                  : Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: matchedGenres.map((genre) {
                        return Chip(
                          label: Text(
                            genre.name,
                            style: const TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Colors.redAccent,
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 12,
                          ),
                        );
                      }).toList(),
                    ),
            ],
          ),
        ),
      );
    }
  }
