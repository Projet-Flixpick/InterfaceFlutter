import 'package:flutter/material.dart';

class TopsScreen extends StatefulWidget {
  const TopsScreen({Key? key}) : super(key: key);

  @override
  _TopsScreenState createState() => _TopsScreenState();
}

class _TopsScreenState extends State<TopsScreen> {
  String _searchQuery = "";

  // Liste des genres
  final List<Genre> _genres = [
    Genre(id: 28, name: 'Action'),
    Genre(id: 35, name: 'Comédie'),
    Genre(id: 18, name: 'Drame'),
    Genre(id: 878, name: 'SF'),
    Genre(id: 27, name: 'Horreur'),
  ];

  // Liste des films
  final List<Film> _movies = [
    Film(
      id: 1,
      title: 'Inception',
      overview: 'Un film de science-fiction réalisé par Christopher Nolan.',
      releaseDate: '2010-07-16',
      posterPath: 'assets/images/icone_film.jpg',
      genres: [
        Genre(id: 28, name: 'Action'),
        Genre(id: 878, name: 'SF'),
      ],
      popularity: 300.5,
      voteAverage: 8.8,
      voteCount: 2000,
      originalLanguage: 'en',
      isAdult: false,
      backdropPath: 'assets/images/icone_film.jpg',
      isVideo: false,
    ),
    Film(
      id: 2,
      title: 'Interstellar',
      overview: 'Un film de science-fiction sur l’exploration de l’espace.',
      releaseDate: '2014-11-07',
      posterPath: 'assets/images/icone_film.jpg',
      genres: [
        Genre(id: 878, name: 'SF'),
        Genre(id: 18, name: 'Drame'),
      ],
      popularity: 400.2,
      voteAverage: 8.6,
      voteCount: 2500,
      originalLanguage: 'en',
      isAdult: false,
      backdropPath: 'assets/images/icone_film.jpg',
      isVideo: false,
    ),
    // Ajoute d'autres films ici
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Top Films"),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Barre de recherche
            TextField(
              decoration: const InputDecoration(
                labelText: "Rechercher un film...",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
            const SizedBox(height: 20),

            // Catégories
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: _genres.map((genre) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ElevatedButton(
                      onPressed: () {},
                      child: Text(genre.name),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            // Liste de films
            Expanded(
              child: ListView.builder(
                itemCount: _movies.length,
                itemBuilder: (context, index) {
                  final movie = _movies[index];
                  if (_searchQuery.isNotEmpty &&
                      !movie.title.toLowerCase().contains(_searchQuery)) {
                    return Container();
                  }
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      leading: Image.asset(
                        movie.posterPath,
                        width: 50,
                        height: 75,
                        fit: BoxFit.cover,
                      ),
                      title: Text(movie.title),
                      subtitle: Text("Année: ${movie.releaseDate}"),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Modèle Film
class Film {
  final int id;
  final String title;
  final String overview;
  final String releaseDate;
  final String posterPath;
  final List<Genre> genres;
  final double popularity;
  final double voteAverage;
  final int voteCount;
  final String originalLanguage;
  final bool isAdult;
  final String backdropPath;
  final bool isVideo;

  Film({
    required this.id,
    required this.title,
    required this.overview,
    required this.releaseDate,
    required this.posterPath,
    required this.genres,
    required this.popularity,
    required this.voteAverage,
    required this.voteCount,
    required this.originalLanguage,
    required this.isAdult,
    required this.backdropPath,
    required this.isVideo,
  });
}

// Modèle Genre
class Genre {
  final int id;
  final String name;

  Genre({
    required this.id,
    required this.name,
  });
}
