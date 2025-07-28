// lib/screens/2.films/film_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/film_model.dart';
import '../../providers/film_statut_provider.dart';
import '../../providers/genre_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/no_image.dart';
import '../4.autre/acteur_detail_screen.dart'; // pour la navigation

class FilmDetailScreen extends StatelessWidget {
  final Film film;

  const FilmDetailScreen({Key? key, required this.film}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cast = film.cast;
    final mongoId = film.mongoId;

    final usFlatrate =
        (film.providers?['US']?['flatrate'] as List?)?.cast<String>();
    final frFlatrate =
        (film.providers?['FR']?['flatrate'] as List?)?.cast<String>();

    final List<String> displayProviders = (usFlatrate?.isNotEmpty == true)
        ? usFlatrate!.take(3).toList()
        : (frFlatrate?.isNotEmpty == true)
            ? frFlatrate!.take(3).toList()
            : [];

    return Scaffold(
      appBar: AppBar(title: Text(film.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Affiche l'affiche du film
            Image.network(
              film.posterPath,
              width: double.infinity,
              height: 600,
              fit: BoxFit.cover,
              errorBuilder: (ctx, err, st) => const NoImageWidget(),
            ),
            const SizedBox(height: 5),

            // Titre + date
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    film.title,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  film.releaseDate,
                  style:
                      const TextStyle(fontSize: 18, color: Colors.black54),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Genres
            Consumer<GenreProvider>(
              builder: (ctx, genreProv, _) {
                final chips = film.genreIds.map((id) {
                  final name = genreProv.getGenreNameById(id);
                  if (name.isEmpty) return null;
                  return Chip(
                    label: Text(name,
                        style: const TextStyle(color: Colors.white)),
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(
                        vertical: 6, horizontal: 10),
                  );
                }).whereType<Chip>().toList();

                if (chips.isEmpty) {
                  return const Text(
                    'Aucun genre disponible.',
                    style: TextStyle(color: Colors.grey),
                  );
                }
                return Wrap(spacing: 10, runSpacing: 10, children: chips);
              },
            ),

            const SizedBox(height: 10),

            // Providers
            if (displayProviders.isNotEmpty) ...[
              const Text('Available on :',
                  style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: displayProviders.map((name) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 6, horizontal: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: Colors.grey.shade200,
                    ),
                    child: Text(name, style: const TextStyle(fontSize: 14)),
                  );
                }).toList(),
              ),
            ] else ...[
              const Text(
                'Available on : Information not available',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],

            const SizedBox(height: 8),

            // Like / Dislike / Seen
            Consumer2<FilmStatutProvider, AuthProvider>(
              builder: (ctx, statutProv, authProv, _) {
                final id = film.mongoId;
                final isLiked = statutProv.isLiked(id);
                final isDisliked = statutProv.isDisliked(id);
                final isSeen = statutProv.isSeen(id);
                final token = authProv.token;

                void handleAction(
                    void Function(String, String) action) {
                  if (token != null && token.split('.').length == 3) {
                    action(id, token);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text("Erreur : utilisateur non connecté.")),
                    );
                  }
                }

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        IconButton(
                          icon: Icon(Icons.thumb_up,
                              color:
                                  isLiked ? Colors.green : Colors.grey),
                          onPressed: () =>
                              handleAction(statutProv.toggleLike),
                        ),
                        const Text('Like'),
                      ],
                    ),
                    Column(
                      children: [
                        IconButton(
                          icon: Icon(Icons.thumb_down,
                              color: isDisliked
                                  ? Colors.red
                                  : Colors.grey),
                          onPressed: () =>
                              handleAction(statutProv.toggleDislike),
                        ),
                        const Text('Dislike'),
                      ],
                    ),
                    Column(
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove_red_eye,
                              color:
                                  isSeen ? Colors.blue : Colors.grey),
                          onPressed: () =>
                              handleAction(statutProv.toggleVu),
                        ),
                        const Text('Seen'),
                      ],
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 20),

            // Synopsis
            Text(film.overview, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),

            // Main Cast
            const Text('Main Cast',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            if (cast.isNotEmpty) ...[
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.7,
                ),
                itemCount: cast.length,
                itemBuilder: (ctx, i) {
                  final actor = cast[i];
                  final profileUrl = actor.profilePath != null
                      ? 'https://image.tmdb.org/t/p/w500${actor.profilePath}'
                      : null;

                  return GestureDetector(
                    onTap: () {
                      // Navigue vers la fiche acteur
                      Navigator.pushNamed(
                        context,
                        ActeurDetailScreen.routeName,
                        arguments: actor.id.toString(),
                      );
                    },
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: profileUrl != null
                              ? NetworkImage(profileUrl)
                              : const AssetImage(
                                      'assets/images/no_image.png')
                                  as ImageProvider,
                        ),
                        const SizedBox(height: 5),
                        Text(actor.name,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14)),
                        const SizedBox(height: 2),
                        Text(actor.character,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  );
                },
              ),
            ] else ...[
              const Text('No cast available'),
            ],

            const SizedBox(height: 30),
            Text('ID: $mongoId',
                style:
                    const TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
