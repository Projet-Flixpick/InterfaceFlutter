import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/film_model.dart';
import '../../providers/film_statut_provider.dart';
import '../../providers/genre_provider.dart';

class FilmDetailScreen extends StatelessWidget {
  final Film film;

  const FilmDetailScreen({Key? key, required this.film}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final providers = film.providers?['FR'];
    final cast = film.cast;

    return Scaffold(
      appBar: AppBar(
        title: Text(film.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              'https://image.tmdb.org/t/p/w500${film.posterPath}',
              width: double.infinity,
              height: 600,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 15),
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
            const SizedBox(height: 20),

            // Genres associés
            Consumer<GenreProvider>(
              builder: (context, genreProvider, _) {
                return Wrap(
                  spacing: 6,
                  children: film.genres.map((genreIdOrName) {
                    final genreName = genreProvider.getGenreNameById(int.tryParse(genreIdOrName) ?? -1);
                    return Chip(
                      label: Text(genreName),
                      visualDensity: VisualDensity.compact,
                      backgroundColor: Colors.deepOrange.shade100,
                    );
                  }).toList(),
                );
              },
            ),

            const SizedBox(height: 10),

            // Boutons Like / Dislike / Vu
            Consumer<FilmStatutProvider>(
              builder: (context, statutProvider, _) {
                final id = film.mongoId;
                final isLiked = statutProvider.isLiked(id);
                final isDisliked = statutProvider.isDisliked(id);
                final isSeen = statutProvider.isSeen(id);

                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.thumb_up,
                          color: isLiked ? Colors.green : Colors.grey),
                      onPressed: () => statutProvider.toggleLike(id),
                      tooltip: "J'aime",
                    ),
                    IconButton(
                      icon: Icon(Icons.thumb_down,
                          color: isDisliked ? Colors.red : Colors.grey),
                      onPressed: () => statutProvider.toggleDislike(id),
                      tooltip: "Je n'aime pas",
                    ),
                    IconButton(
                      icon: Icon(Icons.remove_red_eye,
                          color: isSeen ? Colors.blue : Colors.grey),
                      onPressed: () => statutProvider.toggleVu(id),
                      tooltip: "Vu",
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 20),

            // 🎥 Où louer ou acheter
            if (providers != null) ...[
              const Text(
                'Où acheter ou louer le film ?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              if (providers['buy'] != null && providers['buy'].isNotEmpty) ...[
                const Text('Acheter :', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Column(
                  children: providers['buy']?.map<Widget>((provider) {
                    return ListTile(
                      title: Text(provider),
                      trailing: const Icon(Icons.link),
                      onTap: () => _launchURL(providers['link']),
                    );
                  }).toList() ?? [],
                ),
              ],
              if (providers['rent'] != null && providers['rent'].isNotEmpty) ...[
                const Text('Louer :', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Column(
                  children: providers['rent']?.map<Widget>((provider) {
                    return ListTile(
                      title: Text(provider),
                      trailing: const Icon(Icons.link),
                      onTap: () => _launchURL(providers['link']),
                    );
                  }).toList() ?? [],
                ),
              ],
            ],

            const SizedBox(height: 20),

            const Text(
              'Acteurs principaux',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            if (cast.isNotEmpty) ...[
              Wrap(
                spacing: 10,
                children: cast.map<Widget>((actor) {
                  return Column(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: actor.profilePath != null
                            ? NetworkImage('https://image.tmdb.org/t/p/w500${actor.profilePath}')
                            : const NetworkImage('https://via.placeholder.com/150'),
                      ),
                      const SizedBox(height: 5),
                      Text(actor.name, style: const TextStyle(fontSize: 16)),
                    ],
                  );
                }).toList(),
              ),
            ] else ...[
              const Text('Aucun acteur disponible'),
            ],
          ],
        ),
      ),
    );
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Impossible d\'ouvrir l\'URL : $url';
    }
  }
}
