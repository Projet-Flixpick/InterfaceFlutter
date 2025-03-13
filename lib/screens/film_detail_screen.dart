import 'package:flutter/material.dart';
import '../models/film_model.dart';  // Assurez-vous que Film contient les informations nécessaires.
import 'package:url_launcher/url_launcher.dart';  // Pour ouvrir les liens externes.

class FilmDetailScreen extends StatelessWidget {
  final Film film;  // On passe l'objet film à cette page

  const FilmDetailScreen({Key? key, required this.film}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Récupérer les providers pour la France (FR)
    final providers = film.providers?['FR'];

    // Récupérer les acteurs
    final cast = film.cast;

    return Scaffold(
      appBar: AppBar(
        title: Text(film.title),  // Affiche le titre du film dans la barre d'app
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Affiche l'affiche du film
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
            
            // Section des providers (achat ou location)
            const SizedBox(height: 20),
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

            // Section des acteurs
            const SizedBox(height: 20),
            const Text(
              'Acteurs principaux',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            if (cast != null && cast.isNotEmpty) ...[
              Wrap(
                spacing: 10,
                children: cast.map<Widget>((actor) {
                  return Column(
                    children: [
                      // Affiche l'image de l'acteur (si disponible)
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

  // Fonction pour ouvrir un URL dans un navigateur
  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Impossible d\'ouvrir l\'URL : $url';
    }
  }
}
